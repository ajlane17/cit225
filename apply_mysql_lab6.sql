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
--   mysql> \. apply_mysql_lab6.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab6.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lib/cleanup_mysql.sql
\. /home/student/Data/cit225/mysql/lib/create_mysql_store_ri2.sql
\. /home/student/Data/cit225/mysql/lib/seed_mysql_store_ri2.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

USE studentdb;

-- ---------------------------------
-- Database ALTER table, data INSERT
-- ---------------------------------

-- ALTER rental_item to include two new columns
ALTER TABLE rental_item 
ADD COLUMN rental_item_type INT UNSIGNED NOT NULL,
ADD COLUMN rental_item_price FLOAT NOT NULL,
ADD KEY rental_item_fk5 (rental_item_type),
ADD CONSTRAINT rental_item_fk5 FOREIGN KEY (rental_item_type)
REFERENCES common_lookup (common_lookup_id);

-- CREATE price table
CREATE TABLE price
(	price_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	item_id INT UNSIGNED NOT NULL,
    price_type INT UNSIGNED,
    active_flag ENUM('Y','N') NOT NULL,
    start_date DATE NOT NULL,
	end_date DATE,
    amount DOUBLE(10,2) NOT NULL,
    created_by INT UNSIGNED NOT NULL,
    creation_date DATE NOT NULL,
    last_updated_by INT UNSIGNED NOT NULL,
    last_updated_date DATE NOT NULL,
    
	KEY price_fk1 (item_id),
    CONSTRAINT price_fk1 FOREIGN KEY (item_id)
    REFERENCES item (item_id),
    
    KEY price_fk2 (price_type),
    constraint price_fk2 FOREIGN KEY (price_type)
    REFERENCES common_lookup (common_lookup_id),
    
    KEY price_fk3 (created_by),
    CONSTRAINT price_fk3 FOREIGN KEY (created_by)
    REFERENCES system_user (system_user_id),
    
    KEY price_fk4 (last_updated_by),
    CONSTRAINT price_fk4 FOREIGN KEY (last_updated_by)
    REFERENCES system_user (system_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- RENAME ITEM_RELEASE_DATE to RELEASE_DATE in ITEM table
ALTER TABLE item
CHANGE COLUMN item_release_date release_date DATE NOT NULL;

-- INSERT three new movies to ITEM table
INSERT INTO item (item_barcode, item_type, item_title, item_rating_id, release_date, created_by, 
					creation_date, last_updated_by,last_update_date)
VALUES	('ASIN: B000EHYKRT', 1013, 'Tron', 1003, '2016-10-22', 1001, UTC_DATE(), 1001, UTC_DATE()),
		('ASIN: B000EHYKRU', 1013, 'The Avengers', 1004, '2016-10-22', 1001, UTC_DATE(), 1001, UTC_DATE()),
        ('ASIN: B000EHYKRV', 1013, 'Thor: The Dark World', 1004, '2016-10-22', 1001, UTC_DATE(), 1001, UTC_DATE());
        
-- Add a new MEMBER (POTTER), and Harry, Ginny, and Lily Luna Potter to CONTACT, ADDRESS, STREET_ADDRESS, TELEPHONE
INSERT INTO member (account_number, credit_card_number, credit_card_type, member_type, created_by,
					creation_date, last_Updated_by, last_update_date)
VALUES	('R11-514-39', '1111-1111-3333-2222', 1009, 1005, 1001, UTC_DATE(), 1001, UTC_DATE());

INSERT INTO contact (member_id, contact_type, first_name, middle_name, last_name, created_by,
						creation_date, last_updated_by, last_update_date)
VALUES	(1009, 1004, 'Harry', NULL, 'Potter', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1009, 1004, 'Ginny', NULL, 'Potter', 1001, UTC_DATE(), 1001, UTC_DATE()),
        (1009, 1004, 'Lily', 'Luna', 'Potter', 1001, UTC_DATE(), 1001, UTC_DATE());
        
INSERT INTO address (contact_id, address_type, city, state_province, postal_code, created_by,
						creation_date, last_updated_by, last_update_date)
VALUES	(1013, 1010, 'Provo', 'Utah', '84606', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1014, 1010, 'Provo', 'Utah', '84606', 1001, UTC_DATE(), 1001, UTC_DATE()),
        (1015, 1010, 'Provo', 'Utah', '84606', 1001, UTC_DATE(), 1001, UTC_DATE());
        
INSERT INTO street_address (address_id, street_address, created_by, creation_date,
							last_updated_by, last_update_date)
VALUES	(1013, '334 North 2nd East', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1014, '335 North 2nd East', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1015, '336 North 2nd East', 1001, UTC_DATE(), 1001, UTC_DATE());
        
INSERT INTO telephone (contact_id, address_id, telephone_type, country_code, area_code,
						telephone_number, created_by, creation_date, last_updated_by, last_update_date)
VALUES	(1013, 1013, 1010, 'USA', '801', '423.1235', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1014, 1014, 1010, 'USA', '801', '423.1236', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1015, 1015, 1010, 'USA', '801', '423.1237', 1001, UTC_DATE(), 1001, UTC_DATE());
        
        
-- ADD 3 items to RENTAL, 4 items to RENTAl_ITEM: 
-- Harry: 1 new, 1 old, both for 1 day
-- Ginny: 1 new for 3 days
-- Lily: 1 new item for 5 days
INSERT INTO rental (customer_id, check_out_date, return_date, created_by, creation_date,
					last_updated_by, last_update_date)
VALUES	(1013, '2016-10-22', '2016-10-23', 1001, UTC_DATE(), 1001, UTC_DATE()),
		(1014, '2016-10-22', '2016-10-25', 1001, UTC_DATE(), 1001, UTC_DATE()),
        (1015, '2016-10-22', '2016-10-27', 1001, UTC_DATE(), 1001, UTC_DATE());
        
INSERT INTO rental_item (rental_id, item_id, created_by, creation_date, last_updated_by,
							last_update_date, rental_item_type, rental_item_price)
VALUES	(1006, 1054, 1001, UTC_DATE(), 1001, UTC_DATE(), 0, 0),
		(1006, 1051, 1001, UTC_DATE(), 1001, UTC_DATE(), 0, 0),
        (1007, 1053, 1001, UTC_DATE(), 1001, UTC_DATE(), 0, 0),
        (1008, 1052, 1001, UTC_DATE(), 1001, UTC_DATE(), 0, 0);
        

-- ---------------------------        
-- COMMON_LOOKUP modifications
-- ---------------------------

-- DROP COMMON_LOOKUP_U1 index
DROP INDEX common_lookup_u1 ON common_lookup;

-- ADD three new columns: 
ALTER TABLE common_lookup
ADD COLUMN common_lookup_table VARCHAR(30),
ADD COLUMN common_lookup_column VARCHAR(30),
ADD COLUMN common_lookup_code VARCHAR(30);

-- UPDATE common_lookup_table with common_lookup_context where not equal to 'multiple'
UPDATE common_lookup
SET common_lookup_table = common_lookup_context
WHERE common_lookup_context != 'MULTIPLE';

-- UPDATE common_lookup_table with address where equal to 'multiple'
UPDATE common_lookup
SET common_lookup_table = 'ADDRESS'
WHERE common_lookup_context = 'MULTIPLE';

-- UPDATE common_lookup_column with _context + '_type' where _table equals 'member' and _type equals 'individual' or 'group'
UPDATE common_lookup
SET common_lookup_column = CONCAT(common_lookup_context,'_TYPE')
WHERE common_lookup_table = 'MEMBER'
AND (common_lookup_type = 'INDIVIDUAL' OR common_lookup_type = 'GROUP');

-- UPDATE common_lookup_column with credit_card_type where _type equals 'visa_card', 'master_card', or 'discover_card'

UPDATE common_lookup
SET common_lookup_column = 'CREDIT_CARD_TYPE'
WHERE common_lookup_type = 'VISA_CARD' 
OR common_lookup_type = 'MASTER_CARD'
OR common_lookup_type = 'DISCOVER_CARD';

-- Update the COMMON_LOOKUP_COLUMN column with a value of 'ADDRESS_TYPE' when the COMMON_LOOKUP_CONTEXT value is 'MULTIPLE'.
UPDATE common_lookup
SET common_lookup_column = 'ADDRESS_TYPE'
WHERE common_lookup_context = 'MULTIPLE';

-- Update the COMMON_LOOKUP_COLUMN column with the value of the COMMON_LOOKUP_CONTEXT column and a '_TYPE' string when the 
-- COMMON_LOOKUP_CONTEXT value is anything other than 'MEMBER' or 'MULTIPLE'.
UPDATE common_lookup
SET common_lookup_column = CONCAT(common_lookup_context,'_TYPE')
WHERE common_lookup_context != 'MEMBER'
AND common_lookup_context != 'MULTIPLE';

-- CREATE two new telephone types in the common_lookup table for 'home' and 'work'

INSERT INTO common_lookup (common_lookup_context, common_lookup_type, common_lookup_meaning, created_by, creation_date,
							last_updated_by, last_update_date, common_lookup_table, common_lookup_column, common_lookup_code)
VALUES	('', 'HOME', 'Home', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TELEPHONE', 'TELEPHONE_TYPE', NULL),
		('', 'WORK', 'Work', 1001, UTC_DATE(), 1001, UTC_DATE(), 'TELEPHONE', 'TELEPHONE_TYPE', NULL);
        
-- Update TELEPHONE_TYPE values in telephone table to reflect new key in common_lookup table
UPDATE telephone
SET telephone_type = 1019
WHERE telephone_type = 1010;

UPDATE telephone
SET telephone_type = 1020
WHERE telephone_type = 1011;

-- DRop the common_lookup_context column
ALTER TABLE common_lookup
DROP common_lookup_context;

-- Make the common_lookup_table and common_lookup_column Non-nullable
ALTER TABLE common_lookup
MODIFY common_lookup_table VARCHAR(30) NOT NULL,
MODIFY common_lookup_column VARCHAR(30) NOT NULL;

-- Create a nk_common_lookup unique index across the COMMON_LOOKUP_TABLE, COMMON_LOOKUP_COLUMN, 
-- and COMMON_LOOKUP_TYPE columns found in the COMMON_LOOKUP table
ALTER TABLE common_lookup
ADD UNIQUE KEY nk_common_lookup (common_lookup_table, common_lookup_column, common_lookup_type);
