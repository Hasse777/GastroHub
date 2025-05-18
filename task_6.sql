--Задание 6
--В Gastro Hub решили проверить новую продуктовую гипотезу и поднять цены на капучино. 
--Маркетологи компании собрали совещание, чтобы обсудить, на сколько стоит поднять цены. 
--В это время для отчётности использовать старые цены нельзя. После обсуждения решили увеличить цены на капучино на 20%.
--Обновите данные по ценам так, чтобы до завершения обновления никто не вносил других изменений в цены этих заведений. 
--В заведениях, где цены не меняются, данные о меню должны остаться в полном доступе.

BEGIN;
-- Блокируем обновляемую строку
	SELECT
		r.restaurant_menu
	FROM gastro_hud.restaurants AS r
	WHERE r.type_id =
	(
		SELECT
			rt.type_id
		FROM gastro_hud.restaurant_types AS rt
		WHERE rt.type_name = 'coffee_shop'
	)
	AND r.restaurant_menu -> 'Кофе' ? 'Капучино' -- Проверяем есть ли в кофейне капучино
	FOR UPDATE; -- Использую исключительную блокировку чтобы никто не вносил изменения пока эта транзакция рабоатет.

	
-- Обновляем цены капучино
	UPDATE gastro_hud.restaurants SET
	restaurant_menu = jsonb_set
	(restaurant_menu, 
	'{Кофе, Капучино}',
	((restaurant_menu-> 'Кофе' ->> 'Капучино')::NUMERIC * 1.2)::TEXT::JSONB
	)-- После умножение на 1.2 иногда остаются лишнии нули, например: 360.0.
	-- Можно оставить в таком виде или нули нужно убрать?
	
	WHERE type_id =
	(
		SELECT
			rt.type_id
		FROM gastro_hud.restaurant_types AS rt
		WHERE rt.type_name = 'coffee_shop'
	)
	AND restaurant_menu -> 'Кофе' ? 'Капучино'
	RETURNING *;
	
COMMIT;

--ROLLBACK;