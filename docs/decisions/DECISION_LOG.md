# Architecture Decision Log

## ADR-0001 — Canonical customer and business records
**Decision:** DB01 customer master and DB02 business master are the intended canonical records.  
**Rationale:** Prevent duplicate identities and fragmented lifecycle history.  
**Status:** Documented; implementation must be verified.

## ADR-0002 — Single finance ledger
**Decision:** DB25 is the intended canonical finance ledger. Legacy transactions, receipts, fees, advances and commissions must be reconciled into it rather than creating parallel ledgers.  
**Status:** Documented; reconciliation pending.

## ADR-0003 — Evidence-backed lender and scheme policies
**Decision:** Policy rules require source evidence, reviewer, version and effective date.  
**Rationale:** Public product criteria and scheme rules can change and do not prove sanction.  
**Status:** Documented.

## ADR-0004 — Logical domains are not mandatory microservices
**Decision:** DB01–DB33 and the product-domain tree are logical boundaries. Deployment topology must be chosen after codebase, ownership and scaling review.  
**Status:** Working architecture principle.

## ADR-0005 — No unsupported completion claims
**Decision:** Draft schemas, API blueprints, migration bundles and roadmaps are not considered deployed or implemented without runtime evidence.  
**Status:** Adopted documentation rule.
