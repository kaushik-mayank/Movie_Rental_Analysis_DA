-- 1. What are the purchasing patterns of new customers versus repeat customers?
WITH FirstRental AS (
    SELECT 
        customer_id,
        MIN(rental_date) AS first_rental_date
    FROM rental
    GROUP BY customer_id
),

RentalType AS (
    SELECT 
        r.rental_id,
        r.customer_id,
        r.rental_date,
        CASE 
            WHEN r.rental_date = fr.first_rental_date THEN 'New Purchase'
            ELSE 'Repeat Purchase'
        END AS rental_type,
        p.amount
    FROM rental r
    JOIN FirstRental fr ON r.customer_id = fr.customer_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
)

SELECT 
    rental_type,
    COUNT(*) AS total_rentals,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_payment
FROM RentalType
GROUP BY rental_type;



-- 2. Which films have the highest rental rates and are most in demand?

SELECT 
    f.film_id,
    f.title,
    f.rental_rate,
    COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title, f.rental_rate
ORDER BY f.rental_rate DESC, rental_count DESC
LIMIT 5;

-- 3. Are there correlations between staff performance and customer satisfaction?
WITH FirstRental AS (
    SELECT 
        customer_id,
        MIN(rental_date) AS first_rental_date
    FROM rental
    GROUP BY customer_id
),

RentalLabeled AS (
    SELECT 
        r.rental_id,
        r.customer_id,
        r.staff_id,
        r.rental_date,
        CASE 
            WHEN r.rental_date = fr.first_rental_date THEN 'New'
            ELSE 'Repeat'
        END AS rental_type
    FROM rental r
    JOIN FirstRental fr ON r.customer_id = fr.customer_id
),

StaffPerformance AS (
    SELECT 
        s.staff_id,
        s.first_name,
        s.last_name,
        COUNT(r.rental_id) AS total_rentals,
        SUM(CASE WHEN r.rental_type = 'Repeat' THEN 1 ELSE 0 END) AS repeat_rentals,
        COUNT(DISTINCT r.customer_id) AS total_customers,
        COUNT(DISTINCT CASE WHEN r.rental_type = 'Repeat' THEN r.customer_id END) AS repeat_customers
    FROM RentalLabeled r
    JOIN staff s ON r.staff_id = s.staff_id
    GROUP BY s.staff_id, s.first_name, s.last_name
)

SELECT 
    staff_id,
    CONCAT(first_name, ' ', last_name) AS staff_name,
    total_customers,
    repeat_customers,
    total_rentals,
    repeat_rentals,
    ROUND((repeat_customers * 100.0 / total_customers), 2) AS repeat_customer_pct,
    ROUND((repeat_rentals * 100.0 / total_rentals), 2) AS repeat_rental_pct
FROM StaffPerformance;


-- 4. Are there seasonal trends in customer behavior across different locations?

SELECT c.country, DATE_FORMAT(r.rental_date, '%Y-%m') AS YearMonth , COUNT(*) AS Rental_Purchased
FROM rental r JOIN customer cu ON r.customer_id = cu.customer_id 
JOIN address a ON cu.address_id = a.address_id 
JOIN city ci ON a.city_id = ci.city_id
JOIN country c ON ci.country_id = c.country_id
GROUP BY c.country ,YearMonth
ORDER BY country, YearMonth


-- 5. Are certain language films more popular among specific customer segments?
WITH RentalsByCountryLanguage AS (
    SELECT 
        c.country,
        l.name AS language,
        COUNT(*) AS rental_count
    FROM customer cu 
    JOIN address a ON cu.address_id = a.address_id 
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country c ON ci.country_id = c.country_id
    JOIN rental r ON cu.customer_id = r.customer_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN language l ON f.language_id = l.language_id
    GROUP BY c.country, l.name
),

TotalRentalsByCountry AS (
    SELECT 
        c.country,
        COUNT(*) AS total_rentals
    FROM customer cu 
    JOIN address a ON cu.address_id = a.address_id 
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country c ON ci.country_id = c.country_id
    JOIN rental r ON cu.customer_id = r.customer_id
    GROUP BY c.country
),

