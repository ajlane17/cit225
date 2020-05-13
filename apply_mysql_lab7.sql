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
--   mysql> \. apply_mysql_lab7.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab7.sql
--
-- ----------------------------------------------------------------------

-- Call the basic seeding scripts, this scripts TEE their own log
-- files. That means this script can only start a TEE after they run.
\. /home/student/Data/cit225/mysql/lab6/apply_mysql_lab6.sql

-- Add your lab here:
-- ----------------------------------------------------------------------

USE studentdb;

-- INSERT PRICE & RENTAL_ITEMS rows into COMMON_LOOKUP table (part 1 and 2 from the lab)
INSERT INTO common_lookup (common_lookup_type, common_lookup_meaning, created_by, creation_date, 
							last_updated_by, last_update_date, common_lookup_table,
                            common_lookup_column, common_lookup_code)
VALUES	('YES', 'Yes', 1001, UTC_DATE(), 1001, UTC_DATE(), 'PRICE', 'ACTIVE_FLAG', 'Y'),
		('NO', 'No', 1001, UTC_DATE(), 1001, UTC_DATE(), 'PRICE', 'ACTIVE_FLAG', 'N'),
		('1-DAY RENTAL', '1-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'PRICE', 'PRICE_TYPE', '1'),
		('3-DAY RENTAL', '3-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'PRICE', 'PRICE_TYPE', '3'),
        ('5-DAY RENTAL', '5-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'PRICE', 'PRICE_TYPE', '5'),
        ('1-DAY RENTAL', '1-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'RENTAL_ITEM', 'RENTAL_ITEM_TYPE', '1'),
        ('3-DAY RENTAL', '3-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'RENTAL_ITEM', 'RENTAL_ITEM_TYPE', '3'),
        ('5-DAY RENTAL', '5-Day Rental', 1001, UTC_DATE(), 1001, UTC_DATE(), 'RENTAL_ITEM', 'RENTAL_ITEM_TYPE', '5');
        
-- UPDATE RENTAL_ITEM_PRICE to INT UNSIGNED NOT NULL
ALTER TABLE rental_item
CHANGE COLUMN rental_item_price rental_item_price INT UNSIGNED NOT NULL;

-- Update rental_item_type column
UPDATE   rental_item ri
SET      rental_item_type =
           (SELECT   cl.common_lookup_id
            FROM     common_lookup cl
            WHERE    cl.common_lookup_code =
              (SELECT   DATEDIFF(r.return_date, r.check_out_date)
               FROM     rental r
               WHERE    r.rental_id = ri.rental_id)
            AND      cl.common_lookup_table = 'RENTAL_ITEM'
            AND      cl.common_lookup_column = 'RENTAL_ITEM_TYPE');

-- SELECT statement that returns data set that can be inserted into the price table
SELECT	i.item_id AS item_id,
        cl.common_lookup_id AS price_type,
		af.active_flag AS active_flag,        
        CASE
			WHEN	DATE_SUB(UTC_DATE(), INTERVAL 31 DAY) < i.release_date OR
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
		END AS amount
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
AND NOT	(af.active_flag = 'N' AND DATE_SUB(UTC_DATE(), INTERVAL 30 DAY) < i.release_date)
ORDER BY 1, 2, 3;