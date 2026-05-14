-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema AirportManagementDB
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `AirportManagementDB`;
CREATE SCHEMA `AirportManagementDB`;
USE `AirportManagementDB`;
-- -----------------------------------------------------
-- Table `City`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `City` ;

CREATE TABLE IF NOT EXISTS `City` (
  `city_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(128) NULL,
  `state` VARCHAR(3) NULL,
  `country` VARCHAR(3) NULL,
  `latitude` DECIMAL(8,6) NULL,
  `longitude` DECIMAL(9,6) NULL,
  `altitude` DECIMAL(10,4) NULL,
  `current_weather` ENUM('Sunny', 'Cloudy', 'Rain', 'Snow') NULL,
  `utc_offset` TINYINT NULL,
  PRIMARY KEY (`city_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Airport`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Airport` ;

CREATE TABLE IF NOT EXISTS `Airport` (
  `airport_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `airport_code` VARCHAR(3) NOT NULL,
  `name` VARCHAR(128) NULL,
  `longitude` DECIMAL(9,6) NULL,
  `latitude` DECIMAL(8,6) NULL,
  `altitude` DECIMAL(10,4) NULL,
  `opening_hour` TIME NULL,
  `closing_hour` TIME NULL,
  `city` INT UNSIGNED NULL,
  PRIMARY KEY (`airport_id`),
  UNIQUE INDEX `airport_code_UNIQUE` (`airport_code` ASC) VISIBLE,
  INDEX `FK_AIRPORT_CITY_idx` (`city` ASC) VISIBLE,
  CONSTRAINT `FK_AIRPORT_CITY`
    FOREIGN KEY (`city`)
    REFERENCES `City` (`city_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Terminal`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Terminal` ;

CREATE TABLE IF NOT EXISTS `Terminal` (
  `terminal_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `airport` INT UNSIGNED NOT NULL,
  `name` VARCHAR(128) NULL,
  `opening_hour` TIME NULL,
  `closing_hour` TIME NULL,
  PRIMARY KEY (`terminal_id`),
  INDEX `FK_TERMINAL_AIRPORT_idx` (`airport` ASC) VISIBLE,
  CONSTRAINT `FK_TERMINAL_AIRPORT`
    FOREIGN KEY (`airport`)
    REFERENCES `Airport` (`airport_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Gate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Gate` ;

CREATE TABLE IF NOT EXISTS `Gate` (
  `gate_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `terminal` INT UNSIGNED NULL,
  `gate_number` VARCHAR(10) NULL,
  `gate_type` ENUM('Bridge', 'Tarmac') NULL,
  `aircraft_size` ENUM('Small', 'Medium', 'Large', 'Extra Large') NULL,
  `status` ENUM('Available', 'Plane Docked', 'Unavailable') NULL,
  `opening_hour` TIME NULL,
  `closing_hour` TIME NULL,
  PRIMARY KEY (`gate_id`),
  INDEX `FK_GATE_TERMINAL_idx` (`terminal` ASC) VISIBLE,
  CONSTRAINT `FK_GATE_TERMINAL`
    FOREIGN KEY (`terminal`)
    REFERENCES `Terminal` (`terminal_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Airline`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Airline` ;

CREATE TABLE IF NOT EXISTS `Airline` (
  `airline_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(128) NULL,
  `airline_code` VARCHAR(2) NULL,
  `origin_city` INT UNSIGNED NULL,
  `website` VARCHAR(128) NULL,
  PRIMARY KEY (`airline_id`),
  UNIQUE INDEX `airline_code_UNIQUE` (`airline_code` ASC) VISIBLE,
  INDEX `FK_AIRLINE_ORIGINCITY_idx` (`origin_city` ASC) VISIBLE,
  CONSTRAINT `FK_AIRLINE_ORIGINCITY`
    FOREIGN KEY (`origin_city`)
    REFERENCES `City` (`city_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Hangar`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Hangar` ;

CREATE TABLE IF NOT EXISTS `Hangar` (
  `hangar_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner` INT UNSIGNED NULL,
  `airport` INT UNSIGNED NULL,
  `name` VARCHAR(128) NULL,
  `plane_capacity` TINYINT NULL,
  `opening_hour` TIME NULL,
  `closing_hour` TIME NULL,
  PRIMARY KEY (`hangar_id`),
  INDEX `FK_HANGAR_AIRPORT_idx` (`airport` ASC) VISIBLE,
  INDEX `FK_HANGAR_OWNER_idx` (`owner` ASC) VISIBLE,
  CONSTRAINT `FK_HANGAR_AIRPORT`
    FOREIGN KEY (`airport`)
    REFERENCES `Airport` (`airport_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_HANGAR_OWNER`
    FOREIGN KEY (`owner`)
    REFERENCES `Airline` (`airline_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plane`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Plane` ;

CREATE TABLE IF NOT EXISTS `Plane` (
  `plane_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gate` INT UNSIGNED NULL,
  `hangar` INT UNSIGNED NULL,
  `airline` INT UNSIGNED NULL,
  `tail_number` VARCHAR(5) NOT NULL,
  `aircraft_manufacturer` VARCHAR(128) NULL,
  `aircraft_model` VARCHAR(128) NULL,
  `manufacture_date` DATETIME NULL,
  `seating_capacity` MEDIUMINT UNSIGNED NULL,
  `range` MEDIUMINT UNSIGNED NULL,
  `top_speed` SMALLINT UNSIGNED NULL,
  `last_inspection_date` DATETIME NULL,
  PRIMARY KEY (`plane_id`),
  INDEX `FK_PLANE_GATE_idx` (`gate` ASC) VISIBLE,
  UNIQUE INDEX `tail_number_UNIQUE` (`tail_number` ASC) VISIBLE,
  INDEX `FK_PLANE_HANGAR_idx` (`hangar` ASC) VISIBLE,
  INDEX `FK_PLANE_AIRLINE_idx` (`airline` ASC) VISIBLE,
  CONSTRAINT `FK_PLANE_GATE`
    FOREIGN KEY (`gate`)
    REFERENCES `Gate` (`gate_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PLANE_HANGAR`
    FOREIGN KEY (`hangar`)
    REFERENCES `Hangar` (`hangar_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PLANE_AIRLINE`
    FOREIGN KEY (`airline`)
    REFERENCES `Airline` (`airline_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Runway`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Runway` ;

CREATE TABLE IF NOT EXISTS `Runway` (
  `runway_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `airport` INT UNSIGNED NOT NULL,
  `runway_number` VARCHAR(5) NULL,
  `status` ENUM('Takeoff', 'Landing', 'Available', 'Unavailable') NULL,
  PRIMARY KEY (`runway_id`),
  INDEX `FK_RUNWAY_AIRPORT_idx` (`airport` ASC) VISIBLE,
  CONSTRAINT `FK_RUNWAY_AIRPORT`
    FOREIGN KEY (`airport`)
    REFERENCES `Airport` (`airport_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Flight`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Flight` ;

CREATE TABLE IF NOT EXISTS `Flight` (
  `flight_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `flight_number` VARCHAR(20) NULL,
  `plane` INT UNSIGNED NOT NULL,
  `airline` INT UNSIGNED NOT NULL,
  `takeoff_runway` INT UNSIGNED NOT NULL,
  `landing_runway` INT UNSIGNED NOT NULL,
  `status` ENUM('Upcoming', 'Now Boarding', 'Delayed', 'Cancelled', 'Enroute', 'Taxiing', 'Debaording', 'Complete') NULL,
  `scheduled_departure` DATETIME NULL,
  `scheduled_arrival` DATETIME NULL,
  `actual_departure` DATETIME NULL,
  `acutal_arrival` DATETIME NULL,
  `passenger_count` SMALLINT NULL,
  PRIMARY KEY (`flight_id`),
  UNIQUE INDEX `flight_number_UNIQUE` (`flight_number` ASC) VISIBLE,
  INDEX `FK_FLIGHT_PLANE_idx` (`plane` ASC) VISIBLE,
  INDEX `FK_FLIGHT_AIRLINE_idx` (`airline` ASC) VISIBLE,
  INDEX `FK_FLIGHT_TAKEOFF_idx` (`takeoff_runway` ASC) VISIBLE,
  INDEX `FK_FLIGHT_LANDING_idx` (`landing_runway` ASC) VISIBLE,
  CONSTRAINT `FK_FLIGHT_PLANE`
    FOREIGN KEY (`plane`)
    REFERENCES `Plane` (`plane_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_FLIGHT_AIRLINE`
    FOREIGN KEY (`airline`)
    REFERENCES `Airline` (`airline_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_FLIGHT_TAKEOFF`
    FOREIGN KEY (`takeoff_runway`)
    REFERENCES `Runway` (`runway_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_FLIGHT_LANDING`
    FOREIGN KEY (`landing_runway`)
    REFERENCES `Runway` (`runway_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `User`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `User` ;

CREATE TABLE IF NOT EXISTS `User` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(30) NULL,
  `last_name` VARCHAR(30) NULL,
  `full_name` VARCHAR(64) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) VIRTUAL,
  `email` VARCHAR(64) NULL,
  `password` VARCHAR(20) NULL,
  `date_of_birth` VARCHAR(10) NULL,
  `phone_number` VARCHAR(12) NULL,
  `id_image_url` VARCHAR(128) NULL,
  `id_expiration` DATETIME NULL,
  `passport_image_url` VARCHAR(128) NULL,
  `passport_expiration` DATETIME NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Customer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Customer` ;

CREATE TABLE IF NOT EXISTS `Customer` (
  `customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user` INT UNSIGNED NOT NULL,
  `loyalty_tier` ENUM('Bronze', 'Silver', 'Gold', 'Diamond', 'Emerald', 'Platinum') NULL,
  PRIMARY KEY (`customer_id`),
  INDEX `FK_CUSTOMER_USER_idx` (`user` ASC) VISIBLE,
  CONSTRAINT `FK_CUSTOMER_USER`
    FOREIGN KEY (`user`)
    REFERENCES `User` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Passenger`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Passenger` ;

CREATE TABLE IF NOT EXISTS `Passenger` (
  `passenger_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer` INT UNSIGNED NOT NULL,
  `plane` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`passenger_id`),
  INDEX `FK_PASSENGER_CUSTOMER_idx` (`customer` ASC) VISIBLE,
  INDEX `FK_PASSENGER_PLANE_idx` (`plane` ASC) VISIBLE,
  CONSTRAINT `FK_PASSENGER_CUSTOMER`
    FOREIGN KEY (`customer`)
    REFERENCES `Customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PASSENGER_PLANE`
    FOREIGN KEY (`plane`)
    REFERENCES `Plane` (`plane_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Ticket`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ticket` ;

CREATE TABLE IF NOT EXISTS `Ticket` (
  `ticket_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `flight` INT UNSIGNED NOT NULL,
  `customer` INT UNSIGNED NOT NULL,
  `class` ENUM('Economy', 'Business', 'First') NULL,
  `price` SMALLINT UNSIGNED NULL,
  `purchase_date` DATETIME NULL,
  `assigned_seat` VARCHAR(4) NULL,
  PRIMARY KEY (`ticket_id`),
  INDEX `FK_TICKET_FLIGHT_idx` (`flight` ASC) VISIBLE,
  INDEX `FK_TICKET_CUSTOMER_idx` (`customer` ASC) VISIBLE,
  CONSTRAINT `FK_TICKET_FLIGHT`
    FOREIGN KEY (`flight`)
    REFERENCES `Flight` (`flight_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TICKET_CUSTOMER`
    FOREIGN KEY (`customer`)
    REFERENCES `Customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Luggage_Claim_Belt`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Luggage_Claim_Belt` ;

CREATE TABLE IF NOT EXISTS `Luggage_Claim_Belt` (
  `luggage_claim_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `belt_number` VARCHAR(5) NULL,
  `airport` INT UNSIGNED NULL,
  `last_inspection_date` DATETIME NULL,
  `operating_status` ENUM('Good', 'Offline', 'In Maintainance') NULL,
  `additional_notes` VARCHAR(512) NULL,
  PRIMARY KEY (`luggage_claim_id`),
  INDEX `FK_LUGGAGECLAIMBELT_AIRPORT_idx` (`airport` ASC) VISIBLE,
  CONSTRAINT `FK_LUGGAGECLAIMBELT_AIRPORT`
    FOREIGN KEY (`airport`)
    REFERENCES `Airport` (`airport_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Baggage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Baggage` ;

CREATE TABLE IF NOT EXISTS `Baggage` (
  `baggage_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket` INT UNSIGNED NOT NULL,
  `luggage_claim` INT UNSIGNED NULL,
  `tracking_status` ENUM('Checked', 'On Plane', 'At Claim') NULL,
  `weight` SMALLINT UNSIGNED NULL,
  `height` TINYINT UNSIGNED NULL,
  `length` TINYINT UNSIGNED NULL,
  `width` TINYINT UNSIGNED NULL,
  `last_location` VARCHAR(128) NULL,
  PRIMARY KEY (`baggage_id`),
  INDEX `FK_BAGGAGE_TICKET_idx` (`ticket` ASC) VISIBLE,
  INDEX `FK_BAGGAGE_LUGGAGECLAIMBELT_idx` (`luggage_claim` ASC) VISIBLE,
  CONSTRAINT `FK_BAGGAGE_TICKET`
    FOREIGN KEY (`ticket`)
    REFERENCES `Ticket` (`ticket_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_BAGGAGE_LUGGAGECLAIMBELT`
    FOREIGN KEY (`luggage_claim`)
    REFERENCES `Luggage_Claim_Belt` (`luggage_claim_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Checkin_Machine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Checkin_Machine` ;

CREATE TABLE IF NOT EXISTS `Checkin_Machine` (
  `checkin_machine_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `airport` INT UNSIGNED NULL,
  `software_version` DECIMAL(6,3) NULL,
  `last_inspection_date` DATETIME NULL,
  `operating_status` ENUM('Good', 'Offline', 'In Maintainance') NULL,
  `additional_notes` VARCHAR(512) NULL,
  PRIMARY KEY (`checkin_machine_id`),
  INDEX `FK_CHECKINMACHINE_AIRPORT_idx` (`airport` ASC) VISIBLE,
  CONSTRAINT `FK_CHECKINMACHINE_AIRPORT`
    FOREIGN KEY (`airport`)
    REFERENCES `Airport` (`airport_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Ticket_Machine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ticket_Machine` ;

CREATE TABLE IF NOT EXISTS `Ticket_Machine` (
  `ticket_machine_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `terminal` INT UNSIGNED NULL,
  `gate` INT UNSIGNED NULL,
  `last_inspection_date` DATETIME NULL,
  `operating_status` ENUM('Good', 'Offline', 'In Maintainance') NULL,
  `additional_notes` VARCHAR(512) NULL,
  PRIMARY KEY (`ticket_machine_id`),
  INDEX `FK_TICKETMACHINE_TERMINAL_idx` (`terminal` ASC) VISIBLE,
  INDEX `FK_TICKETMACHINE_GATE_idx` (`gate` ASC) VISIBLE,
  CONSTRAINT `FK_TICKETMACHINE_TERMINAL`
    FOREIGN KEY (`terminal`)
    REFERENCES `Terminal` (`terminal_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TICKETMACHINE_GATE`
    FOREIGN KEY (`gate`)
    REFERENCES `Gate` (`gate_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Employee`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Employee` ;

CREATE TABLE IF NOT EXISTS `Employee` (
  `employee_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(30) NULL,
  `last_name` VARCHAR(30) NULL,
  `full_name` VARCHAR(64) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) VIRTUAL,
  `email` VARCHAR(64) NULL,
  `manager` INT UNSIGNED NULL,
  `role` ENUM('Security PreChecker', 'Flight Crew', 'Ground Crew') NULL,
  PRIMARY KEY (`employee_id`),
  INDEX `FK_EMPLOYEE_MANAGER_idx` (`manager` ASC) VISIBLE,
  CONSTRAINT `FK_EMPLOYEE_MANAGER`
    FOREIGN KEY (`manager`)
    REFERENCES `Employee` (`employee_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Security_PreChecker`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Security_PreChecker` ;

CREATE TABLE IF NOT EXISTS `Security_PreChecker` (
  `security_prechecker_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `monthly_quota` SMALLINT UNSIGNED NULL,
  `monthly_total` SMALLINT UNSIGNED NULL,
  `employee` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`security_prechecker_id`),
  INDEX `FK_SECURITYPRECHECKER_EMPLOYEE_idx` (`employee` ASC) VISIBLE,
  CONSTRAINT `FK_SECURITYPRECHECKER_EMPLOYEE`
    FOREIGN KEY (`employee`)
    REFERENCES `Employee` (`employee_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Notification`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Notification` ;

CREATE TABLE IF NOT EXISTS `Notification` (
  `notification_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user` INT UNSIGNED NULL,
  `customer` INT UNSIGNED NULL,
  `passenger` INT UNSIGNED NULL,
  `message` VARCHAR(1024) NULL,
  `timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`notification_id`),
  INDEX `FK_NOTIFICATION_USER_idx` (`user` ASC) VISIBLE,
  INDEX `FK_NOTIFICATION_CUSTOMER_idx` (`customer` ASC) VISIBLE,
  INDEX `FK_NOTIFICATION_PASSENGER_idx` (`passenger` ASC) VISIBLE,
  CONSTRAINT `FK_NOTIFICATION_USER`
    FOREIGN KEY (`user`)
    REFERENCES `User` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NOTIFICATION_CUSTOMER`
    FOREIGN KEY (`customer`)
    REFERENCES `Customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NOTIFICATION_PASSENGER`
    FOREIGN KEY (`passenger`)
    REFERENCES `Passenger` (`passenger_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Checked_In`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Checked_In` ;

CREATE TABLE IF NOT EXISTS `Checked_In` (
  `checkin_machine` INT UNSIGNED NOT NULL,
  `customer` INT UNSIGNED NOT NULL,
  `timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`checkin_machine`, `customer`),
  INDEX `PKFK_CHECKEDIN_CUSTOMER_idx` (`customer` ASC) VISIBLE,
  CONSTRAINT `PKFK_CHECKEDIN_CHECKINMACHINE`
    FOREIGN KEY (`checkin_machine`)
    REFERENCES `Checkin_Machine` (`checkin_machine_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `PKFK_CHECKEDIN_CUSTOMER`
    FOREIGN KEY (`customer`)
    REFERENCES `Customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Ticket_Scanned`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ticket_Scanned` ;

CREATE TABLE IF NOT EXISTS `Ticket_Scanned` (
  `ticket_machine` INT UNSIGNED NOT NULL,
  `ticket` INT UNSIGNED NOT NULL,
  `timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`ticket_machine`, `ticket`),
  INDEX `PKFK_TICKETSCANNED_TICKET_idx` (`ticket` ASC) VISIBLE,
  CONSTRAINT `PKFK_TICKETSCANNED_TICKETMACHINE`
    FOREIGN KEY (`ticket_machine`)
    REFERENCES `Ticket_Machine` (`ticket_machine_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `PKFK_TICKETSCANNED_TICKET`
    FOREIGN KEY (`ticket`)
    REFERENCES `Ticket` (`ticket_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Security_Approved`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Security_Approved` ;

CREATE TABLE IF NOT EXISTS `Security_Approved` (
  `security` INT UNSIGNED NOT NULL,
  `customer` INT UNSIGNED NOT NULL,
  `timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`security`, `customer`),
  INDEX `PKFK_SECURITYAPPROVED_CUSTOMER_idx` (`customer` ASC) VISIBLE,
  CONSTRAINT `PKFK_SECURITYAPPROVED_SECURITY`
    FOREIGN KEY (`security`)
    REFERENCES `Security_PreChecker` (`security_prechecker_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `PKFK_SECURITYAPPROVED_CUSTOMER`
    FOREIGN KEY (`customer`)
    REFERENCES `Customer` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
