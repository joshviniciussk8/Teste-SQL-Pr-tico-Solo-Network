-- Etapa 3: Função Escalar (T-SQL)
-- Objetivo: retornar o valor mensal total da assinatura com base nos itens cadastrados

IF OBJECT_ID('dbo.fn_CalculateSubscriptionTotal', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalculateSubscriptionTotal;
GO

CREATE OR ALTER FUNCTION dbo.fn_CalculateSubscriptionTotal
(
    @SubscriptionId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT @Total = ISNULL(SUM(si.MonthlyPrice * si.Quantity), 0)
    FROM dbo.SubscriptionItem si
    WHERE si.SubscriptionId = @SubscriptionId;

    RETURN @Total;
END;
GO

-- Exemplo de uso:
-- SELECT dbo.fn_CalculateSubscriptionTotal(1) AS TotalMensal;
