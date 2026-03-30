-- Etapa 5: View Analítica

CREATE OR ALTER VIEW dbo.vw_AnaliticoFaturamento
AS
SELECT
    c.Name AS Cliente,
    s.SubscriptionId AS Assinatura,
    i.ReferenceMonth AS MesReferencia,
    i.TotalAmount AS TotalFaturado,
    COUNT(ii.InvoiceItemId) AS QuantidadeItens
FROM dbo.Invoice i
JOIN dbo.Subscription s
    ON s.SubscriptionId = i.SubscriptionId
JOIN dbo.Customer c
    ON c.CustomerId = s.CustomerId
LEFT JOIN dbo.InvoiceItem ii
    ON ii.InvoiceId = i.InvoiceId
GROUP BY
    c.Name,
    s.SubscriptionId,
    i.ReferenceMonth,
    i.TotalAmount;
GO

-- Exemplo:
-- SELECT * FROM dbo.vw_AnaliticoFaturamento;
