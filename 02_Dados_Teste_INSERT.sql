-- Etapa 2: Carga inicial de dados (INSERT)
-- Execute este script após o 01_Modelagem_Dados_DDL.sql

SET NOCOUNT ON;

DELETE FROM dbo.InvoiceItem;
DELETE FROM dbo.Invoice;
DELETE FROM dbo.SubscriptionItem;
DELETE FROM dbo.Subscription;
DELETE FROM dbo.Customer;

--resetando o identity para garantir que os IDs comecem do 1
DBCC CHECKIDENT ('dbo.InvoiceItem', RESEED, 0);
DBCC CHECKIDENT ('dbo.Invoice', RESEED, 0);
DBCC CHECKIDENT ('dbo.SubscriptionItem', RESEED, 0);
DBCC CHECKIDENT ('dbo.Subscription', RESEED, 0);

DECLARE @Customers TABLE
(
    CustomerId UNIQUEIDENTIFIER,
    Email NVARCHAR(320)
);

INSERT INTO dbo.Customer (Name, Email)
OUTPUT INSERTED.CustomerId, INSERTED.Email INTO @Customers (CustomerId, Email)
VALUES
    (N'Ana Souza', N'ana.souza@exemplo.com'),
    (N'Bruno Lima', N'bruno.lima@exemplo.com'),
    (N'Carla Mendes', N'carla.mendes@exemplo.com'),
    (N'Diego Alves', N'diego.alves@exemplo.com'),
    (N'Eduarda Rocha', N'eduarda.rocha@exemplo.com');

DECLARE @Subscriptions TABLE
(
    SubscriptionId INT,
    Email NVARCHAR(320)
);

DECLARE @SubscriptionsRaw TABLE
(
    SubscriptionId INT,
    CustomerId UNIQUEIDENTIFIER
);

INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
OUTPUT INSERTED.SubscriptionId, INSERTED.CustomerId INTO @SubscriptionsRaw (SubscriptionId, CustomerId)
SELECT c.CustomerId, src.StartDate, src.EndDate, src.Status
FROM
(
    VALUES
        (N'ana.souza@exemplo.com', CAST('2024-01-01' AS DATE), NULL, 'Active'),
        (N'bruno.lima@exemplo.com', CAST('2024-02-01' AS DATE), NULL, 'Suspended'),
        (N'carla.mendes@exemplo.com', CAST('2024-03-01' AS DATE), NULL, 'Active'),
        (N'diego.alves@exemplo.com', CAST('2024-01-15' AS DATE), CAST('2024-11-30' AS DATE), 'Canceled'),
        (N'eduarda.rocha@exemplo.com', CAST('2024-04-01' AS DATE), NULL, 'Active')
) AS src (Email, StartDate, EndDate, Status)
JOIN @Customers c
    ON c.Email = src.Email;

INSERT INTO @Subscriptions (SubscriptionId, Email)
SELECT sr.SubscriptionId, c.Email
FROM @SubscriptionsRaw sr
JOIN @Customers c
    ON c.CustomerId = sr.CustomerId;

INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
SELECT s.SubscriptionId, i.ProductName, i.MonthlyPrice, i.Quantity
FROM
(
    VALUES
        (N'ana.souza@exemplo.com', N'Plano Pro', 99.90, 1),
        (N'ana.souza@exemplo.com', N'Suporte Premium', 29.90, 1),

        (N'bruno.lima@exemplo.com', N'Plano Basic', 49.90, 2),
        (N'bruno.lima@exemplo.com', N'Addon Backup', 19.90, 1),

        (N'carla.mendes@exemplo.com', N'Plano Enterprise', 199.90, 1),
        (N'carla.mendes@exemplo.com', N'Usuário Extra', 15.00, 3),

        (N'diego.alves@exemplo.com', N'Plano Starter', 29.90, 1),
        (N'diego.alves@exemplo.com', N'Relatórios Avançados', 39.90, 1),

        (N'eduarda.rocha@exemplo.com', N'Plano Plus', 79.90, 1),
        (N'eduarda.rocha@exemplo.com', N'Integração API', 49.90, 1),
        (N'eduarda.rocha@exemplo.com', N'Suporte Prioritário', 24.90, 1)
) AS i (Email, ProductName, MonthlyPrice, Quantity)
JOIN @Subscriptions s
    ON s.Email = i.Email;

DECLARE @Invoices TABLE
(
    InvoiceId INT,
    SubscriptionId INT,
    ReferenceMonth CHAR(6)
);

INSERT INTO dbo.Invoice (SubscriptionId, ReferenceMonth, TotalAmount)
OUTPUT INSERTED.InvoiceId, INSERTED.SubscriptionId, INSERTED.ReferenceMonth
INTO @Invoices (InvoiceId, SubscriptionId, ReferenceMonth)
SELECT s.SubscriptionId, i.ReferenceMonth, i.TotalAmount
FROM
(
    VALUES
        (N'ana.souza@exemplo.com', '202501', 129.80),
        (N'bruno.lima@exemplo.com', '202501', 119.70),
        (N'carla.mendes@exemplo.com', '202501', 244.90),
        (N'diego.alves@exemplo.com', '202501', 69.80),
        (N'eduarda.rocha@exemplo.com', '202501', 154.70)
) AS i (Email, ReferenceMonth, TotalAmount)
JOIN @Subscriptions s
    ON s.Email = i.Email;

INSERT INTO dbo.InvoiceItem (InvoiceId, Description, Amount)
SELECT inv.InvoiceId, src.Description, src.Amount
FROM
(
    VALUES
        (N'ana.souza@exemplo.com', '202501', N'Plano Pro', 99.90),
        (N'ana.souza@exemplo.com', '202501', N'Suporte Premium', 29.90),

        (N'bruno.lima@exemplo.com', '202501', N'Plano Basic x2', 99.80),
        (N'bruno.lima@exemplo.com', '202501', N'Addon Backup', 19.90),

        (N'carla.mendes@exemplo.com', '202501', N'Plano Enterprise', 199.90),
        (N'carla.mendes@exemplo.com', '202501', N'Usuário Extra x3', 45.00),

        (N'diego.alves@exemplo.com', '202501', N'Plano Starter', 29.90),
        (N'diego.alves@exemplo.com', '202501', N'Relatórios Avançados', 39.90),

        (N'eduarda.rocha@exemplo.com', '202501', N'Plano Plus', 79.90),
        (N'eduarda.rocha@exemplo.com', '202501', N'Integração API', 49.90),
        (N'eduarda.rocha@exemplo.com', '202501', N'Suporte Prioritário', 24.90)
) AS src (Email, ReferenceMonth, Description, Amount)
JOIN @Subscriptions s
    ON s.Email = src.Email
JOIN @Invoices inv
    ON inv.SubscriptionId = s.SubscriptionId
   AND inv.ReferenceMonth = src.ReferenceMonth;

SELECT 'Carga concluída com sucesso.' AS Resultado;
