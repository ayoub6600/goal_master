# Goal Master Agent Instructions

Last Updated: 2026-08-09
Scope: main local workspace at `/Users/ayoubbelhaj/Documents/GitHub/goal_master`

## Purpose

This file is the mandatory operating guide for any AI agent that starts working on Goal Master.

The goal is:

- reduce repeated rediscovery
- reduce token / credit waste
- keep changes safe across customer app, manager app, and website/backend mirror
- preserve continuity between agents

## Mandatory Startup Protocol

Before making any change:

1. Read `/Users/ayoubbelhaj/Documents/GitHub/goal_master/AI_QUICKSTART.md`
2. Read `/Users/ayoubbelhaj/Documents/GitHub/goal_master/PROJECT_CONTEXT.md`
3. Read the latest relevant entry in:
   `/Users/ayoubbelhaj/Documents/GitHub/goal_master/CODEX_WORK_LOG.md`
4. Check git status in the affected repository
5. Identify which application is affected:
   - customer mobile app
   - stadium manager mobile app
   - website / backend mirror
6. Explain a short plan before editing
7. Make the smallest safe change
8. Record the work in `CODEX_WORK_LOG.md`

## Known Local Repositories

### 1. Customer + main project memory repo

Path:

- `/Users/ayoubbelhaj/Documents/GitHub/goal_master`

Contains:

- customer Flutter app
- project memory files
- raw server mirror under `server_mirror`

### 2. Website repo

Canonical path:

- `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

Important:

- this is the canonical website working copy
- do not use the old duplicate path `goal_master_web`

## Project Components

The product is made of 3 business parts:

1. Customer Mobile Application
2. Stadium Managers Mobile Application
3. Backend + Admin Panel

Important:

- the full backend/admin source was not originally available in GitHub
- some server-side website/backend code was mirrored locally and then prepared in the separate website repo
- do not treat missing backend files in this workspace as accidental defects

## Reading Strategy To Save Credits

Do not read the entire project blindly.

Use this order:

1. `AI_QUICKSTART.md`
2. `PROJECT_CONTEXT.md`
3. latest work log entry
4. only the exact folders related to the requested feature

Examples:

- booking issue in customer app:
  read customer booking feature files only
- manager add-booking issue:
  read manager booking feature files only
- admin/web issue:
  move to `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

## Change Rules

- Do not assume API shapes are stable.
- Do not change any API contract before checking all known consumers.
- Do not refactor broadly unless explicitly asked.
- Do not delete history from `CODEX_WORK_LOG.md`.
- Do not put secrets, passwords, keys, or tokens into documentation files.
- Prefer incremental fixes over large rewrites.
- If database or backend behavior is unclear, document the uncertainty explicitly.

## Documentation Rules

After meaningful work:

- update `PROJECT_CONTEXT.md` if architecture, paths, flows, or important decisions changed
- append a new entry to `CODEX_WORK_LOG.md`
- if a new repeated workflow appears, update this `AGENTS.md` or `AI_QUICKSTART.md`

## Current Important Facts

- Main workspace memory files live in:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master`
- Website repo lives in:
  `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`
- Website local runtime has already been made runnable with local SQLite
- local super admin username is known to be `admin`
- seeded default local password historically used is `12345678`
- credentials must never be copied into persistent docs again unless the user explicitly asks and it is safe

## Expected Output Style

After each change, explain:

- what changed
- why it changed
- which files changed
- how it was checked
- remaining risks

## If A New AI Joins Mid-Project

The new AI must not restart the project understanding from zero.

It should:

1. read `AI_QUICKSTART.md`
2. read `PROJECT_CONTEXT.md`
3. read the latest work log entries
4. inspect git status
5. continue from current state
