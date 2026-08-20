# Goal Master Subscription System Spec

Last Updated: 2026-08-09
Status: Draft approved for phased implementation
Scope: product + technical execution blueprint

## 1. Purpose

This document defines the subscription system for stadium managers in Goal Master.

The system must work consistently across:

- Manager mobile application
- Website / browser access for managers
- Backend / admin panel
- Customer-facing booking visibility rules

The goal is to add subscriptions without breaking the current booking architecture.

## 2. Business Model

Goal Master will use a hybrid commercial model:

- fixed monthly or yearly subscription
- optional small fee only on successful online payments
- no commission on offline / cash bookings

This is intentionally designed to be acceptable for small football fields and local stadium operators.

## 3. Subscription Plans

Initial business recommendation uses 3 plans only as the launch model.

Important architecture decision:

- plans must be managed dynamically from the admin panel
- plan definitions must not be hardcoded in mobile apps or website UI
- the admin must be able to create, edit, activate, deactivate, reorder, and evolve plans over time

This means:

- `Starter`, `Growth`, and `Pro` are recommended launch presets
- but the real system must support admin-defined plans
- apps and website should render plans from backend responses

### 3.1 Starter

Target:

- small venues
- single branch
- 1 to 2 fields

Suggested capabilities:

- limited number of staff users
- basic booking calendar
- manual booking creation
- booking acceptance / rejection
- basic notifications
- simple reporting

### 3.2 Growth

Target:

- active venues with several fields
- teams that need more operational tooling

Suggested capabilities:

- more fields
- more staff accounts
- customer management improvements
- wallet and online payment support if enabled
- monthly booking support
- stronger reporting

### 3.3 Pro

Target:

- larger operators
- multi-branch venues
- high operational usage

Suggested capabilities:

- multiple branches
- larger field count
- more staff accounts
- advanced reports
- broader permissioning
- higher operational limits

### 3.4 Launch Recommendation vs System Capability

Launch recommendation:

- Starter
- Growth
- Pro

System capability:

- admin can create any future plan names
- admin can change prices
- admin can change limits
- admin can change which features are enabled
- admin can retire plans without deleting historical subscriptions

## 4. Billing Modes

Supported billing cycles:

- monthly
- yearly

Commercial rules:

- yearly plan receives a discount
- every new manager may receive a trial period

Suggested default trial:

- 14 or 30 days

Final trial duration should be configurable from admin panel.

## 5. Subscription Lifecycle

Each manager account must always be in one of these states:

- `trial`
- `active`
- `grace_period`
- `expired`
- `suspended`
- `cancelled`

### 5.1 Trial

- full or near-full access within trial rules
- onboarding allowed
- manager can configure venue data

### 5.2 Active

- full access according to plan features and limits

### 5.3 Grace Period

- temporary soft-expiry state
- user sees warnings
- limited time to renew before hard stop

### 5.4 Expired

- no new operational growth
- new bookings policy depends on business rule below

### 5.5 Suspended

- enforced by admin
- may be used for non-payment, abuse, compliance, or support issues

### 5.6 Cancelled

- used when plan is ended intentionally
- historical data remains

## 6. Expiry Policy

Recommended policy after subscription expiry:

- existing data remains readable
- manager cannot expand account
- manager cannot create new branches, fields, or staff beyond current state
- manager cannot accept new bookings if the business decides to stop public booking availability

Recommended first version:

- read access remains
- operational write actions are restricted
- new booking creation and public booking acceptance are blocked

This gives a professional downgrade path without destroying existing operational records.

## 7. Core Product Rules

The subscription system must not duplicate business logic separately in each app.

Source of truth must be:

- backend

Frontend apps and web must consume:

- current subscription status
- plan limits
- enabled features
- blocking reason messages

## 8. Features Controlled By Subscription

These features should be plan-driven:

- max branches
- max fields
- max staff users
- allow online payments
- allow wallet operations
- allow monthly bookings
- allow customer management tools
- allow reports
- allow offers / vouchers later
- allow browser dashboard access

Optional future controls:

- priority support
- analytics depth
- export tools
- API access

## 9. Manager Onboarding Flow

New manager onboarding should become:

1. account creation
2. account verification if required
3. plan selection or trial activation
4. subscription activation result
5. venue onboarding wizard
6. first branch creation
7. first field creation
8. business hours setup
9. staff setup
10. payment method configuration

Important:

