-- ----------------------------------------------------------------------
-- Instructions:
-- ----------------------------------------------------------------------
-- The two scripts contain spooling commands, which is why there
-- isn't a spooling command in this script. When you run this file
-- you first connect to the Oracle database with this syntax:
--
--   mysql -ustudent -pstudent
--
--  or, you can fully qualify the port with this syntax:
--
--   mysql -ustudent -pstudent -P3306
--
-- Then, you call this script with the following syntax:
--
--   mysql> \. apply_mysql_lab2.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab2.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lib/cleanup_mysql.sql
\. /home/student/Data/cit225/mysql/lib/create_mysql_store_ri.sql
\. /home/student/Data/cit225/mysql/lib/seed_mysql_store_ri.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

-- Create a log file.
TEE apply_mysql_lab2.txt

-- This enables dropping tables with foreign key dependencies.
-- It is specific to the InnoDB Engine.
SET FOREIGN_KEY_CHECKS = 0; 

-- Conditionally drop objects.
SELECT 'SYSTEM_USER_LAB' AS "Drop Table";
DROP TABLE IF EXISTS system_user_lab;

-- ------------------------------------------------------------------
-- Create SYSTEM_USER_LAB table.
-- ------------------------------------------------------------------
SELECT 'SYSTEM_USER_LAB' AS "Create Table";

