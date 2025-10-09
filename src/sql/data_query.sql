-- Total number of users
SELECT COUNT(*) AS total_users FROM users;

--Total number of orders
SELECT COUNT(*) AS total_orders FROM orders;

-- Step 1: Total users with at least one session
SELECT COUNT(DISTINCT user_id) AS users_with_session
FROM sessions;

-- Step 2: Users who viewed a product
SELECT COUNT(DISTINCT s.user_id) AS users_viewed_product
FROM events e
JOIN sessions s ON e.session_id = s.session_id
WHERE e.event_type = 'view';

-- Step 3: Users who added to cart
SELECT COUNT(DISTINCT s.user_id) AS users_added_to_cart
FROM events e
JOIN sessions s ON e.session_id = s.session_id
WHERE e.event_type = 'add_to_cart';

-- Step 4: Users who checked out
SELECT COUNT(DISTINCT s.user_id) AS users_checked_out
FROM events e
JOIN sessions s ON e.session_id = s.session_id
WHERE e.event_type = 'checkout';

-- Step 5: Users who made a purchase
SELECT COUNT(DISTINCT user_id) AS users_purchased
FROM orders;


SELECT 
    (SELECT COUNT(DISTINCT user_id) FROM sessions) AS users_with_session,
    (SELECT COUNT(DISTINCT s.user_id) 
     FROM events e JOIN sessions s ON e.session_id = s.session_id 
     WHERE e.event_type = 'view') AS users_viewed_product,
    (SELECT COUNT(DISTINCT s.user_id) 
     FROM events e JOIN sessions s ON e.session_id = s.session_id 
     WHERE e.event_type = 'add_to_cart') AS users_added_to_cart,
    (SELECT COUNT(DISTINCT s.user_id) 
     FROM events e JOIN sessions s ON e.session_id = s.session_id 
     WHERE e.event_type = 'checkout') AS users_checked_out,
    (SELECT COUNT(DISTINCT user_id) FROM orders) AS users_purchased;


WITH funnel AS (
    SELECT 
        (SELECT COUNT(DISTINCT user_id) FROM sessions) AS users_with_session,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'view') AS users_viewed_product,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'add_to_cart') AS users_added_to_cart,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'checkout') AS users_checked_out,
        (SELECT COUNT(DISTINCT user_id) FROM orders) AS users_purchased
)
SELECT 
    users_with_session,
    users_viewed_product,
    ROUND(users_viewed_product::decimal / users_with_session * 100, 2) AS view_conversion_pct,
    users_added_to_cart,
    ROUND(users_added_to_cart::decimal / users_viewed_product * 100, 2) AS add_to_cart_conversion_pct,
    users_checked_out,
    ROUND(users_checked_out::decimal / users_added_to_cart * 100, 2) AS checkout_conversion_pct,
    users_purchased,
    ROUND(users_purchased::decimal / users_checked_out * 100, 2) AS purchase_conversion_pct
FROM funnel;


-- Total revenue and average order value
SELECT 
    COUNT(*) AS total_orders,
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders;

-- Revenue per user
SELECT 
    user_id,
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount),2) AS avg_order_value,
    COUNT(*) AS orders_count
FROM orders
GROUP BY user_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by new vs returning users
WITH first_order AS (
    SELECT user_id, MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY user_id
)
SELECT 
    CASE WHEN first_order_date >= CURRENT_DATE - INTERVAL '30 days' THEN 'New' ELSE 'Returning' END AS user_type,
    SUM(o.order_amount) AS revenue,
    COUNT(DISTINCT o.user_id) AS user_count
FROM orders o
JOIN first_order f ON o.user_id = f.user_id
GROUP BY user_type;

-- Daily revenue
SELECT 
    order_date,
    SUM(order_amount) AS daily_revenue,
    COUNT(*) AS daily_orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- Number of orders per user
SELECT 
    user_id,
    COUNT(*) AS orders_count,
    SUM(order_amount) AS total_revenue
FROM orders
GROUP BY user_id
ORDER BY orders_count DESC
LIMIT 10;

-- Average time between orders for users
WITH user_orders AS (
    SELECT 
        user_id,
        order_date,
        LEAD(order_date) OVER (PARTITION BY user_id ORDER BY order_date) AS next_order_date
    FROM orders
)
SELECT 
    user_id,
    ROUND(AVG(next_order_date - order_date),2) AS avg_days_between_orders
FROM user_orders
WHERE next_order_date IS NOT NULL
GROUP BY user_id
ORDER BY avg_days_between_orders
LIMIT 10;


WITH funnel AS (
    SELECT 
        (SELECT COUNT(DISTINCT user_id) FROM sessions) AS users_with_session,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e 
         JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'view') AS users_viewed_product,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e 
         JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'add_to_cart') AS users_added_to_cart,
        (SELECT COUNT(DISTINCT s.user_id) 
         FROM events e 
         JOIN sessions s ON e.session_id = s.session_id 
         WHERE e.event_type = 'checkout') AS users_checked_out,
        (SELECT COUNT(DISTINCT user_id) FROM orders) AS users_purchased
)
SELECT 'Users with session' AS stage, users_with_session AS users_count, 100 AS conversion_pct FROM funnel
UNION ALL
SELECT 'Viewed Product', users_viewed_product, ROUND(users_viewed_product::decimal / users_with_session * 100,2) FROM funnel
UNION ALL
SELECT 'Add to Cart', users_added_to_cart, ROUND(users_added_to_cart::decimal / users_viewed_product * 100,2) FROM funnel
UNION ALL
SELECT 'Checkout', users_checked_out, ROUND(users_checked_out::decimal / users_added_to_cart * 100,2) FROM funnel
UNION ALL
SELECT 'Purchased', users_purchased, ROUND(users_purchased::decimal / users_checked_out * 100,2) FROM funnel;