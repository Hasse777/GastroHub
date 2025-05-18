--Задание 3
--Найдите топ-3 заведения, где чаще всего менялся менеджер за весь период.
SELECT
	r.restaurant_name,
	COUNT(manager_uuid) AS count_managers -- Если один и тот же менеджер менялся несколько раз это тоже будет считаться за смену? Возможно стоит применить DISTINCT
FROM gastro_hud.restaurant_manager_work_dates AS rmwd
LEFT JOIN gastro_hud.restaurants AS r USING(restaurant_uuid)
GROUP BY restaurant_name
ORDER BY count_managers DESC
LIMIT 3;