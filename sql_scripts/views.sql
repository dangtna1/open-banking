-- View: Customer Spending Summary
CREATE VIEW vw_customer_spending_summary AS
SELECT 
    c.CustomerID,
    c.FullName,
    SUM(CASE WHEN f.Amount < 0 THEN -f.Amount ELSE 0 END) AS TotalSpending,
    SUM(CASE WHEN f.IsSalary = 1 THEN f.Amount ELSE 0 END) AS TotalIncome,
    SUM(CASE WHEN f.IsRecurring = 1 THEN ABS(f.Amount) ELSE 0 END) AS RecurringPayments,
    SUM(CASE WHEN f.IsRefund = 1 THEN ABS(f.Amount) ELSE 0 END) AS Refunds,
    COUNT(*) AS TransactionCount
FROM fact_transactions f
JOIN dim_customers c 
ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName;

-- View: Monthly Category Spending
CREATE VIEW vw_monthly_category_spending AS
SELECT 
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS Month,
    Category,
    SUM(ABS(Amount)) AS TotalAmount
FROM fact_transactions
GROUP BY 
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1),
    Category;

-- View: Region-Level Insights
CREATE VIEW vw_region_financial_health AS
SELECT 
    r.RegionName,
    r.MedianIncome,
    r.MedianRent,
    r.ONS_DeprivationIndex,
    AVG(ABS(f.Amount)) AS AvgTransactionValue,
    COUNT(*) AS TransactionCount
FROM fact_transactions f
JOIN dim_region r ON f.RegionCode = r.RegionCode
GROUP BY 
    r.RegionName,
    r.MedianIncome,
    r.MedianRent,
    r.ONS_DeprivationIndex;


