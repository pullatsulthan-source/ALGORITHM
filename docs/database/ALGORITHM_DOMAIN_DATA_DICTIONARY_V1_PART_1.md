# ALGORITHM — Domain Data Dictionary V1 (Part 1)

**Status:** Proposed domain-level column dictionary for review. Not executable DDL, not a production schema, and not evidence of deployed database objects.

**Coverage:** DB03, DB05–DB15. DB01, DB02, DB04, DB07, DB17, DB18, DB25, DB29, DB32 and DB33 foundation definitions remain in the previously merged ERD V2 document. DB16 and DB19–DB31 are scheduled for Part 2.

## 1. Design rules

- Preserve the approved DB01–DB33 numbering and ownership catalogue.
- All tenant-owned tables include `tenant_id UUID NOT NULL`; global reference catalogues are explicitly marked global.
- Use UUID primary keys, UTC `TIMESTAMPTZ`, `NUMERIC(19,4)` for monetary values, ISO currency codes and controlled status values.
- Apply same-tenant composite foreign keys to tenant-owned relationships.
- Preserve source values, source timestamps, provenance, version history and reviewer decisions.
- Store documents in private object storage; relational tables hold opaque object keys and metadata.
- These proposed names and columns require review against actual workflows, data sources, legal basis and selected runtime before DDL.
- Do not infer eligibility, credit approval, sanction or compliance outcomes from missing data. Unknown remains UNKNOWN/REVIEW.

## 2. DB03 — Industry Intelligence

### `industry_master` (global reference catalogue)
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| industry_code | TEXT | No | UNIQUE within classification system |
| classification_system | TEXT | No | E.g. approved national/international taxonomy identifier |
| industry_name | TEXT | No | Canonical label |
| parent_industry_id | UUID | Yes | FK industry_master(id); hierarchy |
| level_number | INTEGER | Yes | CHECK > 0 |
| description | TEXT | Yes | Definition |
| status | TEXT | No | ACTIVE, INACTIVE, UNDER_REVIEW |
| valid_from | DATE | Yes | Effective start |
| valid_to | DATE | Yes | CHECK valid_to >= valid_from |
| created_at / updated_at | TIMESTAMPTZ | No | Audit timestamps |

### `industry_profile` (tenant-owned business/project classification)
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; UNIQUE(tenant_id,id) |
| tenant_id | UUID | No | FK tenant |
| industry_id | UUID | No | FK industry_master |
| subject_type | TEXT | No | BUSINESS or PROJECT |
| subject_id | UUID | No | Subject reference; subject-specific integrity strategy required |
| classification_role | TEXT | No | PRIMARY, SECONDARY, RELATED |
| confidence_status | TEXT | No | VERIFIED, DECLARED, INFERRED, REVIEW_REQUIRED |
| source_evidence_id | UUID | Yes | DB29 evidence reference |
| valid_from / valid_to | DATE | Yes | Validity interval |
| created_at / created_by | TIMESTAMPTZ / UUID | No/Yes | Audit |

**Boundary:** Industry taxonomy is a reference catalogue. Sector statistics and market facts must be separately sourced and time-stamped; do not store unsourced claims as canonical facts.

### `industry_fact_snapshot`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| industry_id | UUID | No | Industry reference |
| metric_code | TEXT | No | Controlled metric identifier |
| metric_value | NUMERIC(19,4) | Yes | Numeric observation where applicable |
| metric_unit | TEXT | Yes | Unit / denominator |
| geography_code | TEXT | Yes | Geography scope |
| period_start / period_end | DATE | Yes | Observation period |
| source_evidence_id | UUID | No | DB29 evidence |
| captured_at | TIMESTAMPTZ | No | Retrieval/record time |
| verification_status | TEXT | No | UNVERIFIED, VERIFIED, DISPUTED, EXPIRED |

## 3. DB05 — Financial Intelligence

### `financial_profile`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; tenant composite unique |
| tenant_id | UUID | No | Tenant |
| subject_type | TEXT | No | CUSTOMER, BUSINESS, PROJECT |
| subject_id | UUID | No | Subject link; enforce via approved subject-link design |
| accounting_basis | TEXT | Yes | CASH, ACCRUAL, OTHER, UNKNOWN |
| base_currency | CHAR(3) | No | ISO 4217 |
| financial_year_start_month | SMALLINT | Yes | CHECK 1–12 |
| profile_status | TEXT | No | DRAFT, ACTIVE, REVIEW_REQUIRED, ARCHIVED |
| created_at / updated_at | TIMESTAMPTZ | No | Audit timestamps |

