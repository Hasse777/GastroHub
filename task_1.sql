--Задание 1
--Чтобы выдать премию менеджерам, нужно понять, у каких заведений самый высокий средний чек. 
--Создайте представление, которое покажет топ-3 заведения внутри каждого типа заведений по среднему чеку за все даты. 
--Столбец со средним чеком округлите до второго знака после запятой.
CREATE OR REPLACE VIEW gastro_hud.v_restaurants_raiting AS
WITH return_avg AS
(	
	SELECT
		r.restaurant_name,
		rt.type_name,
		ROUND(AVG(avg_check), 2) AS full_avg -- Округляем сумму до двух знаков после запятой
	FROM gastro_hud.sales AS s
	LEFT JOIN gastro_hud.restaurants AS r USING(restaurant_uuid)
	LEFT JOIN gastro_hud.restaurant_types AS rt USING(type_id)
	GROUP BY restaurant_name, type_name
),
rank_rest AS
(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY type_name ORDER BY full_avg DESC) AS id_place
	FROM return_avg AS ra
)
SELECT
	*
FROM rank_rest AS rr
WHERE rr.id_place <= 3; -- Берем только топ 3 заведений по чеку
