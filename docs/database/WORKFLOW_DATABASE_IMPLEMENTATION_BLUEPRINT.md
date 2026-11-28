# ALGORITHM — Workflow & Database Implementation Blueprint

**Status:** Proposed implementation blueprint. It is not evidence of deployed services, executed migrations, or a live database.

## 1. Implementation workflow

### 1.1 Product lifecycle
`Idea → Customer & Business Profile → Financial Intelligence → Project Design → Scheme/Lender Matching → Application → Registration & Compliance → Implementation → Growth → Market Expansion`

### 1.2 Operational state machine
Use explicit state transitions rather than free-form status updates. Every transition records the actor, tenant, timestamp, prior state, new state, reason, source and correlation ID.

| Aggregate | Suggested states (initial working set) |
|---|---|
| Lead | NEW, CONTACTED, QUALIFIED, CONVERTED, ON_HOLD, CLOSED |
| Customer | ACTIVE, INACTIVE, RESTRICTED, MERGED_PENDING_REVIEW |
| Business | DRAFT, PROFILE_PENDING, VERIFIED, ACTIVE, INACTIVE |
| Project | IDEA, DISCOVERY, FEASIBILITY, DPR_PREPARATION, FINANCE_READY, APPROVED, IMPLEMENTING, OPERATIONAL, ON_HOLD, CLOSED |
| Application | DRAFT, DOCUMENTS_PENDING, READINESS_REVIEW, READY_TO_SUBMIT, SUBMITTED, QUERY_RECEIVED, RESUBMISSION_REQUIRED, SANCTIONED, REJECTED, WITHDRAWN, CLOSED |
| Lender submission | PREPARED, SUBMITTED, ACKNOWLEDGED, UNDER_REVIEW, QUERY, SANCTIONED, DECLINED, WITHDRAWN |
| Registration | NOT_STARTED, DOCUMENTS_PENDING, FILED, UNDER_REVIEW, QUERY, APPROVED, REJECTED, COMPLETED |
| Implementation | NOT_STARTED, PLANNED, IN_PROGRESS, BLOCKED, MILESTONE_REVIEW, COMPLETED, CANCELLED |

These are workflow proposals, not approved statutory or lender statuses. Map external statuses to internal states through versioned mapping tables; preserve the original external value.

### 1.3 End-to-end orchestration
1. Capture lead with source, consent basis, purpose and deduplication signals.
2. Resolve or create the canonical customer; possible duplicates go to human review.
3. Link one customer to zero or more businesses; never create a second customer merely because another business is added.
4. Link each business to multiple projects; preserve project versions and source evidence.
5. Build financial and credit snapshots from dated, sourced inputs. Store calculation version and assumptions.
6. Run independent assessments: Lead Quality, Credit Readiness, Scheme Match, Lender Match and Application Readiness. Never collapse these into one score.
7. Create an application and one or more lender submissions. Each submission has its own status, documents, communications and decision evidence.
8. Track registration/compliance and implementation as linked workstreams, not as overwritten application statuses.
9. Post financial events through the canonical finance ledger only; reconcile imported/legacy transactions before posting.
10. Close the case only after required tasks, financial reconciliation and customer communication are complete.

### 1.4 Workflow engine rules
- Every workflow definition is versioned; every running instance pins the version it started with.
- A transition must pass a server-side guard: tenant access, actor permission, required fields, prerequisites and allowed transition.
- Tasks are durable records with owner/team, due date, priority, SLA, status and escalation policy.
- Events use an outbox pattern so database commits and asynchronous notifications cannot silently diverge.
- Consumers must be idempotent. Use unique event IDs, retry policy and dead-letter handling.
- External callbacks are authenticated, signature-checked where supported, deduplicated and logged.
- AI may summarize, extract and recommend. It must not autonomously sanction finance, alter lender policy, make compliance determinations or overwrite verified source data.
- Unknown eligibility remains UNKNOWN/REVIEW; it is not an automatic FAIL.
- Human review is required for material credit, eligibility, policy, compliance and data-merge decisions.

