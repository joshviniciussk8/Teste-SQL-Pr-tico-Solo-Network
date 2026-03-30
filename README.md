# Teste SQL Prático – Solo Network

## Como executar os scripts

> Ambiente alvo: **SQL Server 2019+**

Execute na ordem abaixo:

1. `01-ddl.sql`  
   Cria tabelas, constraints e índices.
2. `02-dml.sql`  
   Limpa os dados existentes e insere massa de teste.
3. `03-functions.sql`  
   Cria função escalar e função tabular.
4. `04-procedures.sql`  
   Cria a procedure `sp_GenerateInvoice`.
5. `05-views.sql`  
   Cria a view analítica `vw_AnaliticoFaturamento`.
6. `06-triggers.sql`  
   Cria estrutura de auditoria e trigger de insert em `Invoice`.
7. `07-queries.sql`  
   Contém consultas analíticas e avançadas para leitura.

### Exemplo rápido de execução

```sql
-- Após executar 01 a 06, rode consultas:
SELECT * FROM dbo.vw_AnaliticoFaturamento;
SELECT dbo.fn_CalculateSubscriptionTotal(1) AS TotalAssinatura;
SELECT * FROM dbo.fn_GetSubscriptionMonthlySummary(202501);
EXEC dbo.sp_GenerateInvoice @SubscriptionId = 1, @ReferenceMonth = '202502';
```

---

## Premissas adotadas

- `CustomerId` definido como `UNIQUEIDENTIFIER` com `DEFAULT NEWSEQUENTIALID()`.
- `ReferenceMonth` representado como `CHAR(6)` no formato `YYYYMM`.
- Valores monetários com `DECIMAL(18,2)`.
- Status da assinatura limitado a: `Active`, `Canceled`, `Suspended`.
- Uma única fatura por assinatura/mês (`UNIQUE (SubscriptionId, ReferenceMonth)`).
- Script `02-dml.sql` é reexecutável (apaga dados e reinicia `IDENTITY`).

---

## Decisões técnicas

- Modelagem com **PK, FK, UNIQUE, CHECK, DEFAULT** para garantir integridade.
- Índices não clusterizados criados em colunas de relacionamento:
  - `Subscription(CustomerId)`
  - `SubscriptionItem(SubscriptionId)`
  - `Invoice(SubscriptionId)`
  - `InvoiceItem(InvoiceId)`
  - `InvoiceAudit(InvoiceId)`
- `sp_GenerateInvoice` implementada com:
  - `BEGIN TRAN`
  - `TRY/CATCH`
  - `COMMIT/ROLLBACK`
  - `THROW`
  - validação de idempotência (checagem + constraint única)
- Abordagem **set-based** (sem cursor).
- `fn_GetSubscriptionMonthlySummary` implementada como **Inline TVF** (melhor otimização pelo otimizador).
- Auditoria de insert em `Invoice` via trigger com `SUSER_SNAME()`.

---

