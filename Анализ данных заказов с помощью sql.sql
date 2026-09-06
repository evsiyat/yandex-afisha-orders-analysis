-- 1. Вычисляем объем таблиц
SELECT 'purchases' AS table_name, COUNT(*) AS row_count
FROM afisha.purchases
	UNION ALL
SELECT 'events', COUNT(*)
FROM afisha.events
	UNION ALL
SELECT 'venues', COUNT(*)
FROM afisha.venues
	UNION ALL
SELECT 'city', COUNT(*)
FROM afisha.city
	UNION ALL
SELECT 'regions', COUNT(*)
FROM afisha.regions;

-- 2. Выводим примеры данных
SELECT *
FROM afisha.purchases
LIMIT 10;

SELECT *
FROM afisha.events
LIMIT 10;

SELECT *
FROM afisha.venues
LIMIT 10;

SELECT *
FROM afisha.city
LIMIT 10;

SELECT *
FROM afisha.regions
LIMIT 10;

-- 3. Проверяем уникальность первичных ключей
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids
FROM afisha.purchases;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS unique_event_ids
FROM afisha.events;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT venue_id) AS unique_venue_ids
FROM afisha.venues;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT city_id) AS unique_city_ids
FROM afisha.city;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT region_id) AS unique_region_ids
FROM afisha.regions;

-- 4. Проверяем наличие пропусков в PURCHASES
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS user_id_nulls,
    COUNT(*) FILTER (WHERE created_dt_msk IS NULL) AS created_dt_nulls,
    COUNT(*) FILTER (WHERE created_ts_msk IS NULL) AS created_ts_nulls,
    COUNT(*) FILTER (WHERE event_id IS NULL) AS event_id_nulls,
    COUNT(*) FILTER (WHERE cinema_circuit IS NULL) AS cinema_circuit_nulls,
    COUNT(*) FILTER (WHERE age_limit IS NULL) AS age_limit_nulls,
    COUNT(*) FILTER (WHERE currency_code IS NULL) AS currency_nulls,
    COUNT(*) FILTER (WHERE device_type_canonical IS NULL) AS device_nulls,
    COUNT(*) FILTER (WHERE revenue IS NULL) AS revenue_nulls,
    COUNT(*) FILTER (WHERE service_name IS NULL) AS service_name_nulls,
    COUNT(*) FILTER (WHERE tickets_count IS NULL) AS tickets_count_nulls,
    COUNT(*) FILTER (WHERE total IS NULL) AS total_nulls
FROM afisha.purchases;

-- 5. Проверяем наличие пропусков в EVENTS
SELECT
    COUNT(*) FILTER (WHERE event_id IS NULL) AS event_id_nulls,
    COUNT(*) FILTER (WHERE event_name_code IS NULL) AS event_name_code_nulls,
    COUNT(*) FILTER (WHERE event_type_description IS NULL) AS description_nulls,
    COUNT(*) FILTER (WHERE event_type_main IS NULL) AS type_nulls,
    COUNT(*) FILTER (WHERE organizers IS NULL) AS organizers_nulls,
    COUNT(*) FILTER (WHERE city_id IS NULL) AS city_id_nulls,
    COUNT(*) FILTER (WHERE venue_id IS NULL) AS venue_id_nulls
FROM afisha.events;

-- 6. Проверяем наличие пропусков в VENUES
SELECT
    COUNT(*) FILTER (WHERE venue_id IS NULL) AS venue_id_nulls,
    COUNT(*) FILTER (WHERE venue_name IS NULL) AS venue_name_nulls,
    COUNT(*) FILTER (WHERE address IS NULL) AS address_nulls
FROM afisha.venues;

-- 7. Проверяем наличие пропусков в CITY
SELECT
    COUNT(*) FILTER (WHERE city_id IS NULL) AS city_id_nulls,
    COUNT(*) FILTER (WHERE city_name IS NULL) AS city_name_nulls,
    COUNT(*) FILTER (WHERE region_id IS NULL) AS region_id_nulls
FROM afisha.city;

-- 8. Проверяем наличие пропусков в REGIONS
SELECT
    COUNT(*) FILTER (WHERE region_id IS NULL) AS region_id_nulls,
    COUNT(*) FILTER (WHERE region_name IS NULL) AS region_name_nulls
FROM afisha.regions;

-- 9. Проверка внешних ключей
-- Заказы с event_id, которого нет в events
SELECT COUNT(*) AS broken_event_links
FROM afisha.purchases p
LEFT JOIN afisha.events e
    ON p.event_id = e.event_id
WHERE e.event_id IS NULL;

-- Мероприятия с city_id, которого нет в city
SELECT COUNT(*) AS broken_city_links
FROM afisha.events e
LEFT JOIN afisha.city c
    ON e.city_id = c.city_id
WHERE c.city_id IS NULL;

-- Мероприятия с venue_id, которого нет в venues
SELECT COUNT(*) AS broken_venue_links
FROM afisha.events e
LEFT JOIN afisha.venues v
    ON e.venue_id = v.venue_id
WHERE v.venue_id IS NULL;

-- Города с region_id, которого нет в regions
SELECT COUNT(*) AS broken_region_links
FROM afisha.city c
LEFT JOIN afisha.regions r
    ON c.region_id = r.region_id
