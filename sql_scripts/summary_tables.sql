-- Monthly Spend Table (materialized)
CREATE TABLE summary_monthly_spend (
    Month DATE,
    CustomerID VARCHAR(50),
    TotalSpend DECIMAL(10,2)
);

INSERT INTO summary_monthly_spend
SELECT 
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1),
    CustomerID,
    SUM(ABS(Amount))
FROM fact_transactions
GROUP BY 
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1),
    CustomerID;

SELECT *
from [dbo].[summary_monthly_spend]
WHERE Month = '2025-01-01'
ORDER BY TotalSpend desc;