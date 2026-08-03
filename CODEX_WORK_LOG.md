# Codex Work Log

This file is append-only.
Do not delete old entries.
Add new entries at the end or prepend them with clear dates, but preserve history.

---

## Entry 1

Date: 2026-08-02

Requested Work:

- Understand the Goal Master project as a long-term production project.
- Build durable project knowledge before any coding work.
- Create `PROJECT_CONTEXT.md`.
- Create `CODEX_WORK_LOG.md`.
- Stop and wait for the next task.

Reason:

- Establish a persistent project memory so future changes are based on actual system understanding.
- Create a repeatable operating protocol for future Codex work on this project.

Work Performed:

- Inspected both currently available repositories:
  `goal_master` and `goal_master_admin`.
- Reviewed top-level structure, `pubspec.yaml`, routing, startup logic, service locator setup, API endpoint definitions, repository implementations, notification logic, and current git status.
- Built a cross-project understanding of the customer app and stadium managers app.
- Documented the absence of backend and admin panel code as an expected current limitation, not a defect.
- Created `PROJECT_CONTEXT.md` as the central local project reference.
- Created this log file.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`

Why These Files Changed:

- `PROJECT_CONTEXT.md` was added to preserve project architecture, flows, technical decisions, known risks, and current workspace boundaries.
- `CODEX_WORK_LOG.md` was added to preserve a permanent history of Codex work and decisions.

Testing / Validation:

- No application code was modified.
- No runtime tests were executed.
- Validation was done through source inspection and cross-checking of key files in both repositories.

Result:

- A durable baseline project context now exists for the currently opened Goal Master workspace.
- Future tasks can begin from an informed, production-oriented understanding rather than from fresh rediscovery.

Remaining Issues / Gaps:

- Backend source is not yet available locally.
- Admin panel source is not yet available locally.
- Database schema is still unknown.
- Formal API documentation is still unavailable.
- Automated test coverage in the visible repositories is minimal.

Important Future Notes:

- Before any new implementation task:
  1. Read `PROJECT_CONTEXT.md`.
  2. Read the latest entry in `CODEX_WORK_LOG.md`.
  3. Check git status in the impacted repository.
  4. Assess cross-project impact.
  5. Present a short plan before editing.
- Preserve the distinction between:
  customer mobile app,
  stadium managers mobile app,
  backend + admin panel.
- When backend or server files become available later, extend the current context incrementally instead of rebuilding it from zero.

---

## Entry 2

Date: 2026-08-02

Requested Work:

- Download the website from the server so it can later be moved into GitHub and maintained locally.

Reason:

- Add the website into the active local project understanding.
- Prepare the website source for future local edits and controlled redeployment.

Work Performed:

- Used the provided server access to inspect `72.60.39.196`.
- Identified that the useful login path was through `root@72.60.39.196`.
- Located the website source under:
  `/home/goalmasters-web/htdocs/web.goalmasters.online/public/GoalMaster`
- Confirmed the website is a Laravel 9 application with `composer.json` and `package.json`.
- Observed that the server vhost document root is:
  `/home/goalmasters-web/htdocs/web.goalmasters.online/public`
- Observed that the top-level server `public/index.php` currently contains only `phpinfo();`
- Created a sanitized archive on the server excluding secrets and large generated dependencies.
- Downloaded the sanitized archive into the local workspace.
- Extracted the website mirror locally into:
  `server_mirror/web.goalmasters.online`
- Updated `PROJECT_CONTEXT.md` to include the website mirror as part of the known project landscape.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `server_mirror/web.goalmasters.online/goalmasters_web_source.tar.gz`
- `server_mirror/web.goalmasters.online/public/...`

Why These Files Changed:

- `PROJECT_CONTEXT.md` was updated to reflect the newly available website source and its deployment structure.
- `CODEX_WORK_LOG.md` was updated to preserve the operational history of the server import.
- `server_mirror/web.goalmasters.online/...` was added as the local mirror of the website source taken from production.

Testing / Validation:

- Validated SSH access to the server.
- Validated the remote path containing the website code.
- Confirmed locally that `.env` was not copied.
- Confirmed locally that dependency directories such as `vendor` and `node_modules` were excluded from the imported mirror.

Result:

- The production website source is now available locally in sanitized form for inspection and future repository preparation.
- Project knowledge has been updated to include this website component.

Remaining Issues / Gaps:

- The website has not yet been initialized as a dedicated Git repository.
- The website has not yet been pushed to GitHub.
- The current production vhost structure appears unusual because the top-level `public/index.php` is only `phpinfo();`
- The relationship between this website source and the still-missing backend/admin-panel repositories remains incomplete.

Important Future Notes:

- Before any cleanup or GitHub migration, review the website mirror structure carefully.
- Do not recreate `.env` from memory; obtain environment values separately and keep them out of Git.
- Review whether the production deployment intentionally serves from nested `public/GoalMaster` or whether this is a transitional structure.

---

## Entry 3

Date: 2026-08-02

Requested Work:

- Prepare the imported website source into a GitHub-ready local working copy.

Reason:

- Separate the raw production mirror from a cleaner source-control-ready copy.
- Reduce the chance of accidentally committing production runtime data into GitHub.

Work Performed:

- Created a second website copy under:
  `github_ready/web.goalmasters.online`
- Flattened the working copy to the Laravel project root taken from:
  `server_mirror/web.goalmasters.online/public/GoalMaster`
- Removed clearly non-repository runtime artifacts from the GitHub-ready copy, including:
  `public/uploadfiles`,
  debugbar output,
  framework session/view/cache runtime files,
  queue log,
  `.DS_Store`,
  and server helper leftovers such as `composer-setup.php`
- Replaced the broken imported `.gitignore` with a cleaner repository-oriented version.
- Added:
  `README.md`
  `DEPLOYMENT_NOTES.md`
- Initialized the GitHub-ready website copy as a standalone local Git repository with branch `main`.
- Confirmed that `.env` is still absent and that `public/uploadfiles` is no longer present in the GitHub-ready copy.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `github_ready/web.goalmasters.online/...`

Why These Files Changed:

- Project memory files were updated to record the new prepared repository workspace.
- The website working copy was cleaned and documented so it can become a dedicated GitHub repository with lower risk.

Testing / Validation:

- Verified `.env` is not present in the GitHub-ready copy.
- Verified `public/uploadfiles` was removed from the GitHub-ready copy.
- Verified a standalone Git repository was initialized successfully in:
  `github_ready/web.goalmasters.online`
- Verified the cleaned tree still contains the Laravel application source structure.

Result:

- A cleaner website repository candidate now exists locally and is ready for GitHub linkage.

Remaining Issues / Gaps:

- GitHub CLI `gh` is not installed on this machine.
- No GitHub remote has been created yet.
- The production vhost/public-root arrangement still needs verification before future deployment work.

Important Future Notes:

- Use `github_ready/web.goalmasters.online` as the base for repository work.
- Keep `server_mirror/web.goalmasters.online` untouched as the raw server reference.
- Before first push, decide the target repository name and owner.

---

## Entry 4

Date: 2026-08-02

Requested Work:

- Link this device to the user's GitHub account through the terminal so Codex can use Git operations directly.

Reason:

- Enable terminal-based repository management for future Goal Master work.

Work Performed:

- Generated a dedicated SSH key for GitHub access on this device.
- Opened the GitHub SSH keys settings page in the in-app browser.
- Added the new public SSH key to GitHub account `ayoub6600`.
- Created local SSH configuration in `~/.ssh/config` to use the dedicated key for `github.com`.
- Verified terminal authentication with:
  `ssh -T git@github.com`

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`

External/Local Environment Changes:

- `~/.ssh/github_goal_master_ed25519`
- `~/.ssh/github_goal_master_ed25519.pub`
- `~/.ssh/config`
- GitHub account `ayoub6600` now contains the added SSH key entry:
  `Codex Goal Master Mac 2026-08-02`

Why These Changes Were Made:

- They allow Codex to perform terminal Git operations against repositories accessible by the user's GitHub account from this device.

Testing / Validation:

- SSH authentication test succeeded.
- GitHub returned:
  `Hi ayoub6600! You've successfully authenticated, but GitHub does not provide shell access.`

