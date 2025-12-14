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

-- Create foreign key relationships
ALTER TABLE fact_transactions
ADD CONSTRAINT FK_fact_transactions_customer FOREIGN KEY (CustomerID) REFERENCES dim_customers(CustomerID);

ALTER TABLE fact_transactions
ADD CONSTRAINT FK_fact_transactions_account FOREIGN KEY (AccountID) REFERENCES dim_accounts(AccountID);

ALTER TABLE fact_transactions
ADD CONSTRAINT FK_fact_transactions_region FOREIGN KEY (RegionCode) REFERENCES dim_region(RegionCode);

-- Create indexes for performance optimization
CREATE INDEX IX_fact_transactions_CustomerID_TransactionDate ON fact_transactions (CustomerID, TransactionDate);
CREATE INDEX IX_fact_transactions_MerchantName ON fact_transactions (MerchantName);