- the current manager flow is incomplete for self-service venue setup
- this subscription project should be paired with proper venue onboarding

## 10. Manager App Requirements

The manager mobile app must support:

- plan selection screen
- current plan summary
- renewal / upgrade / downgrade entry point
- subscription expiry warning banners
- blocked-action messages when plan limit is reached
- onboarding wizard for venue creation

Examples of limit enforcement:

- adding a third field on Starter should show upgrade prompt
- adding extra staff beyond plan limit should show upgrade prompt
- trying to use disabled payment feature should show plan restriction

## 11. Website / Browser Requirements

Managers who log in via browser must see the same account state as in the manager app.

The website manager experience must support:

- plan visibility
- subscription status
- renewal / upgrade
- onboarding continuation if venue setup is incomplete
- same restrictions as mobile app

No separate subscription logic should exist just because the entry point is Safari/browser.

## 12. Customer App Impact

Customer app should not become cluttered with subscription concepts.

Customer-facing behavior should only reflect venue availability rules.

Recommended behavior:

- active venues behave normally
- expired or suspended venues become unavailable for new bookings
- customer should see either:
  - venue hidden from bookable listings
  - or venue visible but marked unavailable

First implementation recommendation:

- prevent booking unavailable venues
- decide later whether to hide or visually mark them

## 13. Backend / Admin Panel Responsibilities

Admin panel must support:

- create plan
- edit plan
- clone plan
- activate plan
- deactivate plan
- archive plan from new sales while keeping historical subscriptions intact
- reorder plan display
- activate or assign subscription
- renew subscription
- suspend subscription
- cancel subscription
- grant trial
- view subscription history
- view manager usage against limits

Admin must also be able to:

- override subscription status
- override expiry date
- grant temporary extension

### 13.1 Plan Management Must Be Admin-Driven

The business owner must be able to manage plans directly from admin panel without code changes.

Required plan-management capabilities:

- create new plan
- edit existing plan
- set display name
- set internal code
- write marketing description
- choose monthly and yearly pricing
- choose trial duration
- toggle active/inactive
- mark recommended / featured plan
- set display order
- set plan color / badge label optionally later
- define limits:
  - branches
  - fields
  - staff
- define features:
  - wallet
  - online payment
  - reports
  - monthly bookings
  - browser dashboard access

Important:

- deleting plans physically is not recommended once used
- use inactive / archived status instead

### 13.2 Subscription Assignment Modes

Admin panel should support more than one assignment path:

1. manager self-selects plan
2. admin manually assigns plan
3. admin grants trial
4. admin upgrades or downgrades manager manually

This keeps the system usable both as a self-service product and as an assisted sales model.

## 14. Proposed Data Model

Recommended core tables:

- `subscription_plans`
- `subscription_plan_features`
- `manager_subscriptions`
- `subscription_invoices`
- `subscription_payments`
- `subscription_change_logs`

Optional but useful:

- `subscription_usage_snapshots`
- `subscription_grace_policies`

### 14.1 subscription_plans

Suggested fields:

- id
- name
- code
- description
- short_description
- badge_label
- is_featured
- billing_cycle_default
- monthly_price
- yearly_price
- trial_days
- status
- sort_order
- archived_at
- created_by
- updated_by

### 14.2 subscription_plan_features

Suggested fields:

- id
- subscription_plan_id
- max_branches
- max_fields
- max_staff
- allow_online_payments
- allow_wallet
- allow_monthly_bookings
- allow_reports
- allow_web_access
- allow_customer_support_tools
- metadata json for future extensions

### 14.3 manager_subscriptions

Suggested fields:

- id
- manager_user_id
- subscription_plan_id
- status
- started_at
- expires_at
- grace_ends_at
- trial_ends_at
- auto_renew
- source
- notes

### 14.4 subscription_invoices

Suggested fields:

- id
- manager_subscription_id
- billing_cycle
- amount
- currency
- status
- issued_at
- due_at
- paid_at

### 14.5 subscription_payments

Suggested fields:

- id
- subscription_invoice_id
- payment_method
- payment_reference
- amount
- status
- paid_at
- metadata

### 14.6 subscription_change_logs

Suggested fields:

- id
- manager_subscription_id
- changed_by
- action
- old_status
- new_status
- note
- created_at

## 15. Usage Enforcement Strategy

Backend must validate limits before allowing actions like:

- creating branch
- creating field
- creating staff account
- enabling certain payment features

