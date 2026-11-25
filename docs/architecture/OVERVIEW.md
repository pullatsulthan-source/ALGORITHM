# ALGORITHM — Architecture Overview

## Product lifecycle
`Idea → Customer & Business Profile → Financial Intelligence → Project Design → Scheme/Lender Matching → Application → Registration & Compliance → Implementation → Growth → Market Expansion`

## Operating layers
### Intelligence
Customer and business intelligence; industry and project intelligence; financial and credit analysis; lender, product and scheme intelligence; evidence-backed AI assistance.

### Operations
CRM and lead qualification; consulting case management; document collection; application preparation and submission tracking; bank follow-ups; registration; vendor procurement; project implementation; payments and accounts; after-service.

### Ecosystem
Customer portal; internal office console; agency and consultant workflows; partner and vendor access; future institutional interfaces. Each portal must use the same governed core records and authorization model.

## Canonical data principle
One customer can have multiple businesses; each business can have multiple projects; each project can have multiple applications; each application can have multiple lender submissions. Avoid duplicate customer identities and parallel finance ledgers.

## Reference service boundaries
These are logical boundaries, not a mandate to create 33 microservices:
- Identity, tenancy and access
- Customer, lead and business profile
- Financial and credit intelligence
- Project and industry intelligence
- Lender, product, policy and scheme intelligence
- Documents and evidence
- CRM, consulting and application operations
- Workflow, tasks and communication
- Registration and compliance
- Vendor, marketplace and implementation
- Payments, accounts and commissions
- Analytics, AI, notifications and governance

## Integration rules
- Use stable internal IDs and explicit external identifiers.
- Record source, retrieval time, effective date, reviewer and confidence.
- Make integrations idempotent and observable.
- Keep secrets out of source control.
- Use retries and dead-letter handling for asynchronous workflows.
- Do not expose lender credentials or privileged data to client applications.
