CREATE TABLE etl_watermark (
    PipelineName NVARCHAR(100) PRIMARY KEY,
    LastProcessedDate DATETIME NOT NULL
);

-- Initial insert for tracking
INSERT INTO etl_watermark (PipelineName, LastProcessedDate)
VALUES ('Pipeline_Load_Transactions', '2025-01-01');