Apps should also show proactive UI warnings, but UI must not be the final enforcement layer.

## 16. API Contract Requirements

The backend should expose a normalized subscription payload to both manager app and website.

Minimum response shape recommendation:

- current plan
- current status
- feature flags
- hard limits
- current usage counts
- blocked actions
- renewal information
- marketing plan list for plan-selection screens

Example data points:

- `plan_name`
- `plan_code`
- `status`
- `expires_at`
- `trial_ends_at`
- `limits`
- `usage`
- `features`
- `can_create_branch`
- `can_create_field`
- `can_create_staff`

Plan-list payload for app/web storefront should include:

- id
- name
- short_description
- monthly_price
- yearly_price
- trial_days
- badge_label
- is_featured
- sort_order
- feature summary
- limit summary

## 17. UX Rules

The subscription UX should be clear and calm.

Avoid aggressive blocking with technical wording.

Use messages like:

- your current plan allows up to 2 fields
- upgrade to Growth to add more fields
- your subscription expires on 2026-09-09
- renew now to continue receiving bookings

Plan selection screens in manager app and web should:

- load available plans dynamically from backend
- respect admin panel display order
- highlight featured plans if configured
- show only active/public plans

## 18. Notifications

Notifications should be sent for:

- trial ending soon
- subscription expiring soon
- subscription expired
- subscription renewed successfully
- subscription suspended

Recommended channels:

- in-app notifications
- website/dashboard alerts
- optional email later

## 19. Reporting

Admin panel should eventually report:

- managers by plan
- expiring soon subscriptions
- expired subscriptions
- trial conversion rate
- plan revenue
- plan distribution

Not required for phase 1 implementation, but should be supported by data model choices.

## 20. Non-Goals For First Release

Do not include these in the first implementation unless needed:

- referral system
- coupon engine for subscriptions
- complex proration
- multi-currency subscription engine
- fully automated tax engine
- partner marketplace integrations

Also avoid in first release:

- complex coupon logic for subscriptions
- public self-service plan-comparison CMS beyond the admin-managed structured fields

## 21. Recommended Implementation Phases

### Phase 1

Product and technical specification approval

### Phase 2

Backend data model and API design

### Phase 3

Admin panel plan management

### Phase 4

Manager app subscription visibility and onboarding

### Phase 5

Website/browser subscription visibility and onboarding

### Phase 6

Customer app availability impact

### Phase 7

Notifications and billing refinements

## 22. Phase 1 Acceptance Criteria

Phase 1 is complete when:

- business model is approved
- plan structure is approved
- subscription lifecycle states are approved
- expiry behavior is approved
- manager onboarding flow is approved
- backend-first enforcement approach is approved

## 23. Open Decisions To Confirm Before Phase 2

These must be confirmed before data model implementation:

1. trial duration:
   `14` or `30` days
2. exact plan names:
   keep `Starter / Growth / Pro` or localize them
3. exact limits per plan
4. exact renewal policy after expiry
5. whether expired venues are hidden or shown as unavailable to customers
6. whether online payment fee is only commercial or also technically represented in dashboard reports
7. whether plan creation is internal admin-only at first release or partially exposed to sales/operator roles

## 24. Recommended Default Decisions

If no further business override is given, proceed with:

1. trial:
   `30 days`
2. plan names:
   `Starter`, `Growth`, `Pro`
3. customer visibility for expired venues:
   visible but not bookable
4. post-expiry:
   read-only + no new bookings
5. yearly plan:
   discounted relative to monthly total
6. plan management:
   full create/edit/activate/deactivate from admin panel
7. plan source:
   backend-driven and not hardcoded in app/web

## 25. Phase 2 Technical Architecture

This section defines the backend data model and API structure for implementation.

Goal:

- make subscriptions fully backend-driven
- preserve existing booking architecture
- avoid hardcoded plan logic in mobile app or website

## 26. Domain Model

The subscription domain should be treated as a dedicated bounded context connected to manager accounts.

Main entities:

- Plan
- Plan Feature Set
- Manager Subscription
- Subscription Invoice
- Subscription Payment
- Subscription Change Log

Connected business entities:

- Manager user account
- Branch
- Field / service
- Staff / employee

Important:

- subscription is attached to the manager account
- usage limits are evaluated against the manager's owned operational entities
- branch, field, and staff creation remain in their current business modules, but their creation must pass subscription validation

## 27. Ownership Model

Recommended ownership rule:

- one manager account owns one commercial subscription context
- that subscription governs all branches and fields under that manager

This avoids early complexity such as:

- one subscription per branch
- mixed branch-level plan assignments

Future extension is possible later, but phase 2 should use:

- one manager -> one active subscription scope

## 28. Suggested Table Set

Core implementation tables:

1. `subscription_plans`
2. `subscription_plan_feature_values`
3. `manager_subscriptions`
4. `manager_subscription_usages`
5. `subscription_invoices`
6. `subscription_payments`
7. `subscription_change_logs`

Optional supporting tables for cleaner admin UX:

8. `subscription_plan_visibility_rules`
9. `subscription_status_histories`

## 29. Table Definitions

### 29.1 subscription_plans

Purpose:

- commercial plan catalog managed by admin panel

Suggested fields:

- `id`
- `uuid`
- `name`
- `code`
- `description`
- `short_description`
- `badge_label`
- `is_featured`
- `monthly_price`
- `yearly_price`
- `trial_days`
- `currency_code`
- `status`
- `is_public`
- `sort_order`
- `archived_at`
- `created_by`
- `updated_by`
- `created_at`
- `updated_at`

Constraints:

- `code` unique
- physical delete should be avoided once subscriptions exist

Suggested status values:

- `draft`
- `active`
- `inactive`
- `archived`

### 29.2 subscription_plan_feature_values

Purpose:

- plan feature and limit definition

Suggested fields:

- `id`
- `subscription_plan_id`
- `max_branches`
- `max_fields`
- `max_staff`
- `allow_online_payments`
- `allow_wallet`
- `allow_monthly_bookings`
- `allow_reports`
- `allow_web_access`
- `allow_customer_support_tools`
- `metadata_json`
- `created_at`
- `updated_at`

Design note:

- first release can keep this as one row per plan
- no need for overly abstract key/value design in phase 2

### 29.3 manager_subscriptions

Purpose:

- current and historical subscriptions attached to managers

Suggested fields:

- `id`
- `uuid`
- `manager_user_id`
- `subscription_plan_id`
- `status`
- `source`
- `billing_cycle`
- `started_at`
- `trial_started_at`
- `trial_ends_at`
- `expires_at`
- `grace_ends_at`
- `cancelled_at`
- `suspended_at`
- `auto_renew`
- `is_current`
- `notes`
- `created_by`
- `updated_by`
- `created_at`
- `updated_at`

Recommended status values:

- `trial`
- `active`
- `grace_period`
- `expired`
- `suspended`
- `cancelled`

Important constraints:

- manager may have many historical subscriptions
- only one row should be `is_current = 1`

### 29.4 manager_subscription_usages

Purpose:

- cache current usage counts for faster checks and dashboard display

Suggested fields:

- `id`
- `manager_subscription_id`
- `manager_user_id`
- `current_branch_count`
- `current_field_count`
- `current_staff_count`
- `last_calculated_at`
- `created_at`
- `updated_at`

Design note:

- this table is optional but strongly recommended
- if not used initially, usage can be computed from live relations and later optimized

### 29.5 subscription_invoices

Purpose:

- billing records for subscription cycles

Suggested fields:

- `id`
- `uuid`
- `manager_subscription_id`
- `manager_user_id`
- `subscription_plan_id`
- `invoice_no`
- `billing_cycle`
- `amount`
- `discount_amount`
- `final_amount`
- `currency_code`
- `status`
- `issued_at`
- `due_at`
- `paid_at`
- `notes`
- `created_at`
- `updated_at`

Suggested status values:

- `draft`
- `issued`
- `paid`
- `failed`
- `cancelled`

### 29.6 subscription_payments

Purpose:

- payment transaction records for subscription invoices

Suggested fields:

- `id`
- `uuid`
- `subscription_invoice_id`
- `manager_user_id`
- `payment_method`
- `payment_reference`
- `gateway_name`
- `amount`
- `currency_code`
- `status`
- `paid_at`
- `metadata_json`
- `created_at`
- `updated_at`

### 29.7 subscription_change_logs

Purpose:

- audit trail for plan and status changes

Suggested fields:

- `id`
- `manager_subscription_id`
- `manager_user_id`
- `actor_user_id`
- `action`
- `old_plan_id`
- `new_plan_id`
- `old_status`
- `new_status`
- `reason`
- `context_json`
- `created_at`

Examples of action values:

