USE `AirportManagementDB`;
/*
     Business Requirement #1
     ----------------------------------------------------
     Purpose: Dynamic Security Precheck Customer Allocation Based on Monthly Quota
     
     Description: The system needs to handle the security prechecks as quickly as possible, which is why each
				  each security prechecker has a monthly quota to meet. If a security prechecker is behind on their
                  quota, the system will dynamically allocate customers to the prechecker with the lowest pending count
                  so they know what to work on next, keeping a steady work flow.
     Challenge:   The system needs to dynamically allocate customers to the security prechecker with the lowest pending count.
     
     Implementation Plan:
        1. QuotaStatus CTE
			a. Aggregates the count of pending passengers for each security prechecker.
            b. Compares the pending count against the monthly quota to determine:
				Reached Quota: Pending exceeds quota.
				Approaching Quota: Pending is between 80-100% of the quota.
				Under Quota: Pending is below 80% of the quota.
        2. PendingPreCheck CTE
			a. Filter Customers who are not in the Security Approved Table. 
            b. Associate a customer with a security prechecker based on the prechecker's monthly quota status.
		3. Display The Customer ID, Customer Full Name, Security Prechecker ID, and Security Prechecker Full Name.
  
  */
WITH QuotaStatus AS (
    SELECT 
        Security_PreChecker.security_prechecker_id,
        Security_PreChecker.monthly_quota,
        COUNT(Security_Approved.customer) AS pending_count,
        CASE
            WHEN COUNT(Security_Approved.customer) >= Security_PreChecker.monthly_quota THEN 'Reached Quota'
            WHEN COUNT(Security_Approved.customer) >= (Security_PreChecker.monthly_quota * 0.8) THEN 'Approaching Quota'
            ELSE 'Under Quota'
        END AS quota_status
    FROM Security_PreChecker
    LEFT JOIN Security_Approved ON Security_PreChecker.security_prechecker_id = Security_Approved.security
    GROUP BY Security_PreChecker.security_prechecker_id
),
PendingPreCheck AS (
    SELECT 
        Customer.customer_id,
        User.full_name AS customer_full_name,
        Security_PreChecker.security_prechecker_id,
        Employee.full_name AS security_prechecker_full_name
    FROM Customer
    JOIN User ON Customer.user = User.user_id
    JOIN Security_PreChecker ON Customer.customer_id % (SELECT COUNT(*) FROM Security_PreChecker) = Security_PreChecker.security_prechecker_id
    JOIN Employee ON Security_PreChecker.security_prechecker_id = Employee.employee_id
    WHERE Customer.customer_id NOT IN (SELECT customer FROM Security_Approved)
)
SELECT 
	PendingPreCheck.security_prechecker_id AS `Security ID`,
    PendingPreCheck.security_prechecker_full_name AS `Security Name`,
    PendingPreCheck.customer_id AS `Customer ID`,
    PendingPreCheck.customer_full_name AS `Customer Name`
FROM PendingPreCheck
JOIN QuotaStatus ON PendingPreCheck.security_prechecker_id = QuotaStatus.security_prechecker_id;
/*
     Business Requirement #2
     ----------------------------------------------------
     Purpose: PreCheck Efficiency Scoring
     Description: Generate a monthly report on total processed passengers, average wait times, and employee performance.
     Challenge:   Aggregates data across multiple tables (Passenger, Ticket, Security_PreChecker) and perform advanced analytics.
    Implementation Plan:
            1. ApprovedPassenger CTE
                a. Join the Security_Approved table and the first instance of Ticket that the customer purchased.
            2. PreCheckEfficiency CTE
                a. Calculate the time waited for approval (approval date - purchase date) and average the wait times.
                b. Group the data by security prechecker and calculate the total processed passengers.
			3. Get Quota Status
            4. Display the Security ID, Security Name, Total Processed Passengers, and Average Wait Time in order of performance (lowest avg wait time)
*/
WITH ApprovedPassenger AS (
    SELECT 
        Security_Approved.security,
        Security_Approved.customer,
        Security_Approved.timestamp AS approval_date,
        Ticket.purchase_date
    FROM Security_Approved
    JOIN Ticket ON Security_Approved.customer = Ticket.customer
),
PreCheckEfficiency AS (
    SELECT 
        Security_PreChecker.security_prechecker_id AS security_id,
        Employee.full_name AS security_name,
        COUNT(ApprovedPassenger.customer) AS total_processed,
        AVG(TIMESTAMPDIFF(HOUR, Ticket.purchase_date, Security_Approved.timestamp)) AS avg_wait_time
    FROM Security_PreChecker
    JOIN Employee ON Security_PreChecker.security_prechecker_id = Employee.employee_id
    JOIN ApprovedPassenger ON Security_PreChecker.security_prechecker_id = ApprovedPassenger.security
    JOIN Ticket ON ApprovedPassenger.customer = Ticket.customer
    JOIN Security_Approved ON ApprovedPassenger.customer = Security_Approved.customer
    GROUP BY Security_PreChecker.security_prechecker_id
),
QuotaStatus AS (
    SELECT 
        Security_PreChecker.security_prechecker_id,
        Security_PreChecker.monthly_quota,
        COUNT(Security_Approved.customer) AS pending_count,
        CASE
            WHEN COUNT(Security_Approved.customer) >= Security_PreChecker.monthly_quota THEN 'Reached Quota'
            WHEN COUNT(Security_Approved.customer) >= (Security_PreChecker.monthly_quota * 0.8) THEN 'Approaching Quota'
            ELSE 'Under Quota'
        END AS quota_status
    FROM Security_PreChecker
    LEFT JOIN Security_Approved ON Security_PreChecker.security_prechecker_id = Security_Approved.security
    GROUP BY Security_PreChecker.security_prechecker_id
)
SELECT 
    PreCheckEfficiency.security_id AS `Security ID`,
    PreCheckEfficiency.security_name AS `Security Name`,
    PreCheckEfficiency.total_processed AS `Total Processed Passengers`,
    QuotaStatus.quota_status AS `Quota Status`,
    ROUND(PreCheckEfficiency.avg_wait_time, 2) AS `Average Wait Time (Hours)`