## 2. Canonical database model

### 2.1 Core relationship graph
`tenant → memberships/users`
`customer → customer_business_links → business → projects → applications → lender_submissions`

Supporting links:
- A customer may have multiple businesses.
- A business may have multiple projects.
- A project may have multiple applications.
- An application may have multiple lender submissions.
- Documents are canonical file records; evidence records link a document or external source to a claim, decision or policy.
- A vendor is canonical in DB21; DB26 adds marketplace-specific profile/listing data.
- DB25 is the single finance ledger boundary.
- Consent is purpose-specific and belongs to DB33.
- User identities are global; tenant memberships define tenant access.

### 2.2 Shared columns and controls
For tenant-scoped business tables, use (where applicable):
- `id`: UUID primary key.
- `tenant_id`: non-null FK to tenant.
- `created_at`, `created_by`, `updated_at`, `updated_by`.
- `record_version`: optimistic concurrency/version counter.
- `source_system`, `source_record_id`: external provenance where applicable.
- `deleted_at`: nullable soft-delete marker only where retention policy permits; never use it to erase legal/audit history.

Use UTC timestamps, explicit currency codes, decimal numeric types for money (never floating point), constrained enumerations/reference tables, and unique constraints for idempotency. Do not duplicate personal data into operational tables when a canonical FK suffices.

### 2.3 DB01–DB33 bounded data domains
Keep the approved catalogue numbering and ownership:
- DB01 Customer & Lead Intelligence — canonical `customer_master`, leads and identity resolution.
- DB02 Business Intelligence — canonical `business_master` and customer-business links.
- DB03 Industry Intelligence — industry classifications, source-backed sector facts.
- DB04 Project Intelligence — project master, versions, feasibility and DPR references.
- DB05 Financial Intelligence — financial profiles, statements, ratios and dated snapshots.
- DB06 Banking & Credit Intelligence — credit facilities, obligations and credit snapshots.
- DB07 Document Intelligence — canonical document metadata, storage references and access classification.
- DB08 Lender Master Intelligence — lender entities and institutional identifiers.
- DB09 All-India Bank Branch & Hierarchy — bank/branch hierarchy and external identifiers.
- DB10 Loan Product Intelligence — product catalogue and versioned product terms.
- DB11 Lender Policy Engine — policy versions, source evidence, reviewer and effective dates.
- DB12 Sanction Authority Intelligence — authority hierarchy and approval limits with provenance.
- DB13 Scheme Intelligence — scheme master and versioned guidelines.
- DB14 Scheme Application Intelligence — scheme-specific application requirements and mappings.
- DB15 Lender-Scheme Mapping — many-to-many mapping with evidence and validity dates.
- DB16 Consultancy & Service Management — service cases, engagements and deliverables.
- DB17 Application Management — canonical applications and lender submissions.
- DB18 Workflow & Task Management — workflow definitions/instances, transitions, tasks and SLAs.
- DB19 Bank Follow-up Intelligence — follow-ups, meetings, queries and outcomes.
- DB20 Registration & Compliance — canonical `registration_master` and compliance cases; FK ownership must be resolved before DDL.
- DB21 Project Implementation — implementation plans, milestones and canonical vendor.
- DB22 Customer Communication — message metadata, templates and delivery events.
- DB23 Partner & DSA Management — partner records, agreements and referrals.
- DB24 Commission Management — commission rules, accruals and settlement references.
- DB25 Payment & Accounts — one finance ledger: accounts, journals, journal lines and reconciliations.
- DB26 Vendor & Marketplace — marketplace profile/listing extensions linked to DB21 vendor.
- DB27 Customer After-Service — support cases, service history and outcomes.
- DB28 Analytics & BI — governed read models and reporting snapshots.
- DB29 Evidence & Source Intelligence — source registry, evidence, verification and provenance.
- DB30 AI Intelligence & Decision Engine — model/prompt/version metadata, runs, recommendations and review outcomes.
- DB31 Notifications & Automation — notification outbox, delivery attempts and automation runs.
- DB32 User, Tenant & Access Governance — global users, tenants, memberships, roles, permissions and audit events.
- DB33 Consent, Privacy & Data Governance — consent, purpose, notice version, withdrawal, retention and privacy requests.

