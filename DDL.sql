-- Создаем схему если она еще не существует
CREATE SCHEMA IF NOT EXISTS gastro_hud;


-- Создаем ENUM тип
CREATE TYPE gastro_hud.restaurant_type AS ENUM
('coffee_shop', 'restaurant', 'bar', 'pizzeria');


-- Создаем отдельную таблицу типов ресторанов
CREATE TABLE IF NOT EXISTS gastro_hud.restaurant_types
(
	type_id SERIAL PRIMARY KEY,
	type_name gastro_hud.restaurant_type NOT NULL UNIQUE
);


-- Создаем таблицу ресторанов
CREATE TABLE IF NOT EXISTS gastro_hud.restaurants
(
	restaurant_uuid UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
	restaurant_name VARCHAR(50) NOT NULL UNIQUE,
	type_id INT REFERENCES gastro_hud.restaurant_types(type_id) ON DELETE RESTRICT,
	restaurant_menu JSONB NOT NULL
);


--Создаем таблицу менеджеров
CREATE TABLE IF NOT EXISTS gastro_hud.managers
(
	manager_uuid UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
	full_name VARCHAR(100) NOT NULL,
	phone_number text NOT NULL
);


--Создаем таблицу работы менеджеров в ресторане
CREATE TABLE IF NOT EXISTS gastro_hud.restaurant_manager_work_dates
(
	restaurant_uuid UUID REFERENCES gastro_hud.restaurants(restaurant_uuid) ON DELETE RESTRICT,
	manager_uuid UUID REFERENCES gastro_hud.managers(manager_uuid) ON DELETE RESTRICT,
	date_begin DATE NOT NULL,
	date_end DATE,
	PRIMARY KEY(restaurant_uuid, manager_uuid)
);


-- Создаем таблицу продаж
CREATE TABLE IF NOT EXISTS gastro_hud.sales
(
	date_sale DATE,
	restaurant_uuid UUID REFERENCES gastro_hud.restaurants(restaurant_uuid) ON DELETE RESTRICT,
	avg_check NUMERIC(10, 2) NOT NULL CHECK(avg_check >= 0),
	PRIMARY KEY(date_sale, restaurant_uuid)
);

