-- Etapa 4: Procedure de geração de fatura

CREATE OR ALTER PROCEDURE dbo.sp_GenerateInvoice
(
    @SubscriptionId INT,
    @ReferenceMonth CHAR(6)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Subscription s
            WHERE s.SubscriptionId = @SubscriptionId
        )
        BEGIN
            THROW 50001, 'Assinatura não encontrada.', 1;
        END;

        IF @ReferenceMonth NOT LIKE '[1-2][0-9][0-9][0-9][0-1][0-9]'
           OR RIGHT(@ReferenceMonth, 2) NOT BETWEEN '01' AND '12'
        BEGIN
            THROW 50002, 'ReferenceMonth inválido. Use o formato YYYYMM.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Invoice i WITH (UPDLOCK, HOLDLOCK)
            WHERE i.SubscriptionId = @SubscriptionId
              AND i.ReferenceMonth = @ReferenceMonth
        )
        BEGIN
            THROW 50003, 'Já existe fatura para a assinatura e mês informados.', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.SubscriptionItem si
            WHERE si.SubscriptionId = @SubscriptionId
        )
        BEGIN
            THROW 50004, 'A assinatura não possui itens para faturamento.', 1;
        END;

        DECLARE @InvoiceId INT;
        DECLARE @TotalAmount DECIMAL(18,2);

        INSERT INTO dbo.Invoice (SubscriptionId, ReferenceMonth, TotalAmount)
        VALUES (@SubscriptionId, @ReferenceMonth, 0);

        SET @InvoiceId = SCOPE_IDENTITY();

        INSERT INTO dbo.InvoiceItem (InvoiceId, Description, Amount)
        SELECT
            @InvoiceId,
            CASE
                WHEN si.Quantity > 1 THEN CONCAT(si.ProductName, ' x', si.Quantity)
                ELSE si.ProductName
            END,
            CAST(si.MonthlyPrice * si.Quantity AS DECIMAL(18,2))
        FROM dbo.SubscriptionItem si
        WHERE si.SubscriptionId = @SubscriptionId;

        SELECT @TotalAmount = ISNULL(SUM(ii.Amount), 0)
        FROM dbo.InvoiceItem ii
        WHERE ii.InvoiceId = @InvoiceId;

        UPDATE dbo.Invoice
        SET TotalAmount = @TotalAmount
        WHERE InvoiceId = @InvoiceId;

        COMMIT;

        SELECT
            @InvoiceId AS InvoiceId,
            @SubscriptionId AS SubscriptionId,
            @ReferenceMonth AS ReferenceMonth,
            @TotalAmount AS TotalAmount;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK;

        THROW;
    END CATCH
END;
GO

-- Exemplo:
-- EXEC dbo.sp_GenerateInvoice @SubscriptionId = 1, @ReferenceMonth = '202502';