CREATE TABLE system_user_lab
( system_user_lab_id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, system_user_name            CHAR(20)     NOT NULL
, system_user_group_id        INT UNSIGNED NOT NULL
, system_user_type            INT UNSIGNED NOT NULL
, first_name                  CHAR(20)
, middle_name                 CHAR(20)
, last_name                   CHAR(20)
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY system_user_fk1 (created_by)
, CONSTRAINT system_user_lab_fk1 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY system_user_lab_fk2 (last_updated_by)
, CONSTRAINT system_user_lab_fk2 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO system_user_lab
( system_user_name
, system_user_group_id
, system_user_type
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
('SYSADMIN', 1, 1, 1, UTC_DATE(), 1, UTC_DATE());

-- Create indexes
CREATE UNIQUE INDEX system_user_lab_u1
ON system_user_lab (system_user_name);

-- Conditionally drop objects.
SELECT 'COMMON_LOOKUP_LAB' AS "Drop Table";
DROP TABLE IF EXISTS common_lookup_lab;

-- ------------------------------------------------------------------
-- Create COMMON_LOOKUP_LAB table.
-- ------------------------------------------------------------------
SELECT 'COMMON_LOOKUP_LAB' AS "Create Table";

CREATE TABLE common_lookup_lab
( common_lookup_lab_id        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, common_lookup_context       CHAR(30)     NOT NULL
, common_lookup_type          CHAR(30)     NOT NULL
, common_lookup_meaning       CHAR(30)     NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, CONSTRAINT common_lookup_lab_u1 UNIQUE INDEX (common_lookup_context, common_lookup_type)
, KEY common_lookup_lab_fk1 (created_by)
, CONSTRAINT common_lookup_lab_fk1 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY common_lookup_lab_fk2 (last_updated_by)
, CONSTRAINT common_lookup_lab_fk2 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('SYSTEM_USER_LAB','SYSTEM_ADMIN','System Administrator', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('SYSTEM_USER_LAB','DBA','Database Administrator', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('CONTACT_LAB','EMPLOYEE','Employee', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('CONTACT_LAB','CUSTOMER','Customer', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MEMBER_LAB','INDIVIDUAL','Individual Membership', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MEMBER_LAB','GROUP','Group Membership', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MEMBER_LAB','DISCOVER_CARD','Discover Card', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MEMBER_LAB','MASTER_CARD','Master Card', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MEMBER_LAB','VISA_CARD','VISA Card', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MULTIPLE','HOME','Home', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('MULTIPLE','WORK','Work', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','DVD_FULL_SCREEN','DVD: Full Screen', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','DVD_WIDE_SCREEN','DVD: Wide Screen', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','NINTENDO_GAMECUBE','Nintendo GameCube', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','PLAYSTATION2','PlayStation2', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','XBOX','XBOX', 1, UTC_DATE(), 1, UTC_DATE());

INSERT INTO common_lookup_lab
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
('ITEM_LAB','BLU-RAY','Blu-ray', 1, UTC_DATE(), 1, UTC_DATE());

-- Create indexes
CREATE INDEX common_lookup_lab_n1
ON common_lookup_lab (common_lookup_context);

-- Conditionally drop objects.
SELECT 'MEMBER_LAB' AS "Drop Table";
DROP TABLE IF EXISTS member_lab;

-- ------------------------------------------------------------------
-- Create MEMBER_LAB table.
-- ------------------------------------------------------------------
SELECT 'MEMBER_LAB' AS "Create Table";

CREATE TABLE member_lab
( member_lab_id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, member_type                 INT UNSIGNED
, account_number              CHAR(10)     NOT NULL
, credit_card_number          CHAR(19)     NOT NULL
, credit_card_type            INT UNSIGNED NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY member_lab_fk1 (created_by)
, CONSTRAINT member_lab_fk1 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY member_lab_fk2 (last_updated_by)
, CONSTRAINT member_lab_fk2 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create indexes
CREATE INDEX member_n1
ON member_lab (credit_card_type);

-- Conditionally drop objects.
SELECT 'CONTACT_LAB' AS "Drop Table";
DROP TABLE IF EXISTS contact_lab;

-- ------------------------------------------------------------------
-- Create CONTACT_LAB table.
-- ------------------------------------------------------------------
SELECT 'CONTACT_LAB' AS "Create Table";

CREATE TABLE contact_lab
( contact_lab_id              INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, member_lab_id               INT UNSIGNED NOT NULL
, contact_type                INT UNSIGNED NOT NULL
, first_name                  CHAR(20)     NOT NULL
, middle_name                 CHAR(20)
, last_name                   CHAR(20)     NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY contact_lab_fk1 (member_lab_id)
, CONSTRAINT contact_lab_fk1 FOREIGN KEY (member_lab_id) REFERENCES member_lab (member_lab_id)
, KEY contact_lab_fk2 (created_by)
, CONSTRAINT contact_lab_fk2 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY contact_lab_fk3 (last_updated_by)
, CONSTRAINT contact_lab_fk3 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create indexes
CREATE INDEX contact_lab_n1
ON contact_lab (member_lab_id);

CREATE INDEX contact_lab_n2
ON contact_lab (contact_type);


-- Conditionally drop objects.
SELECT 'ADDRESS_LAB' AS "Drop Table";
DROP TABLE IF EXISTS address_lab;

-- ------------------------------------------------------------------
-- Create ADDRESS_LAB table.
-- ------------------------------------------------------------------
SELECT 'ADDRESS_LAB' AS "Create Table";

CREATE TABLE address_lab
( address_lab_id              INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, contact_lab_id              INT UNSIGNED NOT NULL
, address_type                INT UNSIGNED NOT NULL
, city                        CHAR(30)     NOT NULL
, state_province              CHAR(30)     NOT NULL
, postal_code                 CHAR(20)     NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY address_lab_fk1 (contact_lab_id)
, CONSTRAINT address_lab_fk1 FOREIGN KEY (contact_lab_id) REFERENCES contact_lab (contact_lab_id)
, KEY address_lab_fk2 (created_by)
, CONSTRAINT address_lab_fk2 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY address_lab_fk3 (last_updated_by)
, CONSTRAINT address_lab_fk3 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- Create indexes
CREATE INDEX address_lab_n1
ON address_lab (contact_lab_id);

CREATE INDEX address_lab_n2
ON address_lab (address_type);


-- Conditionally drop objects.
SELECT 'STREET_ADDRESS_LAB' AS "Drop Table";
DROP TABLE IF EXISTS street_address_lab;

-- ------------------------------------------------------------------
-- Create STREET_ADDRESS_LAB table.
-- ------------------------------------------------------------------
SELECT 'STREET_ADDRESS_LAB' AS "Create Table";

CREATE TABLE street_address_lab
( street_address_lab_id       INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, address_lab_id              INT UNSIGNED NOT NULL
, street_address              CHAR(30)     NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY street_address_lab_fk1 (address_lab_id)
, CONSTRAINT street_address_lab_fk1 FOREIGN KEY (address_lab_id) REFERENCES address_lab (address_lab_id)
, KEY street_address_lab_fk2 (created_by)
, CONSTRAINT street_address_lab_fk2 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY street_address_lab_fk3 (last_updated_by)
, CONSTRAINT street_address_lab_fk3 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- Conditionally drop objects.
SELECT 'TELEPHONE_LAB' AS "Drop Table";
DROP TABLE IF EXISTS telephone_lab;

-- ------------------------------------------------------------------
-- Create TELEPHONE_LAB table.
-- ------------------------------------------------------------------
SELECT 'TELEPHONE_LAB' AS "Drop Table";

CREATE TABLE telephone_lab
( telephone_lab_id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, contact_lab_id              INT UNSIGNED NOT NULL
, address_lab_id              INT UNSIGNED
, telephone_type              INT UNSIGNED NOT NULL
, country_code                CHAR(3)      NOT NULL
, area_code                   CHAR(6)      NOT NULL
, telephone_number            CHAR(10)     NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY telephone_lab_fk1 (contact_lab_id)
, CONSTRAINT telephone_lab_fk1 FOREIGN KEY (contact_lab_id) REFERENCES contact_lab (contact_lab_id)
, KEY telephone_lab_fk2 (address_lab_id)
, CONSTRAINT telephone_lab_fk2 FOREIGN KEY (address_lab_id) REFERENCES address_lab (address_lab_id)
, KEY telephone_lab_fk3 (created_by)
, CONSTRAINT telephone_lab_fk3 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY telephone_lab_fk4 (last_updated_by)
, CONSTRAINT telephone_lab_fk4 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create indexes
CREATE INDEX telephone_lab_n1
ON telephone_lab ( contact_lab_id
                 , address_lab_id );

CREATE INDEX telephone_lab_n2
ON telephone_lab (telephone_type);

-- Conditionally drop objects.
SELECT 'RENTAL_LAB' AS "Drop Table";
DROP TABLE IF EXISTS rental_lab;

-- ------------------------------------------------------------------
-- Create RENTAL_LAB table.
-- ------------------------------------------------------------------
SELECT 'RENTAL_LAB' AS "Create Table";

CREATE TABLE rental_lab
( rental_lab_id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, customer_id                 INT UNSIGNED NOT NULL
, check_out_date              DATE         NOT NULL
, return_date                 DATE         NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY rental_lab_fk1 (customer_id)
, CONSTRAINT rental_lab_fk1 FOREIGN KEY (customer_id) REFERENCES contact_lab (contact_lab_id)
, KEY rental_fk2 (created_by)
, CONSTRAINT rental_lab_fk2 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY rental_lab_fk3 (last_updated_by)
, CONSTRAINT rental_lab_fk3 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Conditionally drop objects.
SELECT 'ITEM_LAB' AS "Drop Table";
DROP TABLE IF EXISTS item_lab;

-- ------------------------------------------------------------------
-- Create ITEM_LAB table.
-- ------------------------------------------------------------------
SELECT 'ITEM_LAB' AS "Create Table";

CREATE TABLE item_lab
( item_lab_id                 INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, item_barcode                CHAR(14)     NOT NULL
, item_type                   INT UNSIGNED NOT NULL
, item_title                  CHAR(60)     NOT NULL
, item_subtitle               CHAR(60)
, item_rating                 CHAR(8)      NOT NULL
, item_release_date           DATE         NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY item_lab_fk1 (item_type)
, CONSTRAINT item_lab_fk1 FOREIGN KEY (item_type) REFERENCES common_lookup_lab (common_lookup_lab_id)
, KEY item_lab_fk2 (created_by)
, CONSTRAINT item_lab_fk2 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY item_lab_fk3 (last_updated_by)
, CONSTRAINT item_lab_fk3 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- Conditionally drop objects.
SELECT 'RENTAL_ITEM_LAB' AS "Drop Table";
DROP TABLE IF EXISTS rental_item_lab;

-- ------------------------------------------------------------------
-- Create RENTAL_ITEM table.
-- ------------------------------------------------------------------
SELECT 'RENTAL_ITEM_LAB' AS "Create Table";

CREATE TABLE rental_item_lab
( rental_item_lab_id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
, rental_lab_id               INT UNSIGNED NOT NULL
, item_lab_id                 INT UNSIGNED NOT NULL
, created_by                  INT UNSIGNED NOT NULL
, creation_date               DATE         NOT NULL
, last_updated_by             INT UNSIGNED NOT NULL
, last_update_date            DATE         NOT NULL
, KEY rental_item_lab_fk1 (rental_lab_id)
, CONSTRAINT rental_item_lab_fk1 FOREIGN KEY (rental_lab_id) REFERENCES rental_lab (rental_lab_id)
, KEY rental_item_lab_fk2 (item_lab_id)
, CONSTRAINT rental_item_lab_fk2 FOREIGN KEY (item_lab_id) REFERENCES item_lab (item_lab_id)
, KEY rental_item_lab_fk3 (created_by)
, CONSTRAINT rental_item_lab_fk3 FOREIGN KEY (created_by) REFERENCES system_user_lab (system_user_lab_id)
, KEY rental_item_lab_fk4 (last_updated_by)
, CONSTRAINT rental_item_lab_fk4 FOREIGN KEY (last_updated_by) REFERENCES system_user_lab (system_user_lab_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Commit inserts.
COMMIT;

-- Display tables.
SHOW TABLES;

-- Close log file.
NOTEE