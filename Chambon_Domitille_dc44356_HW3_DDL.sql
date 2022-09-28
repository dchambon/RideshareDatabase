-- DROP TABLES SECTION
-- Area of the script that drops all tables and sequences in proper order
-- Author: Domitille Chambon (dc44356)
BEGIN

--Deletes all user created sequences
FOR i IN (SELECT us.sequence_name FROM USER_SEQUENCES us) LOOP
EXECUTE IMMEDIATE 'drop sequence '|| i.sequence_name ||'';
END LOOP;

--Deletes all user created tables
FOR i IN (SELECT ut.table_name FROM USER_TABLES ut) LOOP
EXECUTE IMMEDIATE 'drop table '|| i.table_name ||' CASCADE CONSTRAINTS 
';
END LOOP;
END;
/

-- CREATE TABLES SECTION
-- Area of the script that creates tables/sequences and adds constraints either via CREATE or ALTER TABLE statements
-- Author: Domitille Chambon (dc44356)

-- Sequence for driver_ID
CREATE SEQUENCE sequence_driver_ID
MINVALUE 100001
MAXVALUE 999999999
START WITH 100001
INCREMENT BY 1;

-- Driver table
CREATE TABLE Driver
(
    driver_ID               number         default sequence_driver_ID.NEXTVAL primary key,
    first_name              varchar(40)    not null,
    last_name               varchar(40)    not null,
    address                 varchar(40)    not null,
    city                    varchar(40)    not null,
    state                   char(2)        not null,
    zip                     char(5)        not null,
    phone                   char(12)       not null,
    email                   varchar(40)    not null unique,
    dob                     date           not null,
    drivers_license_num     varchar(40)    not null unique,
    CONSTRAINT email_length_check CHECK (LENGTH(email) >= 7)
);

-- Index for Driver table driver last name
CREATE INDEX driver_last_name
ON Driver (last_name);

-- Sequence for bank_account_ID
CREATE SEQUENCE sequence_bank_account_ID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1;

-- Bank_Account table
CREATE TABLE Bank_Account
(
    bank_account_ID         number          default sequence_bank_account_ID.NEXTVAL primary key,
    driver_ID               number          not null unique,
    routing_number          char(9)         not null,
    account_number          varchar(40)     not null,
    CONSTRAINT bank_account_fk_driver FOREIGN KEY (driver_ID) REFERENCES Driver (driver_ID)
);

-- Sequence for vehicle_ID
CREATE SEQUENCE sequence_vehicle_ID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1;

-- Vehicle table
CREATE TABLE Vehicle
(
    vehicle_ID              number          default sequence_vehicle_ID.NEXTVAL primary key,
    year                    varchar(40)     not null,
    make                    varchar(40)     not null,
    model                   varchar(40)     not null,
    color                   varchar(40)     not null,
    VIN                     char(17)        not null unique,
    plate_number            varchar(40)     not null unique,           
    insurance_company       varchar(40)     not null,
    insurance_policy_num    varchar(40)     not null,
    inspection_exp_date     date            not null
);

-- Vehicle_Driver_Linking table
CREATE TABLE Vehicle_Driver_Linking
(
    driver_ID               number          not null,
    vehicle_ID              number          not null,
    active_vehicle_flag     char(1)         not null,
    CONSTRAINT line_items_pk PRIMARY KEY (driver_ID, vehicle_ID),
    CONSTRAINT vehicle_driver_fk_driver FOREIGN KEY (driver_ID) REFERENCES Driver (driver_ID),
    CONSTRAINT vehicle_driver_fk_vehicle FOREIGN KEY (vehicle_ID) REFERENCES Vehicle (vehicle_ID),
    CONSTRAINT flag_check CHECK (active_vehicle_flag = 'Y' or active_vehicle_flag = 'N')
);

-- Sequence for rider_ID
CREATE SEQUENCE sequence_rider_ID
MINVALUE 3000001
MAXVALUE 999999999
START WITH 3000001
INCREMENT BY 1;

-- Rider table
CREATE TABLE Rider
(
    rider_ID                number          default sequence_rider_ID.NEXTVAL primary key,
    first_name              varchar(40)     not null,
    last_name               varchar(40)     not null,
    email                   varchar(40)     not null unique,
    phone                   char(12)        not null,
    address                 varchar(40)     not null,
    city                    varchar(40)     not null,
    zip                     char(5)         not null,
    CONSTRAINT email_length_check2 CHECK (LENGTH(email) >= 7)
);

-- Index for Rider table rider last name
CREATE INDEX rider_last_name
ON Rider (last_name);

