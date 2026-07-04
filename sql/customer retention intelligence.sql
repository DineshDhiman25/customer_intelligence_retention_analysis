USE customer_intelligence;

-- Q1. Dataset overview

SELECT
    COUNT(*) AS Total_Transactions,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM customer_transactions_cleaned;

-- Q2. Customer purchase behaviour

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(AVG(Revenue), 2) AS Avg_Transaction_Value
FROM customer_transactions_cleaned
GROUP BY CustomerID
ORDER BY Total_Revenue DESC;


-- Q3. Repeat vs one-time customers

-- Q3. Repeat vs one-time customers

WITH Customer_Orders AS
(
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Total_Orders
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN Total_Orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type,
    COUNT(*) AS Total_Customers
FROM Customer_Orders
GROUP BY Customer_Type;


-- =====================================================
-- Q4. Repeat vs one-time customer percentage
-- =====================================================

WITH Customer_Orders AS
(
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Total_Orders
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
),
Customer_Types AS
(
    SELECT
        CASE
            WHEN Total_Orders = 1 THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS Customer_Type
    FROM Customer_Orders
)
SELECT
    Customer_Type,
    COUNT(*) AS Total_Customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS Customer_Percentage
FROM Customer_Types
GROUP BY Customer_Type;


-- =====================================================
-- Q5. Top 10 customers by revenue
-- =====================================================

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM customer_transactions_cleaned
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;

-- =====================================================
-- Q6. Customer revenue contribution percentage
-- =====================================================

WITH Customer_Revenue AS
(
    SELECT
        CustomerID,
        SUM(Revenue) AS Total_Revenue
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND(
        Total_Revenue * 100.0 /
        SUM(Total_Revenue) OVER (),
        2
    ) AS Revenue_Contribution_Percentage
FROM Customer_Revenue
ORDER BY Total_Revenue DESC;

-- =====================================================
-- Q7. Monthly active customers
-- =====================================================

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
    COUNT(DISTINCT CustomerID) AS Active_Customers
FROM customer_transactions_cleaned
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Sales_Month;


-- =====================================================
-- Q8. New customers acquired by month
-- =====================================================

WITH Customer_First_Purchase AS
(
    SELECT
        CustomerID,
        MIN(InvoiceDate) AS First_Purchase_Date
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
)
SELECT
    DATE_FORMAT(First_Purchase_Date, '%Y-%m') AS Acquisition_Month,
    COUNT(*) AS New_Customers
FROM Customer_First_Purchase
GROUP BY DATE_FORMAT(First_Purchase_Date, '%Y-%m')
ORDER BY Acquisition_Month;

-- =====================================================
-- Q9. Customer purchase frequency
-- =====================================================

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Purchase_Frequency
FROM customer_transactions_cleaned
GROUP BY CustomerID
ORDER BY Purchase_Frequency DESC;


-- =====================================================
-- Q10. Customer recency
-- =====================================================

SELECT
    CustomerID,
    MAX(InvoiceDate) AS Last_Purchase_Date,
    DATEDIFF(
        (SELECT MAX(InvoiceDate)
         FROM customer_transactions_cleaned),
        MAX(InvoiceDate)
    ) AS Recency_Days
FROM customer_transactions_cleaned
GROUP BY CustomerID
ORDER BY Recency_Days;


-- =====================================================
-- Q11. RFM customer metrics
-- =====================================================

WITH RFM_Metrics AS
(
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM customer_transactions_cleaned),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    Recency,
    Frequency,
    ROUND(Monetary, 2) AS Monetary
FROM RFM_Metrics
ORDER BY Monetary DESC;

-- =====================================================
-- Q12. RFM scoring using NTILE
-- =====================================================

WITH RFM_Metrics AS
(
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM customer_transactions_cleaned),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
),
RFM_Scores AS
(
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        NTILE(5) OVER (
            ORDER BY Recency DESC
        ) AS R_Score,
        NTILE(5) OVER (
            ORDER BY Frequency
        ) AS F_Score,
        NTILE(5) OVER (
            ORDER BY Monetary
        ) AS M_Score
    FROM RFM_Metrics
)
SELECT
    CustomerID,
    Recency,
    Frequency,
    ROUND(Monetary, 2) AS Monetary,
    R_Score,
    F_Score,
    M_Score
FROM RFM_Scores
ORDER BY Monetary DESC;


-- =====================================================
-- Q13. Customer segmentation using RFM scores
-- =====================================================

-- =====================================================
-- Q13. Customer segmentation using RFM scores
-- =====================================================

WITH RFM_Metrics AS
(
    SELECT
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM customer_transactions_cleaned),
            MAX(InvoiceDate)
        ) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
),
RFM_Scores AS
(
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM RFM_Metrics
)
SELECT
    CustomerID,
    Recency,
    Frequency,
    ROUND(Monetary, 2) AS Monetary,
    R_Score,
    F_Score,
    M_Score,
    CASE
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
            THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3
            THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2
            THEN 'New Customers'
        WHEN R_Score <= 2 AND F_Score >= 3
            THEN 'At Risk'
        ELSE 'Regular Customers'
    END AS Customer_Segment
