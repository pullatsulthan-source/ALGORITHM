-- ALGORITHM single-workspace enforcement V1
-- Approved workspace name: AVITRIX
-- New users remain INVITED until an authorized operator activates membership.
-- This migration changes the database schema and creates the canonical workspace.
-- Apply only after review and backup confirmation.

begin;

alter table public.tenant
  add column is_canonical boolean not null default true,
  add constraint tenant_is_canonical_true_ck check (is_canonical is true);

create unique index tenant_single_canonical_workspace_uk
  on public.tenant (is_canonical)
  where is_canonical is true;

insert into public.tenant (name, status, is_canonical)
values ('AVITRIX', 'ACTIVE', true)
on conflict (is_canonical) where is_canonical is true
do nothing;

-- Deployment gate: exactly one canonical workspace must exist.
do $$
declare
  canonical_count integer;
begin
  select count(*) into canonical_count
  from public.tenant
  where is_canonical is true;

  if canonical_count <> 1 then
    raise exception 'Expected exactly one canonical AVITRIX workspace; found %', canonical_count;
  end if;
end
$$;

comment on column public.tenant.is_canonical is
  'The sole canonical ALGORITHM workspace. Database constraints permit at most one tenant row.';

commit;
