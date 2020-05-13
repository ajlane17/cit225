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
--   mysql> \. apply_mysql_lab11.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab11.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lab10/apply_mysql_lab10.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

USE studentdb;

-- Insert into rental table
REPLACE INTO rental (
	SELECT	DISTINCT
			r.rental_id AS rental_id,
			c.contact_id AS customer_id,
			tu.check_out_date AS check_out_date,
			tu.return_date AS return_date,
			1003 AS created_by,
			UTC_DATE() AS creation_date,
			1003 AS last_updated_by,
			UTC_DATE() AS last_update_date
	FROM	member m INNER JOIN contact c
	ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
	ON		c.first_name = tu.first_name
	AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
	AND     c.last_name = tu.last_name
	AND		tu.account_number = m.account_number LEFT JOIN rental r
	ON		c.contact_id = r.customer_id
	AND		tu.check_out_date = r.check_out_date
	AND		tu.return_date = r.return_date
);

-- FIRST update transaction_upload values to match actual keys, source table did not match

UPDATE transaction_upload SET item_id = 1001 WHERE item_id = 1;
UPDATE transaction_upload SET item_id = 1012 WHERE item_id = 12;

-- Insert into rental_item table 

SET FOREIGN_KEY_CHECKS=0; 

-- I had to do this because it kept failing for created_by

REPLACE INTO rental_item (
	SELECT
			ri.rental_item_id AS rental_item_id,
			r.rental_id AS rental_id,
			tu.item_id AS item_id,
			DATEDIFF(r.return_date, r.check_out_date) AS rental_item_price,
			cl.common_lookup_id AS rental_item_type,
			1003 AS created_by,
			UTC_DATE() AS creation_date,
			1003 AS last_updated_by,
			UTC_DATE() AS last_update_date
	FROM	member m INNER JOIN contact c
	ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
	ON		c.first_name = tu.first_name
	AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
	AND     c.last_name = tu.last_name
	AND		tu.account_number = m.account_number LEFT JOIN rental r
	ON		c.contact_id = r.customer_id
	AND		tu.check_out_date = r.check_out_date
	AND		tu.return_date = r.return_date INNER JOIN common_lookup cl
	ON		cl.common_lookup_table = 'RENTAL_ITEM'
	AND		cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
	AND		cl.common_lookup_type = tu.rental_item_type LEFT JOIN rental_item ri
	ON		r.rental_id = ri.rental_id
);

SET FOREIGN_KEY_CHECKS=1;

-- Insert into the transaction table
REPLACE INTO transaction (
	SELECT
			t.transaction_id as transaction_id,
			tu.payment_account_number AS transaction_account,
			cl1.common_lookup_id AS transaction_type,
			tu.transaction_date AS transaction_date,
			(SUM(tu.transaction_amount) / 1.06) AS transaction_amount,
			r.rental_id as rental_id,
			cl2.common_lookup_id AS payment_method_type,
			m.credit_card_number AS payment_account_number,
			1003 AS created_by,
			UTC_DATE() AS creation_date,
			1003 AS last_updated_by,
			UTC_DATE() AS last_update_date
	FROM	member m INNER JOIN contact c
	ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
	ON		c.first_name = tu.first_name
	AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
	AND     c.last_name = tu.last_name
	AND		tu.account_number = m.account_number LEFT JOIN rental r
	ON		c.contact_id = r.customer_id
	AND		tu.check_out_date = r.check_out_date
	AND		tu.return_date = r.return_date INNER JOIN common_lookup cl1
	ON		cl1.common_lookup_table = 'TRANSACTION'
	AND		cl1.common_lookup_column = 'TRANSACTION_TYPE'
	AND		cl1.common_lookup_type = tu.transaction_type INNER JOIN common_lookup cl2
	ON		cl2.common_lookup_table = 'TRANSACTION'
	AND		cl2.common_lookup_column = 'PAYMENT_METHOD_TYPE'
	AND		cl2.common_lookup_type = tu.payment_method_type LEFT JOIN transaction t
	ON		t.transaction_account = tu.payment_account_number
	AND		t.rental_id = r.rental_id
	AND		t.transaction_type = cl1.common_lookup_type
	AND		t.transaction_date = tu.transaction_date
	AND		t.payment_method_type = cl2.common_lookup_id
	AND		t.payment_account_number = m.credit_card_number
	GROUP BY	transaction_id,
				transaction_account,
				transaction_type,
				transaction_date,
				rental_id,
				payment_method_type,
				payment_account_number,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date
);

