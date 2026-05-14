USE `AirportManagementDB`;

-- Insert sample data for `City`
INSERT INTO `City` (`name`, `state`, `country`, `latitude`, `longitude`, `altitude`, `current_weather`, `utc_offset`) VALUES
('New York', 'NY', 'US', 40.7128, -74.0060, 33.0, 'Sunny', -5),
('Los Angeles', 'CA', 'US', 34.0522, -118.2437, 71.0, 'Cloudy', -8),
('London', 'ENG', 'GB', 51.5074, -0.1278, 35.0, 'Rain', 0);

-- Insert sample data for `Airport`
INSERT INTO `Airport` (`airport_code`, `name`, `longitude`, `latitude`, `altitude`, `opening_hour`, `closing_hour`, `city`) VALUES
('JFK', 'John F. Kennedy International Airport', -73.7781, 40.6413, 13.0, '05:00:00', '23:59:59', 1),
('LAX', 'Los Angeles International Airport', -118.4070, 33.9416, 38.0, '06:00:00', '22:00:00', 2),
('LHR', 'Heathrow Airport', -0.4543, 51.4700, 25.0, '04:00:00', '23:59:59', 3);

-- Insert sample data for `Terminal`
INSERT INTO `Terminal` (`airport`, `name`, `opening_hour`, `closing_hour`) VALUES
(1, 'Terminal 1', '05:00:00', '23:59:59'),
(2, 'Terminal 2', '06:00:00', '22:00:00'),
(3, 'Terminal 5', '04:00:00', '23:59:59');

-- Insert sample data for `Gate`
INSERT INTO `Gate` (`terminal`, `gate_number`, `gate_type`, `aircraft_size`, `status`, `opening_hour`, `closing_hour`) VALUES
(1, 'G1', 'Bridge', 'Medium', 'Available', '05:00:00', '23:59:59'),
(2, 'G2', 'Tarmac', 'Small', 'Plane Docked', '06:00:00', '22:00:00'),
(3, 'G3', 'Bridge', 'Large', 'Unavailable', '04:00:00', '23:59:59');

-- Insert sample data for `Airline`
INSERT INTO `Airline` (`name`, `airline_code`, `origin_city`, `website`) VALUES
('American Airlines', 'AA', 1, 'http://www.aa.com'),
('Delta Airlines', 'DL', 2, 'http://www.delta.com'),
('British Airways', 'BA', 3, 'http://www.britishairways.com');

-- Insert sample data for `Hangar`
INSERT INTO `Hangar` (`owner`, `airport`, `name`, `plane_capacity`, `opening_hour`, `closing_hour`) VALUES
(1, 1, 'Hangar A', 20, '05:00:00', '23:59:59'),
(2, 2, 'Hangar B', 15, '06:00:00', '22:00:00'),
(3, 3, 'Hangar C', 30, '04:00:00', '23:59:59');

-- Insert sample data for `Plane`
INSERT INTO `Plane` (`gate`, `hangar`, `airline`, `tail_number`, `aircraft_manufacturer`, `aircraft_model`, `manufacture_date`, `seating_capacity`, `range`, `top_speed`, `last_inspection_date`) VALUES
(1, 1, 1, 'N13', 'Boeing', '737', '2015-04-15 10:30:00', 150, 3000, 600, '2023-12-01 09:00:00'),
(2, 2, 2, 'N67', 'Airbus', 'A320', '2018-08-22 15:45:00', 180, 2500, 500, '2023-11-20 11:00:00'),
(3, 3, 3, 'N11', 'Boeing', '777', '2012-05-10 12:10:00', 300, 8000, 650, '2023-12-05 14:00:00');

-- Insert sample data for `Runway`
INSERT INTO `Runway` (`airport`, `runway_number`, `status`) VALUES
(1, 'R1', 'Takeoff'),
(2, 'R2', 'Landing'),
(3, 'R3', 'Available');

-- Insert sample data for `Flight`
INSERT INTO `Flight` (`flight_number`, `plane`, `airline`, `takeoff_runway`, `landing_runway`, `status`, `scheduled_departure`, `scheduled_arrival`, `actual_departure`, `acutal_arrival`, `passenger_count`) VALUES
('AA100', 1, 1, 1, 2, 'Upcoming', '2024-12-07 09:00:00', '2024-12-07 12:00:00', NULL, NULL, 150),
('DL200', 2, 2, 2, 3, 'Now Boarding', '2024-12-07 14:00:00', '2024-12-07 17:00:00', '2024-12-07 13:50:00', '2024-12-07 16:50:00', 180),
('BA300', 3, 3, 3, 1, 'Delayed', NOW() + INTERVAL 1 HOUR, NOW() + INTERVAL 5 HOUR, '2024-12-07 17:30:00', NULL, 300);

-- Insert sample data for `User`
INSERT INTO `User` (`first_name`, `last_name`, `email`, `password`, `date_of_birth`, `phone_number`, `id_image_url`, `id_expiration`, `passport_image_url`, `passport_expiration`) VALUES
('John', 'Doe', 'johndoe@example.com', 'password123', '1990-01-01', '5551234567', 'images/john_id.jpg', '2025-01-01 12:00:00', 'images/john_passport.jpg', '2030-01-01 12:00:00'),
('Jane', 'Smith', 'janesmith@example.com', 'securepass', '1985-05-15', '5552345678', 'images/jane_id.jpg', '2026-05-15 12:00:00', 'images/jane_passport.jpg', '2031-05-15 12:00:00'),
('Mark', 'Johnson', 'markjohnson@example.com', 'mypassword', '1982-07-30', '5553436789', 'images/mark_id.jpg', '2027-07-30 12:00:00', 'images/mark_passport.jpg', '2032-07-30 12:00:00'),
('Alice', 'Brown', 'alicebrown@example.com', 'password123', '1990-01-01', '5551284567', 'images/alice_id.jpg', '2025-01-01 12:00:00', 'images/alice_passport.jpg', '2030-01-01 12:00:00'),
('Bob', 'White', 'bobwhite@example.com', 'securepass', '1985-05-15', '5552745678', 'images/bob_id.jpg', '2026-05-15 12:00:00', 'images/bob_passport.jpg', '2031-05-15 12:00:00'),
('Charlie', 'Black', 'charlieblack@example.com', 'mypassword', '1982-07-30', '5553459789', 'images/charlie_id.jpg', '2027-07-30 12:00:00', 'images/charlie_passport.jpg', '2032-07-30 12:00:00');