RankedLanguages AS (
    SELECT 
        rbl.country,
        rbl.language,
        rbl.rental_count,
        trc.total_rentals,
        ROUND( (rbl.rental_count / trc.total_rentals) * 100, 2) AS percent_share,
        ROW_NUMBER() OVER (PARTITION BY rbl.country ORDER BY rbl.rental_count DESC) AS rn
    FROM RentalsByCountryLanguage rbl
    JOIN TotalRentalsByCountry trc ON rbl.country = trc.country
)

SELECT
    country,
    language,
    rental_count,
    percent_share
FROM RankedLanguages
WHERE rn <= 3
ORDER BY country, rn;


-- 6. How does customer loyalty impact sales revenue over time?
WITH FirstRental AS (
    SELECT 
        customer_id,
        MIN(rental_date) AS first_rental
    FROM rental
    GROUP BY customer_id
),

LabeledRentals AS (
    SELECT 
        r.rental_id,
        r.customer_id,
        r.rental_date,
        p.amount,
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        CASE 
            WHEN r.rental_date = fr.first_rental THEN 'New'
            ELSE 'Repeat'
        END AS rental_type
    FROM rental r
    JOIN FirstRental fr ON r.customer_id = fr.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
)

SELECT 
    rental_month,
    rental_type,
    ROUND(SUM(amount), 2) AS total_revenue,
    COUNT(*) AS total_rentals
FROM LabeledRentals
GROUP BY rental_month, rental_type
ORDER BY rental_month, rental_type;




-- 7. Are certain film categories more popular in specific locations?

WITH CategoryRentals AS (
    SELECT 
        ctry.country,
        cat.name AS category,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    JOIN customer cu ON r.customer_id = cu.customer_id
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country ctry ON ci.country_id = ctry.country_id
    GROUP BY ctry.country, cat.name
),

TotalRentalsByCountry AS (
    SELECT 
        ctry.country,
        COUNT(*) AS total_rentals
    FROM rental r
    JOIN customer cu ON r.customer_id = cu.customer_id
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country ctry ON ci.country_id = ctry.country_id
    GROUP BY ctry.country
),

RankedCategories AS (
    SELECT 
        cr.country,
        cr.category,
        cr.rental_count,
        trc.total_rentals,
        ROUND((cr.rental_count / trc.total_rentals) * 100, 2) AS percent_share,
        ROW_NUMBER() OVER (PARTITION BY cr.country ORDER BY cr.rental_count DESC) AS rn
    FROM CategoryRentals cr
    JOIN TotalRentalsByCountry trc ON cr.country = trc.country
)

SELECT
    country,
    category,
    rental_count,
    total_rentals,
    percent_share
FROM RankedCategories
WHERE rn = 1
ORDER BY percent_share DESC;


-- 8. How does the availability and knowledge of staff affect customer ratings?
WITH FirstRental AS (
    SELECT 
        customer_id,
        MIN(rental_date) AS first_rental_date
    FROM rental
    GROUP BY customer_id
),

RentalType AS (
    SELECT 
        r.staff_id,
        r.customer_id,
        r.rental_id,
        CASE 
            WHEN r.rental_date = fr.first_rental_date THEN 'New'
            ELSE 'Repeat'
        END AS rental_type
    FROM rental r
    JOIN FirstRental fr ON r.customer_id = fr.customer_id
)

SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    COUNT(*) AS total_rentals,
    SUM(CASE WHEN rt.rental_type = 'Repeat' THEN 1 ELSE 0 END) AS repeat_rentals,
    ROUND(SUM(CASE WHEN rt.rental_type = 'Repeat' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_percentage
FROM RentalType rt
JOIN staff s ON rt.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY repeat_percentage DESC;



-- 9. How does the proximity of stores to customers impact rental frequency?
SELECT
    CASE 
        WHEN a_cust.city_id = a_store.city_id THEN 'Same City'
        ELSE 'Different City'
    END AS city_proximity,

    CASE 
        WHEN a_cust.district = a_store.district THEN 'Same District'
        ELSE 'Different District'
    END AS district_proximity,

    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT cu.customer_id) AS unique_customers,
    ROUND(COUNT(r.rental_id) * 1.0 / COUNT(DISTINCT cu.customer_id), 2) AS avg_rentals_per_customer
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN address a_store ON s.address_id = a_store.address_id
JOIN customer cu ON r.customer_id = cu.customer_id
JOIN address a_cust ON cu.address_id = a_cust.address_id
GROUP BY city_proximity, district_proximity
ORDER BY city_proximity, district_proximity;



-- 10. Do specific film categories attract different age groups of customers?
WITH CategoryByRating AS (
    SELECT 
        CASE
            WHEN f.rating = 'G' THEN 'Kids'
            WHEN f.rating = 'PG' THEN 'Pre-Teens'
            WHEN f.rating = 'PG-13' THEN 'Teens'
            WHEN f.rating = 'R' THEN 'Adults'
            WHEN f.rating = 'NC-17' THEN 'Mature Adults'
            ELSE 'Unknown'
        END AS age_group,
        cat.name AS category,
        COUNT(*) AS film_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    GROUP BY age_group, cat.name
),
Ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY age_group ORDER BY film_count DESC) AS rn
    FROM CategoryByRating
)

SELECT age_group, category, film_count
FROM Ranked
WHERE rn = 1
ORDER BY age_group;


-- 11. What are the demographics and preferences of the highest-spending customers?

WITH TopSpenders AS (
    SELECT 
        p.customer_id,
        SUM(p.amount) AS total_spent
    FROM payment p
    GROUP BY p.customer_id
    ORDER BY total_spent DESC
    LIMIT 10
),

CustomerDemographics AS (
    SELECT 
        cu.customer_id,
        cu.first_name,
        cu.last_name,
        a.address,
        ci.city,
        co.country
    FROM customer cu
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
),

CustomerPreferences AS (
    SELECT 
        r.customer_id,
        cat.name AS favorite_category,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    GROUP BY r.customer_id, cat.name
),

FavoriteCategoryRanked AS (
    SELECT 
        cp.customer_id,
        cp.favorite_category,
        cp.rental_count,
        ROW_NUMBER() OVER (PARTITION BY cp.customer_id ORDER BY cp.rental_count DESC) AS rn
    FROM CustomerPreferences cp
)

SELECT 
    ts.customer_id,
    cd.first_name,
    cd.last_name,
    cd.address,
    cd.city,
    cd.country,
    ts.total_spent,
    fcr.favorite_category,
    fcr.rental_count
FROM TopSpenders ts
JOIN CustomerDemographics cd ON ts.customer_id = cd.customer_id
LEFT JOIN FavoriteCategoryRanked fcr ON ts.customer_id = fcr.customer_id AND fcr.rn = 1
ORDER BY ts.total_spent DESC;


-- 12. How does the availability of inventory impact customer satisfaction and repeat business?

WITH FirstFilmRental AS (
    SELECT 
        customer_id, 
        film_id, 
        MIN(rental_date) AS first_rental_date
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    GROUP BY customer_id, film_id
),

LabeledRentals AS (
    SELECT
        r.customer_id,
        i.film_id,
        CASE 
            WHEN r.rental_date = ffr.first_rental_date THEN 'New'
            ELSE 'Repeat'
        END AS rental_type
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN FirstFilmRental ffr ON r.customer_id = ffr.customer_id AND i.film_id = ffr.film_id
),

RepeatStats AS (
    SELECT
        film_id,
        COUNT(*) AS total_rentals,
        SUM(CASE WHEN rental_type = 'Repeat' THEN 1 ELSE 0 END) AS repeat_rentals
    FROM LabeledRentals
    GROUP BY film_id
),