Result:

- This device is now linked to GitHub for terminal Git over SSH.

Remaining Issues / Gaps:

- `gh` is still not installed.
- Repository creation through GitHub CLI is not available yet unless installed later.

Important Future Notes:

- Git operations over SSH are now available.
- Keep using SSH remotes of the form:
  `git@github.com:<owner>/<repo>.git`

---

## Entry 5

Date: 2026-08-02

Requested Work:

- Create the website repository on GitHub and publish the prepared website source to it.

Reason:

- Move the sanitized website copy into a real GitHub repository so future work can happen locally and be pushed cleanly.

Work Performed:

- Chose repository name:
  `goal-master-web`
- Created a new private GitHub repository under account:
  `ayoub6600/goal-master-web`
- Added `origin` to the local website repository at:
  `github_ready/web.goalmasters.online`
- Staged the full prepared website tree.
- Created the initial commit:
  `Initial sanitized website import`
- Pushed branch `main` to GitHub over SSH.
- Updated project memory to reflect that the website repository now exists remotely.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `github_ready/web.goalmasters.online/.git/...`

External Changes:

- GitHub repository created:
  `ayoub6600/goal-master-web`

Why These Changes Were Made:

- They complete the first real source-control publication step for the website and establish the remote that future local development will use.

Testing / Validation:

- Verified repository creation in GitHub browser UI.
- Verified `origin` remote:
  `git@github.com:ayoub6600/goal-master-web.git`
- Verified push success:
  `main -> main`

Result:

- The website is now published to GitHub and the local working copy tracks `origin/main`.

Remaining Issues / Gaps:

- The customer mobile app and stadium manager mobile app are not yet published into the naming structure we planned.
- The production deployment structure for the website still requires later verification before redeployment changes.

Important Future Notes:

- Continue website Git work from:
  `github_ready/web.goalmasters.online`
- Keep the raw imported copy in:
  `server_mirror/web.goalmasters.online`

---

## Entry 6

Date: 2026-08-02

Requested Work:

- Move the website repository out of the nested `goal_master` path so its local location matches the level of `goal_master` and `goal_master_admin`.

Reason:

- The user wanted the website/backend PHP project to live directly under `Documents/GitHub`, not nested inside the customer application repository.

Work Performed:

- Moved the working website repository from:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/github_ready/web.goalmasters.online`
  to:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
- Verified that the moved repository still has its Git remote:
  `git@github.com:ayoub6600/goal-master-web.git`
- Verified the moved repository still functions as a standalone Git repository.
- Removed the now-empty `github_ready` directory from inside `goal_master`.
- Updated project memory to reference the new top-level path.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`

External / Filesystem Changes:

- New active local website path:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
- Old nested working-copy path removed.

Why These Changes Were Made:

- They align the local filesystem layout with the intended project structure:
  `goal_master`
  `goal_master_admin`
  `goal_master_web`

Testing / Validation:

- Confirmed new Git top-level path with `git rev-parse --show-toplevel`
- Confirmed `origin` remote remained intact after the move
- Confirmed no working tree issues were introduced by the move

Result:

- The website repository now sits beside the customer and manager repositories at the top GitHub workspace level on the local machine.

Remaining Issues / Gaps:

- The raw server mirror still remains under:
  `goal_master/server_mirror/web.goalmasters.online`
  as intended for reference.

Important Future Notes:

- Use `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web` as the day-to-day working repository for the website.
- Treat `server_mirror/web.goalmasters.online` only as a raw production import reference.

---

## Entry 7

Date: 2026-08-02

Requested Work:

- Run the website locally.
- create a local database through migrations.
- verify access to the admin panel.

Reason:

- The website/backend repository had been imported and published, but it was not yet runnable locally.
- We needed a verified local development baseline before future feature or backend work.

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and `CODEX_WORK_LOG.md` and checked git status before starting.
- Inspected the Laravel website repository at:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
- Confirmed local prerequisites:
  PHP, Composer, MySQL client, SQLite client.
- Determined that local MySQL was not practically usable for this task because:
  1. local root access was unavailable, and
  2. the project's MySQL connection uses a hard-coded `db2_` table prefix while historical migrations include raw SQL against unprefixed tables.
- Installed Composer dependencies locally.
- Created a local `.env` configured for SQLite.
- Created local database file:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/database.sqlite`
- Generated the Laravel app key.
- Created the storage symlink.
- Ran migrations and resolved multiple local-run blockers discovered during execution:
  1. a large translation migration with MySQL-style escaping incompatible with SQLite,
  2. column-change migrations that are unsafe on SQLite rebuild flow,
  3. a broken migration that tried to drop `reset_token` inside `up()` when the column did not exist,
  4. a seeder that assumed Arabic language had fixed ID `3`,
  5. missing runtime directories under `storage/framework`.
- Re-ran seeding successfully after the fixes.
- Started the local server on:
  `http://127.0.0.1:8000`
- Verified:
  `/login` loads,
  the seeded `admin` user exists,
  login succeeds,
  and authenticated redirect reaches `/home`.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/.env`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/migrations/2022_04_16_091624_insert_translation_default_en_language.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/migrations/2022_05_07_185540_modify_column_sch_service_table.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/migrations/2022_05_09_163614_modify_column_sch_employee_table.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/migrations/2025_03_19_042811_add_column_reset_token_to_users_table.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/seeders/TranslateSeeder.php`

Why These Files Changed:

- Project memory files were updated to preserve the local-run strategy and the risks discovered.
- `.env` was created to define a safe local development runtime using SQLite.
- The affected migrations were adjusted so local execution could complete on SQLite without changing the intended production MySQL path unnecessarily.
- `TranslateSeeder` was made defensive so it no longer depends on a hard-coded Arabic language ID.

Testing / Validation:

- `composer install`
- `php artisan key:generate`
- `php artisan storage:link`
- `php artisan migrate --seed --force`
- `php artisan db:seed --force`
- `php artisan route:list --path=login`
- HTTP verification with curl:
  `/login` returned `200`
  login POST redirected to `/home`
  authenticated `/home` returned `200`
- SQLite verification confirmed presence of system user `admin`.

Result:

- The website now runs locally on Sunday, August 2, 2026 at:
  `http://127.0.0.1:8000`
- Local migrations and seeds complete successfully using SQLite.
- Admin panel access is verified through the normal web login flow.

Remaining Issues / Gaps:

- The application is running on PHP `8.4.8` while the Laravel codebase targets Laravel 9, so deprecation warnings still appear.
- The local website repository now contains runtime-generated untracked data under `storage/debugbar/`.
- The local-run compatibility fixes should be reviewed later for whether they should remain as committed code, be scoped by environment more explicitly, or be replaced by a cleaner Docker/PHP 8.2 + MySQL setup.
- MySQL-local migration behavior is still not the recommended path until the hard-coded prefix and raw SQL assumptions are reviewed together.

Important Future Notes:

- Current verified local runtime:
  `goal_master_web` + SQLite + `php artisan serve`
- Admin login route:
  `/login`
- Admin dashboard landing route after successful login:
  `/home`
- If login/session errors return later, first verify presence of:
  `storage/framework/sessions`
  `storage/framework/views`
  `storage/framework/cache/data`

---

## Entry 8

Date: 2026-08-02

Requested Work:

- Create a stadium manager locally.
- Create stadium-related data for that manager.
- Create usable schedule/time-slot data for the manager's stadium setup.

Reason:

- The user wanted a ready local dataset that can be used immediately from the manager mobile application and the backend API.
- The goal was not just to insert rows, but to create a coherent manager-owned structure that matches how the API actually filters and serves data.

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and the latest `CODEX_WORK_LOG.md` entry.
- Checked git status before touching the website backend.
- Traced how the manager mobile app consumes backend data:
  `zone -> club/branch -> category -> service -> employee -> timeslot`
- Confirmed that manager-facing branch visibility depends on both:
  1. `cmn_branches.created_by = manager_user_id`
  2. `sec_user_branches`