-- Insert sample data for `Customer`
INSERT INTO `Customer` (`user`, `loyalty_tier`) VALUES
(1, 'Gold'),
(2, 'Platinum'),
(3, 'Silver'),
(4, 'Gold'),
(5, 'Platinum');

-- Insert sample data for `Passenger`
INSERT INTO `Passenger` (`customer`, `plane`) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insert sample data for `Ticket`
INSERT INTO `Ticket` (`flight`, `customer`, `class`, `price`, `purchase_date`, `assigned_seat`) VALUES
(1, 1, 'Economy', 200, '2024-12-01 10:00:00', '12A'),
(2, 2, 'Business', 500, '2024-12-02 12:00:00', '2B'),
(3, 3, 'First', 1000, '2024-12-03 14:00:00', '1A'),
(1, 4, 'Economy', 200, '2024-12-01 10:00:00', '12A'),
(2, 5, 'Business', 500, '2024-12-02 12:00:00', '2B');

-- Insert sample data for `Luggage_Claim_Belt`
INSERT INTO `Luggage_Claim_Belt` (`belt_number`, `airport`, `last_inspection_date`, `operating_status`, `additional_notes`) VALUES
('B1', 1, '2024-12-01 09:00:00', 'Good', 'None'),
('B2', 2, '2024-12-02 10:00:00', 'Offline', 'Under Maintainance'),
('B3', 3, '2024-12-03 11:00:00', 'In Maintainance', 'Scheduled for inspection');

-- Insert sample data for `Baggage`
INSERT INTO `Baggage` (`ticket`, `luggage_claim`, `tracking_status`, `weight`, `height`, `length`, `width`, `last_location`) VALUES
(1, 1, 'Checked', 50, 20, 30, 40, 'JFK'),
(2, 2, 'On Plane', 30, 15, 25, 35, 'LAX'),
(3, 3, 'At Claim', 70, 25, 35, 45, 'LHR');

-- Insert sample data for `Checkin_Machine`
INSERT INTO `Checkin_Machine` (`airport`, `software_version`, `last_inspection_date`, `operating_status`, `additional_notes`) VALUES
(1, 1.000, '2024-12-01 09:00:00', 'Good', 'None'),
(2, 1.100, '2024-12-02 10:00:00', 'Offline', 'Under Maintainance'),
(3, 1.200, '2024-12-03 11:00:00', 'In Maintainance', 'Scheduled for inspection');

-- Insert sample data for `Ticket_Machine`
INSERT INTO `Ticket_Machine` (`terminal`, `gate`, `last_inspection_date`, `operating_status`, `additional_notes`) VALUES
(1, 1, '2024-12-01 09:00:00', 'Good', 'None'),
(2, 2, '2024-12-02 10:00:00', 'Offline', 'Under Maintainance'),
(3, 3, '2024-12-03 11:00:00', 'In Maintainance', 'Scheduled for inspection');

-- Insert sample data for `Employee`
INSERT INTO `Employee` (`first_name`, `last_name`, `email`, `manager`, `role`) VALUES
('Alice', 'Smith', 'testmail@mail.com', NULL, 'Security PreChecker'),
('Bob', 'Johnson', 'bobjohnson@mail.com', 1, 'Flight Crew'),
('Charlie', 'Doe', 'charliedoe@mail.com', 1, 'Ground Crew');

-- Insert sample data for `Security_PreChecker`
INSERT INTO `Security_PreChecker` (`monthly_quota`, `monthly_total`, `employee`) VALUES
(100, 50, 1),
(100, 75, 2),
(100, 25, 3);

-- Insert sample data for `Notification`
INSERT INTO `Notification` (`user`, `customer`, `passenger`, `message`, `timestamp`) VALUES
(1, 1, 1, 'Your flight is boarding soon', '2024-12-07 11:00:00'),
(2, 2, 2, 'Your flight is delayed', '2024-12-07 16:00:00'),
(3, 3, 3, 'Your flight is cancelled', '2024-12-07 20:00:00');

-- Insert sample data for `Checked_In`
INSERT INTO `Checked_In` (`checkin_machine`, `customer`, `timestamp`) VALUES
(1, 1, '2024-12-07 10:00:00'),
(2, 2, '2024-12-07 15:00:00'),
(3, 3, '2024-12-07 19:00:00');

-- Insert sample data for `Ticket_Scanned`
INSERT INTO `Ticket_Scanned` (`ticket_machine`, `ticket`, `timestamp`) VALUES
(1, 1, '2024-12-07 10:30:00'),
(2, 2, '2024-12-07 15:30:00'),
(3, 3, '2024-12-07 19:30:00');

-- Insert sample data for `Security_Approved`
INSERT INTO `Security_Approved` (`security`, `customer`, `timestamp`) VALUES
(1, 1, '2024-12-07 10:45:00'),
(2, 2, '2024-12-07 15:45:00'),
(3, 3, '2024-12-07 19:45:00');