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
--   mysql> \. apply_mysql_lab5.sql
--
--  or, the more verbose syntax:
--
--   mysql> source apply_mysql_lab5.sql
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

-- INNER JOINs with USING
SELECT m.member_id, c.contact_id
FROM member m
INNER JOIN contact c USING (member_id);

SELECT c.contact_id, a.address_id
FROM contact c
INNER JOIN address a USING (contact_id);

SELECT a.address_id, sa.street_address_id
FROM address a
INNER JOIN street_address sa USING (address_id);

SELECT c.contact_id, t.telephone_id
FROM contact c
INNER JOIN telephone t USING (contact_id);

-- INNER JOINs with ON
SELECT c.contact_id, su.system_user_id
FROM contact c
INNER JOIN system_user su ON c.created_by = su.system_user_id
ORDER BY c.contact_id;

SELECT c.contact_id, su.system_user_id
FROM contact c
INNER JOIN system_user su ON c.last_updated_by = su.system_user_id
ORDER BY c.contact_id;

-- Self Joins
SELECT su1.system_user_id, su2.created_by
FROM system_user su1
INNER JOIN system_user su2 ON su1.system_user_id = su2.system_user_id;

SELECT su1.system_user_id, su2.last_updated_by
FROM system_user su1
INNER JOIN system_user su2 ON su1.system_user_id = su2.system_user_id;

SELECT su1.system_user_name 'System User', su1.system_user_id 'System ID', su2.system_user_name 'Created User', 
		su2.system_user_id 'Created By', su3.system_user_name 'Updated User', su3.system_user_id 'Updated By'
FROM system_user su1
INNER JOIN system_user su2 ON su1.created_by = su2.system_user_id
INNER JOIN system_user su3 ON su2.last_updated_by = su3.system_user_id;

-- Outer Join
SELECT r.rental_id, ri.rental_id, ri.item_id, i.item_id
FROM rental r
LEFT JOIN rental_item ri ON r.rental_id = ri.rental_id
LEFT JOIN item i ON ri.item_id = i.item_id
ORDER BY r.rental_id;