InventoryAvailability AS (
    SELECT
        film_id,
        COUNT(*) AS available_copies
    FROM inventory
    GROUP BY film_id
)

SELECT
    f.title,
    ia.available_copies,
    rs.total_rentals,
    rs.repeat_rentals,
    ROUND((rs.repeat_rentals * 100.0) / rs.total_rentals, 2) AS repeat_percentage
FROM RepeatStats rs
JOIN InventoryAvailability ia ON rs.film_id = ia.film_id
JOIN film f ON f.film_id = rs.film_id
ORDER BY repeat_percentage DESC



-- 13. What are the busiest hours or days for each store location, and how does it impact staffing requirements?

WITH RentalCounts AS (
    SELECT
        s.store_id,
        co.country,
        ci.city,
        a.address,
        DATE_FORMAT(r.rental_date, '%W') AS day_of_week,
        HOUR(r.rental_date) AS rental_hour,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN store s ON i.store_id = s.store_id
    JOIN address a ON s.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY s.store_id, co.country, ci.city, a.address, day_of_week, rental_hour
),

BusiestDayPerStore AS (
    SELECT 
        store_id,
        country,
        city,
        address,
        day_of_week,
        SUM(rental_count) AS total_rentals_day,
        RANK() OVER (PARTITION BY store_id ORDER BY SUM(rental_count) DESC) AS day_rank
    FROM RentalCounts
    GROUP BY store_id, country, city, address, day_of_week
),

BusiestHourOnBusiestDay AS (
    SELECT 
        rc.store_id,
        rc.country,
        rc.city,
        rc.address,
        rc.day_of_week,
        rc.rental_hour,
        rc.rental_count,
        RANK() OVER (PARTITION BY rc.store_id ORDER BY rc.rental_count DESC) AS hour_rank
    FROM RentalCounts rc
    JOIN BusiestDayPerStore bd 
      ON rc.store_id = bd.store_id AND rc.day_of_week = bd.day_of_week
    WHERE bd.day_rank = 1
)

SELECT 
    store_id,
    country,
    city,
    address,
    day_of_week AS busiest_day,
    rental_hour AS busiest_hour,
    rental_count AS rentals_in_that_hour
FROM BusiestHourOnBusiestDay
WHERE hour_rank = 1
ORDER BY country, city, store_id;




-- 14. What are the cultural or demographic factors that influence customer preferences in different locations?
WITH CategoryRentalsByCountry AS (
    SELECT
        co.country,
        cat.name AS category,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN customer cu ON r.customer_id = cu.customer_id
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    GROUP BY co.country, cat.name
),

TotalRentalsPerCountry AS (
    SELECT
        country,
        SUM(rental_count) AS total_rentals
    FROM CategoryRentalsByCountry
    GROUP BY country
),

RankedCategories AS (
    SELECT
        crc.country,
        crc.category,
        crc.rental_count,
        tr.total_rentals,
        ROUND((crc.rental_count * 100.0 / tr.total_rentals), 2) AS percent_share,
        ROW_NUMBER() OVER (PARTITION BY crc.country ORDER BY crc.rental_count DESC) AS rn
    FROM CategoryRentalsByCountry crc
    JOIN TotalRentalsPerCountry tr ON crc.country = tr.country
)

SELECT
    country,
    category AS most_preferred_category,
    rental_count,
    percent_share
FROM RankedCategories
WHERE rn = 1
ORDER BY percent_share DESC;


-- 15. How does the availability of films in different languages impact customer satisfaction and rental frequency?
WITH LanguageRentalCounts AS (
    SELECT
        l.name AS language,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN language l ON f.language_id = l.language_id
    GROUP BY l.name
),
TotalRentals AS (
    SELECT SUM(rental_count) AS total_rentals
    FROM LanguageRentalCounts
)
SELECT
    lrc.language,
    lrc.rental_count,
    ROUND((lrc.rental_count * 100.0 / tr.total_rentals), 2) AS percent_share
FROM LanguageRentalCounts lrc, TotalRentals tr
ORDER BY rental_count DESC;















