# Goal Master AI Quickstart

Last Updated: 2026-08-09

This file is the shortest reliable entry point for any AI agent working on Goal Master.

Read this first before opening the larger project context file.

## What This Project Is

Goal Master is a sports booking platform with 3 product parts:

1. customer mobile app
2. stadium manager mobile app
3. backend + admin/web side

## What Is Available Locally Right Now

### Main workspace

Path:

- `/Users/ayoubbelhaj/Documents/GitHub/goal_master`

Contains:

- customer Flutter app
- project memory files
- imported server mirror files

### Website / backend-related local repo

Canonical path:

- `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

Contains:

- Laravel website code
- local runnable website setup
- local SQLite development database

## What Is Not Safe To Assume

- not every backend piece is fully present locally
- API payload types are not fully stable
- notifications are not always schema-uniform
- booking and wallet flows have already needed normalization/fixes

## Current Knowledge Priorities

If the task is about:

- customer app:
  stay in `goal_master/lib/features/...`
- manager app:
  check the separate manager app repository if opened in workspace later
- website/admin/backend:
  use `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

## Files You Must Read Before Editing

1. `/Users/ayoubbelhaj/Documents/GitHub/goal_master/AGENTS.md`
2. `/Users/ayoubbelhaj/Documents/GitHub/goal_master/PROJECT_CONTEXT.md`
3. latest relevant section in:
   `/Users/ayoubbelhaj/Documents/GitHub/goal_master/CODEX_WORK_LOG.md`
4. if the task is about manager subscriptions:
   `/Users/ayoubbelhaj/Documents/GitHub/goal_master/SUBSCRIPTION_SYSTEM_SPEC.md`

## Why These Files Exist

- `AGENTS.md`
  operating rules for any AI
- `PROJECT_CONTEXT.md`
  durable architecture and system memory
- `CODEX_WORK_LOG.md`
  historical log of what changed and why
- `SUBSCRIPTION_SYSTEM_SPEC.md`
  approved product + technical blueprint for the subscription feature

## Fast Rules

- do not re-scan the entire codebase unless required
- do not change API contracts casually
- do not store secrets in docs
- do not remove previous work log entries
- prefer small changes with verification

## Website Runtime Facts

Canonical repo:

- `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

Local dev facts already established:

- local env uses SQLite
- the site was previously verified locally at `http://127.0.0.1:8000`
- Composer dependencies were installed in that repo
- VS Code local PHP wrapper was added there to reduce PHP 8.4 deprecation noise

## When You Finish Work

- append to `CODEX_WORK_LOG.md`
- update `PROJECT_CONTEXT.md` if global knowledge changed
- update `AGENTS.md` or this file if a repeated workflow should be remembered
