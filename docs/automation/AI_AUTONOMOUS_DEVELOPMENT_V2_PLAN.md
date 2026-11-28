# ALGORITHM — AI-Assisted Autonomous Development V2

## Status
Planning specification only. This repository currently contains project documentation and workflow templates; application source code, package manifests, dependency lockfiles, database migrations, and a real application test suite have not yet been identified. Therefore this plan does not claim that AI code generation or deployment is operational.

## Objectives
1. Detect and classify repository issues.
2. Convert approved issue scope into a bounded implementation task.
3. Generate changes on an isolated feature branch.
4. Run repository-specific validation and security checks.
5. Open a pull request with a summary, changed-file list, test evidence, and risk notes.
6. Merge only when GitHub branch protections, required checks, and configured review rules permit it.
7. Deploy only through an explicitly configured deployment workflow and environment protection.

## Proposed workflow
Issue / task intake
→ scope and acceptance criteria
→ AI implementation in isolated branch
→ static checks and tests
→ security and dependency checks
→ pull request
→ automated review and policy checks
→ GitHub-protected merge
→ staged deployment
→ post-deployment health verification

## Required prerequisites
- Actual application source and a documented local build/test command.
- Supported runtime and dependency manifests with lockfiles.
- Deterministic unit/integration test suite and test fixtures.
- CI workflows aligned with the actual languages and project layout.
- Dedicated AI coding runtime/provider integration and a narrowly scoped credential.
- Repository secrets/environment variables configured through GitHub Settings; never commit credentials.
- Separate staging environment and deployment rollback procedure.
- Explicit ownership for production data, migrations, security findings, and release approval.

## Safety and governance boundaries
- AI may propose code and create branches/PRs only within an explicitly assigned task scope.
- AI must not change lender policy, eligibility rules, financial calculations, customer records, production data, or compliance decisions without a separately approved change specification and human review.
- No secrets, personal data, or production credentials may be sent to an external model unless the data handling contract and authorization explicitly permit it.
- Never bypass branch protections, required reviews, status checks, or environment protections.
- No automatic production deployment until staging tests, rollback, observability, and environment approvals are configured.
- Dependency upgrades and security fixes must be reviewed for compatibility; do not auto-merge breaking or high-risk changes.
- Every AI-generated PR must state its task source, files changed, tests run, results, known limitations, and whether any data/schema migration is involved.

## Current CI findings from the test branch
### NodeJS with Webpack
The workflow fails because it runs `npm install` in the repository root but there is no root `package.json`. This is a workflow/repository mismatch, not evidence of a broken Node application. Do not fabricate a package manifest just to make the template workflow green.

### Python package
Dependency installation and Flake8 complete, but `pytest` exits with code 5 because it discovers zero tests. This repository currently has no Python test suite. The Python 3.9 job also fails at runtime setup; inspect the complete setup log before deciding whether to retain that interpreter. Do not add dummy tests to disguise the absence of application code.

### CodeQL
CodeQL succeeds in the observed run. This confirms that workflow run completed successfully; it does not prove application-level security because application source has not been identified.

## Immediate implementation sequence
1. Inventory repository files and classify actual application versus template/documentation files.
2. Remove, disable, or scope irrelevant sample Node/Python workflows so they do not report misleading failures.
3. Add CI only for runtimes and paths that actually exist.
4. Define application build, test, and security commands from the real source.
5. Connect a dedicated AI coding agent with least-privilege access and task allowlists.
6. Test the agent on documentation-only and isolated low-risk code tasks.
7. Enable controlled PR automation; keep protected-branch rules intact.
8. Add staging deployment after infrastructure and rollback readiness are verified.

## Acceptance criteria for V2
- A scoped issue can be converted into an isolated branch and PR.
- Generated changes are reproducible and linked to the source task.
- Applicable tests and security checks run and publish evidence.
- Failed checks block merge.
- External or untrusted contributions never gain privileged write access.
- No production data or protected business rules are changed autonomously.
- Deployment is observable and reversible.

## Current conclusion
Automation V1 has passed a documentation-only branch → validation → PR creation → squash auto-merge test. AI-driven code generation, application tests, and deployment are not yet configured. V2 remains a staged implementation plan pending source-code and runtime prerequisites.