### `financial_statement`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; tenant composite unique |
| tenant_id | UUID | No | Tenant |
| financial_profile_id | UUID | No | FK financial_profile |
| statement_type | TEXT | No | PROFIT_LOSS, BALANCE_SHEET, CASH_FLOW, ITR_SUMMARY, OTHER |
| period_start / period_end | DATE | No | CHECK period_end >= period_start |
| currency_code | CHAR(3) | No | ISO 4217 |
| source_document_id | UUID | Yes | DB07 document |
| source_evidence_id | UUID | Yes | DB29 evidence |
| preparation_basis | TEXT | Yes | AUDITED, MANAGEMENT, FILED, EXTRACTED, DECLARED |
| verification_status | TEXT | No | UNVERIFIED, VERIFIED, REJECTED, REVIEW_REQUIRED |
| external_reference | TEXT | Yes | Source reference |
| created_at / created_by | TIMESTAMPTZ / UUID | No/Yes | Audit |

### `financial_statement_line`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| statement_id | UUID | No | Composite FK financial_statement |
| line_code | TEXT | No | Controlled taxonomy code |
| line_label_source | TEXT | Yes | Original source label |
| amount | NUMERIC(19,4) | No | Signed/typed amount; sign convention must be approved |
| currency_code | CHAR(3) | No | Must match statement currency unless FX conversion is explicit |
| source_page | TEXT | Yes | Source location |
| extraction_confidence | NUMERIC(5,4) | Yes | CHECK 0–1 |
| review_status | TEXT | No | PENDING, ACCEPTED, CORRECTED, REJECTED |

### `financial_snapshot`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| subject_type / subject_id | TEXT / UUID | No | Assessed subject; approved link strategy required |
| as_of_date | DATE | No | Snapshot date |
| snapshot_version | INTEGER | No | CHECK > 0 |
| input_statement_ids | JSONB | Yes | Immutable input ID list or normalized junction in physical design |
| calculation_version | TEXT | No | Formula/package version |
| assumptions | JSONB | Yes | Explicit assumptions |
| output_metrics | JSONB | No | Versioned result payload; not raw source of truth |
| review_status | TEXT | No | DRAFT, REVIEW_REQUIRED, APPROVED, SUPERSEDED |
| created_at / created_by | TIMESTAMPTZ / UUID | No/Yes | Audit |

### `financial_ratio_result`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| financial_snapshot_id | UUID | No | FK snapshot |
| ratio_code | TEXT | No | E.g. approved ratio identifier |
| numerator_value / denominator_value | NUMERIC(19,4) | Yes | Calculation inputs |
| ratio_value | NUMERIC(19,8) | Yes | Null where not computable |
| formula_version | TEXT | No | Reproducibility |
| result_status | TEXT | No | CALCULATED, NOT_COMPUTABLE, REVIEW_REQUIRED |
| explanation | TEXT | Yes | Human-readable rationale |

**Control:** Store original statement facts separately from derived ratios. A recalculation creates a new version; it must not overwrite the historical result.

## 4. DB06 — Banking & Credit Intelligence

### `credit_facility`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; tenant composite unique |
| tenant_id | UUID | No | Tenant |
| subject_type / subject_id | TEXT / UUID | No | Customer/business subject link; enforce approved ownership model |
| lender_id | UUID | Yes | FK DB08 lender |
| facility_type | TEXT | No | TERM_LOAN, CASH_CREDIT, OVERDRAFT, LEASE, OTHER |
| account_reference_masked | TEXT | Yes | Masked reference only |
| sanctioned_amount | NUMERIC(19,4) | Yes | Currency required |
| currency_code | CHAR(3) | Yes | ISO 4217 |
| sanction_date | DATE | Yes | |
| maturity_date | DATE | Yes | |
| facility_status | TEXT | No | PROPOSED, ACTIVE, CLOSED, OVERDUE, DISPUTED, UNKNOWN |
| source_evidence_id | UUID | Yes | DB29 evidence |
| verification_status | TEXT | No | UNVERIFIED, VERIFIED, REVIEW_REQUIRED |

