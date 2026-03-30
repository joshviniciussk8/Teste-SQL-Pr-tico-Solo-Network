-- Etapa 6: Auditoria de Invoice

IF OBJECT_ID('dbo.InvoiceAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvoiceAudit
    (
        InvoiceAuditId INT IDENTITY(1,1) NOT NULL,
        InvoiceId INT NOT NULL,
        OperationDateTime DATETIME2(0) NOT NULL
            CONSTRAINT DF_InvoiceAudit_OperationDateTime DEFAULT SYSUTCDATETIME(),
        TotalAmount DECIMAL(18,2) NOT NULL,
        [User] SYSNAME NOT NULL,

        CONSTRAINT PK_InvoiceAudit PRIMARY KEY (InvoiceAuditId),
        CONSTRAINT FK_InvoiceAudit_Invoice FOREIGN KEY (InvoiceId)
            REFERENCES dbo.Invoice (InvoiceId)
    );

    CREATE NONCLUSTERED INDEX IX_InvoiceAudit_InvoiceId
        ON dbo.InvoiceAudit (InvoiceId);
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_Invoice_Audit_Insert
ON dbo.Invoice
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.InvoiceAudit (InvoiceId, OperationDateTime, TotalAmount, [User])
    SELECT
        i.InvoiceId,
        SYSUTCDATETIME(),
        i.TotalAmount,
        SUSER_SNAME()
    FROM inserted i;
END;
GO