-- Create transaction_upload procedure

-- Conditionally drop the procedure.
DROP PROCEDURE IF EXISTS transaction_upload;
 
-- Reset the execution delimiter to create a stored program.
DELIMITER $$
 
-- The parentheses after the procedure name must be there or the MODIFIES SQL DATA raises an compile time exception.
CREATE PROCEDURE transaction_upload() MODIFIES SQL DATA
 
BEGIN
 
  /* Declare a handler variables. */
  DECLARE duplicate_key INT DEFAULT 0;
  DECLARE foreign_key   INT DEFAULT 0;
 
  /* Declare a duplicate key handler */
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;
  DECLARE CONTINUE HANDLER FOR 1216 SET foreign_key = 1;
 
  /* ---------------------------------------------------------------------- */
 
  /* Start transaction context. */
  START TRANSACTION;
 
  /* Set savepoint. */  
  SAVEPOINT both_or_none;
 
  /* Replace into rental table. */  
	REPLACE INTO rental (
		SELECT	DISTINCT
				r.rental_id AS rental_id,
				c.contact_id AS customer_id,
				tu.check_out_date AS check_out_date,
				tu.return_date AS return_date,
				1003 AS created_by,
				UTC_DATE() AS creation_date,
				1003 AS last_updated_by,
				UTC_DATE() AS last_update_date
		FROM	member m INNER JOIN contact c
		ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
		ON		c.first_name = tu.first_name
		AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
		AND     c.last_name = tu.last_name
		AND		tu.account_number = m.account_number LEFT JOIN rental r
		ON		c.contact_id = r.customer_id
		AND		tu.check_out_date = r.check_out_date
		AND		tu.return_date = r.return_date
	);
 
  /* Replace into rental_item table. */  
	UPDATE transaction_upload SET item_id = 1001 WHERE item_id = 1;
	UPDATE transaction_upload SET item_id = 1012 WHERE item_id = 12;

	SET FOREIGN_KEY_CHECKS=0; 

	REPLACE INTO rental_item (
		SELECT
				ri.rental_item_id AS rental_item_id,
				r.rental_id AS rental_id,
				tu.item_id AS item_id,
				DATEDIFF(r.return_date, r.check_out_date) AS rental_item_price,
				cl.common_lookup_id AS rental_item_type,
				1003 AS created_by,
				UTC_DATE() AS creation_date,
				1003 AS last_updated_by,
				UTC_DATE() AS last_update_date
		FROM	member m INNER JOIN contact c
		ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
		ON		c.first_name = tu.first_name
		AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
		AND     c.last_name = tu.last_name
		AND		tu.account_number = m.account_number LEFT JOIN rental r
		ON		c.contact_id = r.customer_id
		AND		tu.check_out_date = r.check_out_date
		AND		tu.return_date = r.return_date INNER JOIN common_lookup cl
		ON		cl.common_lookup_table = 'RENTAL_ITEM'
		AND		cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
		AND		cl.common_lookup_type = tu.rental_item_type LEFT JOIN rental_item ri
		ON		r.rental_id = ri.rental_id
	);

	SET FOREIGN_KEY_CHECKS=1;
	 
  /* Replace into transaction table. */  
	REPLACE INTO transaction (
		SELECT
				t.transaction_id as transaction_id,
				tu.payment_account_number AS transaction_account,
				cl1.common_lookup_id AS transaction_type,
				tu.transaction_date AS transaction_date,
				(SUM(tu.transaction_amount) / 1.06) AS transaction_amount,
				r.rental_id as rental_id,
				cl2.common_lookup_id AS payment_method_type,
				m.credit_card_number AS payment_account_number,
				1003 AS created_by,
				UTC_DATE() AS creation_date,
				1003 AS last_updated_by,
				UTC_DATE() AS last_update_date
		FROM	member m INNER JOIN contact c
		ON		m.member_id = c.member_id INNER JOIN transaction_upload tu
		ON		c.first_name = tu.first_name
		AND     IFNULL(c.middle_name,'x') = IFNULL(tu.middle_name,'x')
		AND     c.last_name = tu.last_name
		AND		tu.account_number = m.account_number LEFT JOIN rental r
		ON		c.contact_id = r.customer_id
		AND		tu.check_out_date = r.check_out_date
		AND		tu.return_date = r.return_date INNER JOIN common_lookup cl1
		ON		cl1.common_lookup_table = 'TRANSACTION'
		AND		cl1.common_lookup_column = 'TRANSACTION_TYPE'
		AND		cl1.common_lookup_type = tu.transaction_type INNER JOIN common_lookup cl2
		ON		cl2.common_lookup_table = 'TRANSACTION'
		AND		cl2.common_lookup_column = 'PAYMENT_METHOD_TYPE'
		AND		cl2.common_lookup_type = tu.payment_method_type LEFT JOIN transaction t
		ON		t.transaction_account = tu.payment_account_number
		AND		t.rental_id = r.rental_id
		AND		t.transaction_type = cl1.common_lookup_type
		AND		t.transaction_date = tu.transaction_date
		AND		t.payment_method_type = cl2.common_lookup_id
		AND		t.payment_account_number = m.credit_card_number
		GROUP BY	transaction_id,
					transaction_account,
					transaction_type,
					transaction_date,
					rental_id,
					payment_method_type,
					payment_account_number,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date
	);
 
  /* ---------------------------------------------------------------------- */
 
  /* This acts as an exception handling block. */  
  IF duplicate_key = 1 OR foreign_key = 1 THEN
 
    /* This undoes all DML statements to this point in the procedure. */
    ROLLBACK TO SAVEPOINT both_or_none;
 
  ELSE
 
    /* This commits the writes. */
    COMMIT;
 
  END IF;
 
