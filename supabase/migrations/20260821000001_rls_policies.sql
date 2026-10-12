-- AFRO-BARBER: Migration 002 - Row Level Security (RLS) Policies
-- Enforces role-based security at the database layer.

-- Helper functions to extract user profile and role securely
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_barber()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND (role = 'barber' OR role = 'admin')
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Enable RLS on all tables
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hairstyles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hairstyle_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_days_off ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.special_closures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointment_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 1. BRANCHES POLICIES
CREATE POLICY "Public can view active branches" ON public.branches
  FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY "Admin full manage branches" ON public.branches
  FOR ALL USING (public.is_admin());

-- 2. PROFILES POLICIES
CREATE POLICY "Public can view basic profiles" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- 3. SERVICE CATEGORIES POLICIES
CREATE POLICY "Public view active categories" ON public.service_categories
  FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY "Admin manage categories" ON public.service_categories
  FOR ALL USING (public.is_admin());

-- 4. SERVICES POLICIES
CREATE POLICY "Public view active services" ON public.services
  FOR SELECT USING ((is_active = true AND deleted_at IS NULL) OR public.is_admin());

CREATE POLICY "Admin manage services" ON public.services
  FOR ALL USING (public.is_admin());

-- 5. BARBERS POLICIES
CREATE POLICY "Public view active barbers" ON public.barbers
  FOR SELECT USING ((is_active = true AND deleted_at IS NULL) OR public.is_admin() OR auth.uid() = profile_id);

CREATE POLICY "Barber update own profile" ON public.barbers
  FOR UPDATE USING (auth.uid() = profile_id OR public.is_admin());

CREATE POLICY "Admin manage barbers" ON public.barbers
  FOR ALL USING (public.is_admin());

-- 6. HAIRSTYLES & MEDIA POLICIES
CREATE POLICY "Public view active hairstyles" ON public.hairstyles
  FOR SELECT USING ((is_active = true AND deleted_at IS NULL) OR public.is_admin());

CREATE POLICY "Admin manage hairstyles" ON public.hairstyles
  FOR ALL USING (public.is_admin());

CREATE POLICY "Public view active hairstyle media" ON public.hairstyle_media
  FOR SELECT USING (is_active = true OR public.is_admin());

CREATE POLICY "Admin manage hairstyle media" ON public.hairstyle_media
  FOR ALL USING (public.is_admin());

-- 7. BUSINESS HOURS & SCHEDULES POLICIES
CREATE POLICY "Public view business hours" ON public.business_hours
  FOR SELECT USING (true);

CREATE POLICY "Admin manage business hours" ON public.business_hours
  FOR ALL USING (public.is_admin());

CREATE POLICY "Public view barber schedules" ON public.barber_schedules
  FOR SELECT USING (true);

CREATE POLICY "Barber & Admin manage schedules" ON public.barber_schedules
  FOR ALL USING (
    public.is_admin() OR 
    EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND profile_id = auth.uid())
  );

CREATE POLICY "Public view barber days off" ON public.barber_days_off
  FOR SELECT USING (true);

CREATE POLICY "Barber & Admin manage days off" ON public.barber_days_off
  FOR ALL USING (
    public.is_admin() OR 
    EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND profile_id = auth.uid())
  );

CREATE POLICY "Public view special closures" ON public.special_closures
  FOR SELECT USING (true);

CREATE POLICY "Admin manage special closures" ON public.special_closures
  FOR ALL USING (public.is_admin());

CREATE POLICY "Public view business settings" ON public.business_settings
  FOR SELECT USING (true);

CREATE POLICY "Admin manage business settings" ON public.business_settings
  FOR ALL USING (public.is_admin());

-- 8. APPOINTMENTS POLICIES
CREATE POLICY "Users view own appointments" ON public.appointments
  FOR SELECT USING (
    auth.uid() = customer_id OR 
    EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND profile_id = auth.uid()) OR
    public.is_admin()
  );

CREATE POLICY "Customer create appointment" ON public.appointments
  FOR INSERT WITH CHECK (
    auth.uid() = customer_id OR public.is_admin()
  );

CREATE POLICY "Customer, Barber & Admin update appointment" ON public.appointments
  FOR UPDATE USING (
    auth.uid() = customer_id OR 
    EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND profile_id = auth.uid()) OR
    public.is_admin()
  );

CREATE POLICY "Admin delete appointment" ON public.appointments
  FOR DELETE USING (public.is_admin());

-- 9. STATUS HISTORY POLICIES
CREATE POLICY "View appointment status history" ON public.appointment_status_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.appointments a 
      WHERE a.id = appointment_id AND (
        a.customer_id = auth.uid() OR
        EXISTS (SELECT 1 FROM public.barbers b WHERE b.id = a.barber_id AND b.profile_id = auth.uid()) OR
        public.is_admin()
      )
    )
  );

CREATE POLICY "Insert status history" ON public.appointment_status_history
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 10. REVIEWS POLICIES
CREATE POLICY "Public view published reviews" ON public.reviews
  FOR SELECT USING (is_published = true OR public.is_admin() OR auth.uid() = customer_id);

CREATE POLICY "Customer insert review for completed appointment" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = customer_id AND
    EXISTS (
      SELECT 1 FROM public.appointments 
      WHERE id = appointment_id AND customer_id = auth.uid() AND status = 'completed'
    )
  );

CREATE POLICY "Admin & author manage reviews" ON public.reviews
  FOR UPDATE USING (auth.uid() = customer_id OR public.is_admin());

-- 11. FAVORITES POLICIES
CREATE POLICY "User manage own favorites" ON public.favorites
  FOR ALL USING (auth.uid() = user_id);

-- 12. NOTIFICATIONS POLICIES
CREATE POLICY "User manage own notifications" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);
