--- Checking for duplicate records and missing values
SELECT 
COUNT(CAST(started_at AS date)),
COUNT(CAST(ended_at AS date)),
COUNT (DISTINCT ride_id), 
COUNT(member_casual),
COUNT(start_lat),
COUNT(start_station_name),
COUNT(start_station_id),
COUNT(end_lat),
COUNT(end_station_name),
COUNT(end_station_id)
FROM `cyclistic-379422.cyclistic_data.trip_data`;

---Investigating missing values 
SELECT 
*
FROM `cyclistic-379422.cyclistic_data.trip_data`
WHERE start_station_name IS NULL;

---Calculating the number of trips by type
SELECT 
COUNT(ride_id) as num_trips,
member_casual
FROM `cyclistic-379422.cyclistic_data.trip_data`
GROUP BY member_casual;

---Calculating median trip duration by type
SELECT
        DISTINCT median_ride_length,
        member_casual
FROM 
        (
        SELECT 
                ride_id,
                member_casual,
                PERCENTILE_DISC(ended_at-started_at, 0.5 IGNORE NULLS) OVER(PARTITION BY member_casual) AS  median_ride_length
        FROM 
                `cyclistic-379422.cyclistic_data.trip_data`
        )
ORDER BY 
        median_ride_length DESC LIMIT 2;

---Calculating trips by month by type
SELECT 
EXTRACT(month FROM started_at) as month,
COUNT(ride_id) as num_trips,
member_casual
FROM `cyclistic-379422.cyclistic_data.trip_data`
GROUP BY EXTRACT(month FROM started_at),member_casual;

---Calculating trips, rainfall, and snowfall by month
SELECT
  td.*,
  SUM(snow) AS total_snow,
  SUM(precip) AS total_rain
FROM `cyclistic-379422.cyclistic_data.weather` w
JOIN (SELECT 
        EXTRACT(month from started_at) AS month,
        count(*) AS trips
        FROM `cyclistic-379422.cyclistic_data.trip_data`
        GROUP BY EXTRACT(month from started_at)
      ) td
ON EXTRACT(month FROM w.date) = td.month
GROUP BY 1,2
ORDER BY td.month;

---Calculating trips by day of the week by type
SELECT 
  EXTRACT(month from started_at) AS month,
  EXTRACT(DAYOFWEEK
  FROM
    started_at) AS dayofweek,
    member_casual,
  COUNT(*) as num_trips
FROM `cyclistic-379422.cyclistic_data.trip_data`
GROUP BY 1,2,3;

---Identifying top 10 stations for each user type, inlcuding coordinates for plotting
SELECT 
  CONCAT(start_lat,",",start_lng) AS coordinates,
  member_casual,
  COUNT(*) as num_trips
FROM `cyclistic-379422.cyclistic_data.trip_data`
WHERE member_casual='casual'
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 10;

SELECT 
  CONCAT(start_lat,",",start_lng) AS coordinates,
  member_casual,
  COUNT(*) as num_trips
FROM `cyclistic-379422.cyclistic_data.trip_data`
WHERE member_casual='member'
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 10

