CREATE EXTENSION
IF NOT EXISTS postgis;
CREATE EXTENSION
IF NOT EXISTS postgis_topology;
CREATE EXTENSION
IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION
IF NOT EXISTS postgis_tiger_geocoder;

create table trips
(
    medallion varchar(255),
    hack_license varchar(255),
    vendor_id varchar(255),
    rate_code varchar(255),
    store_and_fwd_flag varchar(255),
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    passenger_count integer,
    trip_time_in_secs integer,
    trip_distance numeric,
    pickup_longitude numeric,
    pickup_latitude numeric,
    dropoff_longitude numeric,
    dropoff_latitude numeric
);

COPY trips FROM '/home/trip_data/test.csv' DELIMITER ',' CSV HEADER;

alter table trips add column id serial primary key;
ALTER TABLE trips ADD COLUMN pickup_geo geography;
ALTER TABLE trips ADD COLUMN dropoff_geo geography;

UPDATE trips SET pickup_geo = ST_SetSRID(ST_MakePoint(pickup_longitude, pickup_latitude), 4326);
UPDATE trips SET dropoff_geo = ST_SetSRID(ST_MakePoint(dropoff_longitude, dropoff_latitude), 4326);

create index pickup_idx on trips using GIST
(pickup_geo);
create index dropoff_idx on trips using GIST
(dropoff_geo);
create index trip_time_idx on trips (trip_time_in_secs);
create index trip_distance_idx on trips(trip_distance);
create index trip_datetime_idx on trips(pickup_datetime);

VACUUM ANALYZE trips;