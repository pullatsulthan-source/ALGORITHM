# Security, Privacy & Governance Baseline

## Identity and access
- Authenticate users through a trusted identity provider.
- Resolve active tenant membership server-side.
- Never trust a browser-supplied `tenant_id`, role, permission or ownership claim.
- Apply RBAC plus resource/attribute checks (ABAC) at API and data-access boundaries.
- Restrict staff to assigned departments, cases, document categories and fields.
- Apply least privilege to service accounts and database roles.

## Tenant isolation
- Establish tenant context from verified identity and active membership.
- Use transaction-local tenant context for database operations.
- Ensure application database roles cannot bypass row-level security.
- Test cross-tenant read, write, update, export and background-job isolation.
- Treat RLS SQL drafts as unverified until executed and tested in staging.

## Data protection
- Collect only necessary data for a defined purpose.
- Record consent, purpose, timestamp, notice version and withdrawal.
- Encrypt data in transit and at rest; protect secrets in a managed secret store.
- Apply retention, deletion, legal-hold and access-logging policies.
- Avoid placing personal financial documents in public repositories or logs.

## Decision governance
- Store evidence and source provenance for lender/scheme policies.
- Version policy rules with effective dates and reviewer approval.
- Distinguish `UNKNOWN`, `REVIEW`, `ELIGIBLE`, `INELIGIBLE` and `FAIL` states.
- Keep human review for material credit, eligibility and compliance decisions.
- Never present indicative matching as a lender sanction guarantee.

## Repository hygiene
- Never commit `.env`, API keys, access tokens, bank statements, identity documents, customer files, production dumps or private certificates.
- Use sanitized fixtures and synthetic test data.
- Require code review and automated security checks before merging.
