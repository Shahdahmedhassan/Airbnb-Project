SELECT DB_NAME();
USE Airbnb_DWH;
GO
DROP TABLE IF EXISTS fact_listing;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_room_type;
DROP TABLE IF EXISTS dim_host;
DROP TABLE IF EXISTS dim_day_type;
GO
CREATE TABLE dim_city (
    city_key INT PRIMARY KEY,
    city NVARCHAR(50)
);

CREATE TABLE dim_room_type (
    room_type_key INT PRIMARY KEY,
    room_type NVARCHAR(50),
    room_shared BIT,
    room_private BIT
);

CREATE TABLE dim_host (
    host_key INT PRIMARY KEY,
    host_is_superhost BIT,
    multi BIT,
    biz BIT
);

CREATE TABLE dim_day_type (
    day_type_key INT PRIMARY KEY,
    day_type NVARCHAR(20)
);

CREATE TABLE fact_listing (
    listing_key INT PRIMARY KEY,
    city_key INT NOT NULL,
    room_type_key INT NOT NULL,
    host_key INT NOT NULL,
    day_type_key INT NOT NULL,
    price FLOAT,
    person_capacity INT,
    cleanliness_rating FLOAT,
    guest_satisfaction_overall FLOAT,
    bedrooms INT,
    dist FLOAT,
    metro_dist FLOAT,
    attr_index FLOAT,
    attr_index_norm FLOAT,
    rest_index FLOAT,
    rest_index_norm FLOAT,
    lat FLOAT,
    lng FLOAT,

    CONSTRAINT FK_fact_city FOREIGN KEY (city_key) REFERENCES dim_city(city_key),
    CONSTRAINT FK_fact_room FOREIGN KEY (room_type_key) REFERENCES dim_room_type(room_type_key),
    CONSTRAINT FK_fact_host FOREIGN KEY (host_key) REFERENCES dim_host(host_key),
    CONSTRAINT FK_fact_daytype FOREIGN KEY (day_type_key) REFERENCES dim_day_type(day_type_key)
);
INSERT INTO dim_city (city_key, city)
SELECT city_key, city FROM dim_city_staging;

DROP TABLE dim_city_staging;

INSERT INTO dim_room_type (room_type_key, room_type, room_shared, room_private)
SELECT room_type_key, room_type, room_shared, room_private FROM dim_room_type_staging;
DROP TABLE dim_room_type_staging;

INSERT INTO dim_host (host_key, host_is_superhost, multi, biz)
SELECT host_key, host_is_superhost, multi, biz FROM dim_host_staging;
DROP TABLE dim_host_staging;

INSERT INTO dim_day_type (day_type_key, day_type)
SELECT day_type_key, day_type FROM dim_day_type_staging;
DROP TABLE dim_day_type_staging;

INSERT INTO fact_listing (
    listing_key, city_key, room_type_key, host_key, day_type_key,
    price, person_capacity, cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lat, lng
)
SELECT
    listing_key, city_key, room_type_key, host_key, day_type_key,
    price, person_capacity, cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lat, lng
FROM fact_listing_staging;

DROP TABLE fact_listing_staging;

SELECT 'dim_city' AS table_name, COUNT(*) AS row_count FROM dim_city
UNION ALL
SELECT 'dim_room_type', COUNT(*) FROM dim_room_type
UNION ALL
SELECT 'dim_host', COUNT(*) FROM dim_host
UNION ALL
SELECT 'dim_day_type', COUNT(*) FROM dim_day_type
UNION ALL
SELECT 'fact_listing', COUNT(*) FROM fact_listing;
SELECT name FROM sys.tables WHERE name LIKE '%staging%';