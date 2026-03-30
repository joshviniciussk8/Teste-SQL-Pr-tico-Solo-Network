-- Etapa 8: Função com Valor de Tabela (Table-Valued Function)
-- Objetivo: visão analítica reutilizável das assinaturas e seus valores mensais
-- Tipo: Inline Table-Valued Function (iTVF)

CREATE OR ALTER FUNCTION dbo.fn_GetSubscriptionMonthlySummary
(
    @ReferenceMonth INT -- formato esperado: YYYYMM (ex.: 202501)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.CustomerId,
        c.Name AS CustomerName,
        s.SubscriptionId,
        @ReferenceMonth AS ReferenceMonth,
        COUNT(si.SubscriptionItemId) AS ItemCount,
        CAST(ISNULL(SUM(si.MonthlyPrice * si.Quantity), 0) AS DECIMAL(18,2)) AS MonthlyTotal,
        s.Status AS SubscriptionStatus
    FROM dbo.Subscription s
    INNER JOIN dbo.Customer c
        ON c.CustomerId = s.CustomerId
    LEFT JOIN dbo.SubscriptionItem si
        ON si.SubscriptionId = s.SubscriptionId
    WHERE (@ReferenceMonth BETWEEN 100001 AND 299912)
      AND ((@ReferenceMonth % 100) BETWEEN 1 AND 12)
    GROUP BY
        c.CustomerId,
        c.Name,
        s.SubscriptionId,
        s.Status
);
GO

-- Exemplo de uso:
-- SELECT * FROM dbo.fn_GetSubscriptionMonthlySummary(202501);