WHERE r.region_id IS NULL;

-- 10. Смотрим распределение заказов по типам меропрития
SELECT
    e.event_type_main,
    COUNT(*) AS orders_count
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
GROUP BY e.event_type_main
ORDER BY orders_count DESC;

-- 11. Смотрим распределение заказов по типам устройствам
SELECT
    device_type_canonical,
    COUNT(*) AS orders_count
FROM afisha.purchases
GROUP BY device_type_canonical
ORDER BY orders_count DESC;

-- 12. Смотрим распределение по валютам
SELECT
    currency_code,
    COUNT(*) AS orders_count,
    SUM(total) AS total_sum,
    SUM(revenue) AS revenue_sum
FROM afisha.purchases
GROUP BY currency_code
ORDER BY orders_count DESC;

-- 13. Смотрим распределение по сервисам продажи билетов
SELECT
    service_name,
    COUNT(*) AS orders_count,
    SUM(total) AS total_sum,
    SUM(revenue) AS revenue_sum
FROM afisha.purchases
GROUP BY service_name
ORDER BY orders_count DESC;

-- 14. Смотрим распределение по возрастным ограничениям
SELECT
    age_limit,
    COUNT(*) AS orders_count
FROM afisha.purchases
GROUP BY age_limit
ORDER BY orders_count DESC;

-- 15. Выводим уникальные значения по категориальным данным 
SELECT DISTINCT device_type_canonical
FROM afisha.purchases
ORDER BY device_type_canonical;

SELECT DISTINCT currency_code
FROM afisha.purchases
ORDER BY currency_code;

SELECT DISTINCT cinema_circuit
FROM afisha.purchases
ORDER BY cinema_circuit;

SELECT DISTINCT age_limit
FROM afisha.purchases
ORDER BY age_limit;

SELECT DISTINCT event_type_main
FROM afisha.events
ORDER BY event_type_main;

-- 16. Статистика по REVENUE
SELECT
    COUNT(*) AS orders_count,
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    AVG(revenue) AS avg_revenue,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY revenue) AS median_revenue,
    SUM(revenue) AS total_revenue
FROM afisha.purchases;

-- 17. Статистика по TOTAL
SELECT
    COUNT(*) AS orders_count,
    MIN(total) AS min_total,
    MAX(total) AS max_total,
    AVG(total) AS avg_total,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total) AS median_total,
    SUM(total) AS total_sum
FROM afisha.purchases;

-- 18. Проверка аномальных значений
SELECT *
FROM afisha.purchases
WHERE revenue < 0
   OR total < 0
   OR tickets_count <= 0;

-- 19. Смотрим самые крупные заказы
SELECT
    order_id,
    user_id,
    event_id,
    tickets_count,
    total,
    revenue
FROM afisha.purchases
ORDER BY total DESC
LIMIT 20;

-- 20. Проверка согласованности REVENUE и TOTAL
SELECT
    COUNT(*) AS orders_count,
    COUNT(*) FILTER (WHERE revenue > total) AS revenue_gt_total,
    COUNT(*) FILTER (WHERE revenue < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE total < 0) AS negative_total
FROM afisha.purchases;

-- 21. Проверяем временной разброс данных
SELECT
    MIN(created_dt_msk) AS min_date,
    MAX(created_dt_msk) AS max_date,
    COUNT(DISTINCT created_dt_msk) AS unique_dates
FROM afisha.purchases;

-- 22. Динамика по месяцам
SELECT
    DATE_TRUNC('month', created_dt_msk) AS month,
    COUNT(*) AS orders_count,
    SUM(tickets_count) AS tickets_count,
    SUM(total) AS total_sum,
    SUM(revenue) AS revenue
FROM afisha.purchases
GROUP BY 1
ORDER BY 1;

-- 23. Динамика по дням
SELECT
    created_dt_msk,
    COUNT(*) AS orders_count,
    SUM(total) AS total_sum,
    SUM(revenue) AS revenue
FROM afisha.purchases
GROUP BY created_dt_msk
ORDER BY created_dt_msk;

-- 24. Заказы по регионам
SELECT
    r.region_name,
    COUNT(*) AS orders_count,
    SUM(p.tickets_count) AS tickets_count,
    SUM(p.total) AS total_sum,
    SUM(p.revenue) AS revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.city c
    ON e.city_id = c.city_id
JOIN afisha.regions r
    ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY orders_count DESC;

-- 25. Заказы по городам
SELECT
    c.city_name,
    r.region_name,
    COUNT(*) AS orders_count,
    SUM(p.tickets_count) AS tickets_count,
    SUM(p.total) AS total_sum,
    SUM(p.revenue) AS revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.city c
    ON e.city_id = c.city_id
JOIN afisha.regions r
    ON c.region_id = r.region_id
GROUP BY
    c.city_name,
    r.region_name
ORDER BY orders_count DESC;

-- 26. Площадки с наибольшим количеством заказов
SELECT
    v.venue_name,
    COUNT(*) AS orders_count,
    SUM(p.tickets_count) AS tickets_count,
    SUM(p.total) AS total_sum,
    SUM(p.revenue) AS revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.venues v
    ON e.venue_id = v.venue_id
GROUP BY v.venue_name
ORDER BY orders_count DESC
LIMIT 20;
