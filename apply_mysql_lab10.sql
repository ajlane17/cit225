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
--   mysql> \. apply_mysql_lab10.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab10.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lab9/apply_mysql_lab9.sql

-- Add your lab here:
-- ----------------------------------------------------------------------


use studentdb;

-- Create indexes to improve MySQL performance

CREATE INDEX tu_rental
  ON transaction_upload (first_name, last_name, check_out_date, return_date, account_number, payment_account_number);
  
ALTER TABLE rental_item
  ADD CONSTRAINT natural_key 
  UNIQUE INDEX (rental_item_id, rental_id, item_id, rental_item_type, rental_item_price);
  
ALTER TABLE member
  ADD CONSTRAINT member_u1
  UNIQUE INDEX member_key (credit_card_number, credit_card_type, member_type, account_number);

ALTER TABLE common_lookup ADD CONSTRAINT common_lookup_u1 UNIQUE INDEX 
  common_lookup_key (common_lookup_table,common_lookup_column,common_lookup_type);
  
  -- Populate missing middle names with NULL
  
UPDATE transaction_upload
SET    middle_name = null
WHERE  middle_name = '';

-- Create SELECT statement to import from transaction_upload to rental

SELECT	DISTINCT
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
ORDER BY 1,2,3;

-- Select Statement to insert from transaction_upload into rental_id

SELECT	COUNT(*)
FROM	(SELECT
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
        ON		r.rental_id = ri.rental_id) AS il;
        
-- Create select statement to import transaction_upload into transaction

SELECT	COUNT(*)
FROM	(SELECT
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
                    last_update_date) ri;