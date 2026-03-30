-- Etapa 3: Função Escalar (T-SQL)
-- Objetivo: retornar o valor mensal total da assinatura

CREATE OR ALTER FUNCTION dbo.fn_CalculateSubscriptionTotal
(
    @SubscriptionId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT
        @Total = COALESCE(SUM(si.MonthlyPrice * si.Quantity), 0)        
    FROM dbo.SubscriptionItem si
    WHERE si.SubscriptionId = @SubscriptionId;

    RETURN @Total;
END;
GO

-- Exemplo de uso
--SELECT dbo.fn_CalculateSubscriptionTotal(1) AS MonthlyTotal;
