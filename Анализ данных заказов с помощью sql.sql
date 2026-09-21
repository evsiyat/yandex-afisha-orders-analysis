-- ============================================================
-- Анализ данных заказов сервиса «Яндекс Афиша»
-- PostgreSQL
--
-- Период данных: 01.06.2024 — 31.10.2024
-- Для денежных показателей используется RUB.
--
-- Структура:
-- 1. Знакомство с данными
-- 2. Проверка качества данных
-- 3. Исследование категориальных показателей
-- 4. Анализ выручки и выявление аномалий
-- 5. Анализ временной динамики
-- 6. Анализ регионов, городов и площадок
-- 7. Ключевые продуктовые метрики для дашборда
-- ============================================================


-- ============================================================
-- 1. ЗНАКОМСТВО С ДАННЫМИ
-- ============================================================


-- 1.1. Количество записей в таблицах

SELECT COUNT(*) AS rows_count
FROM afisha.purchases;

SELECT COUNT(*) AS rows_count
FROM afisha.events;

SELECT COUNT(*) AS rows_count
FROM afisha.venues;

SELECT COUNT(*) AS rows_count
FROM afisha.city;

SELECT COUNT(*) AS rows_count
FROM afisha.regions;


-- 1.2. Примеры записей

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


-- ============================================================
-- 2. ПРОВЕРКА КАЧЕСТВА ДАННЫХ
-- ============================================================


-- 2.1. Проверка уникальности идентификаторов

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_id
FROM afisha.purchases;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS unique_event_id
FROM afisha.events;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT venue_id) AS unique_venue_id
FROM afisha.venues;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT city_id) AS unique_city_id
FROM afisha.city;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT region_id) AS unique_region_id
FROM afisha.regions;


-- 2.2. Проверка пропусков в purchases

SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS user_id_nulls,
    COUNT(*) FILTER (WHERE created_dt_msk IS NULL) AS created_dt_nulls,
    COUNT(*) FILTER (WHERE created_ts_msk IS NULL) AS created_ts_nulls,
    COUNT(*) FILTER (WHERE event_id IS NULL) AS event_id_nulls,
    COUNT(*) FILTER (WHERE currency_code IS NULL) AS currency_nulls,
    COUNT(*) FILTER (WHERE device_type_canonical IS NULL) AS device_nulls,
    COUNT(*) FILTER (WHERE revenue IS NULL) AS revenue_nulls,
    COUNT(*) FILTER (WHERE tickets_count IS NULL) AS tickets_count_nulls,
    COUNT(*) FILTER (WHERE total IS NULL) AS total_nulls,
    COUNT(*) FILTER (WHERE service_name IS NULL) AS service_name_nulls
FROM afisha.purchases;


-- 2.3. Проверка пропусков в events

SELECT
    COUNT(*) FILTER (WHERE event_id IS NULL) AS event_id_nulls,
    COUNT(*) FILTER (WHERE event_name_code IS NULL) AS event_name_nulls,
    COUNT(*) FILTER (WHERE event_type_main IS NULL) AS event_type_nulls,
    COUNT(*) FILTER (WHERE city_id IS NULL) AS city_id_nulls,
    COUNT(*) FILTER (WHERE venue_id IS NULL) AS venue_id_nulls
FROM afisha.events;


-- 2.4. Проверка пропусков в venues

SELECT
    COUNT(*) FILTER (WHERE venue_id IS NULL) AS venue_id_nulls,
    COUNT(*) FILTER (WHERE venue_name IS NULL) AS venue_name_nulls,
    COUNT(*) FILTER (WHERE address IS NULL) AS address_nulls
FROM afisha.venues;


-- 2.5. Проверка пропусков в city

SELECT
    COUNT(*) FILTER (WHERE city_id IS NULL) AS city_id_nulls,
    COUNT(*) FILTER (WHERE city_name IS NULL) AS city_name_nulls,
    COUNT(*) FILTER (WHERE region_id IS NULL) AS region_id_nulls
FROM afisha.city;


-- 2.6. Проверка пропусков в regions

SELECT
    COUNT(*) FILTER (WHERE region_id IS NULL) AS region_id_nulls,
    COUNT(*) FILTER (WHERE region_name IS NULL) AS region_name_nulls
FROM afisha.regions;


-- 2.7. Проверка связности таблиц

-- purchases → events

SELECT COUNT(*) AS broken_event_links
FROM afisha.purchases p
LEFT JOIN afisha.events e
    ON p.event_id = e.event_id
WHERE e.event_id IS NULL;


-- events → city

SELECT COUNT(*) AS broken_city_links
FROM afisha.events e
LEFT JOIN afisha.city c
    ON e.city_id = c.city_id
WHERE c.city_id IS NULL;


-- events → venues

SELECT COUNT(*) AS broken_venue_links
FROM afisha.events e
LEFT JOIN afisha.venues v
    ON e.venue_id = v.venue_id
WHERE v.venue_id IS NULL;


