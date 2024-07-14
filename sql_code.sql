-- Top 10 Highest Revenue Generating Products
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

-- Top 5 Highest Selling Products in Each Region
;WITH cte1 AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT * 
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte1
) A
WHERE rn <= 5;

-- Month Over Month Growth Comparison for 2022 and 2023 Sales
;WITH cte2 AS (
    SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte2 
GROUP BY order_month
ORDER BY order_month;

-- For Each Category, Which Month Had the Highest Sales
;WITH cte3 AS (
    SELECT category, FORMAT(order_date, 'yyyyMM') AS order_year_month, SUM(sale_price) AS sales 
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT * 
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte3
) b
WHERE rn = 1;

-- Subcategory with the Highest Growth by Profit in 2023 Compared to 2022
;WITH cte4 AS (
    SELECT sub_category, YEAR(order_date) AS order_year, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
)
, cte5 AS (
    SELECT sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte4 
    GROUP BY sub_category
)
SELECT TOP 1 *,
    (sales_2023 - sales_2022) AS sales_growth
FROM cte5
ORDER BY sales_growth DESC;