- Confirmed that local mobile authentication required a valid local JWT secret.
- Added a new idempotent seeder:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/seeders/DemoStadiumManagerSeeder.php`
- Configured local JWT secret so `/api/login` works locally.
- Seeded a complete demo manager dataset containing:
  1. one manager user
  2. one zone
  3. one club/branch owned by that manager
  4. one service category
  5. two field/service records:
     `Stadium 1`
     `Stadium 2`
  6. two employees, one aligned with each field
  7. branch business hours
  8. employee weekly schedules
  9. employee-service assignments
  10. manager role + branch linkage records
- Verified the resulting data through the live local API.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/.env`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/seeders/DemoStadiumManagerSeeder.php`

Why These Files Changed:

- Project memory files were updated so the new demo-manager dataset and JWT requirement are preserved for future work.
- `.env` was updated by local JWT setup so API login can work.
- `DemoStadiumManagerSeeder.php` was added to make manager demo data reproducible instead of manually inserted.

Testing / Validation:

- Ran:
  `php artisan db:seed --class=DemoStadiumManagerSeeder --force`
- Ran:
  `php artisan jwt:secret --force`
- Verified database contents in local SQLite:
  manager user, branch, category, services, employees, hours, and schedules
- Verified API login success through:
  `POST /api/login`
- Verified authenticated manager API responses for:
  `GET /api/manager/dashboard/analysis`
  `GET /api/list/zone`
  `POST /api/list/club`
  `POST /api/list/category`
  `POST /api/list/service`
  `POST /api/list/booking`
  `POST /api/list/timeslot`
- Verified time-slot response on Sunday, August 2, 2026 for the first demo field returned available slots from `16:00:00` to `23:00:00`.

Result:

- The local backend now contains a usable demo stadium manager dataset aligned with the current application architecture.
- The manager API login works locally.
- The manager can now see zone, club, field/service, employees, and available time slots through the local API.

Remaining Issues / Gaps:

- The current availability logic in the backend blocks primarily by employee/time and not robustly by service, so demo data was intentionally structured with one employee per field to avoid false collisions.
- The demo setup currently creates one club with two fields; if multi-club manager ownership is needed later, extend the same seeder rather than inserting ad hoc rows.
- The project still emits PHP 8.4 deprecation warnings during CLI and HTTP execution.

Important Future Notes:

- Use `DemoStadiumManagerSeeder` for repeatable local manager demo data.
- If a fresh local database is recreated, rerun:
  1. `php artisan migrate --seed --force`
  2. `php artisan db:seed --class=DemoStadiumManagerSeeder --force`
  3. `php artisan jwt:secret --force`

---

## Entry 9

Date: 2026-08-02

Requested Work:

- Run the customer mobile application on `iPhone 17`.
- Run the stadium manager mobile application on `iPhone 17e`.
- Prepare a usable local flow so a customer account can be created and the demo manager can sign in against the same local backend.

Reason:

- The user wanted an end-to-end local test path across both mobile apps using the already prepared local backend and demo manager data.

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and the latest `CODEX_WORK_LOG.md` entry.
- Checked git status in both mobile repositories before editing.
- Confirmed both mobile apps were still pointing at production API base URL:
  `https://web.goalmasters.online/api/`
- Switched both mobile apps to the local backend URL:
  `http://127.0.0.1:8000/api/`
- Enabled non-HTTPS requests for the customer iOS app so local simulator traffic to `127.0.0.1:8000` is allowed.
- Ran `flutter pub get` in both mobile repositories.
- Attempted first iOS launches on:
  `iPhone 17`
  `iPhone 17e`
- Diagnosed a runtime crash path caused by active `google_fonts` usage failing to load `AssetManifest.json` in the current simulator/toolchain environment.
- Removed active `google_fonts` usage from both apps' live theme/text-field code paths so they fall back to stable system text styles for local testing.
- Performed clean simulator reinstalls for both apps.
- Diagnosed the customer app's booking-screen crash further by comparing live local API JSON with Dart model expectations.
- Hardened customer booking/service/employee parsing so numeric API values that arrive as integers are accepted where the app previously assumed strings.
- Relaunched both apps successfully on their requested simulators.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/end_points.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/ios/Runner/Info.plist`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/components/custom_text_field/custom_text_field_actual_field.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/components/custom_text_field/custom_text_field_upper_hint.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/booking/data/model/service_model.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/booking/data/model/employe/employe.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/home/data/model/service_model.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/pubspec.yaml`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/pubspec.lock`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/core/databases/api/end_points.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/main.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/core/components/custom_text_field/custom_text_field_actual_field.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/core/components/custom_text_field/custom_text_field_upper_hint.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/pubspec.yaml`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/pubspec.lock`

Why These Files Changed:

- The endpoint files were changed so both apps target the local backend instead of production during this test cycle.
- The customer iOS plist was changed to permit local HTTP traffic on simulator.
- The app theme/text-field files were changed to bypass the unstable `google_fonts` runtime path on the current Flutter/iOS environment.
- The customer booking-related model files were changed to accept both numeric and string JSON values from the backend where strict casting was causing runtime failures.
- Project memory files were updated to preserve the current local mobile runtime strategy and the simulator-specific issues discovered.

Testing / Validation:

- `flutter pub get` in:
  `goal_master`
  `goal_master_admin`
- Verified local backend HTTP response at:
  `http://127.0.0.1:8000/home`
- Launched customer app on simulator:
  `iPhone 17`
- Launched manager app on simulator:
  `iPhone 17e`
- Took simulator screenshots after launch to verify foreground state.
- Verified the customer app reaches fresh-install state without the earlier `google_fonts` crash.
- Verified the manager app reaches fresh-install state against the local backend and shows the iOS notification prompt.

Result:

- Customer app is running on `iPhone 17`.
- Manager app is running on `iPhone 17e`.
- Both are pointed at the same local backend:
  `http://127.0.0.1:8000/api/`
- The demo manager credentials remain usable for manager login:
  `manager_demo / 12345678`

Remaining Issues / Gaps:

- On fresh launch, both apps currently stop first at the iOS notification permission prompt and require one tap by the tester before continuing.
- The mobile apps are temporarily configured for local backend usage and should be restored before any production-targeted build.
- The customer app had strict response-model assumptions; additional endpoints may still need the same defensive parsing treatment if other local API type mismatches appear later.

Important Future Notes:

- For the current local test lane, keep `goal_master`, `goal_master_admin`, and `goal_master_web` aligned to the same machine and local backend runtime.
- If customer booking screens fail again after backend changes, compare live JSON payload types before changing UI logic.

---

## Entry 10

Date: 2026-08-02

Requested Work:

- Fix customer registration failure shown from the mobile app.
- Fix the manager app booking flow where the category appears but the matching stadium/services do not show.

Reason:

- The user encountered two live blockers during the first end-to-end mobile test:
  1. customer registration failed with a database integrity error
  2. manager add-booking flow failed when loading services after category selection

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and the latest `CODEX_WORK_LOG.md` entry.
- Checked git status in customer, manager, and website repositories.
- Traced the customer registration request from the Flutter app to the actual backend route:
  `routes/api.php -> Api\Auth\AuthController::create`
- Confirmed the mobile app sends `phone_number`, not `phone_no`.
- Confirmed the local SQLite schema requires `users.email` as `NOT NULL`.
- Confirmed the API registration controller was creating users from validated request data without ensuring `email` was present.
- Added API-side fallback email generation using either:
  1. the username when it is a valid email, or
  2. a deterministic local placeholder based on phone number.
- Confirmed that `User` model mass assignment had `email` commented out in `$fillable`, preventing the generated email from being inserted.
- Re-enabled `email` in `User::$fillable`.
- Verified customer API registration success locally after those changes.
- Traced the manager service-loading failure to strict `String` casts inside the booking service model.
- Hardened the manager booking `Service` model to accept numeric-or-string JSON values for fields such as:
  `price`
  `created_by`
  `updated_by`
  time-related fields
- Hardened the manager booking `Employee` model similarly for fields such as:
  `target_service_amount`
  `commission`
  `salary`
