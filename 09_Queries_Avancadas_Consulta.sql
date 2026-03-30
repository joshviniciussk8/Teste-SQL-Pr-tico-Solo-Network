-- Etapa 9: Queries Avançadas de Consulta (Leitura)
-- Boas práticas de nomenclatura aplicadas: aliases claros, CTEs descritivas e colunas padronizadas.

/*
Query 1 – Faturamento acumulado (Running Total)
Objetivo: listar o faturamento acumulado mês a mês por cliente.
Requisitos: SUM() OVER (PARTITION BY ... ORDER BY ...), sem subquery correlacionada.
*/
;WITH MonthlyRevenueByCustomer AS
(
    SELECT
        c.CustomerId,
        c.Name AS CustomerName,
        i.ReferenceMonth,
        SUM(i.TotalAmount) AS MonthlyRevenue
    FROM dbo.Invoice AS i
    INNER JOIN dbo.Subscription AS s
        ON s.SubscriptionId = i.SubscriptionId
    INNER JOIN dbo.Customer AS c
        ON c.CustomerId = s.CustomerId
    GROUP BY
        c.CustomerId,
        c.Name,
        i.ReferenceMonth
)
SELECT
    m.CustomerId,
    m.CustomerName,
    m.ReferenceMonth,
    m.MonthlyRevenue,
    SUM(m.MonthlyRevenue) OVER
    (
        PARTITION BY m.CustomerId
        ORDER BY m.ReferenceMonth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotalRevenue
FROM MonthlyRevenueByCustomer AS m
ORDER BY
    m.CustomerName,
    m.ReferenceMonth;


/*
Query 2 – Detecção de Assinaturas Inativas
Objetivo: listar assinaturas Active sem fatura nos últimos 3 meses.
Requisitos: LEFT JOIN, HAVING, uso de datas/YYYYMM.
*/
SELECT
    s.SubscriptionId,
    c.CustomerId,
    c.Name AS CustomerName,
    s.Status AS SubscriptionStatus
FROM dbo.Subscription AS s
INNER JOIN dbo.Customer AS c
    ON c.CustomerId = s.CustomerId
LEFT JOIN dbo.Invoice AS i
    ON i.SubscriptionId = s.SubscriptionId
   AND CONVERT(DATE, CONCAT(i.ReferenceMonth, '01')) >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -2, SYSUTCDATETIME())), MONTH(DATEADD(MONTH, -2, SYSUTCDATETIME())), 1)
   AND CONVERT(DATE, CONCAT(i.ReferenceMonth, '01')) < DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SYSUTCDATETIME()), MONTH(SYSUTCDATETIME()), 1))
WHERE s.Status = 'Active'
GROUP BY
    s.SubscriptionId,
    c.CustomerId,
    c.Name,
    s.Status
HAVING COUNT(i.InvoiceId) = 0
ORDER BY
    c.Name,
    s.SubscriptionId;


/*
Query 3 – Última Fatura por Assinatura (APPLY)
Objetivo: listar clientes e retornar a última fatura de cada assinatura.
Requisitos: OUTER APPLY/CROSS APPLY, TOP 1, ORDER BY.
*/
SELECT
    c.CustomerId,
    c.Name AS CustomerName,
    s.SubscriptionId,
    lastInv.InvoiceId,
    lastInv.ReferenceMonth,
    lastInv.TotalAmount,
    lastInv.CreatedAt
FROM dbo.Customer AS c
INNER JOIN dbo.Subscription AS s
    ON s.CustomerId = c.CustomerId
OUTER APPLY
(
    SELECT TOP (1)
        i.InvoiceId,
        i.ReferenceMonth,
        i.TotalAmount,
        i.CreatedAt
    FROM dbo.Invoice AS i
    WHERE i.SubscriptionId = s.SubscriptionId
    ORDER BY
        i.ReferenceMonth DESC,
        i.InvoiceId DESC
) AS lastInv
ORDER BY
    c.Name,
    s.SubscriptionId;


/*
Query 4 – Comparação (Anti-Join)
Objetivo:
1) Assinaturas sem itens
2) Assinaturas com itens, mas sem faturas
Requisitos: NOT EXISTS, evitar NOT IN.
*/
SELECT
    'SemItens' AS Scenario,
    s.SubscriptionId,
    s.CustomerId,
    s.Status
FROM dbo.Subscription AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.SubscriptionItem AS si
    WHERE si.SubscriptionId = s.SubscriptionId
)

UNION ALL

SELECT
    'ComItensSemFaturas' AS Scenario,
    s.SubscriptionId,
    s.CustomerId,
    s.Status
FROM dbo.Subscription AS s
WHERE EXISTS
(
    SELECT 1
    FROM dbo.SubscriptionItem AS si
    WHERE si.SubscriptionId = s.SubscriptionId
)
AND NOT EXISTS
(
    SELECT 1
    FROM dbo.Invoice AS i
    WHERE i.SubscriptionId = s.SubscriptionId
)
ORDER BY
    Scenario,
    SubscriptionId;