-- city → regions

SELECT COUNT(*) AS broken_region_links
FROM afisha.city c
LEFT JOIN afisha.regions r
    ON c.region_id = r.region_id
WHERE r.region_id IS NULL;


-- ============================================================
-- 3. ИССЛЕДОВАНИЕ КАТЕГОРИАЛЬНЫХ ПОКАЗАТЕЛЕЙ
-- ============================================================


-- 3.1. Заказы по типам мероприятий

SELECT
    e.event_type_main,
    COUNT(*) AS total_orders
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
GROUP BY e.event_type_main
ORDER BY total_orders DESC;


-- 3.2. Заказы по типам устройств

SELECT
    device_type_canonical,
    COUNT(*) AS total_orders
FROM afisha.purchases
GROUP BY device_type_canonical
ORDER BY total_orders DESC;


-- 3.3. Распределение по валютам

SELECT
    currency_code,
    COUNT(*) AS total_orders,
    SUM(revenue) AS total_revenue
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_orders DESC;


-- 3.4. Распределение по билетным сервисам

SELECT
    service_name,
    COUNT(*) AS total_orders,
    SUM(total) AS total_amount,
    SUM(revenue) AS total_revenue
FROM afisha.purchases
GROUP BY service_name
ORDER BY total_orders DESC;


-- 3.5. Распределение по возрастным ограничениям

SELECT
    age_limit,
    COUNT(*) AS total_orders
FROM afisha.purchases
GROUP BY age_limit
ORDER BY total_orders DESC;


-- 3.6. Уникальные значения категориальных признаков

SELECT DISTINCT device_type_canonical
FROM afisha.purchases
ORDER BY device_type_canonical;

SELECT DISTINCT currency_code
FROM afisha.purchases
ORDER BY currency_code;

SELECT DISTINCT age_limit
FROM afisha.purchases
ORDER BY age_limit;

SELECT DISTINCT event_type_main
FROM afisha.events
ORDER BY event_type_main;


-- ============================================================
-- 4. АНАЛИЗ ВЫРУЧКИ И ВЫЯВЛЕНИЕ АНОМАЛИЙ
-- ============================================================


-- 4.1. Основная статистика по выручке

SELECT
    COUNT(*) AS total_orders,
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    AVG(revenue) AS avg_revenue,
    STDDEV(revenue) AS std_revenue
FROM afisha.purchases
WHERE currency_code = 'rub';


-- 4.2. Основная статистика по сумме заказа

SELECT
    COUNT(*) AS total_orders,
    MIN(total) AS min_total,
    MAX(total) AS max_total,
    AVG(total) AS avg_total,
    STDDEV(total) AS std_total
FROM afisha.purchases
WHERE currency_code = 'rub';


-- 4.3. Поиск аномальных значений

SELECT
    COUNT(*) AS anomalous_orders
FROM afisha.purchases
WHERE revenue < 0
   OR total < 0
   OR tickets_count <= 0;


-- 4.4. Просмотр аномальных заказов

SELECT *
FROM afisha.purchases
WHERE revenue < 0
   OR total < 0
   OR tickets_count <= 0
ORDER BY revenue
LIMIT 100;


-- 4.5. Самые крупные заказы

SELECT
    order_id,
    user_id,
    created_dt_msk,
    event_id,
    tickets_count,
    revenue,
    total,
    currency_code
FROM afisha.purchases
WHERE currency_code = 'rub'
ORDER BY total DESC
LIMIT 20;


-- 4.6. Проверка согласованности revenue и total

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE revenue < 0) AS negative_revenue,
    COUNT(*) FILTER (WHERE total < 0) AS negative_total,
    COUNT(*) FILTER (WHERE revenue > total) AS revenue_greater_than_total
FROM afisha.purchases
WHERE currency_code = 'rub';


-- ============================================================
-- 5. АНАЛИЗ ВРЕМЕННОЙ ДИНАМИКИ
-- ============================================================


-- 5.1. Период данных

SELECT
    MIN(created_dt_msk)::date AS min_date,
    MAX(created_dt_msk)::date AS max_date,
    COUNT(DISTINCT created_dt_msk::date) AS unique_dates
FROM afisha.purchases;


-- 5.2. Помесячная динамика

SELECT
    DATE_TRUNC('month', created_dt_msk)::date AS month,
    COUNT(*) AS total_orders,
    SUM(tickets_count) AS total_tickets,
    SUM(total) AS total_amount,
    SUM(revenue) AS total_revenue
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY month
ORDER BY month;


-- 5.3. Дневная динамика

SELECT
    created_dt_msk::date AS date,
    COUNT(*) AS total_orders,
    SUM(total) AS total_amount,
    SUM(revenue) AS total_revenue
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY date
ORDER BY date;


-- ============================================================
-- 6. АНАЛИЗ РЕГИОНОВ, ГОРОДОВ И ПЛОЩАДОК
-- ============================================================


-- 6.1. Регионы по количеству заказов

