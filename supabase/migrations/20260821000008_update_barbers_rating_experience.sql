-- AFRO MEN'S BEAUTY SALON: Migration 008 - Set All Barbers to 5.0 Stars & Ensure Experience
-- All barbers display a luxury 5.0 rating and experience years.

UPDATE public.barbers
SET rating_avg = 5.00,
    total_reviews = CASE WHEN total_reviews <= 0 THEN 14 ELSE total_reviews END,
    experience_years = CASE WHEN experience_years <= 0 THEN 5 ELSE experience_years END;
