-- SQL Server 2019+
-- Etapa 1: Modelagem de Dados (DDL)

IF OBJECT_ID('dbo.InvoiceItem', 'U') IS NOT NULL
    DROP TABLE dbo.InvoiceItem;

IF OBJECT_ID('dbo.Invoice', 'U') IS NOT NULL
    DROP TABLE dbo.Invoice;

IF OBJECT_ID('dbo.SubscriptionItem', 'U') IS NOT NULL
    DROP TABLE dbo.SubscriptionItem;

IF OBJECT_ID('dbo.Subscription', 'U') IS NOT NULL
    DROP TABLE dbo.Subscription;

IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL
    DROP TABLE dbo.Customer;
GO

CREATE TABLE dbo.Customer
(
    CustomerId UNIQUEIDENTIFIER NOT NULL --Guid
        CONSTRAINT DF_Customer_CustomerId DEFAULT NEWSEQUENTIALID(),
    Name NVARCHAR(200) NOT NULL,
    Email NVARCHAR(320) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Customer_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Customer PRIMARY KEY (CustomerId),
    CONSTRAINT UQ_Customer_Email UNIQUE (Email)
);
GO

CREATE TABLE dbo.Subscription
(
    SubscriptionId INT IDENTITY(1,1) NOT NULL,
    CustomerId UNIQUEIDENTIFIER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Subscription_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Subscription PRIMARY KEY (SubscriptionId),
    CONSTRAINT FK_Subscription_Customer FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customer (CustomerId),
    CONSTRAINT CK_Subscription_Status CHECK (Status IN ('Active', 'Canceled', 'Suspended')),
    CONSTRAINT CK_Subscription_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

CREATE TABLE dbo.SubscriptionItem
(
    SubscriptionItemId INT IDENTITY(1,1) NOT NULL,
    SubscriptionId INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    MonthlyPrice DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_SubscriptionItem_MonthlyPrice DEFAULT (0),
    Quantity INT NOT NULL
        CONSTRAINT DF_SubscriptionItem_Quantity DEFAULT (1),

    CONSTRAINT PK_SubscriptionItem PRIMARY KEY (SubscriptionItemId),
    CONSTRAINT FK_SubscriptionItem_Subscription FOREIGN KEY (SubscriptionId)
        REFERENCES dbo.Subscription (SubscriptionId),
    CONSTRAINT CK_SubscriptionItem_MonthlyPrice CHECK (MonthlyPrice >= 0),
    CONSTRAINT CK_SubscriptionItem_Quantity CHECK (Quantity > 0)
);
GO

CREATE TABLE dbo.Invoice --Fatura
(
    InvoiceId INT IDENTITY(1,1) NOT NULL,
    SubscriptionId INT NOT NULL,
    ReferenceMonth CHAR(6) NOT NULL, -- YYYYMM
    TotalAmount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Invoice_TotalAmount DEFAULT (0),
    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Invoice_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Invoice PRIMARY KEY (InvoiceId),
    CONSTRAINT FK_Invoice_Subscription FOREIGN KEY (SubscriptionId)
        REFERENCES dbo.Subscription (SubscriptionId),
    CONSTRAINT UQ_Invoice_Subscription_ReferenceMonth UNIQUE (SubscriptionId, ReferenceMonth),
    CONSTRAINT CK_Invoice_ReferenceMonth CHECK
    (
        ReferenceMonth LIKE '[1-2][0-9][0-9][0-9][0-1][0-9]' --revisar
        AND RIGHT(ReferenceMonth, 2) BETWEEN '01' AND '12'
    ),
    CONSTRAINT CK_Invoice_TotalAmount CHECK (TotalAmount >= 0)
);
GO

CREATE TABLE dbo.InvoiceItem
(
    InvoiceItemId INT IDENTITY(1,1) NOT NULL,
    InvoiceId INT NOT NULL,
    Description NVARCHAR(300) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_InvoiceItem PRIMARY KEY (InvoiceItemId),
    CONSTRAINT FK_InvoiceItem_Invoice FOREIGN KEY (InvoiceId)
        REFERENCES dbo.Invoice (InvoiceId),
    CONSTRAINT CK_InvoiceItem_Amount CHECK (Amount >= 0)
);
GO

--consultas por CustomerId são frequentes (relacionamento Customer -> Subscription)
-- e este índice reduz leituras na busca de assinaturas por cliente.
CREATE NONCLUSTERED INDEX IX_Subscription_CustomerId
    ON dbo.Subscription (CustomerId);

CREATE NONCLUSTERED INDEX IX_SubscriptionItem_SubscriptionId
    ON dbo.SubscriptionItem (SubscriptionId);

CREATE NONCLUSTERED INDEX IX_Invoice_SubscriptionId
    ON dbo.Invoice (SubscriptionId);

CREATE NONCLUSTERED INDEX IX_InvoiceItem_InvoiceId
    ON dbo.InvoiceItem (InvoiceId);
GO
