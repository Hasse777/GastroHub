--Задание 4
--Найдите пиццерию с самым большим количеством пицц в меню. Если таких пиццерий несколько, выведите все.
--Вот формат итоговой таблицы, числа и названия — для наглядности:
WITH pizza_count AS
(
	SELECT
		r.restaurant_name,
		COUNT(*) AS total_pizzas
	FROM gastro_hud.restaurants AS r, jsonb_object_keys(r.restaurant_menu -> 'Пицца') -- Испозую декартово произведение чтобы каждому названию ресторана соответствовала 1 пицца.
	WHERE r.type_id =
	-- Подзапрос для сопоставление type_id
	(
		SELECT
			rt.type_id
		FROM gastro_hud.restaurant_types AS rt
		WHERE rt.type_name = 'pizzeria'
	)
	AND r.restaurant_menu ? 'Пицца'
	GROUP BY restaurant_name, restaurant_menu
),
pizza_place AS
(
	SELECT
		*,
		DENSE_RANK() OVER(ORDER BY total_pizzas DESC) AS place -- Находим первые места и назначаем им 1 ранг
	FROM pizza_count AS pc
)
SELECT
	pp.restaurant_name,
	pp.total_pizzas 
FROM pizza_place AS pp
WHERE pp.place = 1; -- Отбираем только 1 ранг