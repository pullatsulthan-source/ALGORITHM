# DB01–DB33 Database Domain Catalogue

This catalogue records the logical domain map from the consolidated architecture work. It is not a claim that all tables have been deployed or runtime-tested.

| Domain | Scope |
|---|---|
| DB01 | Customer & Lead Intelligence |
| DB02 | Business Intelligence |
| DB03 | Industry Intelligence |
| DB04 | Project Intelligence |
| DB05 | Financial Intelligence |
| DB06 | Banking & Credit Intelligence |
| DB07 | Document Intelligence |
| DB08 | Lender Master Intelligence |
| DB09 | All-India Bank Branch & Hierarchy |
| DB10 | Loan Product Intelligence |
| DB11 | Lender Policy Engine |
| DB12 | Sanction Authority Intelligence |
| DB13 | Scheme Intelligence |
| DB14 | Scheme Application Intelligence |
| DB15 | Lender-Scheme Mapping |
| DB16 | Consultancy & Service Management |
| DB17 | Application Management |
| DB18 | Workflow & Task Management |
| DB19 | Bank Follow-up Intelligence |
| DB20 | Registration & Compliance |
| DB21 | Project Implementation |
| DB22 | Customer Communication |
| DB23 | Partner & DSA Management |
| DB24 | Commission Management |
| DB25 | Payment & Accounts |
| DB26 | Vendor & Marketplace |
| DB27 | Customer After-Service |
| DB28 | Analytics & BI |
| DB29 | Evidence & Source Intelligence |
| DB30 | AI Intelligence & Decision Engine |
| DB31 | Notifications & Automation |
| DB32 | User, Tenant & Access Governance |
| DB33 | Consent, Privacy & Data Governance |

## Canonical ownership decisions
- DB01 `customer_master` is the canonical customer.
- DB02 `business_master` is the canonical business.
- DB21 `vendor` is canonical; DB26 marketplace profile extends it.
- DB25 finance accounts/journals/journal lines form the intended single finance ledger; legacy transactions require reconciliation.
- DB32 users are global identities; tenants are root tenant records; memberships connect users to tenants.
- DB07 document instances are canonical file records; DB29 evidence records capture provenance and verification.
- DB33 consent records are the canonical purpose-specific consent records.
- A canonical `registration_master` is required; the earlier unresolved FK mapping must be closed.

## Migration gate
Before applying any DDL: inspect the target database, take and verify a restorable backup, run migrations in isolated staging, validate constraints and row-level security, test tenant isolation, and obtain explicit deployment approval. Draft SQL must never be treated as executed SQL.
