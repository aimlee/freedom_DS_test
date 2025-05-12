----------------------------------------------Q1--------------------------------------------------------------
-- create active user 
WITH active_credits AS (
  SELECT 
    customer_id, 
    SUM(credit_amount) AS total_credit
  FROM credit_contracts t1
  WHERE t1.end_date    IS     NULL
     OR t1.end_date    >     CURRENT_DATE
  GROUP BY customer_id
),
-- create active deposite 
active_deposits AS (
  SELECT 
    customer_id, 
    SUM(deposit_amount) AS total_deposit
  FROM deposit_contracts t2
  WHERE t2.end_date    IS     NULL
     OR t2.end_date    >     CURRENT_DATE
  GROUP BY customer_id
)

-- from above select only those, who has more deposite than credits
SELECT 
  c.customer_id,
  c.name,
  ac.total_credit,
  ad.total_deposit
FROM customers c
  JOIN active_credits ac
    ON c.customer_id = ac.customer_id
  JOIN active_deposits ad
    ON c.customer_id = ad.customer_id
WHERE ad.total_deposit > ac.total_credit
;
----------------------------------------------EXCEL--------------------------------------------------------------

/*
=ЕСЛИ(A1<>5; "не равно"; "равно")
*/

----------------------------------------------Q2--------------------------------------------------------------
----A----
SELECT
  id,
  country,
  city,
  population,
  SUM(population) OVER (PARTITION BY country) AS sum_popul
FROM population_c;
----B----
SELECT 
     p.id,
     p.country,
     p.city,
     p.population,
     COALESCE(
       LEAD(p.population) OVER (PARTITION BY p.country ORDER BY p.id),
       0
     ) AS next_c
FROM population_c p;
---------------------------------------------Q3-------------------------------------------------------------------
----A----
SELECT
  i.id               AS item_id,
  i.name             AS item_name,
  i.serial_number    AS serial_number,
  w.name             AS warehouse_name,
  w.mol              AS warehouse_mol,
  d.count            AS quantity
FROM details d
JOIN items i
  ON d.item_id = i.id
JOIN warehouses w
  ON d.warehouse_id = w.id;
----B----
CREATE VIEW view_item_stock AS
SELECT
  i.id               AS item_id,
  i.name             AS item_name,
  i.serial_number    AS serial_number,
  w.name             AS warehouse_name,
  w.mol              AS warehouse_mol,
  d.count            AS quantity
FROM details d
JOIN items i
  ON d.item_id = i.id
JOIN warehouses w
  ON d.warehouse_id = w.id;
----C----
SELECT
  view_schema,
  table_name
FROM information_schema.view_table_usage
WHERE view_name = 'view_item_stock';
----D----
SELECT
  i.id               AS item_id,
  i.name             AS item_name,
  i.serial_number    AS serial_number,
  SUM(d.count)       AS total_quantity
FROM details d
JOIN items i
  ON d.item_id = i.id
GROUP BY
  i.id,
  i.name,
  i.serial_number
HAVING
  SUM(d.count) > 500;