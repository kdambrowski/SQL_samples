-- Write a query to retrieve all passengers who live in Warsaw or Krakow and had a flight between 2022-01-01 and 2022-06-01.
SELECT DISTINCT r.pasazer_id1 AS passenger_id,
    p.first_name,
    p.last_name,
    a.city AS passenger_hometown
FROM booking AS r
    JOIN address AS a ON r.passenger_address_id1 = a.id
    JOIN flight ON r.flight_flight_number1 = flight.flight_number
    JOIN passenger AS p ON r.passenger_id1 = p.id
WHERE flight.departure_date BETWEEN '2022-01-01T00:00:00.000' AND '2022-06-01T23:59:59.999'
    AND a.city IN ('Warsaw', 'Krakow');

-- Write a query to count the number of flights for each airplane from 2022-01-01 until today. 
SELECT s.id AS airplane_number, 
    COUNT(s.id) AS number_of_flights_from_2022_01_01_to_today 
FROM flight
    JOIN airplane AS s ON s.id = flight.airplane_id1
WHERE flight.departure_date BETWEEN '2022-01-01' AND NOW()
GROUP BY s.id;

-- For the previous query, add information about the number of passengers served by each airplane and what
-- a percentage of these passengers had additional baggage (baggage information is stored in the booking table
-- in the baggage field. If it's empty, the passenger didn't have additional baggage).
SELECT s.id AS airplane_id, 
    COUNT(DISTINCT flight.flight_number) AS number_of_flights_from_2022_01_01_to_today, 
    COUNT(booking.passenger_id1) AS number_of_passengers_served_by_airplane,
    (COUNT(CASE WHEN booking.baggage IS NOT NULL THEN 1 END) / COUNT(booking.passenger_id1)) AS percentage_of_passengers_with_additional_baggage
FROM booking
    JOIN flight ON booking.flight_flight_number1 = flight.flight_number
    JOIN airplane AS s ON s.id = flight.airplane_id1
WHERE flight.departure_date BETWEEN '2022-01-01' AND NOW()
GROUP BY s.id;


-- Write a query to retrieve, for each passenger, their 3 most recent flights with a breakdown by airplane manufacturer.
WITH recent_flights AS (
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY flight.departure_date DESC) AS row_number, 
        p.id AS passenger_id,
        p.first_name,
        p.last_name,
        flight.departure_date,
        airplane.manufacturer AS airplane_manufacturer
    FROM booking AS b 
        JOIN passenger AS p ON b.passenger_id1 = p.id
        JOIN flight ON b.flight_flight_number1 = flight.flight_number
        JOIN airplane ON flight.airplane_id1 = airplane.id
)
SELECT passenger_id, first_name, last_name, departure_date, airplane_manufacturer
FROM recent_flights
WHERE row_number < 4;


-- Write a query to retrieve information about the number of passengers served by each airplane for 
-- each month in the period from 2022-01-01 to 2023-02-28. Additionally, add the cumulative sum of passengers
-- served by each airplane.
WITH CTE AS (
SELECT
    airplane.id,
    airplane.manufacturer,
    airplane.type,
    CONCAT(YEAR(flight.departure_date),'-',LPAD(MONTH(flight.departure_date), 2, 0)) AS month,
    COUNT(booking.id) AS number_of_served_passengers
FROM
    airplane
JOIN
    flight ON airplane.id = flight.airplane_id1
JOIN
    booking ON booking.flight_flight_number1 = flight.flight_number
WHERE
   flight.departure_date BETWEEN '2022-01-01T00:00:00.000' AND '2023-02-28T23:59:59.999'
GROUP BY
    airplane.id,
    airplane.manufacturer,
    airplane.type,
    CONCAT(YEAR(flight.departure_date),'-',LPAD(MONTH(flight.departure_date), 2, 0))
)
SELECT
    *,
    SUM(number_of_served_passengers) OVER (
    PARTITION BY id ORDER BY month) AS cumulative_passengers
FROM
    CTE;
