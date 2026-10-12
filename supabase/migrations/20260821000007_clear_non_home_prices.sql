-- AFRO MEN'S BEAUTY SALON: Migration 007 - Clear Non-Home Service Prices
-- Keeps price exclusively for Home to Home service; salon services have unlisted prices.

UPDATE public.services
SET price = NULL
WHERE name NOT ILIKE '%home%';
