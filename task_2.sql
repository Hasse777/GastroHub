--Задание 2
--Создайте материализованное представление, которое покажет, как изменяется средний чек для каждого заведения от года к году за все года за исключением 2023 года. 
--Все столбцы со средним чеком округлите до второго знака после запятой.
CREATE MATERIALIZED VIEW gastro_hud.v_avg_by_year AS
WITH avg_by_year AS
(
	SELECT
		EXTRACT(YEAR FROM date_sale) AS year_sale,
		r.restaurant_name,
		rt.type_name,
		ROUND(AVG(avg_check), 2) AS avg_year
	FROM gastro_hud.sales AS s
	LEFT JOIN gastro_hud.restaurants AS r USING(restaurant_uuid)
	LEFT JOIN gastro_hud.restaurant_types AS rt USING(type_id)
	WHERE EXTRACT(YEAR FROM date_sale) <> 2023
	GROUP BY year_sale, restaurant_name, type_name
),
lag_count AS
(
	SELECT
		*,
		LAG(avg_year) OVER(PARTITION BY restaurant_name ORDER BY year_sale) AS previous_year,
		ROUND((avg_year / LAG(avg_year) OVER(PARTITION BY restaurant_name ORDER BY year_sale) - 1) * 100, 2) AS change_average_check
)
SELECT *
FROM lag_count
ORDER BY restaurant_name, year_sale;