- Rebuilt both mobile apps after the fixes.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Auth/AuthController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Auth/RegisterController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Models/User.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/booking/data/model/service_model.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/booking/data/model/employe/employe.dart`

Why These Files Changed:

- The API auth controller needed to populate `email` for locally registered customer users because the current database schema requires it.
- The `User` model needed `email` restored in `$fillable` so the generated value is actually persisted.
- The manager app booking models needed defensive parsing because the local backend returns some numeric values as integers while the Flutter models expected strings.
- Project memory files were updated so the true API registration path and these local-run constraints are preserved.

Testing / Validation:

- Verified customer registration request path by code inspection.
- Verified registration failure root cause through live API response showing:
  `NOT NULL constraint failed: users.email`
- Verified customer registration success by calling:
  `POST /api/register`
  with:
  `name`
  `username`
  `password`
  `password_confirmation`
  `phone_number`
- Successful API registration created local user `id=32` with generated email:
  `0916776604@goalmaster.local`
- Rebuilt:
  `goal_master`
  `goal_master_admin`
  on the active iOS simulators.

Result:

- Customer registration is fixed at the API level for the local mobile test environment.
- The manager app booking service/employee parsing was hardened against the numeric JSON values returned by the local backend.

Remaining Issues / Gaps:

- The final visual confirmation that manager stadium cards now appear after category selection still requires re-running that interaction in the app UI after rebuild.
- `RegisterController` web-side was also adjusted earlier for consistency, but the mobile app uses the API auth controller path as the authoritative registration flow.

Important Future Notes:

- If registration breaks again, inspect the API path first, not the classic web auth controller.
- When local SQLite is used, schema requirements such as mandatory `users.email` may surface differently than production MySQL behavior.

---

## Entry 11

Date: 2026-08-02

Requested Work:

- Fix the manager add-booking flow after the user reached the final payment/save step and received a generic validation error.

Reason:

- After earlier parsing fixes, the manager app could finally reach the save-booking request, but the UI still showed a misleading generic error and the backend flow was leaving behind confusing partially successful state.

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and the latest `CODEX_WORK_LOG.md` entry.
- Checked git status before continuing in manager app and website backend repositories.
- Reproduced the failing save-booking request using the same payload shape sent by the manager app.
- Confirmed the original shell payload the user shared was not valid JSON, then reran it as valid JSON.
- Identified that the first backend rejection was a real slot-conflict message returned in response `data`, not a validation-schema error.
- Confirmed the manager app error layer discarded that message and replaced it with:
  `Validation failed. Please check your input.`
- Updated manager app error parsing so 400/401/403/405/422 responses also return string messages from response `data` when present.
- Inspected local SQLite booking tables and found a previously attempted booking had already been persisted for:
  branch `2`
  employee `2`
  service `2`
  date `2026-08-03`
  time `16:00:00 -> 17:00:00`
- Removed the conflicting locally created test booking rows so the slot could be tested again cleanly.
- Re-ran the same booking request and exposed a deeper backend issue:
  `Attempt to read property "id" on null`
- Traced that failure to post-commit notification logic in:
  `Api/Booking/BookingController.php`
  when a `cmn_customer` exists but has no linked `users` account.
- Added null guards so socket and app notifications are sent only when a linked `User` exists.
- Added protective try/catch around non-critical post-booking side effects after `DB::commit()` so notification or WhatsApp failures cannot incorrectly turn a saved booking into an API error response.
- Re-ran the same booking request successfully and received:
  HTTP `200 OK`
  `{"status":"true","paymentType":"localPayment","data":"Successfully saved"}`
- Deleted the final verification booking afterward so the user can retry the same slot from the app UI without that slot being consumed by the verification request.
- Rebuilt the manager app on `iPhone 17e`.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/core/errors/exceptions.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`

Why These Files Changed:

- The manager app needed to surface actual backend string errors from response `data` rather than replacing them with a generic message.
- The backend booking controller needed null-safe and failure-tolerant post-commit side-effect handling so booking persistence remains authoritative even if notification paths fail.
- Project memory files were updated to preserve the real root causes and verified fix path.

Testing / Validation:

- Replayed manager booking save request with valid JSON and bearer token.
- Verified conflict response before cleanup:
  the selected service was reported unavailable for `2026-08-03 16:00:00 -> 17:00:00`
- Inspected local SQLite tables:
  `sch_service_bookings`
  `sch_service_booking_infos`
  `cmn_customers`
- Removed conflicting verification-created booking rows.
- Replayed the same booking save request again.
- Verified final successful response:
  HTTP `200 OK`
  `status=true`
  `paymentType=localPayment`
  `data=Successfully saved`
- Deleted the final verification booking so the slot remains free for UI retesting.
- Rebuilt manager app on simulator:
  `iPhone 17e`

Result:

- Manager app can now receive the backend's true booking-save failure text when the backend rejects a slot.
- The backend no longer crashes on post-commit notification flow when the booked customer does not have a linked user account.
- The booking save path itself is verified working for the tested local cash-booking payload.

Remaining Issues / Gaps:

- Socket connection timeouts still appear in the manager app logs during local simulation, but they did not block booking-save verification.
- The final user-facing confirmation should now be performed once more from the app UI to confirm the same success path visually end-to-end.

Important Future Notes:

- If a booking appears to fail in the UI but the slot becomes occupied, inspect post-commit side effects and database rows before assuming validation failure.
- For local debugging, clean verification-created booking rows after API replay tests so the user can retry the same slot from the simulator.

---

## Entry 12

Date: 2026-08-02

Requested Work:

- Fix the manager app booking list failure showing:
  `type 'String' is not a subtype of type 'int'`
  after the user opened the booking list / `حجوزاتي`.

Reason:

- The manager app was able to create and load bookings locally, but the booking list screen still crashed because the Flutter parsing layer assumed stricter JSON scalar types than the backend actually returns.

Work Performed:

- Re-read `PROJECT_CONTEXT.md` and the latest `CODEX_WORK_LOG.md` entry.
- Checked git status in the customer, manager, and website repositories before changing files.
- Replayed the manager booking list API locally with the current bearer token:
  `GET /api/user/booking/all?page=1&pageSize=10`
- Confirmed that the backend returns booking amount fields such as:
  `service_amount`
  `paid_amount`
  `due`
  as JSON numbers, not guaranteed strings.
- Compared that response against the manager app booking models and found strict assignments like:
  `final String serviceAmount;`
  populated directly from raw JSON values.
- Updated manager booking models to coerce mixed backend scalars safely:
  `booking_all_list_response.dart`
  `booking_details.dart`
  `booking_history_response.dart`
- Added narrow local helper conversions in those files so IDs and statuses parse to `int`, while display-oriented scalar values parse via `.toString()`.
- Ran `dart format` on the edited model files.
- Ran `flutter analyze` against the edited files.
- Rebuilt and launched the manager app on simulator `iPhone 17e`.
- Captured a fresh simulator screenshot after relaunch to verify the app still loads into the authenticated manager home flow.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/booking/data/model/booking_all_list_response.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/booking/data/model/booking_details.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/booking/data/model/booking_history_response.dart`

Why These Files Changed:

- The manager booking list and detail models needed tolerant parsing for backend fields that may be emitted as either strings or numbers.
- `PROJECT_CONTEXT.md` was updated to preserve the discovered API type-instability note for future mobile work.
- `CODEX_WORK_LOG.md` was updated to preserve the root cause and fix path.

Testing / Validation:

- Verified live API response shape from:
  `http://127.0.0.1:8000/api/user/booking/all?page=1&pageSize=10`
- Confirmed returned list data includes numeric values for:
  `service_amount`
  `paid_amount`
  `due`
- `dart format` completed successfully on all edited model files.
- `flutter analyze` reported only two non-blocking `prefer_final_locals` infos in `booking_history_response.dart`.
- Rebuilt and relaunched manager app on:
  `iPhone 17e`
- Confirmed the app launches back into the logged-in manager home screen after the model fix.

Result:

- The manager booking models no longer rely on raw strict JSON scalar types for money and status-related fields.
- The specific runtime crash path behind:
  `type 'String' is not a subtype of type 'int'`
  was addressed in the booking parsing layer.

Remaining Issues / Gaps:

- Final visual verification of the exact `حجوزاتي` tab after this rebuild still depends on opening that tab again in the running simulator session.
- The manager app still logs a separate Flutter `Zone mismatch` assertion during startup; it did not block this booking-model fix, but it remains a real startup-structure issue to clean later.

