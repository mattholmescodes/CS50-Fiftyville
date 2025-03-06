-- Keep a log of any SQL queries you execute as you solve the mystery.

-- The CS50 Duck has been stolen! The town of Fiftyville has called upon you to solve the mystery of the stolen duck.
-- Authorities believe that the thief stole the duck and then, shortly afterwards, took a flight out of town with the help of an accomplice. Your goal is to identify:

-- Who the thief is,
-- What city the thief escaped to, and
-- Who the thief’s accomplice is who helped them escape
-- All you know is that the theft took place on July 28, 2024 and that it took place on Humphrey Street.

-- Query 1: Find crime scene report that matches day and location:
SELECT description FROM crime_scene_reports
WHERE year == 2024 AND month == 7 AND day == 28 AND street == 'Humphrey Street';

-- REPORT FROM QUERY 1:
-- Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time –
-- each of their interview transcripts mentions the bakery.
-- Littering took place at 16:36. No known witnesses.

-- Query 2: Search for license plates and activity at the bakery at 10:15am
SELECT activity, license_plate FROM bakery_security_logs
WHERE hour == 10 AND minute == 15;

-- REPORT FROM QUERY 2:
-- +----------+---------------+
-- | activity | license_plate |
-- +----------+---------------+
-- | exit     | 11J91FW       |
-- +----------+---------------+

-- Query 3: Collect interview transcripts from people who were present at the bakery at 10:15am (Interviews mention the bakery, only 3)
SELECT DISTINCT transcript FROM interviews
JOIN bakery_security_logs
ON interviews.year = bakery_security_logs.year
WHERE bakery_security_logs.hour == 10
AND bakery_security_logs.minute == 15
AND interviews.transcript LIKE '%bakery%';

--REPORT FROM QUERY 3 (IMPORTANT DETAILS CAPITALISED)
-- | As the thief was leaving the bakery, they called someone who TALKED TO THEM FOR LESS THAN A MINUTE. In the call, I heard the thief say that they were planning to take the EARLIEST FLIGHT OUT OF FIFTYVILLE TOMORROW. The thief then asked the PERSON ON THE OTHER END OF THE PHONE to purchase the flight ticket. |
-- | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM ON LEGGETT STREET and saw the thief there withdrawing some money.                                                                                                 |
-- | I saw Richard take a bite out of his pastry at the bakery before his pastry was stolen from him. <- STATEMENT NOT RELEVANT                                                                                                                                                                                                                 |
-- | Sometime WITHIN 10 MINUTES OF THE THEFT, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.

-- CURRENT CLUES:
-- Spoke to person who purchased flight ticket for less than a minute at 10:15am - Check phone logs
-- Taking earliest flight out of fiftyville on July 29 2024, can check for which flight (Will only find airport id, need to join airports to retrieve city)
-- Withdrew money from ATM on Leggett street - Look at ATM logs
-- Left bakery sometime within 10 minutes of the theft - Redo Query 2 where minute is between 15 and 25

-- Query 4: Find city thief escaped to:
SELECT city, hour, minute, FROM airports
JOIN flights
ON airports.id = destination_airport_id
WHERE flights.month == 7
AND flights.day == 29
AND flights.year == 2024
ORDER BY hour;

-- REPORT FROM QUERY 4:
-- +---------------+------+--------+
-- |     city      | hour | minute |
-- +---------------+------+--------+
-- | New York City | 8    | 20     |
-- | Chicago       | 9    | 30     |
-- | San Francisco | 12   | 15     |
-- | Tokyo         | 15   | 20     |
-- | Boston        | 16   | 0      |
-- +---------------+------+--------+
-- Suspect has escaped to New York City.

-- Query 5: Check format of duration in phone_calls for future queries.
SELECT duration FROM phone_calls;

-- QUERY 5 RETURNS DURATION IN SECONDS

-- Query 6: Look at caller and receiver of phone calls on July 28 2024 that lasted less than a minute:
SELECT caller, receiver FROM phone_calls
WHERE year == 2024
AND month == 7
AND day == 28
AND duration < 60;

-- REPORT FROM QUERY 6:
-- +----------------+----------------+
-- |     caller     |    receiver    |
-- +----------------+----------------+
-- | (130) 555-0289 | (996) 555-8899 |
-- | (499) 555-9472 | (892) 555-8872 |
-- | (367) 555-5533 | (375) 555-8161 |
-- | (499) 555-9472 | (717) 555-1342 |
-- | (286) 555-6063 | (676) 555-6554 |
-- | (770) 555-1861 | (725) 555-3243 |
-- | (031) 555-6622 | (910) 555-3251 |
-- | (826) 555-1652 | (066) 555-9701 |
-- | (338) 555-6650 | (704) 555-2131 |
-- +----------------+----------------+