### `credit_obligation_snapshot`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| credit_facility_id | UUID | No | FK facility |
| as_of_date | DATE | No | Snapshot date |
| outstanding_amount | NUMERIC(19,4) | Yes | |
| overdue_amount | NUMERIC(19,4) | Yes | |
| emi_or_periodic_due | NUMERIC(19,4) | Yes | |
| next_due_date | DATE | Yes | |
| currency_code | CHAR(3) | No | ISO 4217 |
| source_evidence_id | UUID | Yes | DB29 |
| verification_status | TEXT | No | UNVERIFIED, VERIFIED, DISPUTED |

### `credit_enquiry_record`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | No | Tenant |
| subject_type / subject_id | TEXT / UUID | No | Subject link |
| bureau_or_source | TEXT | No | Reporting source |
| enquiry_reference_masked | TEXT | Yes | Masked identifier |
| enquiry_date | DATE | Yes | |
| report_date | DATE | No | |
| source_document_id | UUID | Yes | DB07 |
| source_evidence_id | UUID | Yes | DB29 |
| consent_record_id | UUID | No | DB33 consent reference |
| review_status | TEXT | No | PENDING, VERIFIED, DISPUTED, EXPIRED |

**Control:** Credit information access must be purpose- and consent-governed. Do not infer a credit score from incomplete obligations or treat imported values as verified without evidence.

## 5. DB08 — Lender Master Intelligence

### `lender_master` (global reference)
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_code | TEXT | No | UNIQUE canonical code |
| legal_name | TEXT | No | Legal institutional name |
| display_name | TEXT | Yes | |
| lender_category | TEXT | No | BANK, NBFC, COOPERATIVE, DEVELOPMENT_FINANCE, OTHER |
| regulator_name | TEXT | Yes | |
| official_website | TEXT | Yes | Official source URL |
| country_code | CHAR(2) | No | ISO 3166-1 alpha-2 |
| operating_status | TEXT | No | ACTIVE, RESTRICTED, MERGED, CLOSED, UNDER_REVIEW |
| valid_from / valid_to | DATE | Yes | Effective interval |
| created_at / updated_at | TIMESTAMPTZ | No | Audit |

### `lender_identifier`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_id | UUID | No | FK lender_master |
| identifier_type | TEXT | No | REGULATORY_ID, INTERNAL_CODE, OTHER |
| identifier_value | TEXT | No | |
| issuing_authority | TEXT | Yes | |
| valid_from / valid_to | DATE | Yes | |
| source_evidence_id | UUID | Yes | DB29 |
| UNIQUE | — | — | (identifier_type, identifier_value, valid_from) subject to temporal review |

## 6. DB09 — All-India Bank Branch & Hierarchy

### `bank_branch` (global reference)
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_id | UUID | No | FK DB08 |
| branch_code | TEXT | Yes | IFSC or other code; source-specific validation |
| branch_name | TEXT | No | |
| address_line | TEXT | Yes | |
| locality | TEXT | Yes | |
| district_code | TEXT | Yes | Standard geography reference |
| state_code | TEXT | Yes | Standard geography reference |
| postal_code | TEXT | Yes | |
| latitude / longitude | NUMERIC(10,7) | Yes | Range checks; coordinates optional |
| contact_phone | TEXT | Yes | Public institutional contact only |
| branch_status | TEXT | No | ACTIVE, CLOSED, MERGED, RELOCATED, UNKNOWN |
| source_evidence_id | UUID | Yes | DB29 |
| valid_from / valid_to | DATE | Yes | |

### `branch_hierarchy`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_id | UUID | No | FK lender |
| parent_branch_id | UUID | Yes | FK bank_branch |
| child_branch_id | UUID | No | FK bank_branch |
| hierarchy_type | TEXT | No | REGION, ZONE, CIRCLE, CONTROLLING_OFFICE, OTHER |
| valid_from / valid_to | DATE | Yes | |
| source_evidence_id | UUID | Yes | DB29 |

**Control:** Branch codes and hierarchy are source- and effective-date-dependent. Preserve historical branch identifiers after mergers/closures.

