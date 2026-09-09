# Fund payment harness

This is a read-only smoke harness for the deployed Fund Management API. It is
intended to catch the production symptoms seen in the partial-payment incident:

- the frontend health endpoint is not healthy;
- negative or inconsistent due balances;
- a period where `amountPaid + outstandingAmount` no longer equals
  `amountDue`.

The backend remains the source of truth for FIFO allocation and reconciliation.
The public payment-history request is also used as a backend/API smoke check.
This harness does not write transactions, reallocate payments, or mutate live
data.

## Run against a deployed environment

```bash
BASE_URL=https://quybpdev.apps.drgdevlab.com \
MEMBER_CODE=THOTV17094 YEAR=2026 \
./harness/check-public-payment.sh
```

The output lists any currently partial periods. It does not claim that two
payments were merged because the public API intentionally exposes period
aggregates, not the private payment ledger.
