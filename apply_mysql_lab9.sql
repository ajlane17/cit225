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
--   mysql> \. apply_mysql_lab9.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab9.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lab8/apply_mysql_lab8.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

use studentdb;

-- Create TRANSACTION table
CREATE TABLE transaction (
	transaction_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	transaction_account CHAR(15) NOT NULL,
    transaction_type INT UNSIGNED NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_amount DOUBLE NOT NULL,
    rental_id INT UNSIGNED NOT NULL,
    payment_method_type INT UNSIGNED NOT NULL,
    payment_account_number CHAR(20) NOT NULL,
    created_by INT UNSIGNED NOT NULL,
    creation_date DATE NOT NULL,
    last_updated_by INT UNSIGNED NOT NULL,
    last_update_date DATE NOT NULL,
    
	KEY transaction_fk1 (transaction_type),
    CONSTRAINT transaction_fk1 FOREIGN KEY (transaction_type)
    REFERENCES common_lookup (common_lookup_id),
    
	KEY transaction_fk2 (rental_id),
    CONSTRAINT transaction_fk2 FOREIGN KEY (rental_id)
    REFERENCES rental (rental_id),
    
	KEY transaction_fk3 (created_by),
    CONSTRAINT transaction_fk3 FOREIGN KEY (created_by)
    REFERENCES system_user (system_user_id),
    
	KEY transaction_fk4 (last_updated_by),
    CONSTRAINT transaction_fk4 FOREIGN KEY (last_updated_by)
    REFERENCES system_user (system_user_id)
);

-- ADD UNIQUE INDEX to columns in transaction table
ALTER TABLE transaction
ADD CONSTRAINT natural_key UNIQUE INDEX (
	rental_id,
	transaction_type,
    transaction_date,
    payment_method_type,
    payment_account_number,
    transaction_account
);