## 7. DB10 — Loan Product Intelligence

### `loan_product`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; global catalogue |
| lender_id | UUID | No | FK DB08 |
| product_code | TEXT | No | Unique within lender |
| product_name | TEXT | No | |
| product_category | TEXT | No | TERM, WORKING_CAPITAL, EQUIPMENT, VEHICLE, OTHER |
| target_segment | TEXT | Yes | |
| official_product_url | TEXT | Yes | Official source |
| product_status | TEXT | No | ACTIVE, WITHDRAWN, UNDER_REVIEW |
| created_at / updated_at | TIMESTAMPTZ | No | Audit |

### `loan_product_version`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| loan_product_id | UUID | No | FK product |
| version_number | INTEGER | No | UNIQUE(product_id, version_number); > 0 |
| min_amount / max_amount | NUMERIC(19,4) | Yes | Currency specified |
| currency_code | CHAR(3) | Yes | ISO 4217 |
| min_tenure_months / max_tenure_months | INTEGER | Yes | Non-negative; min <= max |
| interest_basis | TEXT | Yes | FIXED, FLOATING, LINKED, NOT_STATED |
| published_rate_min / published_rate_max | NUMERIC(9,5) | Yes | Not a customer quote |
| collateral_summary | TEXT | Yes | Source-derived summary |
| eligibility_summary | TEXT | Yes | Informational, not approval |
| source_evidence_id | UUID | No | DB29 official evidence |
| effective_from / effective_to | DATE | No/Yes | Validity |
| reviewer_id | UUID | Yes | Authorized reviewer |
| approval_status | TEXT | No | DRAFT, REVIEWED, APPROVED, SUPERSEDED |

## 8. DB11 — Lender Policy Engine

### `lender_policy`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_id | UUID | No | FK DB08 |
| policy_code | TEXT | No | Unique within lender |
| policy_name | TEXT | No | |
| policy_scope | TEXT | No | PRODUCT, SEGMENT, GEOGRAPHY, GENERAL |
| status | TEXT | No | ACTIVE, SUSPENDED, RETIRED, UNDER_REVIEW |
| created_at / updated_at | TIMESTAMPTZ | No | Audit |

### `lender_policy_version`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| policy_id | UUID | No | FK lender_policy |
| version_number | INTEGER | No | UNIQUE(policy_id, version_number) |
| source_evidence_id | UUID | No | DB29; official source required for approved rule |
| source_reference_text | TEXT | Yes | Circular/notification reference |
| retrieved_at | TIMESTAMPTZ | No | Source capture time |
| effective_from / effective_to | DATE | Yes | Effective interval |
| policy_payload | JSONB | No | Versioned structured policy; schema-versioned |
| interpretation_notes | TEXT | Yes | Reviewer interpretation, separate from source text |
| reviewer_id | UUID | Yes | Human reviewer |
| approved_by | UUID | Yes | Authorized approver |
| approval_status | TEXT | No | DRAFT, REVIEW_REQUIRED, APPROVED, REJECTED, SUPERSEDED |
| approved_at | TIMESTAMPTZ | Yes | |
| created_at | TIMESTAMPTZ | No | |

### `policy_rule`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| tenant_id | UUID | Yes | Null only for globally governed rule catalogue |
| policy_version_id | UUID | No | FK policy version |
| rule_code | TEXT | No | Unique within version |
| rule_category | TEXT | No | ELIGIBILITY, DOCUMENT, FINANCIAL, COLLATERAL, PROCESS |
| rule_expression | JSONB | No | Restricted declarative expression; never executable arbitrary code |
| outcome_values | JSONB | No | PASS, FAIL, UNKNOWN, REVIEW mappings |
| source_locator | TEXT | Yes | Page/paragraph/section |
| rule_status | TEXT | No | PROPOSED, REVIEWED, APPROVED, DISABLED |

**Non-negotiable governance:** No AI or automation may autonomously publish, edit or activate lender policy. Official source, retrieval timestamp, version, effective date and authorized human approval are required. A recommendation is not a sanction prediction.

## 9. DB12 — Sanction Authority Intelligence

