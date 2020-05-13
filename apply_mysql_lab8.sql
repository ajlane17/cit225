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
--   mysql> \. apply_mysql_lab8.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab8.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lab7/apply_mysql_lab7.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

use studentdb;

-- INSERT price data from Lab 7 query
INSERT INTO price (item_id, price_type, active_flag, start_date, end_date, amount, 
					created_by, creation_date, last_updated_by, last_updated_date)
SELECT	i.item_id AS item_id,
        cl.common_lookup_id AS price_type,
		af.active_flag AS active_flag,        
        CASE
			WHEN	DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) < i.release_date OR
					DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) > i.release_date AND af.active_flag = 'N' THEN
				i.release_date
			ELSE
				DATE_ADD(i.release_date, INTERVAL 31 DAY)
		END AS start_date,
		CASE
			WHEN DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) > i.release_date AND af.active_flag = 'N' THEN
				DATE_ADD(i.release_date, INTERVAL 30 DAY)
		END AS end_date,
        CASE
			WHEN DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) < i.release_date THEN
				CASE
					WHEN dr.rental_days = 1 THEN 3
                    WHEN dr.rental_days = 3 THEN 10
                    WHEN dr.rental_days = 5 THEN 15
				END
			WHEN DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) > i.release_date AND af.active_flag = 'N' THEN
				CASE
					WHEN dr.rental_days = 1 THEN 3
                    WHEN dr.rental_days = 3 THEN 10
                    WHEN dr.rental_days = 5 THEN 15
				END
			ELSE
				CASE
					WHEN dr.rental_days = 1 THEN 1
                    WHEN dr.rental_days = 3 THEN 3
                    WHEN dr.rental_days = 5 THEN 5
				END
		END AS amount,
        1001 AS created_by,
        UTC_DATE() AS creation_date,
        1001 AS last_updated_by,
        UTC_DATE() AS last_updated_date
FROM 	item i CROSS JOIN
		(SELECT 'Y' AS active_flag FROM dual
         UNION ALL
         SELECT 'N' AS active_flag FROM dual) af CROSS JOIN
		(SELECT '1' AS rental_days FROM dual
         UNION ALL
         SELECT '3' AS rental_days FROM dual
         UNION ALL
         SELECT '5' AS rental_days FROM dual) dr INNER JOIN
         common_lookup cl ON dr.rental_days = SUBSTR(cl.common_lookup_type,1,1)
WHERE    cl.common_lookup_table = 'PRICE'
AND      cl.common_lookup_column = 'PRICE_TYPE'
AND NOT	(af.active_flag = 'N' AND DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) < i.release_date);

-- Add NOT NULL to price_type column in price table
ALTER TABLE price
DROP FOREIGN KEY price_fk2;

ALTER TABLE price
CHANGE COLUMN price_type price_type INT UNSIGNED NOT NULL;

ALTER TABLE price
ADD CONSTRAINT price_fk2 FOREIGN KEY (price_type)
REFERENCES common_lookup (common_lookup_id);

-- Update additional rows in rental_item table 
UPDATE   rental_item ri
SET      rental_item_price =
          (SELECT   p.amount
           FROM     price p INNER JOIN common_lookup cl1
           ON       p.price_type = cl1.common_lookup_id CROSS JOIN rental r
                    CROSS JOIN common_lookup cl2 
           WHERE    p.item_id = ri.item_id AND ri.rental_id = r.rental_id
           AND      ri.rental_item_type = cl2.common_lookup_id
           AND      cl1.common_lookup_code = cl2.common_lookup_code
           AND      r.check_out_date
                      BETWEEN p.start_date AND IFNULL(p.end_date, DATE_ADD(UTC_DATE(), INTERVAL 1 DAY)));
                      
-- Add not null to rental_item_price column of rental_item table 
-- Note: It's already not null from a previous lab, but I'll do it again anyway.
ALTER TABLE rental_item
CHANGE COLUMN rental_item_price rental_item_price INT UNSIGNED NOT NULL;