- `created`
- `trial_granted`
- `activated`
- `renewed`
- `upgraded`
- `downgraded`
- `expired`
- `suspended`
- `cancelled`
- `reactivated`

## 30. Relationship Map

Recommended relationships:

- `subscription_plans` hasOne `subscription_plan_feature_values`
- `subscription_plans` hasMany `manager_subscriptions`
- `manager_subscriptions` belongsTo `subscription_plans`
- `manager_subscriptions` belongsTo manager user
- `manager_subscriptions` hasOne `manager_subscription_usages`
- `manager_subscriptions` hasMany `subscription_invoices`
- `subscription_invoices` hasMany `subscription_payments`
- `manager_subscriptions` hasMany `subscription_change_logs`

Manager-side operational counts should eventually resolve from:

- branches owned by manager
- fields/services under those branches
- staff/employee users linked to manager or branch

## 31. Where This Integrates With Existing Modules

The subscription system should connect to current modules at enforcement points, not by rewriting those modules.

Enforcement points:

- branch creation
- service/field creation
- employee/staff creation
- enabling online payment configuration
- monthly booking creation if restricted by plan
- browser dashboard access

Do not embed plan constants into:

- booking screens
- wallet widgets
- customer app route logic

Instead:

- backend returns current permissions
- frontend decides what to show or block

## 32. Usage Calculation Rules

Usage should be defined consistently:

- `branch_count` = active branches owned by manager
- `field_count` = active playable services / stadium fields under manager ownership
- `staff_count` = active employee/staff accounts linked to the manager's operation

Recommended first version:

- count only active records
- ignore soft-deleted/inactive records in usage limits

## 33. API Surface Overview

The API should be split into 3 groups:

1. admin plan management APIs
2. manager subscription APIs
3. internal enforcement / summary APIs

## 34. Admin Plan Management APIs

Suggested endpoints:

- `GET /api/admin/subscription-plans`
- `POST /api/admin/subscription-plans`
- `GET /api/admin/subscription-plans/{id}`
- `PUT /api/admin/subscription-plans/{id}`
- `PATCH /api/admin/subscription-plans/{id}/status`
- `POST /api/admin/subscription-plans/{id}/clone`
- `GET /api/admin/subscription-plans/{id}/subscriptions`

Suggested endpoint purposes:

- list plans with filters
- create plan
- fetch single plan
- update plan
- activate/deactivate/archive plan
- clone plan as new draft
- inspect plan subscribers

### 34.1 Admin Plan List Response

Each row should include:

- plan id
- name
- code
- status
- public visibility
- prices
- trial days
- featured flag
- order
- active subscriber count

### 34.2 Admin Plan Create / Update Payload

Suggested payload:

- `name`
- `code`
- `description`
- `short_description`
- `badge_label`
- `is_featured`
- `monthly_price`
- `yearly_price`
- `trial_days`
- `currency_code`
- `status`
- `is_public`
- `sort_order`
- `features`

Where `features` includes:

- `max_branches`
- `max_fields`
- `max_staff`
- `allow_online_payments`
- `allow_wallet`
- `allow_monthly_bookings`
- `allow_reports`
- `allow_web_access`

## 35. Admin Subscription Management APIs

Suggested endpoints:

- `GET /api/admin/manager-subscriptions`
- `GET /api/admin/manager-subscriptions/{id}`
- `POST /api/admin/manager-subscriptions/assign`
- `POST /api/admin/manager-subscriptions/{id}/renew`
- `POST /api/admin/manager-subscriptions/{id}/upgrade`
- `POST /api/admin/manager-subscriptions/{id}/downgrade`
- `POST /api/admin/manager-subscriptions/{id}/suspend`
- `POST /api/admin/manager-subscriptions/{id}/reactivate`
- `POST /api/admin/manager-subscriptions/{id}/cancel`
- `POST /api/admin/manager-subscriptions/{id}/grant-trial`

Use cases:

- assign plan manually
- renew subscription manually
- change plan
- suspend/restore account
- grant trial

## 36. Manager-Facing APIs

Suggested endpoints for manager app and web:

- `GET /api/manager/subscription/current`
- `GET /api/manager/subscription/plans`
- `POST /api/manager/subscription/select-plan`
- `POST /api/manager/subscription/renew`
- `GET /api/manager/subscription/invoices`
- `GET /api/manager/subscription/usage`
- `GET /api/manager/subscription/onboarding-status`

Purposes:

