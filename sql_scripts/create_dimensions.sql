CREATE TABLE dim_customers (
  CustomerID INT PRIMARY KEY,
  FullName NVARCHAR(50),	
  Age INT,
  AgeBand	NVARCHAR(50),
  IncomeMonthly FLOAT,
  IncomeBand NVARCHAR(50),
  City NVARCHAR(50),
  RegionCode NVARCHAR(10),
  Persona	NVARCHAR(20),
  RiskSegment NVARCHAR(50)
);

CREATE TABLE dim_accounts (
  AccountID INT PRIMARY KEY,
  CustomerID INT,
  ProductType NVARCHAR(50),
  OpenDate DATE,
  IsStudent BIT,
  IsJoint BIT
);
ALTER TABLE dim_accounts ALTER COLUMN IsStudent INT;
ALTER TABLE dim_accounts ALTER COLUMN IsJoint INT;

CREATE TABLE dim_region (
  RegionCode NVARCHAR(10) PRIMARY KEY,
  RegionName NVARCHAR(100),
  ONS_DeprivationIndex DECIMAL(5,2),
  MedianIncome INT,
  MedianRent INT
);