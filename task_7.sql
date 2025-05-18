--Задание 7
--Руководство GastroHub приняло решение сделать единый номер телефонов для всех менеджеров. 
--Новый номер — 8-800-2500-***, где порядковый номер менеджера выставляется по алфавиту, начиная с номера 100. 
--Старый и новый номер нужно будет хранить в массиве, где первый элемент массива — новый номер, а второй — старый.
--Во время проведения этих изменений таблица managers должна быть недоступна для изменений со стороны других пользователей, но доступна для чтения.

BEGIN;


LOCK TABLE gastro_hud.managers IN EXCLUSIVE MODE; -- Блокирую таблицу на любые изменения. Оставляю возможность чтения данных


ALTER TABLE gastro_hud.managers ADD COLUMN IF NOT EXISTS -- Добавляем колонку массив с номерами телефона
manager_phone TEXT ARRAY[2]; -- Решил указать размер для лучшего понимание.


WITH row_managers AS -- Временная таблица с менеджерами по алфавиту
(
	SELECT
		m.manager_uuid,
		m.phone_number,
		ROW_NUMBER() OVER(ORDER BY m.full_name) AS rw_rank --Нумеруем менеджеров по алфавиту
	FROM gastro_hud.managers AS m
),
new_num AS -- В временной таблице формируем поле с новым номером
(
	SELECT
		*,
		-- Прибавляем порядок по алфавиту к 99 чтобы получить новый номер.
		-- Если менеджеров больше 999 номер точно будет корректным?
		ARRAY[
		'8-800-2500-' || (99 + fm.rw_rank)::TEXT,
		fm.phone_number
		] AS new_phone_arr
	FROM row_managers AS fm
)
UPDATE gastro_hud.managers AS m SET
manager_phone = nn.new_phone_arr
FROM new_num AS nn
WHERE m.manager_uuid = nn.manager_uuid;


--Удаляем колонку старого номера телефона
ALTER TABLE gastro_hud.managers 
DROP COLUMN IF EXISTS phone_number;


--Накладываю ограничение NOT NULL на массив с номерами
ALTER TABLE gastro_hud.managers
ALTER COLUMN manager_phone SET NOT NULL;

COMMIT;

--ROLLBACK;