-- Sequence for payment_ID
CREATE SEQUENCE sequence_payment_ID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1;

-- Rider_Payment table
CREATE TABLE Rider_Payment
(
    payment_ID              number          default sequence_payment_ID.NEXTVAL primary key,
    rider_ID                number          not null,
    cardholder_first_name   varchar(40)     not null,
    cardholder_mid_name     varchar(40)     ,
    cardholder_last_name    varchar(40)     not null,
    cardtype                char(4)         not null,
    cardnumber              char(16)        not null,
    expiration_date         date            not null,
    CC_ID                   char(3)         not null,
    billing_address         varchar(40)     not null,
    billing_city            varchar(40)     not null,
    billing_state           char(2)         not null,
    billing_zip             char(5)         not null,
    primary_card_flag       char(1)         not null,
    CONSTRAINT flag_check2 CHECK (primary_card_flag = 'Y' or primary_card_flag = 'N'),
    CONSTRAINT rider_payment_fk_rider FOREIGN KEY (rider_ID) REFERENCES Rider (rider_ID)
);

-- Index for Rider_Payment table foreign key
CREATE INDEX rider_payment_rider_ID
ON Rider_Payment (rider_ID);

-- Sequence for discount_ID
CREATE SEQUENCE sequence_discount_ID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1;

-- Discounts table
CREATE TABLE Discounts
(
    discount_ID             number          default sequence_discount_ID.NEXTVAL primary key,
    rider_ID                number          not null,
    discount_type           varchar(40)     not null,
    discount_percent        number          not null,
    used_flag               char(1)         default 'N',
    expiration_date         date            default (sysdate + 30),
    CONSTRAINT flag_check3 CHECK (used_flag = 'Y' or used_flag = 'N'),
    CONSTRAINT discounts_fk_rider FOREIGN KEY (rider_ID) REFERENCES Rider (rider_ID)
);

-- Index for Discounts table foreign key
CREATE INDEX discounts_rider_ID
ON Discounts (rider_ID);

-- Sequence for ride_ID
CREATE SEQUENCE sequence_ride_ID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1;

-- Ride table
CREATE TABLE Ride
(
    ride_ID                 number          default sequence_ride_ID.NEXTVAL primary key,
    driver_ID               number          not null,
    rider_ID                number          not null,
    vehicle_ID              number          not null,
    pickup_address          varchar(40)     not null,
    dropoff_address         varchar(40)     not null,
    request_datetime        date            default sysdate,
    start_datetime          varchar(40)     ,
    end_datetime            varchar(40)     ,
    initial_fare            number          ,
    discount_amount         number          ,
    final_fare              number          ,
    rating                  number          ,
    CONSTRAINT ride_fk_driver FOREIGN KEY (driver_ID) REFERENCES Driver (driver_ID),
    CONSTRAINT ride_fk_rider FOREIGN KEY (rider_ID) REFERENCES Rider (rider_ID),
    CONSTRAINT ride_fk_vehicle FOREIGN KEY (vehicle_ID) REFERENCES Vehicle (vehicle_ID),
    CONSTRAINT fare_check CHECK (final_fare = (initial_fare - discount_amount))
);

-- Index for Ride table foreign keys
CREATE INDEX ride_driver_ID
ON Ride (driver_ID);

CREATE INDEX ride_rider_ID 
ON Ride (rider_ID);

CREATE INDEX ride_vehicle_ID
ON Ride (vehicle_ID);

-- INSERT DATA SECTION
-- Area of the script that inserts data into the tables using “INSERT INTO”
-- Author: Domitille Chambon (dc44356)

-- Inserts into Rider table
INSERT INTO Rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('Domitille', 'Chambon', 'dc44356@my.utexas.edu', '865-250-4349', '17027 Turin Ridge', 'San Antonio', '78255');
INSERT INTO Rider_Payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_MID_NAME, CARDHOLDER_LAST_NAME, CARDTYPE, CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000001, 'Domitille', 'M', 'Chambon', 'AMEX', '1726354857463524', '21-MAY-25', '987', '17027 Turin Ridge', 'San Antonio', 'TX', '78255', 'Y');

INSERT INTO Rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('Tim', 'Smith', 'ts57485@my.utexas.edu', '376-456-0926', '801 Peach Tree Lane', 'Rochester Hills', '48306');
INSERT INTO Rider_Payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_LAST_NAME, CARDTYPE, CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000002, 'Tim', 'Smith', 'VISA', '9384657483746593', '05-JAN-27', '634', '801 Peach Tree Lane', 'Rochester Hills', 'MI', '48306', 'Y');

