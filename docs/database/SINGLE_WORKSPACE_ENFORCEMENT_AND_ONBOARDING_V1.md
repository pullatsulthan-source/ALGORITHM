# ALGORITHM — Single-Workspace Enforcement & User Onboarding V1

**Status:** Design specification for review. Not executable migration SQL. No live database changes are made by this document.

## 1. Approved architecture decision

ALGORITHM uses a **single-tenant / single-workspace** operating model:

- Exactly one centrally managed organization workspace is intended.
- Multiple authorized users may access that same workspace.
- A user cannot create, select, switch between, or join another independent tenant.
- Multiple businesses, projects, applications and customer records remain supported **inside the one workspace**. Single-tenant does not mean single-business or single-user.
- Supabase Auth remains the approved initial identity source.
- The existing DB01–DB33 catalogue and numbering remain unchanged.

## 2. Live baseline verified before this design

Supabase project: `ALGORITHM-PRODUCTION` (`wzuztgjkksvubuoomduu`), PostgreSQL 17.12.

Current public tables (all RLS enabled; all currently contain zero rows):

- `public.app_user`: `id` references `auth.users(id)`; display name and timestamps.
- `public.tenant`: `id`, `name`, `status`, timestamps.
- `public.tenant_membership`: `tenant_id`, `user_id`, membership status and timestamps; unique tenant/user pair.

Current migration history contains `20261128035316_core_identity_tenant_foundation_v1`.

Current client permissions: SELECT only for authenticated users, with self/active-membership RLS policies; no client INSERT/UPDATE/DELETE policies. No app-user or tenant records currently exist. The existing schema does **not** yet enforce a one-workspace-only invariant.

## 3. Proposed additive schema change

Keep the three existing tables. Do not drop or rename them.

### 3.1 Canonical workspace marker

Add a non-null boolean marker to `public.tenant`, with a database check requiring it to be TRUE, and a unique index over that marker.

Intended effect:

- Every tenant row is designated as the one canonical workspace.
- The unique index prevents a second tenant row.
- The initial workspace is created once by a trusted bootstrap operation.
- The database may temporarily contain zero tenant rows before bootstrap; the deployment gate must not declare onboarding ready until exactly one canonical workspace exists.

Do not rely on a frontend check or a tenant ID supplied by the browser to enforce this invariant.

### 3.2 Membership integrity

Keep the existing unique constraint on `(tenant_id, user_id)`. Keep the existing membership states: `INVITED`, `ACTIVE`, `SUSPENDED`, `REVOKED`.

The trusted backend must always attach users to the canonical workspace. The client must not choose `tenant_id`, write membership status, or grant itself access.

### 3.3 Profile integrity

Keep `app_user.id` linked to `auth.users.id`. A profile is provisioned only after the Auth identity has been verified by the trusted backend. Do not use user-editable Auth metadata as an authorization source.

## 4. Trusted onboarding workflow

1. An authorized operator creates/invites a user through the approved Supabase Auth flow.
2. The backend verifies the Auth user identity from a trusted server-side context.
3. In one controlled transaction, the backend creates or updates the `app_user` profile and creates one `tenant_membership` row for the canonical workspace.
4. New membership starts as `INVITED` (or remains inactive until the invitation/approval process is completed).
5. An authorized operator activates membership after the required verification.
6. On each protected request, the backend verifies the Supabase access token and confirms the user's ACTIVE membership in the canonical workspace.
7. Suspension or revocation changes membership status through the trusted backend; the next authorization check denies workspace access.

No automatic Auth trigger is included in this design. No public client write policies are proposed. No `SECURITY DEFINER` function is proposed.

## 5. Access control boundaries

- `anon`: no access to private application records.
- `authenticated`: only the explicitly approved read access enforced by RLS; no direct writes to identity or membership tables.
- Trusted backend: performs invitation, profile provisioning, membership activation/suspension/revocation using server-only credentials.
- Never expose Supabase `service_role` or secret keys in browser/mobile clients.
- Keep role/permission matrix out of this migration. The user has not yet approved a role hierarchy or permission matrix.
- Every future tenant-scoped business table must use the single canonical workspace ID and have RLS designed for its actual access pattern.

## 6. Migration sequence (proposed; not yet applied)

**Migration A — Single-workspace invariant**
- Add canonical-workspace marker and constraints/index to `public.tenant`.
- Verify no existing tenant rows violate the intended invariant (currently verified count is zero).
- Keep RLS and existing SELECT policies intact.
- Do not insert the workspace row until its official display/legal name is supplied and approved.

**Bootstrap — Create the one workspace**
- Insert exactly one canonical workspace using the approved name.
- Verify the count is exactly one.
- Record the workspace UUID in trusted deployment configuration/secret management, not in browser-controlled configuration.

**Migration B / backend onboarding**
- Implement server-side profile and membership provisioning.
- Add no browser write permissions.
- Implement activation, suspension and revocation workflow.
- Do not introduce roles/permissions until the authorization matrix is separately approved.

## 7. Required verification tests

1. A second tenant insert is rejected by the database uniqueness constraint.
2. A non-canonical tenant row cannot be inserted.
3. The workspace bootstrap creates exactly one row and is safe to retry without duplicating it.
4. An unauthenticated caller cannot read workspace/private data.
5. An authenticated user without ACTIVE membership cannot access protected workspace data.
6. An ACTIVE member can read only the rows allowed by the approved RLS policy.
7. A user cannot create, update, delete or reassign their own membership through the client API.
8. A suspended/revoked user is denied on the next protected request.
9. A client cannot override the canonical workspace by sending a different tenant ID.
10. No service-role key appears in frontend code, public environment variables, repository history or client bundles.

Run Supabase Security Advisor after DDL and verify RLS behaviour with separate test identities before production use.

## 8. Decisions still required before live implementation

- Official workspace display name (and legal name if different).
- Who is authorized to invite and activate users.
- Which sign-in provider(s) to enable in Supabase Auth (not selected by this architecture decision).
- Whether invitation acceptance alone activates membership or requires operator approval.
- The role/permission matrix (not included or inferred here).

## 9. Explicit exclusions

This design does not:
- Apply any SQL migration.
- Create a tenant/workspace row or Auth user.
- Configure Google, email, phone or another Auth provider.
- Define application roles or permissions.
- Integrate application code or deploy an onboarding endpoint.
- Change DB01–DB33 numbering or resolve unrelated open architecture decisions.

**Implementation gate:** Only after the remaining decisions are approved should a numbered migration be prepared, reviewed, tested against staging, applied, and verified.
