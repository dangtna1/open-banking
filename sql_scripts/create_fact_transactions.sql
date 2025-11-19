CREATE TABLE fact_transactions (
  TransactionID BIGINT PRIMARY KEY,
  AccountID INT,
  CustomerID INT,
  Amount DECIMAL(12,2),
  Currency NVARCHAR(10),
  MerchantName NVARCHAR(200),
  MCC INT,
  Category NVARCHAR(50),
  Channel NVARCHAR(50),
  City NVARCHAR(100),
  RegionCode NVARCHAR(10),
  IsRecurring BIT,
  IsRefund BIT,
  IsSalary BIT,
  BalanceAfter DECIMAL(12,2),
  TransactionDate DATETIME
);

ALTER TABLE [dbo].[fact_transactions]
ALTER COLUMN IsRefund INT;