Important Future Notes:

- Do not assume booking-related API money fields are strings in the manager app.
- For this backend, prefer tolerant scalar parsing in mobile models unless the API contract is later normalized centrally.

---

## Entry 13

Date: 2026-08-02

Requested Work:

- Investigate why customer wallet balance became `12` after a canceled online top-up flow that should not have credited the user.
- Add admin-panel support to manage a website user's wallet with direct charge, direct withdrawal, and a reason/description.
- Fix the customer app issue shown on the home screen:
  `type 'Null' is not a subtype of type 'int'`

Reason:

- The user observed a real financial integrity problem in local testing:
  a canceled top-up appeared to create duplicate balance credits.
- Wallet adjustments for website users needed an operational admin flow instead of direct database edits.
- The customer home screen still contained a parsing crash in one of its API-driven sections.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Inspected the customer app online top-up flow and found an explicit second credit path in:
  `payment_webview_page.dart`
  where tapping the page header/logo directly called `addTransaction(...)` without any payment success verification.
- Inspected local SQLite balance rows for user `ayoubb` and confirmed two real duplicate credits existed:
  amount `6`
  type `credit`
  created one second apart.
- Extended the customer app transaction API call to pass an optional payment reference.
- Updated the customer payment webview flow to:
  generate a stable merchant reference once,
  send it only on verified success,
  guard against handling success/cancel/error more than once,
  stop the accidental direct credit call on the page header,
  and return `false` to the previous screen on payment cancellation.
- Updated the local customer service model parsing so null or mixed scalar fields no longer crash the home services section when fields like `branch_id` are absent or null.
- Added server-side duplicate protection in:
  `Wallet/UserWalletController::store()`
  so repeated online top-up callbacks with the same reference no longer insert duplicate balance rows.
- Added a new nullable `description` column to `cmn_user_balances` and updated the model fillable list.
- Extended web admin wallet management in:
  `resources/views/user_management/user.blade.php`
  `public/js/custom/user_management/user.js`
  `Payment/UserBalanceController.php`
  so admins can now choose:
  `add`
  or
  `withdraw`
  and must provide a description.
- Added withdrawal balance checks with row locking in the web admin controller.
- Secured the `user-balance-add` web route with `auth` middleware.
- Cleaned the local test user balance rows for user `33` after validation so the current local balance returned to `0`.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/data/repo/card_repo.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/data/repo/card_repo_imp.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/presentation/manager/add_transaction_cubit/add_transaction_cubit.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/presentation/view/widgets/payment_webview_page.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/presentation/view/widgets/top_up_sheet_visa.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/home/data/model/service_model.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Models/Customer/CmnUserBalance.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Wallet/UserWalletController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Requests/Requesttransaction.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/resources/views/user_management/user.blade.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/public/js/custom/user_management/user.js`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/routes/web.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/database/migrations/2026_08_02_061500_add_description_to_cmn_user_balances_table.php`

Why These Files Changed:

- The customer app needed to stop creating balance rows outside the true payment-success path.
- The backend needed idempotency-style duplicate protection for online top-ups.
- The customer home services parsing needed to tolerate null/mixed backend scalars.
- The web admin needed a proper wallet operation form supporting both credit and debit with operator-entered reasons.
- The wallet admin route needed explicit auth protection.

Testing / Validation:

- Queried local SQLite before the fix and confirmed duplicate rows for user `33`:
  two `credit` rows of amount `6`.
- Ran `php -l` on all modified PHP files.
- Ran `php artisan migrate --force` and confirmed the new migration completed:
  `2026_08_02_061500_add_description_to_cmn_user_balances_table`
- Generated a local JWT for user `33`.
- Replayed `POST /api/user/wallet/transaction-store` twice with the same `reference`.
- Verified only one new row was inserted for that repeated reference:
  `description = online_topup:ORDER_DUPLICATE_TEST_20260802`
- Verified service list API response still loads successfully from:
  `POST /api/get-service-info`
- Ran `dart format` on modified Flutter files.
- Ran `flutter analyze` on the touched Flutter files.
  Remaining output is informational only in `payment_webview_page.dart`.
- Cleared the local incorrect wallet credit rows for user `33`.
- Verified the current local balance for user `33` is now `0`.

Result:

- Customer online top-up no longer has the obvious duplicate-credit trigger in the Flutter UI.
- Backend `transaction-store` now ignores repeated top-up persistence for the same payment reference.
- Local bad wallet rows were removed, so the user account is no longer inflated by the earlier bug.
- Web admin now has a wallet-management flow that supports direct charge, direct withdrawal, and required descriptions.
- The customer home services parsing is hardened against null/int backend values.

Remaining Issues / Gaps:

- The customer app screenshot verification after the service-model fix was not fully completed in-app because the simulator capture returned to the iPhone home screen rather than an in-app page snapshot.
- The web admin wallet UI was validated by code path and backend migration, but not yet manually clicked through end-to-end in the browser during this turn.
- `payment_webview_page.dart` still has a few non-blocking analyzer infos around async context usage and string interpolation style.

Important Future Notes:

- For money movement, backend persistence must never depend solely on client-side success signals without a server-side duplicate guard.
- For admin wallet operations, preserve the new `description` field rather than overloading the `type` field with human reasons.

---

## Entry 14

Date: 2026-08-02

Requested Work:

- Fix the new admin wallet error shown in the browser when saving a direct wallet charge:
  `SQLSTATE[23000]: Integrity constraint violation: 19 CHECK constraint failed: type`
- Send a real-time WebSocket notification to the user when the admin performs a wallet charge.

Reason:

- The previous admin wallet implementation introduced new `type` values that do not exist in the current `cmn_user_balances` enum, so the database correctly rejected the insert.
- Wallet charging needs an immediate customer-facing notification through the existing socket channel.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Inspected the `cmn_user_balances` migration that defines the enum constraint and confirmed the only allowed values are:
  `credit`, `recharge`, `transfer`, `balance`
- Inspected the existing socket notification helper and current notification usage patterns in the booking flow.
- Updated:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
  so admin wallet charge now stores `type = credit` and admin wallet withdrawal now stores `type = balance` instead of invalid custom enum values.
- Kept the operator-entered reason in `description`, which is the correct field for human-entered explanations.
- Added a charge-only `SocketNotify(...)` call so direct admin wallet charging now emits a real-time notification payload to the charged user.
- Updated `PROJECT_CONTEXT.md` with a permanent note that admin wallet adjustments must stay inside the existing enum and use `description` for reasons.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`

Why These Files Changed:

- The controller needed a production-safe compatibility fix with the existing database schema.
- The project context needed to preserve this constraint so future wallet changes do not reintroduce invalid enum values.
- The work log needed a permanent record of the financial-flow fix.

Testing / Validation:

- Ran `php -l` on:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
- Verified the syntax is valid.
- Confirmed by schema inspection that the chosen replacement `type` values are allowed by the active migration.
- Attempted a quick Laravel `tinker` validation, but the local environment currently has a separate `PsySH` / PHP compatibility issue that prevented that tool-based check.

Result:

- The admin wallet insert path is now aligned with the current `cmn_user_balances.type` enum and should no longer fail on direct charge because of invalid `type` values.
- Direct admin wallet charge now emits a customer WebSocket notification payload through the existing notification channel.

Remaining Issues / Gaps:

- I have not yet re-clicked the browser modal end-to-end after this exact fix inside the web UI during this turn.
- The WebSocket delivery was wired to the existing backend event path, but I did not capture a fresh live client-side receipt screenshot in this turn.
- The local Laravel console environment still shows unrelated deprecated/vendor compatibility noise during `tinker` execution.

Important Future Notes:

- Do not introduce new wallet `type` strings unless the database enum/migration is updated first and all consumers are reviewed.
- Use `description` for operator-entered reasons and audit text.
- For customer-facing wallet top-up alerts, the existing socket path is now active only for admin direct charge, not for withdraw.

---

## Entry 15

Date: 2026-08-02

Requested Work:

- Ensure there is a persistent project memory file for all modifications so future tasks can resume with context efficiently.
- Fix wallet transaction presentation in the customer app so admin deposits no longer appear as `دفع بالكريديت`.
- Show the actual deposit description/reason in the wallet UI and in the transaction details dialog.
- Investigate why wallet notifications did not appear on the customer mobile app after admin charge.

Reason:

- The user wants durable project memory to reduce repeated rediscovery work and token waste.
- The wallet UI was still mislabeling admin deposits because the client mapped all `credit` rows to the wrong human label.
- The transaction details popup was not showing the real operation details that matter for support/audit.
- Notification delivery needed end-to-end tracing across backend event shape, stored notifications, client socket parsing, and local broadcast configuration.

Work Performed:

- Confirmed the persistent project memory files already exist and remain the canonical references:
  `PROJECT_CONTEXT.md`
  `CODEX_WORK_LOG.md`
- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Inspected the customer app wallet transaction model and UI.
- Inspected the customer app notification socket service and notification cubit.
- Inspected the local website `.env` and confirmed:
  `BROADCAST_DRIVER=log`
  which means real backend WebSocket broadcasting is not active in the current local environment.
- Identified a client-side socket parsing mismatch:
  the app expected paginated/database-style notification JSON,
  while the socket event path sends a different payload shape.
- Added a new backend database notification class:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Notifications/WalletTransactionNotification.php`
  so admin wallet charge now creates a persisted user notification with:
  `id`, `message`, `type`, `amount`, `description`, `created_at`
