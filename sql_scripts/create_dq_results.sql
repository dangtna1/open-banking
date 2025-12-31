CREATE TABLE dq_results (
    CheckName VARCHAR(100),
    IssueCount INT,
    RunDate DATETIME DEFAULT SYSDATETIME()
);