FROM PreCheckEfficiency
JOIN QuotaStatus ON PreCheckEfficiency.security_id = QuotaStatus.security_prechecker_id
ORDER BY PreCheckEfficiency.avg_wait_time ASC, PreCheckEfficiency.total_processed DESC;
/*
     Business Requirement #3
     ----------------------------------------------------
     Purpose: Automated Check-In System
        Description: When a customer checks in at a check-in machine, the system will automatically check them in for their flight.
                     The system checks if the customers ticket is for a flight at the current airport and if the flight is upcoming.
                     If So, They get added to the passenger list and receive a notification.
        Challenge:   The system needs to automatically check in customers based on their ticket and flight status.
        Implementation Plan:
            1. Trigger for Checked_In Table insertion
                a. Check if the ticket is for a flight at the current airport.
                b. Check if the flight is upcoming.
                c. Insert the customer into the Checked_In Table.
                d. Send a notification to the customer that includes:
                    i. The timestamp of the check-in.
                    ii. The flight number.
                    iii. gate number.
            2. Display the Customer ID, Customer Full Name, and Timestamp of the Check-In, and notification message.
*/
DELIMITER $$
DROP TRIGGER IF EXISTS CheckInAutomated$$
CREATE TRIGGER CheckInAutomated 
AFTER INSERT ON Checked_In
FOR EACH ROW
BEGIN
    DECLARE flight_id INT;
    DECLARE flight_number VARCHAR(20);
    DECLARE gate_number VARCHAR(10);
    DECLARE timestamp TIMESTAMP;
    DECLARE message VARCHAR(1024);
    
    SELECT 
        Flight.flight_id, 
        Flight.flight_number, 
        Gate.gate_number, 
        NEW.timestamp
    INTO 
        flight_id, 
        flight_number, 
        gate_number, 
        timestamp
    FROM Flight
    JOIN Ticket ON Flight.flight_id = Ticket.flight
    JOIN Gate ON Flight.landing_runway = Gate.gate_id
    WHERE Ticket.customer = NEW.customer
    AND Flight.status = 'Upcoming'
    LIMIT 1;
    
    INSERT INTO Passenger (customer, plane) 
    VALUES (NEW.customer, (SELECT plane FROM Flight WHERE flight_id = flight_id LIMIT 1));
    
    SET message = CONCAT('You have been checked in for flight ', flight_number, ' at gate ', gate_number, '.');
    
    INSERT INTO Notification (user, customer, message, timestamp) 
    VALUES (
        (SELECT user FROM Customer WHERE customer_id = NEW.customer LIMIT 1), 
        NEW.customer, 
        message, 
        timestamp
    );
END$$
DELIMITER ;
-- Test the Trigger
INSERT INTO `User` (`first_name`, `last_name`, `email`, `password`, `date_of_birth`, `phone_number`, `id_image_url`, `id_expiration`, `passport_image_url`, `passport_expiration`) VALUES
('Mister', 'Grader', 'johndoe@exaple.com', 'password123', '1990-01-01', '5551234563', 'images/john_id.jpg', '2025-01-01 12:00:00', 'images/john_passport.jpg', '2030-01-01 12:00:00');
INSERT INTO `Customer` (`user`, `loyalty_tier`) VALUES
(7, 'Gold');
INSERT INTO `Flight` (`flight_number`, `plane`, `airline`, `takeoff_runway`, `landing_runway`, `status`, `scheduled_departure`, `scheduled_arrival`, `actual_departure`, `acutal_arrival`, `passenger_count`) VALUES
('AA500', 1, 1, 1, 2, 'Upcoming', NOW() + INTERVAL 1 HOUR, NOW() + INTERVAL 4 HOUR, NULL, NULL, 150);
INSERT INTO `Ticket` (`flight`, `customer`, `class`, `price`, `purchase_date`, `assigned_seat`) VALUES
(4, 6, 'Economy', 200, NOW(), '12A');
INSERT INTO `Checked_In` (`checkin_machine`, `customer`, `timestamp`) VALUES
(1, 6, NOW());
SELECT 
    Customer.customer_id AS `Customer ID`,
    User.full_name AS `Customer Name`,
    Checked_In.timestamp AS `Check-In Timestamp`,
    Notification.message AS `Notification Message`