- fetch current subscription summary
- fetch public/available plans
- select a plan
- renew current subscription
- view billing history
- view usage against limits
- continue onboarding

## 37. Internal Enforcement APIs Or Services

Not every rule must be exposed as a public endpoint.

Recommended internal service methods:

- `canCreateBranch(managerId)`
- `canCreateField(managerId)`
- `canCreateStaff(managerId)`
- `canUseOnlinePayments(managerId)`
- `canUseMonthlyBookings(managerId)`
- `canAccessWebDashboard(managerId)`

Implementation note:

- expose these through backend service classes first
- frontend can rely on summary payload rather than calling six separate APIs

## 38. Current Subscription Summary Response

`GET /api/manager/subscription/current`

Recommended response shape:

- `subscription`
- `plan`
- `features`
- `limits`
- `usage`
- `permissions`
- `warnings`
- `blocking_state`

Example structure:

- `subscription.status`
- `subscription.started_at`
- `subscription.expires_at`
- `subscription.trial_ends_at`
- `subscription.grace_ends_at`
- `plan.id`
- `plan.name`
- `plan.code`
- `plan.monthly_price`
- `plan.yearly_price`
- `features.allow_online_payments`
- `limits.max_fields`
- `usage.current_field_count`
- `permissions.can_create_field`
- `warnings.expiring_soon`
- `blocking_state.reason`

## 39. Public Plan List Response

`GET /api/manager/subscription/plans`

Should return only:

- active
- public
- sellable plans

Suggested fields:

- `id`
- `name`
- `short_description`
- `description`
- `badge_label`
- `is_featured`
- `monthly_price`
- `yearly_price`
- `trial_days`
- `currency_code`
- `sort_order`
- `features_summary`
- `limits_summary`

## 40. Onboarding Status API

`GET /api/manager/subscription/onboarding-status`

Purpose:

- help manager app and web continue setup intelligently

Suggested response:

- `subscription_ready`
- `plan_selected`
- `venue_profile_completed`
- `first_branch_created`
- `first_field_created`
- `business_hours_completed`
- `staff_setup_completed`
- `payment_setup_completed`
- `next_step`

## 41. Validation Rules

Backend validation should reject invalid commercial data:

For plan creation:

- unique code
- non-negative pricing
- yearly price should not exceed 12x monthly without explicit override
- trial days should be bounded
- limits should be non-negative integers

For manager subscription assignment:

- manager must exist
- plan must be active unless explicit admin override
- only one current subscription row per manager

## 42. Access Control

Recommended permission separation:

- super admin:
  full access
- finance/admin operator:
  manage renewals and billing
- support/admin operator:
  view status, possibly grant trial or extension
- manager:
  view own subscription and request/perform renewal

First release recommendation:

- plan creation and editing should be super-admin only

## 43. Expiry and Renewal Jobs

Recommended scheduled backend jobs:

- mark subscriptions entering grace period
- mark subscriptions expired
- generate renewal reminders
- refresh usage snapshots

Suggested daily jobs:

- `subscription:refresh-statuses`
- `subscription:refresh-usages`
- `subscription:send-reminders`

## 44. Website / Web Access Enforcement

Browser dashboard access should be checked by backend middleware or gate logic.

If plan disallows web access or subscription is not valid:

- deny protected manager dashboard features
- show clear renewal or upgrade message

Do not rely on frontend route hiding alone.

## 45. Customer Availability Enforcement

Customer-facing booking availability should derive from venue subscription status.

Recommended first rule:

- if manager subscription is `expired` or `suspended`
- public booking actions are blocked

Implementation can choose one of two UI outputs:

1. venue remains visible but unbookable
2. venue hidden from search/listing

Recommended default:

- visible but unbookable

## 46. Event and Notification Triggers

Trigger events when:

- trial starts
- trial ends soon
- subscription activated
- subscription upgraded
- subscription renewed
- subscription enters grace period
- subscription expires
- subscription is suspended

These events should feed:

- in-app notification
- web dashboard alert
- optional email later

## 47. Phase 2 Acceptance Criteria

Phase 2 is complete when:

- core data model is approved
- ownership model is approved
- plan-management API shape is approved
- manager summary API shape is approved
- enforcement points are approved
- lifecycle job requirements are approved

## 48. Phase 3 Handoff

Once phase 2 is approved, the next implementation target is:

- admin panel subscription plan management UI
- admin subscription assignment and renewal UI
- backend migrations and service layer