### `sanction_authority`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| lender_id | UUID | No | FK DB08 |
| authority_code | TEXT | No | Unique within lender |
| authority_name | TEXT | No | |
| authority_level | TEXT | Yes | Branch, regional, zonal, central, committee etc. |
| parent_authority_id | UUID | Yes | FK self |
| authority_status | TEXT | No | ACTIVE, INACTIVE, UNDER_REVIEW |
| source_evidence_id | UUID | Yes | DB29 |

### `authority_limit_version`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| authority_id | UUID | No | FK sanction_authority |
| product_category | TEXT | Yes | Optional scope |
| min_amount / max_amount | NUMERIC(19,4) | Yes | Currency specified |
| currency_code | CHAR(3) | Yes | ISO 4217 |
| limit_basis | TEXT | No | INDIVIDUAL, COMMITTEE, DELEGATED, OTHER |
| effective_from / effective_to | DATE | No/Yes | Validity |
| source_evidence_id | UUID | No | DB29 |
| reviewer_id / approver_id | UUID | Yes | Authorized human actors |
| approval_status | TEXT | No | DRAFT, REVIEWED, APPROVED, SUPERSEDED |

**Control:** Authority limits are informational, versioned and source-backed. Do not infer actual delegation or sanction authority from job titles.

## 10. DB13 — Scheme Intelligence

### `scheme_master` (global scheme catalogue)
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| scheme_code | TEXT | No | UNIQUE canonical identifier |
| scheme_name | TEXT | No | Official scheme name |
| administering_authority | TEXT | No | Ministry/agency/state authority |
| scheme_level | TEXT | No | CENTRAL, STATE, OTHER |
| scheme_category | TEXT | Yes | CREDIT, SUBSIDY, GUARANTEE, INCENTIVE, OTHER |
| official_website | TEXT | Yes | Official source |
| scheme_status | TEXT | No | ACTIVE, CLOSED, PAUSED, ANNOUNCED, UNDER_REVIEW |
| created_at / updated_at | TIMESTAMPTZ | No | Audit |

### `scheme_guideline_version`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| scheme_id | UUID | No | FK scheme_master |
| version_number | INTEGER | No | UNIQUE(scheme_id, version_number) |
| guideline_title | TEXT | No | |
| source_evidence_id | UUID | No | DB29 official source |
| source_reference | TEXT | Yes | Notification/order number |
| retrieved_at | TIMESTAMPTZ | No | |
| published_at | DATE | Yes | |
| effective_from / effective_to | DATE | Yes | |
| guideline_snapshot | JSONB | No | Structured, versioned extraction |
| reviewer_id / approver_id | UUID | Yes | Human governance |
| approval_status | TEXT | No | DRAFT, REVIEW_REQUIRED, APPROVED, SUPERSEDED |

### `scheme_eligibility_dimension`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| guideline_version_id | UUID | No | FK scheme_guideline_version |
| dimension_code | TEXT | No | Entity type, location, activity, project size, etc. |
| requirement_description | TEXT | No | |
| evaluation_method | TEXT | No | DECLARATIVE, DOCUMENT_REVIEW, MANUAL |
| required_evidence_type | TEXT | Yes | DB07/DB29 classification |
| unknown_handling | TEXT | No | Must permit UNKNOWN or REVIEW |
| source_locator | TEXT | Yes | Section/page |

## 11. DB14 — Scheme Application Intelligence

### `scheme_requirement`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| guideline_version_id | UUID | No | FK DB13 guideline version |
| requirement_code | TEXT | No | Unique within guideline version |
| requirement_name | TEXT | No | |
| requirement_type | TEXT | No | DOCUMENT, DECLARATION, FINANCIAL, REGISTRATION, OTHER |
| mandatory_flag | BOOLEAN | No | Source-backed |
| applies_to | TEXT | No | CUSTOMER, BUSINESS, PROJECT, APPLICATION |
| evidence_type_code | TEXT | Yes | DB07 document taxonomy |
| validation_rule | JSONB | Yes | Declarative validation only |
| source_locator | TEXT | Yes | Source page/section |
| requirement_status | TEXT | No | ACTIVE, WITHDRAWN, UNDER_REVIEW |