FROM Checked_In
JOIN Customer ON Checked_In.customer = Customer.customer_id
JOIN User ON Customer.user = User.user_id
JOIN Notification ON Customer.customer_id = Notification.customer
WHERE Customer.customer_id = 6;
/*
     Business Requirement #4
     ----------------------------------------------------
     Purpose: Flight Display System
        Description: The system needs to display the status of all flights at the airport, including the flight number, airline, 
                     takeoff runway, landing runway, and status for the flights after the current time, in order of scheduled departure time.
                     The system should also display the number of passengers on each flight.
        Challenge:   The system needs to display the status of all flights at the airport, including the number of passengers on each flight.
        Implementation Plan:
            1. FlightStatus CTE
                a. Join the Flight, Airline, Runway, and Passenger tables to get the flight status.
                b. Count the number of passengers on each flight.
            2. Display the Flight Number, Airline Name, Departure City, Arrival City, Status, and Passenger Count.
*/
WITH FlightStatus AS (
    SELECT 
        Flight.flight_number AS `Flight Number`,
        Airline.name AS `Airline Name`,
        (SELECT City.name FROM City WHERE City.city_id = (SELECT Airport.city FROM Airport WHERE Airport.airport_id = (SELECT Runway.airport FROM Runway WHERE Runway.runway_id = Flight.takeoff_runway))) AS `Departure City`,
        (SELECT City.name FROM City WHERE City.city_id = (SELECT Airport.city FROM Airport WHERE Airport.airport_id = (SELECT Runway.airport FROM Runway WHERE Runway.runway_id = Flight.landing_runway))) AS `Arrival City`,
        Flight.status AS `Status`,
        COUNT(Passenger.customer) AS `Passenger Count`
    FROM Flight
    JOIN Airline ON Flight.airline = Airline.airline_id
    JOIN Runway ON Flight.takeoff_runway = Runway.runway_id
    JOIN Passenger ON Flight.flight_id = Passenger.plane
    WHERE Flight.scheduled_departure > NOW()
    GROUP BY Flight.flight_id
)
SELECT 
    FlightStatus.`Flight Number`,
    FlightStatus.`Airline Name`,
    FlightStatus.`Departure City`,
    FlightStatus.`Arrival City`,
    FlightStatus.`Status`,
    FlightStatus.`Passenger Count`
FROM FlightStatus
ORDER BY FlightStatus.`Status`, FlightStatus.`Passenger Count` DESC;
/*
     Business Requirement #5
     ----------------------------------------------------
     Purpose: Automated Flight Status Change Notification
        Description: When a flight status changes, the system will automatically send a notification to all customers who are passengers on the flight.
        Challenge:   The system needs to automatically send notifications to all passengers on a flight when the flight status changes.
        Implementation Plan:
            1. Trigger for Notification Table insertion
                a. Check if the flight status has changed.
                b. Get the passengers on the flight.
                c. Send a notification to each customer who has a ticket for that flight that includes:
                    i. The timestamp of the status change.
                    ii. The new status of the flight.
            2. Display the Customer ID, Customer Full Name, and Notification Message.
*/
DELIMITER $$
DROP TRIGGER IF EXISTS FlightStatusChangeNotification$$
CREATE TRIGGER FlightStatusChangeNotification
AFTER UPDATE ON Flight
FOR EACH ROW
BEGIN
    DECLARE message VARCHAR(1024);
    
    IF OLD.status != NEW.status THEN
        SELECT 
            CONCAT('The status of flight ', NEW.flight_number, ' has changed to ', NEW.status, '.') 
        INTO message;
        
        INSERT INTO Notification (user, customer, message, timestamp) 
        SELECT 
            User.user_id, 
            Customer.customer_id, 
            message, 
            NOW()
        FROM Ticket
        JOIN Customer ON Ticket.customer = Customer.customer_id
        JOIN User ON Customer.user = User.user_id
        WHERE Ticket.flight = NEW.flight_id;
    END IF;
END$$
DELIMITER ;
-- Test the Trigger
UPDATE Flight SET status = 'Now Boarding' WHERE flight_id = 4;
UPDATE Flight SET status = 'Delayed' WHERE flight_id = 4;
UPDATE Flight SET status = 'Cancelled' WHERE flight_id = 4;
SELECT 
    Customer.customer_id AS `Customer ID`,
    User.full_name AS `Customer Name`,
    Notification.message AS `Notification Message`
FROM Notification
JOIN Customer ON Notification.customer = Customer.customer_id
JOIN User ON Customer.user = User.user_id
WHERE Customer.customer_id = 6;