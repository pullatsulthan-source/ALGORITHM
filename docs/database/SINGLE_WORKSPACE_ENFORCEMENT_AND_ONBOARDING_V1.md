# ALGORITHM — Single-Workspace Enforcement & User Onboarding V1

**Status:** Architecture decision approved. SQL migration drafted in the same branch but not applied to Supabase. Backend onboarding remains a subsequent implementation task.

## 1. Approved decisions

- Workspace name: **AVITRIX**.
- Operating model: exactly one centrally managed workspace; no multi-tenant capability or tenant switching.
- Multiple authorized users may access the same workspace.
- **Only an authorized operator may activate a user's membership.** Invitation acceptance alone does not grant access.
- Supabase Auth is the approved initial identity source. Specific sign-in provider settings remain unconfigured/unselected.
- Multiple businesses, projects, applications and customer records remain supported inside the one workspace.
- DB01–DB33 catalogue and numbering remain unchanged.

## 2. Verified live baseline

Supabase project: `ALGORITHM-PRODUCTION` (`wzuztgjkksvubuoomduu`), PostgreSQL 17.12.

The three public tables currently exist with RLS enabled and zero rows:

- `public.app_user`: profile keyed to `auth.users(id)`.
- `public.tenant`: tenant master with name and status.
- `public.tenant_membership`: user-to-tenant membership, unique on `(tenant_id, user_id)`.

Migration history contains `20261128035316_core_identity_tenant_foundation_v1`. Current client permissions are SELECT only under the existing RLS policies; no client INSERT/UPDATE/DELETE policies exist. No Auth users, profiles, tenants or memberships have been inserted by the foundation migration.

## 3. Single-workspace enforcement migration

File: `supabase/migrations/20261128090000_single_workspace_enforcement_v1.sql`

The draft migration:
1. Adds `tenant.is_canonical` with a TRUE-only check constraint.
2. Adds a unique partial index so at most one canonical workspace row can exist.
3. Inserts the canonical workspace named `AVITRIX`.
4. Verifies that exactly one canonical workspace exists before commit.
5. Leaves existing RLS policies and client write restrictions unchanged.

The migration is committed for review only. It has **not** been applied to the live Supabase project.

## 4. User onboarding and activation

1. An authorized operator creates/invites a user through the selected Supabase Auth provider.
2. The trusted backend verifies the Auth identity.
3. The backend creates/updates `app_user` and creates a `tenant_membership` row tied to the canonical AVITRIX workspace with status `INVITED`.
4. Invitation acceptance does not activate access.
5. An authorized operator reviews and changes membership to `ACTIVE` through a trusted backend operation.
6. Every protected request verifies the Auth JWT and confirms ACTIVE membership in the canonical workspace.
7. Authorized operator may set membership to `SUSPENDED` or `REVOKED`; those states deny workspace access.

No public client write policies, automatic Auth trigger, or `SECURITY DEFINER` function are proposed. The service-role/secret key must never be exposed in browser or mobile code.

## 5. Implementation still required

- Review and apply the SQL migration.
- Implement trusted server-side invitation, profile provisioning and operator-only membership activation/suspension/revocation.
- Decide the sign-in provider(s) in Supabase Auth.
- Define who qualifies as an authorized operator and how operator authority is secured.
- Approve the role/permission matrix separately; no role hierarchy is inferred here.
- Test RLS and onboarding with separate test identities, then run Supabase Security Advisor.

## 6. Explicit exclusions

This update does not configure Auth providers, create Auth users, implement backend endpoints, define roles/permissions, or integrate application code. No live database changes have been made by this document or the migration draft.

**Production gate:** Do not declare onboarding ready until the migration is reviewed/applied, exactly one AVITRIX workspace is verified, operator-only activation is implemented, and authorization tests pass.
