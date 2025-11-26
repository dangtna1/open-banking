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
