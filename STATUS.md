# Project Status & Evidence Boundary

**Snapshot:** 2026-11-20  
**Status:** Documentation bootstrap; implementation status not verified.

| Area | Current status | Evidence boundary |
|---|---|---|
| GitHub repository | Created | Private repository and main branch verified |
| Product vision | Documented | Based on prior project requirements and consolidation notes |
| Platform domains | Working proposal | 17-domain list; earlier 16/17 discrepancy remains open |
| DB01–DB33 | Architecture catalogue | Design/dictionary artifacts exist; not evidence of deployed database |
| PostgreSQL migrations | Draft/prepared | Not confirmed executed on a target database |
| Tenant RLS | Draft/prepared | Runtime enforcement and tests not verified |
| API/backend | Not verified | Actual application source repository not audited |
| External lender/bank integrations | Not verified | Contracts, API credentials and live connectivity not established |
| Production deployment | Not verified | No production deployment evidence in this bootstrap |

## Open reconciliation items
- Resolve 16 vs 17 product-domain count.
- Reconcile V1.2 lender count: stated 41 vs workbook extraction 40.
- Reconcile workflow stage count: 22 vs 23.
- Resolve `registration_master` canonical FK mapping.
- Complete canonical vendor and finance-ledger reconciliation.
- Review 348 candidate user-reference columns semantically.
- Execute and test tenant RLS in isolated staging.
- Verify source freshness and policy evidence for lender/scheme rules.
- Inspect actual application source before claiming code-level completion.

## Status vocabulary
- `VERIFIED`: supported by current direct evidence.
- `DOCUMENTED`: described in an approved or working artifact.
- `PROPOSED`: design recommendation, not approved implementation.
- `IN_PROGRESS`: active work with evidence of execution.
- `BLOCKED`: cannot proceed without a dependency.
- `NOT_VERIFIED`: insufficient evidence to assert completion.
- `DEFERRED`: intentionally postponed.