- Updated:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
  so admin wallet charge now:
  1. creates the wallet row,
  2. emits the socket payload,
  3. writes a database notification for the charged user.
- Extended the customer wallet transaction model to parse `description`.
- Updated the customer wallet transaction UI so:
  admin direct deposits display as:
  `شحن من الإدارة`
  instead of:
  `دفع بالكريديت`
- Added logic so online top-up rows still render distinctly from admin direct charge rows.
- Expanded the transaction details dialog behind the info icon to show:
  operation type,
  amount,
  description,
  date,
  completion status,
  wallet owner details,
  and related user details when available.
- Updated the socket service to normalize both notification payload shapes:
  database-style notifications
  and direct socket broadcast payloads
- Reduced the app notification polling interval from `15` seconds to `5` seconds so local fallback notification delivery is more immediate while true local broadcasting remains disabled.
- Updated `PROJECT_CONTEXT.md` with the important local broadcast limitation and fallback behavior.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Notifications/WalletTransactionNotification.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/balance/data/model/transactions_response.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/card/presentation/view/transaction_item.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/utils/notification_socket_service.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/manager/notification_cubit/notification_cubit.dart`

Why These Files Changed:

- The backend needed a stored notification path so local mobile testing would still surface wallet alerts even when real broadcasting is unavailable.
- The customer wallet transaction parser needed to preserve backend `description`.
- The customer wallet transaction UI needed correct business labels for admin charge versus online top-up.
- The info/details dialog needed to expose transaction audit information instead of only partial user info.
- The socket service needed to understand both backend notification payload shapes.
- The project context needed a permanent note that local WebSocket broadcasting is currently disabled by environment configuration.

Testing / Validation:

- Ran `php -l` on:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Payment/UserBalanceController.php`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Notifications/WalletTransactionNotification.php`
- Ran `dart format` on the touched Flutter files.
- Executed a direct Laravel bootstrap validation script that:
  created a wallet transaction,
  created a wallet notification,
  read back the stored notification payload,
  and then cleaned up the test rows.
- Confirmed the stored notification payload includes:
  `message`, `amount`, `description`, `type = wallet_transaction`
- Ran `flutter analyze` on the touched Flutter files.
  Remaining results are non-blocking infos only, mostly existing `print` usage and `withOpacity` deprecation notices.

Result:

- The persistent project memory files remain in place and continue to be updated after each meaningful change.
- Customer wallet rows can now display the operator-entered reason/description.
- Admin direct deposit is now labeled as an admin-origin charge instead of a misleading credit-card payment label.
- The transaction details dialog now shows the actual operation details expected by the user.
- Local wallet notification delivery now has a persisted-notification fallback path that the customer app can pick up quickly through polling.
- The socket parser is now compatible with both stored-notification JSON and direct socket payload JSON.

Remaining Issues / Gaps:

- True local WebSocket broadcasting is still not active because the current local website environment uses:
  `BROADCAST_DRIVER=log`
- Because of that environment setting, the customer app's local notification visibility currently depends on the database-notification + polling fallback unless broadcast infrastructure is configured.
- I did not complete a fresh in-simulator visual confirmation screenshot of the wallet notification arrival during this turn.

Important Future Notes:

- If real local WebSocket behavior is required, local broadcast configuration must be enabled first; code-only changes cannot bypass `BROADCAST_DRIVER=log`.
- For wallet-origin labeling, use `description` plus business context instead of inventing new enum values in `cmn_user_balances.type`.

---

## Entry 16

Date: 2026-08-02

Requested Work:

- Fix the customer notification details screen crash that happens when opening the details of a wallet/admin-charge notification.
- Add a financial transactions page to the admin panel covering wallet charges, withdrawals, user-to-user transfers, and online top-up records.
- Add a per-user transactions entry next to wallet management in the admin user list.

Reason:

- The mobile notification details route was still hard-wired to booking details and therefore tried to treat wallet notifications as booking notifications.
- The admin panel needed an operational financial-history view instead of forcing inspection through individual wallet rows only.
- Per-user financial investigation needs to be accessible directly from the user list.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Traced the customer notification details flow and confirmed:
  `ItemsNotification`
  passed only an integer ID,
  and the route always created `BookingDetailsCubit`,
  which is invalid for wallet notifications.
- Extended the customer notification model so notification `data` now supports:
  `type`, `amount`, `description`, `created_at`
- Updated the customer notification details route to pass the full `NotificationItem` instead of only an ID.
- Made the notification details screen branch by notification type:
  booking notifications still load booking details,
  wallet notifications now render a dedicated financial details screen without touching booking APIs.
- Updated the socket normalization logic so direct socket-delivered wallet notifications also carry enough metadata for the details screen if tapped immediately.
- Added admin-panel endpoints and a view for wallet transactions:
  `wallet-transactions`
  `get-wallet-transactions`
- Added a new admin-panel page:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/resources/views/user_management/wallet_transactions.blade.php`
- Added a new admin-panel table script:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/public/js/custom/user_management/wallet_transactions.js`
- The transactions page now shows global financial operations with labels derived from business meaning:
  admin charge,
  admin withdrawal,
  online top-up,
  card recharge,
  transfer in,
  transfer out
- Added a global `المعاملات المالية` button in the user-management page header.
- Added a per-user `المعاملات` button beside `إدارة المحفظة` in the user list table.
- Updated `PROJECT_CONTEXT.md` so future work preserves the notification-type branching and the new admin financial page.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/data/model/notification_response.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/presentation/view/widgets/items_notification.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/presentation/view/widgets/notification_items_details.dart.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/routing/routes.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/utils/notification_socket_service.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/UserManagement/UserController.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/routes/web.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/resources/views/user_management/user.blade.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/public/js/custom/user_management/user.js`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/resources/views/user_management/wallet_transactions.blade.php`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/public/js/custom/user_management/wallet_transactions.js`

Why These Files Changed:

- The mobile app needed notification-type-aware navigation and rendering.
- Wallet notifications needed their own presentation instead of reusing booking details.
- The admin panel needed both a global and user-scoped transaction history surface.
- The project memory needed to preserve the new financial-admin UI and notification-detail branching rules.

Testing / Validation:

- Ran `dart format` on the modified Flutter files.
- Ran `flutter analyze` on the touched notification/navigation files.
  Remaining output is limited to existing or non-blocking warnings such as:
  one unused import in `routes.dart`,
  `withOpacity` deprecation notices,
  and pre-existing `print` diagnostics in the socket service.