FROM RFM_Scores
ORDER BY Monetary DESC;

-- =====================================================
-- Q14. At-risk and inactive customers
-- =====================================================
-- Q14. At-risk and inactive customers

WITH Customer_Activity AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS Last_Purchase_Date,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM customer_transactions_cleaned),
            MAX(InvoiceDate)
        ) AS Recency_Days,
        COUNT(DISTINCT InvoiceNo) AS Total_Orders,
        SUM(Revenue) AS Total_Revenue
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    Last_Purchase_Date,
    Recency_Days,
    Total_Orders,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    CASE
        WHEN Recency_Days > 180 THEN 'Inactive'
        WHEN Recency_Days > 90 THEN 'At Risk'
        ELSE 'Active'
    END AS Customer_Status
FROM Customer_Activity
ORDER BY Recency_Days DESC;


-- =====================================================
-- Q15. Monthly cohort retention analysis
-- =====================================================

WITH Customer_Cohort AS
(
    SELECT
        CustomerID,
        DATE_FORMAT(
            MIN(InvoiceDate),
            '%Y-%m-01'
        ) AS Cohort_Month
    FROM customer_transactions_cleaned
    GROUP BY CustomerID
),
Customer_Activity AS
(
    SELECT DISTINCT
        CustomerID,
        DATE_FORMAT(
            InvoiceDate,
            '%Y-%m-01'
        ) AS Activity_Month
    FROM customer_transactions_cleaned
),
Cohort_Data AS
(
    SELECT
        cc.CustomerID,
        STR_TO_DATE(
            cc.Cohort_Month,
            '%Y-%m-%d'
        ) AS Cohort_Month,
        STR_TO_DATE(
            ca.Activity_Month,
            '%Y-%m-%d'
        ) AS Activity_Month
    FROM Customer_Cohort cc
    JOIN Customer_Activity ca
        ON cc.CustomerID = ca.CustomerID
),
Cohort_Index AS
(
    SELECT
        CustomerID,
        Cohort_Month,
        Activity_Month,
        TIMESTAMPDIFF(
            MONTH,
            Cohort_Month,
            Activity_Month
        ) AS Cohort_Month_Index
    FROM Cohort_Data
),
Cohort_Counts AS
(
    SELECT
        Cohort_Month,
        Cohort_Month_Index,
        COUNT(DISTINCT CustomerID) AS Active_Customers
    FROM Cohort_Index
    GROUP BY
        Cohort_Month,
        Cohort_Month_Index
),
Cohort_Size AS
(
    SELECT
        Cohort_Month,
        Active_Customers AS Initial_Customers
    FROM Cohort_Counts
    WHERE Cohort_Month_Index = 0
)
SELECT
    cc.Cohort_Month,
    cc.Cohort_Month_Index,
    cc.Active_Customers,
    cs.Initial_Customers,
    ROUND(
        cc.Active_Customers * 100.0 /
        cs.Initial_Customers,
        2
    ) AS Retention_Rate
FROM Cohort_Counts cc
JOIN Cohort_Size cs
    ON cc.Cohort_Month = cs.Cohort_Month
ORDER BY
    cc.Cohort_Month,
    cc.Cohort_Month_Index;