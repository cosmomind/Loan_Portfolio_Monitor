-- Total Loan Applications
SELECT COUNT(id) AS Loan_Count FROM credit_risk.financial_loan

-- Altering table to get the 'date' datatype
ALTER TABLE credit_risk.financial_loan
ADD issue_date_new DATE

UPDATE credit_risk.financial_loan
SET issue_date_new = TRY_CONVERT(date,issue_date, 103)

-- Getting max value from issue_date
SELECT MAX(issue_date_new) FROM credit_risk.financial_loan

-- MTD Loan Count
SELECT COUNT(id) AS MTD_Loan_Count
FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 12 AND YEAR(issue_date_new) = 2021

-- PMTD Loan Count
SELECT COUNT(id) AS  PMTD_Loan_Count
FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 11 AND YEAR(issue_date_new) = 2021

-- Total Loan Amount, MTD Total Loan Amount, PMTD Total Loan Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM credit_risk.financial_loan
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 12
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 11

-- Total Amount Received, MTD Total Amount Received, PMTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM credit_risk.financial_loan
SELECT SUM(total_payment) AS Total_Amount_Collected FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 12
SELECT SUM(total_payment) AS Total_Amount_Collected FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 11

-- Average Interest Rate, MTD Average Interest Rate, PMTD Average Interest Rate
SELECT AVG(int_rate)*100 AS Avg_Int_Rate FROM credit_risk.financial_loan
SELECT AVG(int_rate)*100 AS MTD_Avg_Int_Rate FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 12
SELECT AVG(int_rate)*100 AS PMTD_Avg_Int_Rate FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 11

-- Average DTI, MTD Average DTI, PMTD Average DTI
SELECT AVG(dti)*100 AS Avg_DTI FROM credit_risk.financial_loan
SELECT AVG(dti)*100 AS MTD_Avg_DTI FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 12
SELECT AVG(dti)*100 AS PMTD_Avg_DTI FROM credit_risk.financial_loan
WHERE MONTH(issue_date_new) = 11

-- Portfolio At Risk (PAR)
SELECT ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount END) * 100.0
    / NULLIF(SUM(loan_amount), 0), 2) AS Portfolio_At_Risk_Pct
FROM credit_risk.financial_loan



--  Default Recovery Rate
SELECT
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN total_payment END) * 100.0
    / NULLIF(SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount END), 0), 2)
    AS Default_Recovery_Rate
FROM credit_risk.financial_loan

-- Performing Loan Metrics
-- Performing Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0) /
       COUNT(id) AS Performing_Loan_Percentage
FROM credit_risk.financial_loan

-- Performing Loan Funded Amount
SELECT SUM(loan_amount) AS Performing_Loan_Funded_amount FROM credit_risk.financial_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

-- Performing Loan Amount Received
SELECT SUM(total_payment) AS Performing_Loan_amount_received FROM credit_risk.financial_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

-- Non-Performing Loan Metrics
-- Non-Performing Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
	COUNT(id) AS Non_performing_Loan_Percentage
FROM credit_risk.financial_loan

-- Non Performing Loan Funded Amount
SELECT SUM(loan_amount) AS Non_performing_Loan_Funded_amount FROM credit_risk.financial_loan
WHERE loan_status = 'Charged Off'

-- Non Performing Loan Amount Received
SELECT SUM(total_payment) AS Non_performing_Loan_amount_received FROM credit_risk.financial_loan
WHERE loan_status = 'Charged Off'

--By Loan Status
SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        SUM(total_payment) AS Total_Amount_Received,
        SUM(loan_amount) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
    FROM
        credit_risk.financial_loan
    GROUP BY
        loan_status

--By Month
SELECT 
	MONTH(issue_date_new) AS Month_Munber, 
	DATENAME(MONTH, issue_date_new) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM  credit_risk.financial_loan
GROUP BY MONTH(issue_date_new), DATENAME(MONTH, issue_date_new)
ORDER BY MONTH(issue_date_new)

--By Term
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM credit_risk.financial_loan
GROUP BY term
ORDER BY term

--By Employment Length
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM credit_risk.financial_loan
GROUP BY emp_length
ORDER BY emp_length

--By Purpose
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM credit_risk.financial_loan
GROUP BY purpose
ORDER BY purpose


--By Home Ownership
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM credit_risk.financial_loan
GROUP BY home_ownership
ORDER BY home_ownership

--For grade filters
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM credit_risk.financial_loan
WHERE grade = 'A'
GROUP BY purpose
ORDER BY purpose

--Default Rate by Grade (CHARACTER)
SELECT 
    grade,
    COUNT(id) AS Total_Loans,
    ROUND(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0
    / NULLIF(COUNT(id), 0), 2) AS Default_Rate_Pct
FROM credit_risk.financial_loan
GROUP BY grade
ORDER BY grade

-- Default Rate by Purpose (CONDITIONS)
SELECT 
    purpose,
    COUNT(id) AS Total_Loans,
    ROUND(AVG(loan_amount), 2) AS Avg_Loan_Amount,
    ROUND(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0
    / NULLIF(COUNT(id), 0), 2) AS Default_Rate_Pct
FROM credit_risk.financial_loan
GROUP BY purpose
ORDER BY Default_Rate_Pct DESC

-- Default Rate by Income Group (CAPACITY)
WITH Income_Groups AS (
    SELECT 
        id, loan_status, dti,
        CASE 
            WHEN annual_income < 50000 THEN 'Low Income'
            WHEN annual_income BETWEEN 50000 AND 100000 THEN 'Middle Income'
            ELSE 'High Income'
        END AS Income_Group
    FROM credit_risk.financial_loan
)
SELECT 
    Income_Group,
    COUNT(id) AS Total_Loans,
    ROUND(AVG(dti * 100), 2) AS Avg_DTI,
    ROUND(COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0
    / NULLIF(COUNT(id), 0), 2) AS Default_Rate_Pct
FROM Income_Groups
GROUP BY Income_Group

-- Running Total of Loans Funded by Month
SELECT 
    DATENAME(MONTH, issue_date_new) AS Month_Name,
    MONTH(issue_date_new) AS Month_Number,
    SUM(loan_amount) AS Monthly_Funded_Amount,
    SUM(SUM(loan_amount)) OVER (ORDER BY MONTH(issue_date_new)) AS Running_Total
FROM credit_risk.financial_loan
GROUP BY DATENAME(MONTH, issue_date_new), MONTH(issue_date_new)
ORDER BY MONTH(issue_date_new)