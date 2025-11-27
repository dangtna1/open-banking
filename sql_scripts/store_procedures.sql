-- Merchant performance report (month-over-month change) procedure
CREATE PROCEDURE usp_merchant_mom_change
    @MerchantName NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    WITH MonthlySpend AS (
        SELECT 
            MerchantName,
            DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS Month,
            SUM(ABS(Amount)) AS TotalSpend
        FROM fact_transactions
        WHERE MerchantName = @MerchantName
        GROUP BY 
            MerchantName,
            DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1)
    ),
    Lagged AS (
        SELECT
            Month,
            TotalSpend,
            LAG(TotalSpend) OVER (ORDER BY Month) AS PrevMonthSpend
        FROM MonthlySpend
    )
    SELECT
        Month,
        TotalSpend,
        PrevMonthSpend,
        TotalSpend - PrevMonthSpend AS MonthChange,
        CASE 
            WHEN PrevMonthSpend = 0 THEN NULL
            ELSE (TotalSpend - PrevMonthSpend) / PrevMonthSpend * 100
        END AS PercentChange
    FROM Lagged;
END;

EXEC usp_merchant_mom_change @MerchantName = 'Tesco';

-------------------------------------------------------------------------------
-- Data Quality Stored Procedures
-------------------------------------------------------------------------------

-- Check nulls in key fields
CREATE PROCEDURE usp_dq_check_nulls
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 'CustomerID' AS ColumnName, COUNT(*) AS NullCount 
    FROM fact_transactions WHERE CustomerID IS NULL;

    SELECT 'AccountID' AS ColumnName, COUNT(*) AS NullCount 
    FROM fact_transactions WHERE AccountID IS NULL;

    SELECT 'TransactionDate' AS ColumnName, COUNT(*) AS NullCount 
    FROM fact_transactions WHERE TransactionDate IS NULL;
END;

-- Check for invalid amounts
CREATE PROCEDURE usp_dq_check_amounts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COUNT(*) AS InvalidAmountCount
    FROM fact_transactions
    WHERE Amount IS NULL
       OR TRY_CAST(Amount AS DECIMAL(10,2)) IS NULL;
END;

-- Check duplicate transactions
CREATE PROCEDURE usp_dq_check_duplicates
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        TransactionID,
        COUNT(*) AS Occurrences
    FROM fact_transactions
    GROUP BY TransactionID
    HAVING COUNT(*) > 1;
END;

-- Find transactions that reference non-existent dimension rows
CREATE PROCEDURE usp_dq_check_orphan_keys
AS
BEGIN
    SET NOCOUNT ON;

    -- Orphan Customers
    SELECT 
        'Customer' AS OrphanType,
        f.CustomerID,
        COUNT(*) AS TransactionCount
    FROM fact_transactions f
    LEFT JOIN dim_customers c ON f.CustomerID = c.CustomerID
    WHERE c.CustomerID IS NULL
    GROUP BY f.CustomerID;

    -- Orphan Accounts
    SELECT 
        'Account' AS OrphanType,
        f.AccountID,
        COUNT(*) AS TransactionCount
    FROM fact_transactions f
    LEFT JOIN dim_accounts a ON f.AccountID = a.AccountID
    WHERE a.AccountID IS NULL
    GROUP BY f.AccountID;

    -- Orphan Regions
    SELECT 
        'Region' AS OrphanType,
        f.RegionCode,
        COUNT(*) AS TransactionCount
    FROM fact_transactions f
    LEFT JOIN dim_region r ON f.RegionCode = r.RegionCode
    WHERE r.RegionCode IS NULL
    GROUP BY f.RegionCode;
END;

-- Detect future dates, extremely old dates, and missing dates
CREATE PROCEDURE usp_dq_check_date_anomalies
    @MinValidDate DATE = '2015-01-01'
AS
BEGIN
    SET NOCOUNT ON;

    -- Future dated transactions
    SELECT 
        'FutureDate' AS AnomalyType,
        TransactionID,
        TransactionDate
    FROM fact_transactions
    WHERE TransactionDate > SYSDATETIME();

    -- Too old dates (before system go-live)
    SELECT 
        'TooOldDate' AS AnomalyType,
        TransactionID,
        TransactionDate
    FROM fact_transactions
    WHERE TransactionDate < @MinValidDate;

    -- Null dates
    SELECT 
        'NullDate' AS AnomalyType,
        TransactionID
    FROM fact_transactions
    WHERE TransactionDate IS NULL;
END;

-- Checks if BalanceAfter matches previous balance + amount (by Account)
CREATE PROCEDURE usp_dq_check_balance_consistency
    @Tolerance DECIMAL(12,2) = 0.01   -- allow small rounding diffs
AS
BEGIN
    SET NOCOUNT ON;

    WITH Ordered AS (
        SELECT
            TransactionID,
            AccountID,
            TransactionDate,
            Amount,
            BalanceAfter,
            LAG(BalanceAfter) OVER (
                PARTITION BY AccountID
                ORDER BY TransactionDate, TransactionID
            ) AS PrevBalance
        FROM fact_transactions
    ),
    CheckBalance AS (
        SELECT
            TransactionID,
            AccountID,
            TransactionDate,
            Amount,
            PrevBalance,
            BalanceAfter,
            (PrevBalance + Amount) AS ExpectedBalance,
            ABS((PrevBalance + Amount) - BalanceAfter) AS Diff
        FROM Ordered
        WHERE PrevBalance IS NOT NULL
    )
    SELECT *
    FROM CheckBalance
    WHERE Diff > @Tolerance
    ORDER BY Diff DESC;
END;

-- Check weird salary transactions (negative, too frequent, zero, etc.)
CREATE PROCEDURE usp_dq_check_salary_logic
    @MaxSalaryPaymentsPerMonth INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Salary with non-positive amount
    SELECT
        'NonPositiveSalary' AS SalaryIssue,
        TransactionID,
        CustomerID,
        Amount,
        TransactionDate
    FROM fact_transactions
    WHERE IsSalary = 1
      AND Amount <= 0;

    -- 2. Customers with too many salary payments in a month
    WITH SalaryMonthly AS (
        SELECT
            CustomerID,
            DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS Month,
            COUNT(*) AS SalaryCount
        FROM fact_transactions
        WHERE IsSalary = 1
        GROUP BY
            CustomerID,
            DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1)
    )
    SELECT
        'TooManySalariesPerMonth' AS SalaryIssue,
        CustomerID,
        Month,
        SalaryCount
    FROM SalaryMonthly
    WHERE SalaryCount > @MaxSalaryPaymentsPerMonth;

    -- 3. Salary flagged but MerchantName missing (optional rule)
    SELECT
        'SalaryMissingMerchant' AS SalaryIssue,
        TransactionID,
        CustomerID,
        Amount,
        TransactionDate
    FROM fact_transactions
    WHERE IsSalary = 1
      AND (MerchantName IS NULL OR LTRIM(RTRIM(MerchantName)) = '');
END;