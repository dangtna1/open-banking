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