This is the existing DB01–DB33 catalogue expressed as implementation ownership guidance; it does not resolve the separate 16/17 product-domain taxonomy question.

### 2.4 Critical relational constraints
- Enforce unique canonical customer identity only with a reviewed identity-resolution policy; do not assume phone/email alone is globally unique.
- Use explicit junction tables for customer-business, business-project, project-application and application-lender-submission relationships.
- Enforce one tenant per tenant-scoped record and validate that linked records share the same tenant.
- Store lender/scheme policy as immutable versions with source URL/reference, retrieved_at, effective_from/to, reviewer and approval state.
- Store original source values alongside normalized values.
- Journal entries must balance: total debits equal total credits per journal and currency. Corrections use reversal/adjustment entries, not destructive edits.
- Store money as `NUMERIC(19,4)` (or a reviewed precision standard) with ISO currency code.
- Document binaries belong in private object storage; database stores metadata and opaque object key, never public file URLs.
- Add foreign keys, check constraints and indexes from access patterns; avoid speculative indexes on every column.

## 3. Tenant security and privacy
- Authenticate through a trusted identity provider; resolve active tenant membership on the server.
- Never trust browser-supplied tenant IDs, roles, ownership claims or permissions.
- Apply RBAC plus resource/attribute authorization at API and data-access boundaries.
- Enable PostgreSQL RLS on every tenant-scoped table. Set tenant context transaction-locally after verified membership; ensure app roles cannot bypass RLS.
- Test cross-tenant SELECT, INSERT, UPDATE, DELETE, export, search and background-job isolation.
- Keep privileged migrations under a separate owner role; runtime roles must not own protected tables or have BYPASSRLS.
- Capture purpose-specific consent, notice version, timestamp, collection channel and withdrawal.
- Encrypt in transit and at rest; keep secrets in a managed secret store.
- Use synthetic test fixtures only. Never commit customer KYC, bank statements, identity documents or production dumps.

## 4. Migration and release algorithm
1. Inspect the target database engine/version, extensions, schema, row counts and existing constraints.
2. Take a backup and verify restoration before any migration.
3. Resolve open canonical ownership/FK decisions, especially `registration_master`, vendor and finance-ledger reconciliation.
4. Write additive, numbered migrations; include forward and rollback/recovery notes. Avoid destructive rename/drop until data migration and rollback are proven.
5. Apply to an isolated staging database using a migration role.
6. Run schema checks, referential-integrity checks, tenant RLS tests, authorization tests and representative workflow tests.
7. Reconcile record counts, balances and source-to-target mappings.
8. Obtain explicit deployment approval; apply to production using a controlled release process.
9. Verify health, access boundaries, audit logs and financial invariants; retain rollback/restore evidence.

**No migration is executed by adding this document or the CI workflow.** The repository currently has no verified production application or database connection.

## 5. Implementation phases
- Phase A — resolve open data decisions and approve ERD/table ownership.
- Phase B — establish PostgreSQL baseline, migration tooling, tenant/auth foundations and audit.
- Phase C — implement DB01/DB02/DB32/DB33 canonical identity, tenant and consent foundations.
- Phase D — implement DB04/DB05/DB06/DB07/DB29 intelligence and evidence.
- Phase E — implement DB08–DB15 lender, product, policy and scheme intelligence.
- Phase F — implement DB16–DB20 CRM, applications, workflow and compliance.
- Phase G — implement DB21–DB27 implementation, communications, partner, finance and marketplace after reconciliation.
- Phase H — implement DB28/DB30/DB31 analytics, AI governance and automation.
- Phase I — load testing, security verification, backup/restore drill and controlled release.

Phases are sequencing recommendations; they do not alter the DB01–DB33 catalogue or claim any phase is complete.
