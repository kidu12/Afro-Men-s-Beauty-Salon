-- AFRO-BARBER: Migration 003 - Concurrency-Safe Atomic Booking Engine & RPCs

-- 1. Function: Calculate Barber Rating on Review Insert/Update
CREATE OR REPLACE FUNCTION public.update_barber_rating_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.barbers
  SET 
    rating_avg = COALESCE((
      SELECT ROUND(AVG(rating)::numeric, 2)
      FROM public.reviews
      WHERE barber_id = NEW.barber_id AND is_published = true
    ), 0.0),
    total_reviews = (
      SELECT COUNT(*)
      FROM public.reviews
      WHERE barber_id = NEW.barber_id AND is_published = true
    ),
    updated_at = now()
  WHERE id = NEW.barber_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_review_rating_sync ON public.reviews;
CREATE TRIGGER trigger_review_rating_sync
AFTER INSERT OR UPDATE OR DELETE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION public.update_barber_rating_stats();

-- 2. Concurrency-Safe Atomic Booking Function
CREATE OR REPLACE FUNCTION public.create_appointment_atomic(
  p_customer_id UUID,
  p_barber_id UUID,
  p_service_id UUID,
  p_hairstyle_id UUID,
  p_appointment_date DATE,
  p_start_time TIME,
  p_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_service RECORD;
  v_barber RECORD;
  v_branch_id UUID;
  v_duration_minutes INTEGER;
  v_end_time TIME;
  v_day_of_week INTEGER;
  v_biz_hours RECORD;
  v_barber_sched RECORD;
  v_has_day_off BOOLEAN;
  v_has_closure BOOLEAN;
  v_overlap_count INTEGER;
  v_new_appointment_id UUID;
BEGIN
  -- A. Fetch and validate Service
  SELECT id, branch_id, name, price, duration_minutes, is_active, deleted_at
  INTO v_service
  FROM public.services
  WHERE id = p_service_id;

  IF NOT FOUND OR v_service.is_active = false OR v_service.deleted_at IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Service is inactive or unavailable.');
  END IF;

  -- Verify duration is configured per requirement
  IF v_service.duration_minutes IS NULL OR v_service.duration_minutes <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'This service cannot be booked yet because its duration is not configured.');
  END IF;

  v_duration_minutes := v_service.duration_minutes;
  v_end_time := p_start_time + (v_duration_minutes || ' minutes')::INTERVAL;
  v_branch_id := v_service.branch_id;

  -- B. Fetch and lock Barber row to serialize concurrent booking attempts
  SELECT id, is_active, deleted_at
  INTO v_barber
  FROM public.barbers
  WHERE id = p_barber_id
  FOR UPDATE;

  IF NOT FOUND OR v_barber.is_active = false OR v_barber.deleted_at IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Selected barber is unavailable.');
  END IF;

  -- C. Validate Shop Closures and Hours
  v_day_of_week := EXTRACT(DOW FROM p_appointment_date); -- 0 = Sunday, 1 = Monday, etc.

  -- Check special closures
  SELECT EXISTS(
    SELECT 1 FROM public.special_closures
    WHERE (branch_id = v_branch_id OR branch_id IS NULL) AND closure_date = p_appointment_date
  ) INTO v_has_closure;

  IF v_has_closure THEN
    RETURN jsonb_build_object('success', false, 'error', 'The barbershop is closed on the selected date.');
  END IF;

  -- Check shop business hours
  IF v_branch_id IS NOT NULL THEN
    SELECT open_time, close_time, is_closed
    INTO v_biz_hours
    FROM public.business_hours
    WHERE branch_id = v_branch_id AND day_of_week = v_day_of_week;

    IF FOUND THEN
      IF v_biz_hours.is_closed = true THEN
        RETURN jsonb_build_object('success', false, 'error', 'The shop is closed on this day of the week.');
      END IF;

      IF p_start_time < v_biz_hours.open_time OR v_end_time > v_biz_hours.close_time THEN
        RETURN jsonb_build_object('success', false, 'error', 'Appointment time falls outside operating hours.');
      END IF;
    END IF;
  END IF;

  -- D. Validate Barber Schedule and Days Off
  SELECT EXISTS(
    SELECT 1 FROM public.barber_days_off
    WHERE barber_id = p_barber_id AND off_date = p_appointment_date
  ) INTO v_has_day_off;

  IF v_has_day_off THEN
    RETURN jsonb_build_object('success', false, 'error', 'The selected barber is off duty on this date.');
  END IF;

  SELECT start_time, end_time, is_working
  INTO v_barber_sched
  FROM public.barber_schedules
  WHERE barber_id = p_barber_id AND day_of_week = v_day_of_week;

  IF FOUND THEN
    IF v_barber_sched.is_working = false THEN
      RETURN jsonb_build_object('success', false, 'error', 'The selected barber is not scheduled to work on this day.');
    END IF;

    IF p_start_time < v_barber_sched.start_time OR v_end_time > v_barber_sched.end_time THEN
      RETURN jsonb_build_object('success', false, 'error', 'Appointment time falls outside barber schedule.');
    END IF;
  END IF;

  -- E. Double-Booking Prevention: Check for overlapping appointments
  SELECT COUNT(*)
  INTO v_overlap_count
  FROM public.appointments
  WHERE barber_id = p_barber_id
    AND appointment_date = p_appointment_date
    AND status NOT IN ('cancelled', 'no_show')
    AND (start_time < v_end_time AND end_time > p_start_time);

  IF v_overlap_count > 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'This time slot was just booked by another customer. Please choose another time.');
  END IF;

  -- Generate Unique Appointment Reference
  DECLARE
    v_date_code TEXT := to_char(p_appointment_date, 'YYYYMMDD');
    v_seq INTEGER;
    v_reference TEXT;
  BEGIN
    SELECT COUNT(*) + 1 INTO v_seq FROM public.appointments WHERE appointment_date = p_appointment_date;
    v_reference := 'AFB-' || v_date_code || '-' || lpad(v_seq::text, 4, '0');

    -- F. Create Appointment Record with Snapshots & Reference
    INSERT INTO public.appointments (
      appointment_reference,
      branch_id,
      customer_id,
      barber_id,
      service_id,
      hairstyle_id,
      appointment_date,
      start_time,
      end_time,
      status,
      price_snapshot,
      duration_snapshot,
      service_name_snapshot,
      notes
    ) VALUES (
      v_reference,
      v_branch_id,
      p_customer_id,
      p_barber_id,
      p_service_id,
      p_hairstyle_id,
      p_appointment_date,
      p_start_time,
      v_end_time,
      'confirmed',
      v_service.price, -- May be null per business rules!
      v_duration_minutes,
      v_service.name,
      p_notes
    )
    RETURNING id INTO v_new_appointment_id;

    -- G. Audit Log
    INSERT INTO public.appointment_status_history (
      appointment_id,
      old_status,
      new_status,
      changed_by,
      notes
    ) VALUES (
      v_new_appointment_id,
      NULL,
      'confirmed',
      p_customer_id,
      'Initial booking created with ref ' || v_reference
    );

    -- H. Notification
    INSERT INTO public.notifications (
      user_id,
      title,
      message,
      type,
      data
    ) VALUES (
      p_customer_id,
      'Appointment Confirmed! 💈',
      'Your appointment (' || v_reference || ') for ' || v_service.name || ' on ' || to_char(p_appointment_date, 'Mon DD, YYYY') || ' at ' || to_char(p_start_time, 'HH12:MI AM') || ' is confirmed.',
      'appointment_confirmed',
      jsonb_build_object('appointment_id', v_new_appointment_id, 'reference', v_reference)
    );

    RETURN jsonb_build_object(
      'success', true,
      'appointment_id', v_new_appointment_id,
      'reference', v_reference,
      'end_time', to_char(v_end_time, 'HH24:MI:SS')
    );
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
