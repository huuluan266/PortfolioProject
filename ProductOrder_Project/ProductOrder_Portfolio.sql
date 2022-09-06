
--Explore the original datasets
SELECT * FROM [dbo].[customers]
SELECT * FROM [dbo].[orders]
SELECT * FROM [dbo].[product_orders]
SELECT * FROM [dbo].[products]


-- LOOK AT THE GAP OF DAYS BETWEEN EACH CUSTOMER'S PURCHASE
WITH frequency1 AS
(SELECT a.order_id AS order_id, a.customer_id AS customer_id, a.order_date AS FirstPurchase, b.order_date AS NextPurchase, datediff(day, a.order_date, b.order_date) AS frequency
FROM [dbo].[orders] AS a
LEFT JOIN [dbo].[orders] AS b
ON a.customer_id = b.customer_id
WHERE a.order_date != b.order_date)
--ORDER BY a.customer_id, a.order_date

SELECT c.order_id, c.customer_id, f.FirstPurchase, f.NextPurchase, c.frequency
FROM (SELECT order_id, customer_id, MIN(frequency) AS frequency
FROM frequency1
WHERE frequency > 0
GROUP BY order_id, customer_id) AS c
LEFT JOIN frequency1 AS f
ON c.order_id = f.order_id
WHERE datediff(day, f.FirstPurchase, f.NextPurchase) = c.frequency
ORDER BY c.customer_id, f.FirstPurchase

-- LOOK AT THE AVERAGE GAP OF DAYS BETWEEN EACH CUSTOMER'S PURCHASE
WITH frequency1 AS
(SELECT a.order_id AS order_id, a.customer_id AS customer_id, a.order_date AS FirstPurchase, b.order_date AS NextPurchase, datediff(day, a.order_date, b.order_date) AS frequency
FROM [dbo].[orders] AS a
LEFT JOIN [dbo].[orders] AS b
ON a.customer_id = b.customer_id
WHERE a.order_date != b.order_date)
--ORDER BY a.customer_id, a.order_date

SELECT d.customer_id, cusTable.first_name, cusTable.last_name, AVG(d.frequency) AS AvgPurchasingDay
FROM (SELECT c.order_id, c.customer_id, f.FirstPurchase, f.NextPurchase, c.frequency
	FROM (SELECT order_id, customer_id, MIN(frequency) AS frequency
		FROM frequency1
		WHERE frequency > 0
		GROUP BY order_id, customer_id) AS c
	LEFT JOIN frequency1 AS f
	ON c.order_id = f.order_id
	WHERE datediff(day, f.FirstPurchase, f.NextPurchase) = c.frequency) d
	--ORDER BY c.customer_id, f.FirstPurchase) d
INNER JOIN [dbo].[customers] AS cusTable
ON d.customer_id = cusTable.customer_id
GROUP BY d.customer_id, cusTable.first_name, cusTable.last_name

-- LOOKING AT THE NUMBER OF PRODUCTS SOLD
SELECT po.product_id AS product_id, p.product_name AS product_name, SUM(po.quantity) AS TotalQuantity, p.product_type AS product_type 
FROM [dbo].[product_orders] AS po
INNER JOIN [dbo].[products] AS p
ON po.product_id = p.product_id
GROUP BY po.product_id, p.product_name, p.product_type
ORDER BY 4

-- LOOKING AT THE TYPE OF PRODUCTS WHICH ARE SOLD MOST
SELECT p.product_type AS product_type, SUM(po.quantity) AS TotalQuantity
FROM [dbo].[product_orders] AS po
INNER JOIN [dbo].[products] AS p
ON po.product_id = p.product_id
GROUP BY p.product_type
ORDER BY 2 DESC

--LOOKING AT MONTHS WITH HIGH SALES VOLUME
SELECT MONTH(b.order_date) AS MonthList, YEAR(b.order_date) AS YearList, SUM(a.TotalQuantity) TotalQuantityByMonth
FROM (SELECT order_id, SUM(quantity) AS TotalQuantity
	FROM [dbo].[product_orders]
	GROUP BY order_id) a
--ORDER BY 1, 2 DESC)
INNER JOIN [dbo].[orders] b
ON a.order_id = b.order_id
GROUP BY MONTH(b.order_date), YEAR(b.order_date)
ORDER BY 3 DESC