SELECT
    r.region_name,
    COUNT(*) AS total_orders,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.total) AS total_amount,
    SUM(p.revenue) AS total_revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.city c
    ON e.city_id = c.city_id
JOIN afisha.regions r
    ON c.region_id = r.region_id
WHERE p.currency_code = 'rub'
GROUP BY r.region_name
ORDER BY total_orders DESC;


-- 6.2. Города по количеству заказов

SELECT
    c.city_name,
    r.region_name,
    COUNT(*) AS total_orders,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.total) AS total_amount,
    SUM(p.revenue) AS total_revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.city c
    ON e.city_id = c.city_id
JOIN afisha.regions r
    ON c.region_id = r.region_id
WHERE p.currency_code = 'rub'
GROUP BY
    c.city_name,
    r.region_name
ORDER BY total_orders DESC
LIMIT 20;


-- 6.3. Площадки по количеству заказов

SELECT
    v.venue_name,
    COUNT(*) AS total_orders,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.total) AS total_amount,
    SUM(p.revenue) AS total_revenue
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.venues v
    ON e.venue_id = v.venue_id
WHERE p.currency_code = 'rub'
GROUP BY v.venue_name
ORDER BY total_orders DESC
LIMIT 20;


-- ============================================================
-- 7. КЛЮЧЕВЫЕ ПРОДУКТОВЫЕ МЕТРИКИ ДЛЯ ДАШБОРДА
-- ============================================================


-- 7.1. Основные KPI за весь период

SELECT
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    AVG(revenue) AS avg_revenue_per_order,
    SUM(tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(revenue) * 1.0 / SUM(tickets_count) AS avg_revenue_per_ticket
FROM afisha.purchases
WHERE currency_code = 'rub';


-- 7.2. Недельная динамика ключевых показателей

SELECT
    DATE_TRUNC('week', created_dt_msk)::date AS week,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    AVG(revenue) AS avg_revenue_per_order,
    SUM(tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(revenue) * 1.0 / SUM(tickets_count) AS avg_revenue_per_ticket
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY week
ORDER BY week ASC;


-- 7.3. Структура выручки по типам мероприятий

SELECT
    e.event_type_main,
    SUM(p.revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT p.user_id) AS total_users,
    AVG(p.revenue) AS avg_revenue_per_order,
    SUM(p.tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(p.revenue) * 1.0 / SUM(p.tickets_count) AS avg_revenue_per_ticket,
    ROUND(
        (
            100.0 * SUM(p.revenue)
            / SUM(SUM(p.revenue)) OVER ()
        )::numeric,
        2
    ) AS revenue_share_pct
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
WHERE p.currency_code = 'rub'
GROUP BY e.event_type_main
ORDER BY total_revenue DESC;


-- 7.4. Структура выручки по типам устройств

SELECT
    device_type_canonical,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    AVG(revenue) AS avg_revenue_per_order,
    ROUND(
        (
            100.0 * SUM(revenue)
            / SUM(SUM(revenue)) OVER ()
        )::numeric,
        2
    ) AS revenue_share_pct
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY total_revenue DESC;


-- 7.5. Топ-7 регионов по выручке

SELECT
    r.region_name,
    SUM(p.revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT p.user_id) AS total_users,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(p.revenue) * 1.0 / SUM(p.tickets_count) AS avg_revenue_per_ticket
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.city c
    ON e.city_id = c.city_id
JOIN afisha.regions r
    ON c.region_id = r.region_id
WHERE p.currency_code = 'rub'
GROUP BY r.region_name
ORDER BY total_revenue DESC
LIMIT 7;


-- 7.6. Топ-20 событий по выручке

SELECT
    e.event_name_code AS event_name,
    e.event_type_main,
    SUM(p.revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT p.user_id) AS total_users,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(p.revenue) * 1.0 / SUM(p.tickets_count) AS avg_revenue_per_ticket
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
WHERE p.currency_code = 'rub'
GROUP BY
    e.event_name_code,
    e.event_type_main
ORDER BY total_revenue DESC
LIMIT 20;


-- 7.7. Топ-20 площадок по выручке

SELECT
    v.venue_name,
    SUM(p.revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT p.user_id) AS total_users,
    SUM(p.tickets_count) AS total_tickets,
    SUM(p.tickets_count) * 1.0 / COUNT(*) AS avg_tickets_per_order,
    SUM(p.revenue) * 1.0 / SUM(p.tickets_count) AS avg_revenue_per_ticket
FROM afisha.purchases p
JOIN afisha.events e
    ON p.event_id = e.event_id
JOIN afisha.venues v
    ON e.venue_id = v.venue_id
WHERE p.currency_code = 'rub'
GROUP BY v.venue_name
ORDER BY total_revenue DESC
LIMIT 20;


-- 7.8. Сравнение показателей по валютам

SELECT
    currency_code,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    AVG(revenue) AS avg_revenue_per_order
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC;