-- Query 7: Find account numbers of person who withdrew money from Leggett Street on 28th July:
SELECT DISTINCT account_number FROM atm_transactions
JOIN bakery_security_logs ON atm_transactions.year = bakery_security_logs.year
WHERE atm_transactions.atm_location == 'Leggett Street'
AND atm_transactions.year == 2024
AND atm_transactions.month == 7
AND atm_transactions.day == 28
AND bakery_security_logs.hour < 10;

-- REPORT FROM QUERY 7:
-- +----------------+
-- | account_number |
-- +----------------+
-- | 28500762       |
-- | 28296815       |
-- | 76054385       |
-- | 49610011       |
-- | 16153065       |
-- | 86363979       |
-- | 25506511       |
-- | 81061156       |
-- | 26013199       |
-- +----------------+

-- Query 8: Redo Query 2 but between 10:15 and 10:25
SELECT license_plate, minute FROM bakery_security_logs
WHERE hour == 10
AND minute > 15 AND MINUTE < 25
AND activity == 'exit'
ORDER BY minute;

-- REPORT FROM QUERY 8:
-- +---------------+--------+
-- | license_plate | minute |
-- +---------------+--------+
-- | 5P2BI95       | 16     |
-- | PF37ZVK       | 16     |
-- | 94KL13X       | 18     |
-- | 6P58WS2       | 18     |
-- | 4328GD8       | 19     |
-- | G412CB7       | 20     |
-- | 1M92998       | 20     |
-- | L93JTIZ       | 21     |
-- | XE95071       | 21     |
-- | 322W7JE       | 23     |
-- | 0NTHK55       | 23     |
-- | IH61GO8       | 24     |
-- +---------------+--------+


-- Query 9: Look at purchased flights to NYC, find passport number:
SELECT passport_number FROM passengers
JOIN flights ON passengers.flight_id = flights.id
JOIN airports ON flights.destination_airport_id = airports.id
WHERE airports.city == 'New York City'
AND flights.year == 2024
AND flights.month == 7
AND flights.day == 29;

-- REPORT FROM QUERY 9:
-- +-----------------+
-- | passport_number |
-- +-----------------+
-- | 7214083635      |
-- | 1695452385      |
-- | 5773159633      |
-- | 1540955065      |
-- | 8294398571      |
-- | 1988161715      |
-- | 9878712108      |
-- | 8496433585      |
-- +-----------------+

-- Query 10: Collect persons name, phone number, passport number and license plate from account numbers, cross reference other reports:
SELECT name, phone_number, passport_number, license_plate FROM people
JOIN bank_accounts ON people.id = bank_accounts.person_id
WHERE bank_accounts.account_number == 28500762
OR bank_accounts.account_number == 28296815
OR bank_accounts.account_number == 76054385
OR bank_accounts.account_number == 49610011
OR bank_accounts.account_number == 16153065
OR bank_accounts.account_number == 86363979
OR bank_accounts.account_number == 25506511
OR bank_accounts.account_number == 81061156
OR bank_accounts.account_number == 26013199;

-- QUERY 10 REPORT:

-- +---------+----------------+-----------------+---------------+
-- |  name   |  phone_number  | passport_number | license_plate |
-- +---------+----------------+-----------------+---------------+
-- | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
-- | Kaelyn  | (098) 555-1164 | 8304650265      | I449449       |
-- | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
-- | Brooke  | (122) 555-4581 | 4408372428      | QX4YZN3       |
-- | Kenny   | (826) 555-1652 | 9878712108      | 30G67EN       |
-- | Iman    | (829) 555-5269 | 7049073643      | L93JTIZ       |
-- | Luca    | (389) 555-5198 | 8496433585      | 4328GD8       |
-- | Taylor  | (286) 555-6063 | 1988161715      | 1106N58       |
-- | Benista | (338) 555-6650 | 9586786673      | 8X428L0       |
-- +---------+----------------+-----------------+---------------+

-- MATCHES:

-- PASSPORT NO:         PHONE NO:               LICENSE PLATE

-- TAYLOR               TAYLOR                  BRUCE
-- KENNY                DIANA                   LUCA
-- BRUCE                KENNY                   IMAN
-- LUCA                 BENISTA                 DIANA
--                      BRUCE

-- BRUCE IS ONLY PERSON THAT APPEARS ON EACH OF THESE, THEREFORE BRUCE IS THE THIEF.

-- Query 11 - Find Assistant:
SELECT DISTINCT name FROM people
JOIN phone_calls ON people.phone_number = phone_calls.receiver
WHERE phone_calls.receiver == '(375) 555-8161';

-- QUERY 11 REPORT:
-- +-------+
-- | name  |
-- +-------+
-- | Robin |
-- +-------+

-- ROBIN IS THE ASSISTANT

-- CONCLUSION:

-- THIEF: BRUCE
-- ASSISTANT: ROBIN
-- CITY ESCAPED TO: NEW YORK CITY