- Ran `php -l` on:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/UserManagement/UserController.php`
- Ran `php artisan route:list` and confirmed:
  `wallet-transactions`
  `get-wallet-transactions`
  `user-info`
  `user-balance-add`
  are all registered.

Result:

- Wallet/admin-charge notifications no longer go through the booking-details code path.
- The customer app now has a dedicated wallet-notification details screen.
- The admin panel now has a transactions page for global financial history.
- The user list now offers a direct per-user transactions entry beside wallet management.

Remaining Issues / Gaps:

- I have not yet manually clicked through the new admin transactions page in the browser during this exact turn.
- `flutter analyze` still reports a few non-blocking existing warnings unrelated to runtime correctness.

Important Future Notes:

- Any new notification category must declare its display strategy explicitly instead of assuming it maps to bookings.
- For finance support/debugging, prefer the new admin transactions page over reading raw wallet rows manually.

---

## Entry 17

Date: 2026-08-02

Requested Work:

- Diagnose the new booking failure shown in the customer app during booking confirmation.
- Explain the real cause.
- Fix the misleading generic error handling so the user sees the actual business reason.
- Prevent the booking-details API from crashing when a booking lookup returns a JSON error response instead of a booking array.

Reason:

- The customer app showed a generic internal-server banner during booking confirmation, which hid the real cause from the user.
- Laravel logs also showed a separate crash in `getBookingInfo()` caused by treating a `JsonResponse` as an array.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Traced the customer booking flow from:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/booking/presentation/view/widgets/choose_payment.dart`
  to:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart`
  to:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/booking/data/repo/booking_repo_imp.dart`
- Confirmed that the selected payment option `رصيد المستخدم` sends `payment_type = 4`, which maps to `PaymentType::UserBalance`.
- Reproduced the exact booking API request locally against:
  `POST http://127.0.0.1:8000/api/user/booking/store-booking`
- Verified the real failure cause:
  the booking total is `120`,
  while the current user wallet balance is `20`,
  so user-balance payment must fail.
- Confirmed the old backend behavior incorrectly returned this business failure as HTTP `500`, which made the customer app display:
  `خطأ في الخادم الداخلي، يرجى المحاولة لاحقًا`
- Updated the booking backend so insufficient-balance and unauthenticated user-balance cases now return HTTP `400` with a readable `message`.
- Included balance context in the insufficient-balance response:
  `required_balance`
  and
  `current_balance`
- Fixed `getBookingInfo()` so if `getDataInfo()` returns a `JsonResponse`, it is returned directly instead of being accessed as an array.
- Updated the Flutter API error parsing so responses carrying a useful `message` or string `data` surface that message to the UI instead of falling back to a generic server error.
- Performed a hot restart on the customer app after the Dart-side error-handling change.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/errors/exceptions.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/api_consumer_extension.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`

Why These Files Changed:

- The Flutter app needed to surface backend business messages instead of collapsing them into a fake internal-server message.
- The Laravel booking API needed correct status codes and message fields for user-balance booking failures.
- The booking-details endpoint needed a guard against invalid array access when no booking payload exists.
- Project memory needed to preserve the real cause and the chosen handling approach.

Testing / Validation:

- Replayed the real booking API request with:
  `payment_type = 4`
  `branch_id = 2`
  `employee_id = 2`
  `service_id = 2`
  `date = 2026-08-02`
  `22:00:00 -> 23:00:00`
- Confirmed the response changed from HTTP `500` to HTTP `400`.
- Confirmed the new backend response body is:
  `message = ليس لديك رصيد كافٍ في حسابك.`
  with:
  `required_balance = 120`
  and
  `current_balance = 20`
- Ran:
  `php -l /Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`
- Ran:
  `dart format`
  on the updated Flutter files.
- Performed a customer-app hot restart in the running simulator session.

Result:

- The booking issue is now diagnosed precisely:
  the failure is due to insufficient wallet balance, not an unknown backend crash.
- The backend now reports that failure as a readable validation-style business error.
- The customer app has the parsing needed to show the real backend message instead of the generic internal-server banner.
- The `getBookingInfo()` path is protected from the `JsonResponse as array` crash.

Remaining Issues / Gaps:

- I did not capture a fresh simulator screenshot of the new booking error text after the hot restart inside this exact log entry.
- If the user wants wallet-based booking to succeed, either the wallet must be recharged above the booking cost or the booking must use another payment type such as `الدفع عند الوصول`.

Important Future Notes:

- Business-rule failures such as insufficient balance should stay in the `4xx` range and must not be returned as generic `500` errors.
- When debugging booking complaints, always compare:
  selected `payment_type`,
  service cost,
  and current user wallet balance
  before assuming schedule or availability issues.

---

## Entry 18

Date: 2026-08-02

Requested Work:

- Fix the new booking failure that appeared after retrying the same booking flow.
- Diagnose the `UNIQUE constraint failed: sch_service_bookings.id` error shown in the customer app.

Reason:

- The previous business-error fix exposed the next real failure in the booking write path.
- The booking API was attempting to insert booking rows in a way that treated the real bookings table as if it were a pivot table, causing duplicate primary-key insertion behavior.

Work Performed:

- Re-read project context and the latest work log implicitly from the current active task context before continuing.
- Inspected:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Models/Booking/SchServiceBookingInfo.php`
  and
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Models/Booking/SchServiceBooking.php`
- Confirmed that:
  `sch_service_bookings`
  is a real table with:
  `id integer primary key autoincrement`
  and not a pivot table.
- Confirmed the API controller was using:
  `serviceBookings()->attach(...)`
  to persist booking rows, which is structurally wrong for this schema.
- Added a dedicated helper in:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`
  that normalizes booking payloads, removes any accidental `id`, ensures `sch_service_booking_info_id` is set, and saves rows with:
  `serviceBookinges()->createMany(...)`
- Replaced the broken `attach(...)` usage in the API booking save flow and in the nearby monthly booking paths inside the same controller.
- Re-tested the same booking request locally with:
  `payment_type = 1`
  to avoid the separate insufficient-balance branch and isolate the persistence bug.
- Performed a hot restart on the running customer app after the backend fix so the simulator is on the current runtime state.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`

Why These Files Changed:

- The API booking controller needed a correct persistence strategy for real booking rows.
- The project memory needed to record that `sch_service_bookings` must not be treated like a pivot table in future edits.

Testing / Validation:

- Ran:
  `php -l /Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Http/Controllers/Api/Booking/BookingController.php`
- Replayed the booking API request directly with:
  `POST /api/user/booking/store-booking`
  using:
  `branch_id = 2`
  `employee_id = 2`
  `service_id = 2`
  `payment_type = 1`
  `service_date = 2026-08-02`
  `start_time = 22:00:00`
  `end_time = 23:00:00`
- Confirmed the response is now:
  `HTTP 200`
  with:
  `{"status":"true","paymentType":"localPayment","data":"Successfully saved"}`
- Observed new notifications generated for the customer after the successful booking, including:
  `ServiceOrderNotification`
  and
  `UserNotification`

Result:

- The duplicate-primary-key booking failure is fixed in the local API booking path.
- The same booking request now saves successfully.
- The customer runtime now has both:
  clearer insufficient-balance handling
  and
  corrected booking-row persistence.

Remaining Issues / Gaps:

- Similar `attach(...)` misuse still appears in other non-API controllers such as the web/site booking controllers and may need the same structural cleanup later.
- I did not yet refactor the model relation names themselves; the fix is currently localized to the API controller path that was failing.

Important Future Notes:

- Do not use `belongsToMany()->attach(...)` to persist rows into `sch_service_bookings`.
- Prefer `serviceBookinges()->createMany(...)` or a clearer dedicated `hasMany` relation for any future booking row inserts against this table.

---

## Entry 19

Date: 2026-08-02

Requested Work:

- Diagnose why the customer notification `تم تأكيد حجزك` sometimes shows:
  `رقم الحجز: 0`
- Fix why opening its details can remain stuck because the booking details screen is launched with an invalid booking id.
- Verify the fix with real notification payloads.

Reason:

- The notification list and details flow depended on a single notification payload shape.
- Real API responses showed that booking-related notifications are not uniform:
  `ServiceOrderNotification` uses `data.id`
  while `UserNotification` uses `data.booking_id`
- Because the client only parsed `data.id`, `UserNotification` booking ids became `0`, which then broke details navigation.

Work Performed:

- Re-read the active task context and continued from the documented booking/notification state.
- Inspected:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web/app/Notifications/UserNotification.php`
  and confirmed that it stores:
  `booking_id`
  not
  `id`
