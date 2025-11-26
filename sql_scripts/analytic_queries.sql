-- Top 10 merchants by total spend
SELECT TOP 10
    MerchantName,
	SUM(ABS(Amount)) AS totalSpent
FROM [dbo].[fact_transactions]
GROUP BY MerchantName
ORDER BY totalSpent DESC;

-- Average time between recurring payments per customer and merchant
WITH rec AS (
    SELECT 
        CustomerID,
        MerchantName,
        TransactionDate,
        LEAD(TransactionDate) OVER (PARTITION BY CustomerID, MerchantName ORDER BY TransactionDate) AS NextPayment
    FROM fact_transactions
    WHERE IsRecurring = 1
)
SELECT 
    CustomerID,
    MerchantName,
    DATEDIFF(day, TransactionDate, NextPayment) AS DaysBetween
FROM rec
WHERE NextPayment IS NOT NULL;

