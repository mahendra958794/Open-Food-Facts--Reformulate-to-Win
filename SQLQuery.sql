CREATE DATABASE OPEN_FOOD_FACT;
USE OPEN_FOOD_FACT; 

SELECT COUNT(*) AS total_rows
FROM products;

SELECT TOP 10 *
FROM products;

SELECT
    SUM(CASE WHEN Health_score IS NULL THEN 1 ELSE 0 END) AS null_health_score,
    SUM(CASE WHEN Sugar IS NULL THEN 1 ELSE 0 END) AS null_sugar,
    SUM(CASE WHEN Fat IS NULL THEN 1 ELSE 0 END) AS null_fat,
    SUM(CASE WHEN Salt IS NULL THEN 1 ELSE 0 END) AS null_salt
FROM products;

CREATE VIEW product_health AS
SELECT
    Product,Brand,Category,Label, Energy,Fat,Sugar,Salt,
    Sat_fat,Is_vegan,Contains_palm_oil,Health_score,
    CASE
        WHEN Health_score >= 70 THEN 'Healthy'
        WHEN Health_score BETWEEN 40 AND 69 THEN 'Moderate'
        ELSE 'Unhealthy'
    END AS Health_category
FROM products;

SELECT TOP 10 *
FROM product_health;

SELECT
    Category,
    Health_category,
    COUNT(*) AS product_count
FROM products_health
GROUP BY Category, Health_category
ORDER BY Category, product_count DESC;


SELECT
    Category,
    COUNT(*) AS total_products,
    SUM(CASE WHEN Health_category = 'Unhealthy' THEN 1 ELSE 0 END) AS unhealthy_products,
    ROUND(
        SUM(CASE WHEN Health_category = 'Unhealthy' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS unhealthy_percentage
FROM products_health
GROUP BY Category
ORDER BY unhealthy_percentage DESC;

SELECT TOP 50
    Brand,
    ROUND(AVG(Health_score), 2) AS avg_health_score,
    COUNT(*) AS product_count
FROM products_health
GROUP BY Brand
HAVING COUNT(*) >= 10
ORDER BY avg_health_score DESC;


SELECT
    Category,
    Brand,
    ROUND(AVG(Health_score), 2) AS avg_health_score
FROM products_health
GROUP BY Category, Brand
HAVING COUNT(*) >= 3
ORDER BY Category, avg_health_score DESC;


CREATE VIEW category_best_score AS
SELECT
    Category,
    MAX(avg_health_score) AS best_health_score
FROM (
    SELECT
        Category,
        Brand,
        AVG(Health_score) AS avg_health_score
    FROM products_health
    GROUP BY Category, Brand
) t
GROUP BY Category;


SELECT
    p.Product,
    p.Brand,
    p.Category,
    p.Health_score,
    c.best_health_score,
    (c.best_health_score - p.Health_score) AS health_gap
FROM products_health p
JOIN category_best_score c
ON p.Category = c.Category
ORDER BY health_gap DESC ;


SELECT
    Product,
    Brand,
    Category,
    Health_score
FROM products_health
WHERE Health_category = 'Unhealthy'
ORDER BY Health_score ASC;


SELECT
    Product,
    Brand,
    Category,
    Health_score,
    Health_category,
    CASE
        WHEN Health_score >= 70 THEN 'Healthy Choice'
        WHEN Health_score BETWEEN 40 AND 69 THEN 'Balanced Nutrition'
        ELSE 'Reformulation Needed'
    END AS Health_claim,
    CASE
        WHEN Is_vegan = 1 THEN 'Vegan'
        ELSE 'Non-Vegan'
    END AS Vegan_claim,
    CASE
        WHEN Contains_palm_oil = 0 THEN 'Palm Oil Free'
        ELSE 'Contains Palm Oil'
    END AS Palm_oil_claim
FROM product_health;


CREATE VIEW OUTPUT_FOR AS
SELECT
    Product,
    Brand,
    Category,
    Health_score,
    Health_category,
    Energy,
    Is_vegan,
    Fat,
    Salt,
    Sugar,
    Sat_fat,
    Contains_palm_oil
FROM products_health;

SELECT * FROM OUTPUT_FOR;