-- Insert Transaction_type rows and payment_method rows
INSERT INTO common_lookup (
	common_lookup_type,
    common_lookup_meaning,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    common_lookup_table,
    common_lookup_column,
    common_lookup_code
)
VALUES
('CREDIT', 'Credit', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'TRANSACTION_TYPE', 'CR'),
('DEBIT', 'Debit', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'TRANSACTION_TYPE', 'DR'),
('DISCOVER_CARD', 'Discover Card', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'PAYMENT_METHOD_TYPE', NULL),
('VISA_CARD', 'Visa Card', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'PAYMENT_METHOD_TYPE', NULL),
('MASTER_CARD', 'Master Card', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'PAYMENT_METHOD_TYPE', NULL),
('CASH', 'Cash', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TRANSACTION', 'PAYMENT_METHOD_TYPE', NULL);

-- Create AIRPORT table
CREATE TABLE airport (
	airport_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    airport_code CHAR(3) NOT NULL,
    airport_city CHAR(30) NOT NULL,
    city CHAR(30) NOT NULL,
    state_province CHAR(30) NOT NULL,
    created_by INT UNSIGNED NOT NULL,
    creation_date DATE NOT NULL,
    last_updated_by INT UNSIGNED NOT NULL,
    last_update_date DATE NOT NULL,
    
    key airport_fk1 (created_by),
    CONSTRAINT airport_fk1 FOREIGN KEY (created_by)
    REFERENCES system_user (system_user_id),
    
    key airport_fk2 (last_updated_by),
    CONSTRAINT airport_fk2 FOREIGN KEY (last_updated_by)
    REFERENCES system_user (system_user_id)
);

-- ADD UNIQUE INDEX to columns in airport table
ALTER TABLE airport
ADD CONSTRAINT nk_airport UNIQUE INDEX (
	airport_code,
    airport_city,
    city,
    state_province
);

-- INSERT airports into airport table
INSERT INTO airport (
	airport_code,
    airport_city,
    city,
    state_province,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
)
VALUES
('LAX', 'Los Angeles', 'Los Angeles', 'California', 1001, UTC_DATE(), 1001, UTC_DATE()),
('SLC', 'Salt Lake City', 'Provo', 'Utah', 1001, UTC_DATE(), 1001, UTC_DATE()),
('SLC', 'Salt Lake City', 'Spanish Fork', 'Utah', 1001, UTC_DATE(), 1001, UTC_DATE()),
('SFO', 'San Francisco', 'San Francisco', 'California', 1001, UTC_DATE(), 1001, UTC_DATE()),
('SJC', 'San Jose', 'San Jose', 'California', 1001, UTC_DATE(), 1001, UTC_DATE()),
('SJC', 'San Jose', 'San Carlos', 'California', 1001, UTC_DATE(), 1001, UTC_DATE());

-- Create ACCOUNT_LIST table
CREATE TABLE account_list (
	account_list_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    account_number CHAR(10) NOT NULL,
    consumed_date DATE,
    consumed_by INT UNSIGNED,
    created_by INT UNSIGNED NOT NULL,
    creation_date DATE NOT NULL,
    last_updated_by INT UNSIGNED NOT NULL,
    last_update_date DATE NOT NULL,
    
    KEY account_list_fk1 (created_by),
    CONSTRAINT account_list_fk1 FOREIGN KEY (created_by)
    REFERENCES system_user (system_user_id),
    
    KEY account_list_fk2 (last_updated_by),
    CONSTRAINT account_list_fk2 FOREIGN KEY (last_updated_by)
    REFERENCES system_user (system_user_id)
);

-- -----------------------------------------
-- SEED ACCOUNT_LIST table (script provided)
-- -----------------------------------------

-- Conditionally drop the procedure.
SELECT 'DROP PROCEDURE seed_account_list' AS "Statement";
DROP PROCEDURE IF EXISTS seed_account_list;
 
-- Create procedure to insert automatic numbered rows.
SELECT 'CREATE PROCEDURE seed_account_list' AS "Statement";
 
-- Reset delimiter to write a procedure.
DELIMITER $$
 
CREATE PROCEDURE seed_account_list() MODIFIES SQL DATA
BEGIN
 
  /* Declare local variable for call parameters. */
  DECLARE lv_key CHAR(3);
 
  /* Declare local control loop variables. */
  DECLARE lv_key_min  INT DEFAULT 0;
  DECLARE lv_key_max  INT DEFAULT 50;
 
  /* Declare a local variable for a subsequent handler. */
  DECLARE duplicate_key INT DEFAULT 0;
  DECLARE fetched INT DEFAULT 0;
 
  /* Declare a SQL cursor fabricated from local variables. */  
  DECLARE parameter_cursor CURSOR FOR
    SELECT DISTINCT airport_code FROM airport;
 
  /* Declare a duplicate key handler */
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;
 
  /* Declare a not found record handler to close a cursor loop. */
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fetched = 1;
 
  /* Start transaction context. */
  START TRANSACTION;
 
  /* Set savepoint. */  
  SAVEPOINT all_or_none;
 
  /* Open a local cursor. */  
  OPEN parameter_cursor;
  cursor_parameter: LOOP
 
    FETCH parameter_cursor
    INTO  lv_key;
 
    /* Place the catch handler for no more rows found
       immediately after the fetch operation.          */
    IF fetched = 1 THEN LEAVE cursor_parameter; END IF;
 
    seed: WHILE (lv_key_min < lv_key_max) DO
      SET lv_key_min = lv_key_min + 1;
 
      INSERT INTO account_list
      VALUES
      ( null
      , CONCAT(lv_key,'-',LPAD(lv_key_min,6,'0'))
      , null
      , null
      , 1002
      , UTC_DATE()
      , 1002
      , UTC_DATE());
    END WHILE;
 
    /* Reset nested low range variable. */
    SET lv_key_min = 0;
 
  END LOOP cursor_parameter;
  CLOSE parameter_cursor;
 
    /* This acts as an exception handling block. */  
  IF duplicate_key = 1 THEN
 
    /* This undoes all DML statements to this point in the procedure. */
    ROLLBACK TO SAVEPOINT all_or_none;
 
  END IF;
 
  /* Commit the writes as a group. */
  COMMIT;
 
END;
$$
 
-- Reset delimiter to the default.
DELIMITER ;

-- Call the new stored procedure
CALL seed_account_list();

-- Update ADDRESS table to use full state names (query provided)
UPDATE address
SET    state_province = 'California'
WHERE  state_province = 'CA';

-- ---------------------------------------
-- UPDATE_MEMBER_ACCOUNT (script provided)
-- ---------------------------------------

-- Reset delimiter to write a procedure.
DELIMITER $$
 
CREATE PROCEDURE update_member_account() MODIFIES SQL DATA
BEGIN
 
  /* Declare local variable for call parameters. */
  DECLARE lv_member_id      INT UNSIGNED;
  DECLARE lv_city           CHAR(30);
  DECLARE lv_state_province CHAR(30);
  DECLARE lv_account_number CHAR(10);
 
  /* Declare a local variable for a subsequent handler. */
  DECLARE duplicate_key INT DEFAULT 0;
  DECLARE fetched INT DEFAULT 0;
 
  /* Declare a SQL cursor fabricated from local variables. */  
  DECLARE member_cursor CURSOR FOR
    SELECT   DISTINCT
             m.member_id
    ,        a.city
    ,        a.state_province
    FROM     member m INNER JOIN contact c
    ON       m.member_id = c.member_id INNER JOIN address a
    ON       c.contact_id = a.contact_id
    ORDER BY m.member_id;
 
  /* Declare a duplicate key handler */
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;
 
  /* Declare a not found record handler to close a cursor loop. */
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fetched = 1;
 
  /* Start transaction context. */
  START TRANSACTION;
 
  /* Set savepoint. */  
  SAVEPOINT all_or_none;
 
  /* Open a local cursor. */  
  OPEN member_cursor;
  cursor_member: LOOP
 
    FETCH member_cursor
    INTO  lv_member_id
    ,     lv_city
    ,     lv_state_province;
 
    /* Place the catch handler for no more rows found
       immediately after the fetch operation.          */
    IF fetched = 1 THEN LEAVE cursor_member; END IF;
 
      /* Secure a unique account number as they're consumed from the list. */
      SELECT al.account_number
      INTO   lv_account_number
      FROM   account_list al INNER JOIN airport ap
      ON     SUBSTRING(al.account_number,1,3) = ap.airport_code
      WHERE  ap.city = lv_city
      AND    ap.state_province = lv_state_province
      AND    consumed_by IS NULL
      AND    consumed_date IS NULL LIMIT 1;
 
      /* Update a member with a unique account number linked to their nearest airport. */
      UPDATE member
      SET    account_number = lv_account_number
      WHERE  member_id = lv_member_id;
 
      /* Mark consumed the last used account number. */      
      UPDATE account_list
      SET    consumed_by = 1002
      ,      consumed_date = UTC_DATE()
      WHERE  account_number = lv_account_number;
 
  END LOOP cursor_member;
  CLOSE member_cursor;
 
    /* This acts as an exception handling block. */  
  IF duplicate_key = 1 THEN
 
    /* This undoes all DML statements to this point in the procedure. */
    ROLLBACK TO SAVEPOINT all_or_none;
 
  END IF;
 
  /* Commit the writes as a group. */
  COMMIT;
 
END;
$$
 
-- Reset delimiter to the default.
DELIMITER ;

-- Call stored procedure
CALL update_member_account();

-- Create TRANSACTION_UPLOAD table
CREATE TABLE transaction_upload (
	account_number CHAR(10),
    first_name CHAR(20),
    middle_name CHAR(20),
    last_name CHAR(20),
    check_out_date DATE,
    return_date DATE,
    rental_item_type CHAR(12),
    transaction_type CHAR(14),
    transaction_amount DOUBLE(10,2),
    transaction_date DATE,
    item_id INT UNSIGNED,
    payment_method_type CHAR(14),
    payment_account_number CHAR(19)
);

-- Import data from CSV too transaction_upload table
-- File path for my Windows: "D:/OneDrive/Documents/BYUI/CIT 225/Week 09/transaction_upload_mysql.csv"
LOAD DATA INFILE "/u01/app/mysql/upload/transaction_upload_mysql.csv"
INTO TABLE transaction_upload
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';