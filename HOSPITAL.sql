-- =====================
-- Hospital Analysis 
-- =====================

CREATE DATABASE IF NOT EXISTS hospital_analysis;
USE hospital_analysis;

-- =========================================================
-- TABLE CREATION
-- =========================================================
CREATE TABLE patients (
    Patient_ID INT PRIMARY KEY,
    Age INT,
    Gender ENUM('Male', 'Female'),
    `Condition` VARCHAR(100),
    `Procedure` VARCHAR(100),
    Cost DECIMAL(10,2),
    Length_of_Stay INT,
    Readmission ENUM('Yes', 'No'),
    `Outcome` ENUM('Recovered', 'Stable'),
    Satisfaction INT
);

-- =========================================================
-- 1️. Patient Demographics Overview
-- Purpose: Summarize patient distribution by gender, showing total count, average, minimum, and maximum age per gender.
-- =========================================================
SELECT 
    Gender,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(Age), 2) AS Average_Age,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM patients
GROUP BY Gender;

-- =========================================================
-- 2️. Condition Prevalence Analysis
-- Purpose: Identify the most common medical conditions and their average treatment cost and hospital stay duration.
-- =========================================================
SELECT 
    `Condition`,
    COUNT(*) AS Patient_Count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients)), 2) AS Percentage,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay
FROM patients
GROUP BY `Condition`
ORDER BY Patient_Count DESC;

-- =========================================================
-- 3️. Cost Analysis by Procedure
-- Purpose: Compare procedures by total, average, and range of costs.
-- =========================================================
SELECT 
    `Procedure`,
    COUNT(*) AS Cases,
    ROUND(AVG(Cost), 2) AS Average_Cost,
    ROUND(MIN(Cost), 2) AS Min_Cost,
    ROUND(MAX(Cost), 2) AS Max_Cost,
    ROUND(SUM(Cost), 2) AS Total_Cost
FROM patients
GROUP BY `Procedure`
ORDER BY Average_Cost DESC;

-- =========================================================
-- 4️. Readmission Rate Analysis
-- Purpose: Measure how often patients are readmitted for each condition and outcome category.
-- =========================================================
SELECT 
    `Condition`,
    `Outcome`,
    COUNT(*) AS Total_Cases,
    SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) AS Readmissions,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
GROUP BY `Condition`, `Outcome`
HAVING COUNT(*) > 10
ORDER BY Readmission_Rate DESC;

-- =========================================================
-- 5️. Length of Stay vs Cost
-- Purpose: Categorize patients by hospital stay duration and compare their average costs and satisfaction.
-- =========================================================
SELECT 
    CASE 
        WHEN Length_of_Stay <= 3 THEN 'Short Stay (1-3 days)'
        WHEN Length_of_Stay <= 7 THEN 'Medium Stay (4-7 days)'
        ELSE 'Long Stay (8+ days)'
    END AS Stay_Category,
    COUNT(*) AS Patient_Count,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction
FROM patients
GROUP BY Stay_Category
ORDER BY Avg_Stay;

-- =========================================================
-- 6️. Satisfaction by Outcome & Readmission
-- Purpose: Correlate recovery outcome and readmission status with patient satisfaction and treatment cost.
-- =========================================================
SELECT 
    `Outcome`,
    Readmission,
    COUNT(*) AS Cases,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    ROUND(AVG(Cost), 2) AS Avg_Cost
FROM patients
GROUP BY `Outcome`, Readmission
ORDER BY `Outcome`, Readmission;

-- =========================================================
-- 7️. Age Group Analysis
-- Purpose: Segment patients into age groups to compare cost, length of stay, satisfaction, and readmission rates.
-- =========================================================
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Young (Below 30)'
        WHEN Age < 50 THEN 'Middle-Aged (30-49)'
        WHEN Age < 70 THEN 'Senior (50-69)'
        ELSE 'Elderly (70+)'
    END AS Age_Group,
    COUNT(*) AS Patient_Count,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
GROUP BY Age_Group
ORDER BY FIELD(
    Age_Group,
    'Young (Below 30)',
    'Middle-Aged (30-49)',
    'Senior (50-69)',
    'Elderly (70+)'
);

-- =========================================================
-- 8️. High-Cost Patients
-- Purpose: Identify patients whose costs exceed the average treatment cost across all patients.
-- =========================================================
SELECT 
    Patient_ID,Age,Gender,`Condition`,`Procedure`,Cost,Length_of_Stay,Readmission,`Outcome`,Satisfaction
