-- Вставляем данные в таблицу типы ресторанов
INSERT INTO gastro_hud.restaurant_types(type_name)
SELECT DISTINCT
	CASE
		WHEN m.menu ? 'Пицца' THEN 'pizzeria'
		WHEN m.menu ? 'Кофе' THEN 'coffee_shop'
		WHEN m.menu ? 'Коктейль' THEN 'bar'
		WHEN m.menu ? 'Горячее' THEN 'restaurant'
	END::gastro_hud.restaurant_type
FROM raw_data.menu AS m
RETURNING *;


--Вставляем данные в тублицу ресторанов
INSERT INTO gastro_hud.restaurants(restaurant_name, type_id, restaurant_menu)
SELECT DISTINCT
	m.cafe_name,
	rt.type_id,
	m.menu	
FROM raw_data.menu AS m
LEFT JOIN gastro_hud.restaurant_types AS rt ON
	(m.menu ? 'Пицца' AND rt.type_name = 'pizzeria') OR
	(m.menu ? 'Кофе' AND rt.type_name = 'coffee_shop') OR
	(m.menu ? 'Коктейль' AND rt.type_name = 'bar') OR
	(m.menu ? 'Горячее' AND rt.type_name = 'restaurant')
RETURNING *;


--Вставляем данные в таблицу менеджеров
INSERT INTO gastro_hud.managers(full_name, phone_number)
SELECT DISTINCT
	rd.manager,
	rd.manager_phone
FROM raw_data.sales AS rd
RETURNING *;



-- Вставляем данные в таблицу работы менеджеров в ресторане
INSERT INTO gastro_hud.restaurant_manager_work_dates(restaurant_uuid, manager_uuid, date_begin, date_end)
SELECT
	r.restaurant_uuid,
	m.manager_uuid,
	MIN(s.report_date),
	MAX(s.report_date)
FROM raw_data.sales AS s
LEFT JOIN gastro_hud.managers AS m 
	ON m.full_name = s.manager AND m.phone_number = s.manager_phone
LEFT JOIN gastro_hud.restaurants AS r 
	ON r.restaurant_name = s.cafe_name
GROUP BY m.manager_uuid, r.restaurant_uuid
RETURNING *;


-- Вставляем данные в таблицу продаж
INSERT INTO gastro_hud.sales(date_sale, restaurant_uuid, avg_check)
SELECT DISTINCT
	s.report_date,
	r.restaurant_uuid,
	s.avg_check
FROM raw_data.sales AS s
LEFT JOIN gastro_hud.restaurants AS r ON r.restaurant_name = s.cafe_name
RETURNING *;