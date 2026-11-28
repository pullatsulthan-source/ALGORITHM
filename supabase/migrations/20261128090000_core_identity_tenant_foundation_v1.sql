-- ALGORITHM Database Foundation V1
-- Scope: identity reference, tenant master, tenant membership.
-- Deliberately excludes role/permission matrix, identity merge rules, polymorphic subject links,
-- registration ownership, vendor/ledger reconciliation, and auth provider configuration.
-- Client writes are disabled until a reviewed onboarding and authorization workflow is implemented.

begin;

create table public.app_user (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.app_user is
  'Application profile keyed to Supabase Auth. Provision and maintain through trusted server-side workflows; no client write policy is enabled.';

create table public.tenant (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) > 0),
  status text not null default 'ACTIVE'
    check (status in ('ACTIVE', 'SUSPENDED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.tenant is
  'Tenant master. Tenant creation is reserved for a trusted onboarding workflow pending approval.';

create table public.tenant_membership (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenant(id) on delete restrict,
  user_id uuid not null references auth.users(id) on delete cascade,
  membership_status text not null default 'INVITED'
    check (membership_status in ('INVITED', 'ACTIVE', 'SUSPENDED', 'REVOKED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tenant_membership_tenant_user_uk unique (tenant_id, user_id)
);

create index tenant_membership_user_status_idx
  on public.tenant_membership (user_id, membership_status);

create index tenant_membership_tenant_status_idx
  on public.tenant_membership (tenant_id, membership_status);

alter table public.app_user enable row level security;
alter table public.tenant enable row level security;
alter table public.tenant_membership enable row level security;

revoke all on table public.app_user from anon, authenticated;
revoke all on table public.tenant from anon, authenticated;
revoke all on table public.tenant_membership from anon, authenticated;

grant select on table public.app_user to authenticated;
grant select on table public.tenant to authenticated;
grant select on table public.tenant_membership to authenticated;

create policy app_user_select_self
  on public.app_user
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy tenant_select_active_member
  on public.tenant
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.tenant_membership tm
      where tm.tenant_id = tenant.id
        and tm.user_id = (select auth.uid())
        and tm.membership_status = 'ACTIVE'
    )
  );

create policy tenant_membership_select_self
  on public.tenant_membership
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

commit;
