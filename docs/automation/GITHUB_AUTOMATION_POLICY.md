# GitHub Automation Policy — ALGORITHM

**Repository:** `pullatsulthan-source/ALGORITHM`  
**Default branch:** `main`

## Automation enabled by workflow

The workflow at `.github/workflows/automation.yml` provides:

1. **Validation:** `git diff --check` and JSON syntax validation on supported pushes and pull requests.
2. **Automatic PR creation:** pushes to `feature/**`, `fix/**`, `docs/**`, `chore/**` and `automation/**` open a PR targeting `main`.
3. **Automatic merge request:** after validation, the workflow requests GitHub auto-merge using squash merge.
4. **Issue triage:** newly opened or edited issues receive a type label and `triage:needs-review`.

## No manual owner approval for eligible merges

For pull requests authored by the repository owner, from a branch in the same repository, and not marked as draft, the workflow enables auto-merge without waiting for a separate manual owner approval.

**This does not bypass GitHub repository rules.** GitHub must still enforce the active default-branch ruleset, including Copilot code review, and any required status checks or protections. Cross-repository pull requests, external contributors' PRs and draft PRs are not automatically merged.

## Branch naming

Use one of these prefixes to trigger automatic PR creation:

- `feature/short-description`
- `fix/short-description`
- `docs/short-description`
- `chore/short-description`
- `automation/short-description`

Do not push unfinished work to `main`.

## Commit automation boundary

The workflow does not invent product code or generate arbitrary commits. It validates and promotes changes already pushed to a supported branch. A future code-generation or AI coding agent needs a defined task source, repository write credentials, an execution environment, tests and an explicit scope before it can safely author commits.

## Issue automation boundary

Issue triage only labels issues. It does not close issues, make product decisions, assign external contributors, or expose security reports publicly. Suspected vulnerabilities must be reported privately using the process in `SECURITY.md`.

## Operational safeguards

- Workflow permissions are limited to repository contents, pull requests and issues.
- Automatic merge uses GitHub's native auto-merge and does not bypass branch rules.
- Only same-repository PRs authored by the repository owner are eligible for automatic merge.
- The public repository must never receive secrets, access tokens, customer records, bank statements, identity documents or production exports.
- Review workflow run logs and GitHub Security settings periodically.