END;
$$
 
-- Reset the delimiter to the default.
DELIMITER ;

CALL transaction_upload();

SELECT   c1.rental_count
,        c2.rental_item_count
,        c3.transaction_count
FROM    (SELECT COUNT(*) AS rental_count FROM rental) c1 CROSS JOIN
        (SELECT COUNT(*) AS rental_item_count FROM rental_item) c2 CROSS JOIN
        (SELECT COUNT(*) AS transaction_count FROM transaction) c3;
        
        
-- Create a query to present the financial data from 2009 by month
SELECT
		il.month AS 'MONTH YEAR',
		il.base AS 'BASE_REVENUE',
        il.plus10 AS '10_PLUS',
        il.plus20 AS '20_PLUS',
        il.only10 AS '10_PLUS_LESS_BASE',
        il.only20 AS '20_PLUS_LESS_BASE'
FROM	(SELECT
				CONCAT(EXTRACT(MONTH FROM t.transaction_date),CONCAT('-',EXTRACT(YEAR FROM t.transaction_date))) AS MONTH,
                EXTRACT(MONTH FROM t.transaction_date) AS sortkey,
                CONCAT('$',FORMAT(SUM(t.transaction_amount),2)) AS base,
                CONCAT('$',FORMAT(SUM(t.transaction_amount) * 1.1,2)) AS plus10,
                CONCAT('$',FORMAT(SUM(t.transaction_amount) * 1.2,2)) AS plus20,
                CONCAT('$',FORMAT(SUM(t.transaction_amount) * 0.1,2)) AS only10,
                CONCAT('$',FORMAT(SUM(t.transaction_amount) * 0.2,2)) AS only20
		FROM 	transaction t
        WHERE	EXTRACT(YEAR FROM t.transaction_date) = 2009
        GROUP BY	CONCAT(EXTRACT(MONTH FROM t.transaction_date),CONCAT('-',EXTRACT(YEAR FROM t.transaction_date))),
					EXTRACT(MONTH FROM t.transaction_date)) il
		ORDER BY	il.sortkey;