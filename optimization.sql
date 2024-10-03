#non-optimized

explain analyze
SELECT
    c.*,
    o.*,
    p.*,
    dp.*,
    (SELECT COUNT(*) FROM orders o2 WHERE o2.client_id = c.id) AS total_orders,
    (SELECT SUM(o3.amount) FROM orders o3 WHERE o3.product_id = p.product_id) AS total_amount
FROM clients c
JOIN orders o ON c.id = o.client_id
JOIN products p ON o.product_id = p.product_id
JOIN delivery_points dp ON o.point_id = dp.point_id
LEFT JOIN (
    SELECT
        o.order_id,
        o.order_date,
        o.amount,
        c.id AS client_id,
        c.name,
        CASE
            WHEN MONTH(o.order_date) = MONTH(c.birthday)
                 AND DAY(o.order_date) = DAY(c.birthday)
            THEN o.amount * 0.90
            ELSE o.amount
        END AS discount_amount
    FROM orders o
    JOIN clients c ON o.client_id = c.id
) AS discount_table ON o.order_id = discount_table.order_id
WHERE
    o.order_date IN (
        SELECT DISTINCT order_date
        FROM orders o4
        WHERE o4.order_date BETWEEN '2020-01-01' AND '2022-01-01'
    )
    AND p.product_category NOT IN ('Category1', 'Category2', 'Category3', 'Category4')
ORDER BY
    o.order_date DESC;


   # optimized

create index idx_orders_order_price on orders(price);
create index idx_orders_order_amount on orders(amount);

with
calculation as (
    select
        c.id as client_id,
        count(*) as total_orders,
        SUM(o.amount) as total_amount
    from clients c
    left join orders o on c.id = o.client_id
    group by c.id
),
discount_cte as (
    select
        o.order_id,
        o.order_date,
        o.amount,
        case when month(o.order_date) = month(c.birthday) and day(o.order_date) = day(c.birthday) then o.amount * 0.90 else amount  end as discount_amount
    from orders o
    join clients c on o.client_id = c.id
)

select
    c.*,
    o.*,
    p.*,
    dp.*,
    calc.total_orders,
    calc.total_amount,
    dc.discount_amount
from clients c
join orders o on c.id = o.client_id
join products p on o.product_id = p.product_id
join delivery_points dp on o.point_id = dp.point_id
left join calculation calc on c.id = calc.client_id
left join discount_cte dc on o.order_id = dc.order_id
where o.order_date >= '2020-01-01' and o.order_date < '2022-01-01' and p.product_category in ('Category5')
order by o.order_date desc;