### `scheme_application_mapping`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; tenant composite unique |
| tenant_id | UUID | No | Tenant |
| application_id | UUID | No | FK DB17 application |
| scheme_id | UUID | No | FK DB13 scheme |
| guideline_version_id | UUID | No | Exact evaluated version |
| match_status | TEXT | No | MATCH, NO_MATCH, UNKNOWN, REVIEW_REQUIRED |
| assessment_reference_id | UUID | Yes | Separate assessment result record |
| evaluated_at | TIMESTAMPTZ | Yes | |
| reviewer_id | UUID | Yes | Human reviewer |
| review_status | TEXT | No | PENDING, ACCEPTED, REJECTED, OVERRIDDEN |
| override_reason | TEXT | Yes | Required for human override |

## 12. DB15 — Lender-Scheme Mapping

### `lender_scheme_mapping`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK; global reference |
| lender_id | UUID | No | FK DB08 |
| scheme_id | UUID | No | FK DB13 |
| loan_product_id | UUID | Yes | FK DB10 |
| mapping_type | TEXT | No | IMPLEMENTING_LENDER, PARTICIPATING_LENDER, FACILITATOR, OTHER |
| mapping_status | TEXT | No | PROPOSED, VERIFIED, ACTIVE, INACTIVE, DISPUTED |
| source_evidence_id | UUID | No | DB29 |
| valid_from / valid_to | DATE | Yes | Effective interval |
| reviewer_id | UUID | Yes | Human reviewer |
| approved_at | TIMESTAMPTZ | Yes | |
| UNIQUE | — | — | lender, scheme, product, mapping_type and validity require temporal uniqueness strategy |

### `lender_scheme_mapping_history`
| Column | Type | Null | Rule / purpose |
|---|---|---:|---|
| id | UUID | No | PK |
| mapping_id | UUID | No | FK lender_scheme_mapping |
| prior_status / new_status | TEXT | No | State change |
| change_reason | TEXT | No | |
| source_evidence_id | UUID | Yes | DB29 |
| changed_by | UUID | Yes | Human/system actor |
| changed_at | TIMESTAMPTZ | No | |
| review_reference | TEXT | Yes | Approval/review trace |

## 13. Cross-domain relationship and integrity requirements

1. DB03 classifications may be linked to DB02 businesses and DB04 projects; final subject-link constraints must be chosen before physical DDL.
2. DB05 financial profiles and DB06 credit facilities must link to canonical customer/business/project identities without duplicating customer master data.
3. DB05 statement values and DB06 credit values retain source document/evidence references and verification status.
4. DB08 lender is the canonical institution referenced by DB09 branches, DB10 products, DB11 policies and DB12 authorities.
5. DB10 product terms, DB11 policy rules and DB12 authority limits are versioned and effective-dated; preserve superseded versions.
6. DB13 scheme guideline versions are the source of DB14 requirements and DB15 mappings.
7. DB14 scheme application matching is an assessment record, not a lender sanction or guarantee of eligibility.
8. All evidence references resolve to DB29; all source files resolve to DB07 document metadata.
9. Tenant-specific assessments and application mappings enforce tenant consistency with DB17 application.
10. No cross-domain process may bypass DB33 consent, DB32 access governance or audit controls.

## 14. Open decisions carried forward

- Confirm separate product taxonomy versus DB16/DB17 database-domain numbering; this document does not renumber either domain.
- Confirm canonical subject-link strategy for polymorphic customer/business/project references before adding enforceable FKs.
- Approve classification systems and authoritative sources for DB03.
- Approve financial statement taxonomy, sign convention, fiscal-year rules, FX conversion source/rate timestamp and rounding policy for DB05.
- Approve permitted credit-data sources, consent basis, retention period and access roles for DB06.
- Approve official lender/branch/product/policy/scheme data sources, refresh cadence and reviewer authority.
- Approve policy expression schema and rule test methodology; arbitrary executable expressions are prohibited.
- Confirm whether DB12 authority data is sourced from official delegation documents and who can approve updates.
- Confirm temporal uniqueness and effective-date overlap rules for DB08–DB15.
- Confirm actual PostgreSQL target, extensions, migration tooling, backup and recovery objectives before DDL.

## 15. Readiness statement

This Part 1 document expands proposed data ownership and column-level structure for DB03 and DB05–DB15 only. It does not create database tables, execute migrations, connect to a production database, approve lender/scheme rules, or resolve the open decisions above. Physical DDL must follow architecture, privacy, security and domain-owner review.
