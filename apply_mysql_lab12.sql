use studentdb;


-- CREATE calendar table
CREATE TABLE calendar
(	calendar_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	calendar_name CHAR(10) NOT NULL,
    calendar_short_name CHAR(3) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_by INT UNSIGNED NOT NULL,
    creation_date DATE NOT NULL,
    last_updated_by INT UNSIGNED NOT NULL,
    last_update_date DATE NOT NULL,
        
    KEY calendar_fk1 (created_by),
    CONSTRAINT calendar_fk1 FOREIGN KEY (created_by)
    REFERENCES system_user (system_user_id),
    
    KEY calendar_fk2 (last_updated_by),
    CONSTRAINT calendar_fk2 FOREIGN KEY (last_updated_by)
    REFERENCES system_user (system_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- INSERT data into calendar table
INSERT INTO calendar (
	calendar_name,
    calendar_short_name,
    start_date,
    end_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
)
VALUES
('January', 'JAN', '2009-01-01','2009-01-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('February', 'FEB', '2009-02-01','2009-02-28', 1001, UTC_DATE(), 1001, UTC_DATE()),
('March', 'MAR', '2009-03-01','2009-03-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('April', 'APR', '2009-04-01','2009-04-30', 1001, UTC_DATE(), 1001, UTC_DATE()),
('May', 'MAY', '2009-05-01','2009-05-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('June', 'JUN', '2009-06-01','2009-06-30', 1001, UTC_DATE(), 1001, UTC_DATE()),
('July', 'JUL', '2009-07-01','2009-07-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('August', 'AUG', '2009-08-01','2009-08-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('September', 'SEP', '2009-09-01','2009-09-30', 1001, UTC_DATE(), 1001, UTC_DATE()),
('October', 'OCT', '2009-10-01','2009-10-31', 1001, UTC_DATE(), 1001, UTC_DATE()),
('November', 'NOV', '2009-11-01','2009-11-30', 1001, UTC_DATE(), 1001, UTC_DATE()),
('December', 'DEC', '2009-12-01','2009-12-31', 1001, UTC_DATE(), 1001, UTC_DATE());

-- Create transaction_reversal table from transaction table
CREATE TABLE transaction_reversal AS SELECT * FROM transaction;
TRUNCATE TABLE transaction_reversal;

-- INSERT new CSV into transaction_reversal table
LOAD DATA INFILE "D:/OneDrive/Documents/BYUI/CIT 225/Week 07/transaction_upload2_mysql.csv"
INTO TABLE transaction_reversal
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- UPDATE column data to match appropriate keys
UPDATE transaction_reversal SET created_by = 1003 WHERE created_by = 3;
UPDATE transaction_reversal SET last_updated_by = 1003 WHERE last_updated_by = 3;
UPDATE transaction_reversal SET transaction_type = 1029 WHERE transaction_type = 27;
UPDATE transaction_reversal SET payment_method_type = 1032 WHERE payment_method_type = 28;
UPDATE transaction_reversal	SET rental_id = rental_id + 1000;

-- Update transaction table with transaction_reversal data
INSERT INTO transaction (transaction_account, transaction_type, transaction_date,
			transaction_amount,rental_id, payment_method_type, payment_account_number,
            created_by, creation_date, last_updated_by, last_update_date)
SELECT	transaction_account, transaction_type, transaction_date,
			transaction_amount,rental_id, payment_method_type, payment_account_number,
            created_by, creation_date, last_updated_by, last_update_date
 FROM    transaction_reversal;
 
-- Create a transformation report using a cross join
SELECT   CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 'Debit'
           WHEN t.transaction_account = '222-222-222-222' THEN 'Credit'
         END AS 'Account'
,        CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 1
           WHEN t.transaction_account = '222-222-222-222' THEN 2
         END AS 'Sortkey'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 1 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT' 
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Jan'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 2 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Feb'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 3 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Mar'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN (EXTRACT(MONTH FROM transaction_date) = 1 OR
					EXTRACT(MONTH FROM transaction_date) = 2 OR
                    EXTRACT(MONTH FROM transaction_date) = 3) AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'F1Q'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 4 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Apr'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 5 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'May'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 6 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Jun'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN (EXTRACT(MONTH FROM transaction_date) = 4 OR
					EXTRACT(MONTH FROM transaction_date) = 5 OR
                    EXTRACT(MONTH FROM transaction_date) = 6) AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'F2Q'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 7 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Jul'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 8 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Aug'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 9 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Sep'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN (EXTRACT(MONTH FROM transaction_date) = 7 OR
					EXTRACT(MONTH FROM transaction_date) = 8 OR
                    EXTRACT(MONTH FROM transaction_date) = 9) AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'F3Q'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 10 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Oct'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 11 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Nov'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(MONTH FROM transaction_date) = 12 AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'Dec'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN (EXTRACT(MONTH FROM transaction_date) = 10 OR
					EXTRACT(MONTH FROM transaction_date) = 11 OR
                    EXTRACT(MONTH FROM transaction_date) = 12) AND
                    EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'F4Q'
,        LPAD(FORMAT
        (SUM(CASE
               WHEN EXTRACT(YEAR FROM transaction_date) = 2009 THEN
                 CASE
                   WHEN cl.common_lookup_type = 'DEBIT'
                   THEN t.transaction_amount
                   ELSE t.transaction_amount * -1
                 END
             END),2),10,' ') AS 'YTD'
FROM     transaction t INNER JOIN common_lookup cl
ON       t.transaction_type = cl.common_lookup_id 
WHERE    cl.common_lookup_table = 'TRANSACTION'
AND      cl.common_lookup_column = 'TRANSACTION_TYPE' 
GROUP BY CASE
           WHEN t.transaction_account = '111-111-111-111' THEN 'Debit'
           WHEN t.transaction_account = '222-222-222-222' THEN 'Credit'
         END
ORDER BY 2;