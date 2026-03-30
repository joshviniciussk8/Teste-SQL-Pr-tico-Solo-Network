-- Etapa 2: Carga inicial de dados (DML)

SET NOCOUNT ON;

BEGIN TRAN;

-- 1) Clientes
INSERT INTO dbo.Customer (Name, Email)
SELECT v.Name, v.Email
FROM (VALUES
    (N'Ana Souza',       N'ana.souza@demo.com'),
    (N'Bruno Lima',      N'bruno.lima@demo.com'),
    (N'Carla Mendes',    N'carla.mendes@demo.com'),
    (N'Diego Alves',     N'diego.alves@demo.com'),
    (N'Elisa Rocha',     N'elisa.rocha@demo.com')
) v(Name, Email)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Customer c
    WHERE c.Email = v.Email
);

DECLARE
    @CustomerAna UNIQUEIDENTIFIER,
    @CustomerBruno UNIQUEIDENTIFIER,
    @CustomerCarla UNIQUEIDENTIFIER,
    @CustomerDiego UNIQUEIDENTIFIER,
    @CustomerElisa UNIQUEIDENTIFIER;

SELECT @CustomerAna   = CustomerId FROM dbo.Customer WHERE Email = N'ana.souza@demo.com';
SELECT @CustomerBruno = CustomerId FROM dbo.Customer WHERE Email = N'bruno.lima@demo.com';
SELECT @CustomerCarla = CustomerId FROM dbo.Customer WHERE Email = N'carla.mendes@demo.com';
SELECT @CustomerDiego = CustomerId FROM dbo.Customer WHERE Email = N'diego.alves@demo.com';
SELECT @CustomerElisa = CustomerId FROM dbo.Customer WHERE Email = N'elisa.rocha@demo.com';

-- 2) Assinaturas (1 por cliente)
IF NOT EXISTS (SELECT 1 FROM dbo.Subscription WHERE CustomerId = @CustomerAna AND StartDate = '2025-01-01')
    INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
    VALUES (@CustomerAna, '2025-01-01', NULL, 'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Subscription WHERE CustomerId = @CustomerBruno AND StartDate = '2025-02-01')
    INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
    VALUES (@CustomerBruno, '2025-02-01', NULL, 'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Subscription WHERE CustomerId = @CustomerCarla AND StartDate = '2024-10-01')
    INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
    VALUES (@CustomerCarla, '2024-10-01', '2025-01-31', 'Canceled');

IF NOT EXISTS (SELECT 1 FROM dbo.Subscription WHERE CustomerId = @CustomerDiego AND StartDate = '2025-03-01')
    INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
    VALUES (@CustomerDiego, '2025-03-01', NULL, 'Suspended');

IF NOT EXISTS (SELECT 1 FROM dbo.Subscription WHERE CustomerId = @CustomerElisa AND StartDate = '2025-01-15')
    INSERT INTO dbo.Subscription (CustomerId, StartDate, EndDate, Status)
    VALUES (@CustomerElisa, '2025-01-15', NULL, 'Active');

DECLARE
    @SubAna INT,
    @SubBruno INT,
    @SubCarla INT,
    @SubDiego INT,
    @SubElisa INT;

SELECT @SubAna   = SubscriptionId FROM dbo.Subscription WHERE CustomerId = @CustomerAna   AND StartDate = '2025-01-01';
SELECT @SubBruno = SubscriptionId FROM dbo.Subscription WHERE CustomerId = @CustomerBruno AND StartDate = '2025-02-01';
SELECT @SubCarla = SubscriptionId FROM dbo.Subscription WHERE CustomerId = @CustomerCarla AND StartDate = '2024-10-01';
SELECT @SubDiego = SubscriptionId FROM dbo.Subscription WHERE CustomerId = @CustomerDiego AND StartDate = '2025-03-01';
SELECT @SubElisa = SubscriptionId FROM dbo.Subscription WHERE CustomerId = @CustomerElisa AND StartDate = '2025-01-15';

-- 3) Itens da assinatura (multiplos por assinatura)
IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubAna AND ProductName = N'Plano Streaming')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubAna, N'Plano Streaming', 39.90, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubAna AND ProductName = N'Pacote Canais Esportes')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubAna, N'Pacote Canais Esportes', 24.90, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubBruno AND ProductName = N'Plano SaaS Basico')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubBruno, N'Plano SaaS Basico', 99.00, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubBruno AND ProductName = N'Usuarios Adicionais')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubBruno, N'Usuarios Adicionais', 20.00, 3);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubCarla AND ProductName = N'Assinatura Revista Digital')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubCarla, N'Assinatura Revista Digital', 15.50, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubCarla AND ProductName = N'Acesso Arquivo Premium')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubCarla, N'Acesso Arquivo Premium', 12.00, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubDiego AND ProductName = N'Plataforma Cursos')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubDiego, N'Plataforma Cursos', 59.90, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubDiego AND ProductName = N'Mentoria Mensal')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubDiego, N'Mentoria Mensal', 120.00, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubElisa AND ProductName = N'Plano Cloud Storage')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubElisa, N'Plano Cloud Storage', 49.90, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionItem WHERE SubscriptionId = @SubElisa AND ProductName = N'Backup Avancado')
    INSERT INTO dbo.SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity)
    VALUES (@SubElisa, N'Backup Avancado', 19.90, 1);

COMMIT TRAN;

-- Validacao rapida
SELECT
    c.CustomerId,
    c.Name,
    c.Email,
    s.SubscriptionId,
    s.Status,
    COUNT(si.SubscriptionItemId) AS TotalItens
FROM dbo.Customer c
INNER JOIN dbo.Subscription s ON s.CustomerId = c.CustomerId
INNER JOIN dbo.SubscriptionItem si ON si.SubscriptionId = s.SubscriptionId
GROUP BY c.CustomerId, c.Name, c.Email, s.SubscriptionId, s.Status
ORDER BY c.Name;
