-- Etapa 7: Query Analítica - Ranking (Top 3 clientes que mais faturaram no último ano)

;WITH FaturamentoUltimoAno AS
(
    SELECT
        c.CustomerId,
        c.Name AS Cliente,
        SUM(i.TotalAmount) AS TotalFaturado
    FROM dbo.Invoice i
    INNER JOIN dbo.Subscription s
        ON s.SubscriptionId = i.SubscriptionId
    INNER JOIN dbo.Customer c
        ON c.CustomerId = s.CustomerId
    WHERE i.CreatedAt >= DATEADD(YEAR, -1, SYSUTCDATETIME())
    GROUP BY
        c.CustomerId,
        c.Name
), Ranking AS
(
    SELECT
        f.CustomerId,
        f.Cliente,
        f.TotalFaturado,
        DENSE_RANK() OVER (ORDER BY f.TotalFaturado DESC) AS Posicao
    FROM FaturamentoUltimoAno f
)
SELECT TOP (3)
    r.Posicao,
    r.CustomerId,
    r.Cliente,
    r.TotalFaturado
FROM Ranking r
ORDER BY
    r.TotalFaturado DESC,
    r.Cliente ASC;