INSERT INTO Rider (FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS, CITY, ZIP)
VALUES ('David', 'Travel', 'dt83946@my.utexas.edu', '093-475-9012', '11406 Bancroft Lane', 'Knoxville', '39734');
INSERT INTO Rider_Payment (RIDER_ID, CARDHOLDER_FIRST_NAME, CARDHOLDER_MID_NAME, CARDHOLDER_LAST_NAME, CARDTYPE, CARDNUMBER, EXPIRATION_DATE, CC_ID, BILLING_ADDRESS, BILLING_CITY, BILLING_STATE, BILLING_ZIP, PRIMARY_CARD_FLAG)
VALUES (3000003, 'David', 'J', 'Travel', 'AMEX', '1037293746354653', '12-OCT-23', '642', '11406 Bancroft Lane', 'Knoxville', 'TN', '39734', 'Y');

commit;

-- Inserts into Driver table
INSERT INTO Driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Monica', 'Geller', '75623 Apple Street', 'Austin', 'TX', '47364', '847-586-0987', 'mg46576@my.utexas.edu', '18-APR-92', '98765423');
INSERT INTO Bank_Account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100001, '829384756', '76537098765');

INSERT INTO Driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Rachel', 'Green', '432 School Road', 'Austin', 'TX', '47364', '938-435-4326', 'rg46352@my.utexas.edu', '23-JUN-02', '46374659576');
INSERT INTO Bank_Account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100002, '093456375', '1234565433457');

INSERT INTO Driver (FIRST_NAME, LAST_NAME, ADDRESS, CITY, STATE, ZIP, PHONE, EMAIL, DOB, DRIVERS_LICENSE_NUM)
VALUES ('Phoebe', 'Buffay', '8364 McCombs Lane', 'Austin', 'TX', '47364', '093-463-0456', 'pb65423@my.utexas.edu', '09-DEC-87', '094567909876523');
INSERT INTO Bank_Account (DRIVER_ID, ROUTING_NUMBER, ACCOUNT_NUMBER)
VALUES (100003, '945632457', '094567987654');

commit;

-- Inserts into Vehicle table
INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUM, INSPECTION_EXP_DATE)
VALUES ('2012', 'Ford', 'Focus', 'Grey', '09876789876567565', 'DFS874', 'All State', '98765', '23-FEB-23');
INSERT INTO Vehicle_Driver_Linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100001, 1, 'Y');

INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUM, INSPECTION_EXP_DATE)
VALUES ('2005', 'Chevrolet', 'Malibu', 'White', '94657485734254637', 'LKD925', 'All State', '098765', '12-APR-23');
INSERT INTO Vehicle_Driver_Linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100002, 2, 'Y');

INSERT INTO Vehicle (YEAR, MAKE, MODEL, COLOR, VIN, PLATE_NUMBER, INSURANCE_COMPANY, INSURANCE_POLICY_NUM, INSPECTION_EXP_DATE)
VALUES ('2016', 'Honda', 'Odyssey', 'White', '16253447568473645', 'PEW567', 'All State', '87654', '02-JUN-23');
INSERT INTO Vehicle_Driver_Linking (DRIVER_ID, VEHICLE_ID, ACTIVE_VEHICLE_FLAG)
VALUES (100003, 3, 'Y');

commit;

-- Inserts into ride table
INSERT INTO Ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, START_DATETIME, END_DATETIME, INITIAL_FARE, FINAL_FARE, RATING)
VALUES (100003, 3000001, 3, '645 College Street', '247 Go Home Lane', '18-JUL-22', '13:59:23', '14:23:43', 23.45, 23.45, 4);

INSERT INTO Ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, INITIAL_FARE)
VALUES (100001, 3000002, 1, '2345 Banana Tree Lane', '8765 Sleepy Hollow', sysdate, 32.13);

INSERT INTO Ride (DRIVER_ID, RIDER_ID, VEHICLE_ID, PICKUP_ADDRESS, DROPOFF_ADDRESS, REQUEST_DATETIME, START_DATETIME, END_DATETIME, INITIAL_FARE, FINAL_FARE, RATING)
VALUES (100002, 3000003, 2, '098 Water Street', '8765 Bed Time Lane', '23-MAR-22', '04:44:21', '05:13:01', 68.32, 68.32, 2);

commit;

-- Insert into discount table
-- Discount percent is a decimal in terms of percentage
INSERT INTO Discounts (RIDER_ID, DISCOUNT_TYPE, DISCOUNT_PERCENT, USED_FLAG)
VALUES (3000001, 'Free', 1, 'N');

commit;