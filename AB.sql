-- 1. Select or create database

USE ab_testing_db;

-- 2. Create main user table with new name
CREATE TABLE ab_test_data_2024 (
    user_id INT PRIMARY KEY,
    cohort CHAR(1),                        -- 'A' or 'B'
    feature_flag TINYINT,                  -- 0 or 1
    session_time FLOAT,                    -- e.g., minutes or seconds
    conversion TINYINT,                    -- 0 or 1
    platform VARCHAR(20),
    region VARCHAR(20),
    event_date DATE
);

-- 3. View allowed secure file path (required for LOAD DATA INFILE)
SHOW VARIABLES LIKE "secure_file_priv";

-- 4. Load CSV data (edit path if needed)
-- Make sure the file exists inside the secure_file_priv directory
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ab_test_user_data.csv'
INTO TABLE ab_test_data_2024
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 5. Preview imported data
SELECT * FROM ab_test_data_2024 LIMIT 10;

-- 6. Test A/B cohort aggregation
SELECT 
    cohort, 
    COUNT(*) AS users,
    ROUND(AVG(session_time), 2) AS avg_session,
    ROUND(AVG(conversion), 2) AS conversion_rate
FROM 
    ab_test_data_2024
GROUP BY 
    cohort;

-- 7. Create reusable view for Tableau/dashboard
CREATE OR REPLACE VIEW cohort_summary_view AS
SELECT
    cohort,
    COUNT(user_id) AS user_count,
    ROUND(AVG(session_time), 2) AS avg_session_time,
    ROUND(SUM(conversion) / COUNT(user_id), 4) AS conversion_rate,
    MIN(event_date) AS test_start_date,
    MAX(event_date) AS test_end_date
FROM
    ab_test_data_2024
GROUP BY
    cohort;

-- 8. Verify the view returns the correct results
SELECT * FROM cohort_summary_view;