- Inspected:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/data/model/notification_response.dart`
  and confirmed the app parsed only:
  `json['id']`
- Updated the notification model so `NotificationInnerData` now normalizes both:
  `booking_id`
  and
  `id`
- Updated notification details routing so booking notifications use:
  `notification.data.bookingId`
  instead of
  `notification.data.id`
- Added a guard in routing:
  if a non-wallet notification still has an invalid booking id, it now falls back to the generic notification details screen instead of launching booking-details loading with id `0`
- Updated the notification item details popup to display the normalized booking id.
- Updated socket notification normalization so any future realtime booking payload carrying `booking_id` is preserved too.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/data/model/notification_response.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/routing/routes.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/features/notification/presentation/view/widgets/items_notification.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/utils/notification_socket_service.dart`

Why These Files Changed:

- The client needed schema normalization for booking notification ids.
- The notification details route needed to stop using `0` as a booking id for `UserNotification`.
- The popup/details UI needed to display the real booking id.
- Project memory needed to preserve that notification payloads are not uniform across classes.

Testing / Validation:

- Ran:
  `dart format`
  on the modified customer notification files.
- Ran:
  `flutter analyze`
  on the touched files.
  Result:
  no blocking compile errors,
  only existing/non-blocking warnings such as one unused import in `routes.dart`,
  `withOpacity` deprecation notices,
  and existing `print` guidance in the socket service.
- Queried the real notification API:
  `GET /api/user/notifications/get-notification?page=1`
- Verified the live payload includes entries such as:
  `UserNotification -> data.booking_id = 5`
  and
  `ServiceOrderNotification -> data.id = 5`
- Confirmed the original root cause:
  before normalization,
  `UserNotification` had no `id` field,
  so the client resolved booking id to `0`

Result:

- The customer app now has the data normalization needed to resolve booking ids correctly from `UserNotification`.
- The `رقم الحجز: 0` issue is addressed at the parsing layer.
- Notification details routing no longer blindly launches booking details with an invalid booking id.

Remaining Issues / Gaps:

- The current `flutter run` simulator session disconnected during the verification cycle, so I did not capture a fresh post-fix screenshot from the app UI in this exact entry.
- There are still older historical notifications in local data that were already created before the fix; newly parsed API data now carries the correct booking id.

Important Future Notes:

- Do not assume all booking notifications use the same identifier key.
- For notification-driven navigation, prefer a normalized field such as `bookingId` in the client model instead of reading raw `id` directly from payloads.

---

## Entry 20

Date: 2026-08-02

Requested Work:

- Fix the customer `إعادة المحاولة` button in the no-internet screen so the app actually returns to normal when internet is available again.
- Verify the fix with code-level and runtime checks.

Reason:

- The retry button triggered a connectivity refresh, but the no-internet screen itself did not reliably dismiss when internet returned.
- The previous connection check also depended only on network presence, which is weaker than verifying real internet reachability.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Inspected:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/connection_cubit.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/no_internet_view.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/dio_consumer.dart`
- Confirmed two issues:
  1. the retry flow only checked connectivity transport state,
  2. the no-internet screen did not automatically close when connection recovered in the pushed-screen scenario.
- Updated `ConnectionCubit` so it now:
  checks transport availability first,
  then validates real internet reachability using:
  `InternetAddress.lookup('example.com')`
- Updated `NoInternetView` to listen to `ConnectionCubit`.
  When connectivity becomes valid again, it now pops itself if it is on top of the navigation stack.
- Updated the retry button to await the async refresh instead of firing and returning immediately.
- Restarted the customer app on the `iPhone 17` simulator after the change.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/connection_cubit.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/no_internet_view.dart`

Why These Files Changed:

- The connectivity state needed stronger validation than transport presence alone.
- The no-internet UI needed to react to recovered connectivity by closing itself.
- The project memory needed to preserve how offline recovery now works.

Testing / Validation:

- Ran:
  `dart format`
  on:
  `connection_cubit.dart`
  and
  `no_internet_view.dart`
- Ran:
  `flutter analyze`
  on the same two files.
  Result:
  `No issues found!`
- Re-ran the customer app with:
  `flutter run -d E0727D41-E7DE-42EA-A9D5-65AE0DDB2909`
- Confirmed the app launches successfully after the change on `iPhone 17`.

Result:

- The retry flow now verifies real internet access.
- The no-internet screen now has logic to dismiss itself once connectivity is restored and retry succeeds.
- The updated customer build is running again on the simulator for user retest.

Remaining Issues / Gaps:

- I did not programmatically toggle simulator network state inside this entry; final visual confirmation still depends on pressing `إعادة المحاولة` in the current screen with internet restored.

Important Future Notes:

- Offline recovery should not rely on `ConnectivityResult` alone.
- When showing no-internet UI as a pushed route, always ensure there is a listener path that dismisses it after a successful retry.

---

## Entry 21

Date: 2026-08-02

Requested Work:

- Fix the remaining case where the customer app still stayed on the no-internet screen even after internet returned and the user pressed `إعادة المحاولة`.
- Perform a real app restart / retest path, not just code edits.

Reason:

- The previous retry fix improved `ConnectionCubit`, but the app still had another code path that opened `NoInternetView` as a standalone pushed page from the network layer.
- This caused the user to remain stuck on the offline screen until fully killing and reopening the app.

Work Performed:

- Re-read `PROJECT_CONTEXT.md`, the latest `CODEX_WORK_LOG.md` entry, and checked git status before editing.
- Inspected:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/connection_cubit.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/no_internet_view.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/dio_consumer.dart`
- Found two architectural causes:
  1. `main.dart` switched between two separate app trees:
     one `MaterialApp` for offline mode and one `MaterialApp.router` for the real app.
  2. `dio_consumer.dart` still pushed `NoInternetView` directly on network connection failures.
- Updated `main.dart` so the app always keeps the real `MaterialApp.router` alive and shows `NoInternetView` as an overlay using `builder` + `Stack`.
- Removed the direct offline-screen push from `dio_consumer.dart`.
  Connection failures are now left to the centralized connectivity flow instead of opening a second independent screen stack.
- Ran `flutter pub get` after adding the missing explicit `flutter_localizations` dependency declaration in `pubspec.yaml`.
- Performed a fresh `flutter run` on `iPhone 17`.
- Performed `hot restart` after the final network-layer fix so the running simulator received the corrected logic.

Files Changed:

- `PROJECT_CONTEXT.md`
- `CODEX_WORK_LOG.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/dio_consumer.dart`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/pubspec.yaml`

Why These Files Changed:

- `main.dart` needed an app-level structural fix so offline UI would not replace the full application tree.
- `dio_consumer.dart` needed to stop creating a second no-internet route manually.
- `pubspec.yaml` needed explicit `flutter_localizations` registration so the imports used by `main.dart` are declared correctly.
- Project memory files were updated so future work remembers the real root cause and not only the first partial fix.

Testing / Validation:

- Ran:
  `dart format`
  on:
  `main.dart`
  and
  `dio_consumer.dart`
- Ran:
  `flutter analyze`
  on:
  `main.dart`
  `connection_cubit.dart`
  `no_internet_view.dart`
  `splash_view.dart`
  `dio_consumer.dart`
- Result:
  no blocking analyzer errors;
  only existing `avoid_print` informational lints remain in `dio_consumer.dart`.
- Ran:
  `flutter pub get`
- Ran:
  `flutter run -d "iPhone 17"`
- Applied:
  `hot restart`
  on the running app after the final patch.

Result:

- The no-internet UI is now controlled from one central place instead of being created by both the app root and the network layer.
- The customer app on `iPhone 17` has been restarted with the corrected flow.
- The most likely cause of the stuck `إعادة المحاولة` button behavior has been removed from the codebase.

Remaining Issues / Gaps:

- Final visual confirmation still depends on pressing `إعادة المحاولة` on the currently running simulator after restoring internet.
- `dio_consumer.dart` still contains legacy `print` statements that are informational-only and unrelated to the retry failure.

Important Future Notes:

- Do not push `NoInternetView` directly from low-level networking code.
- Keep offline handling centralized in `ConnectionCubit` plus the app root overlay.
- If this screen regresses again, inspect architecture first before assuming the retry button callback is the only problem.