FROM patients
WHERE Cost > (SELECT AVG(Cost) FROM patients)
ORDER BY Cost DESC
LIMIT 50;

-- =========================================================
-- 9️. Procedure Effectiveness
-- Purpose: Measure recovery rates and satisfaction levels for each type of medical procedure.
-- =========================================================
SELECT 
    `Procedure`,
    COUNT(*) AS Total_Cases,
    SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) AS Recovered_Cases,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction
FROM patients
GROUP BY `Procedure`
HAVING COUNT(*) > 5
ORDER BY Recovery_Rate DESC;

-- =========================================================
-- 10. Monthly Trend (Simulated)
-- Purpose: Simulate admission and readmission trends by month using a modulo operation on Patient_ID.
-- =========================================================
SELECT 
    ((Patient_ID % 12) + 1) AS Month_Num,
    CONCAT('Month ', ((Patient_ID % 12) + 1)) AS Month_Label,
    COUNT(*) AS Admissions,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
GROUP BY Month_Num, Month_Label
ORDER BY Month_Num;

-- =========================================================
-- 11️. Gender-Based Treatment Differences
-- Purpose: Compare treatment outcomes and costs for each condition across male and female patients.
-- =========================================================
SELECT 
    Gender,
    `Condition`,
    COUNT(*) AS Cases,
    ROUND(AVG(Age), 2) AS Avg_Age,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate
FROM patients
GROUP BY Gender, `Condition`
HAVING COUNT(*) > 5
ORDER BY Gender, Cases DESC;

-- =========================================================
-- 12️. Cost Efficiency
-- Purpose: Compute a "Cost-Effectiveness Score" combining average cost, recovery rate, and satisfaction.
-- =========================================================
SELECT 
    `Condition`,
    `Procedure`,
    COUNT(*) AS Cases,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    ROUND(
        AVG(Cost) / NULLIF(
            (AVG(Satisfaction) * (SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))),
        0), 
    2) AS Cost_Effectiveness_Score
FROM patients
GROUP BY `Condition`, `Procedure`
HAVING COUNT(*) > 3
ORDER BY Cost_Effectiveness_Score ASC;

-- =========================================================
-- 13️. Readmission Risk Factors
-- Purpose: Identify conditions associated with higher patient readmission rates.
-- =========================================================
SELECT 
    `Condition`,
    ROUND(AVG(Age), 2) AS Avg_Age,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    COUNT(*) AS Total_Cases,
    SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) AS Readmissions,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
GROUP BY `Condition`
HAVING COUNT(*) > 10
ORDER BY Readmission_Rate DESC;

-- =========================================================
-- 14️. Satisfaction Drivers
-- Purpose: Group patients by satisfaction levels and analyze their recovery and readmission outcomes.
-- =========================================================
SELECT 
    CASE 
        WHEN Satisfaction >= 4 THEN 'High Satisfaction (4-5)'
        WHEN Satisfaction >= 3 THEN 'Medium Satisfaction (3)'
        ELSE 'Low Satisfaction (1-2)'
    END AS Satisfaction_Level,
    COUNT(*) AS Patient_Count,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
GROUP BY Satisfaction_Level
ORDER BY FIELD(
    Satisfaction_Level,
    'High Satisfaction (4-5)',
    'Medium Satisfaction (3)',
    'Low Satisfaction (1-2)'
);

-- =========================================================
-- 15️. Performance Dashboard
-- Purpose: Provide an overall hospital summary and a high-cost patient comparison for executive reporting.
-- =========================================================
SELECT 
    'Overall Metrics' AS Metric,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(Age), 2) AS Avg_Age,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
UNION ALL
SELECT 
    'High Cost Analysis' AS Metric,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(Age), 2) AS Avg_Age,
    ROUND(AVG(Cost), 2) AS Avg_Cost,
    ROUND(AVG(Length_of_Stay), 2) AS Avg_Stay,
    ROUND(AVG(Satisfaction), 2) AS Avg_Satisfaction,
    ROUND((SUM(CASE WHEN `Outcome` = 'Recovered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Recovery_Rate,
    ROUND((SUM(CASE WHEN Readmission = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Readmission_Rate
FROM patients
WHERE Cost > (SELECT AVG(Cost) FROM patients);

-- =================================
-- =================================