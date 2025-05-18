--Задание 5
--Найдите самую дорогую пиццу для каждой пиццерии.
WITH total_pizzas AS
(
	SELECT
	r.restaurant_name,
	'Пицца' AS pizza_type,
	menu.KEY AS pizza,
	menu.VALUE::INT AS price
	FROM 
		gastro_hud.restaurants AS r, 
		jsonb_each_text(r.restaurant_menu -> 'Пицца') AS menu
	WHERE r.restaurant_menu ? 'Пицца' 
	-- Подзапрос для сопоставление type_id
	AND type_id =
	(
		SELECT
			rt.type_id
		FROM gastro_hud.restaurant_types AS rt
		WHERE rt.type_name = 'pizzeria'
	)
	-- Выбираем только пиццерии и если в их меню есть "Пицца".
	-- Немного странно, но я решил учесть случай если в меню пиццерии нет пиццы
),
most_expensive_pizza AS
(
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY restaurant_name ORDER BY price DESC) AS place
	FROM total_pizzas AS tp
)
SELECT
	mep.restaurant_name,
	mep.pizza_type,
	mep.pizza,
	mep.price
FROM most_expensive_pizza AS mep
WHERE mep.place = 1;