# Goal Master Project Context

Last Updated: 2026-08-09
Maintained By: Codex project agent
Scope: current Codex workspace only

Primary onboarding files for any future AI:

- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/AGENTS.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/AI_QUICKSTART.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/SUBSCRIPTION_SYSTEM_SPEC.md`
- `/Users/ayoubbelhaj/Documents/GitHub/goal_master/CODEX_WORK_LOG.md`

## 1. Project Summary

Goal Master is a multi-application sports booking platform. Based on the code currently available in this workspace, the locally accessible parts are:

1. `goal_master`
   Customer mobile application.
2. `goal_master_admin`
   Stadium managers mobile application.
3. `server_mirror/web.goalmasters.online`
   Local mirror of the production website source pulled from the server on 2026-08-02.
4. `goal-master-web`
   GitHub-ready local working copy of the website source prepared on 2026-08-02 and normalized to a top-level sibling path on 2026-08-09.
5. Backend + Admin Panel
   Still not fully present locally as separate repositories and must not be treated as missing code defects.

Important boundary:

- The backend and server-side admin panel are intentionally unavailable in this workspace at this stage.
- When backend files or server access become available later, they should be merged into this understanding incrementally, not by rebuilding project knowledge from zero.

## 1.1 AI Continuity Layer

To reduce repeated rediscovery and token waste, this project now has a documentation stack for future AI agents:

1. `AI_QUICKSTART.md`
   shortest safe project entry point
2. `AGENTS.md`
   mandatory operating protocol for any AI agent
3. `PROJECT_CONTEXT.md`
   long-form durable project memory
4. `CODEX_WORK_LOG.md`
   append-only historical record of work, decisions, and verification
5. `SUBSCRIPTION_SYSTEM_SPEC.md`
   approved blueprint for stadium-manager subscription architecture

Current subscription-system direction:

- launch recommendation uses 3 plans:
  `Starter`, `Growth`, `Pro`
- but system architecture must support dynamic plan management from admin panel
- app and web must consume plans from backend, not from hardcoded frontend constants
- phase 2 architecture is now defined in `SUBSCRIPTION_SYSTEM_SPEC.md` including:
  data model,
  ownership model,
  API groups,
  enforcement points,
  and lifecycle job expectations
- phase 3 implementation has now started in the website/admin codebase with the first admin slice:
  subscription plan management
  at route:
  `/subscription-plans`
  backed by local tables:
  `subscription_plans`
  and
  `subscription_plan_feature_values`
- phase 3 now also includes the second admin slice:
  assigning a subscription plan to a stadium-manager/system-user account
  from the existing admin user-management page:
  `/user-info`
  using a modal-backed flow and local table:
  `manager_subscriptions`
- stadium-manager onboarding no longer assumes that creating one branch is enough to start bookings
- the real operational setup sequence, based on the existing admin panel/backend logic, is:
  `Branch -> Business Hours -> Category -> Service -> Employee/Schedule -> Booking`
- this matters because booking availability depends on:
  branch hours,
  employee-service mappings,
  and employee schedules,
  not only on branch existence
- the temporary old mobile flow that created a branch plus fake default services was identified as too simplistic and is being replaced gradually by a stage-based setup flow
- manager notifications now need to support more than one backend payload shape:
  some notifications store the booking reference in
  `data.id`
  while others store it in
  `data.booking_id`
- this was confirmed on Thursday, August 13, 2026 during local-payment request testing for booking `#13`
- any future manager-app notification parsing change must remain compatible with both payload shapes
- local-payment request notifications should be treated as a special manager workflow:
  pending approval,
  actionable,
  and distinct from generic “new booking” notifications
- customer-facing booking status notifications must not resolve the recipient through plain phone-number matching alone
- this became critical on Friday, August 14, 2026 when local booking `#13` belonged to:
  `cmn_customer_id = 43`
  with
  `user_id = null`
  while the same phone number was also used by manager system user `33`
- safe notification recipient resolution must prefer:
  `customer->user`
  and only allow fallback matches if the fallback user is explicitly:
  `user_type = WebsiteUser`
- production server inspection on Tuesday, August 11, 2026 confirmed that the original live Goal Master database uses a Laravel table prefix model:
  logical table names in code such as
  `users`,
  `cmn_branches`,
  `sch_service_categories`,
  `sch_services`,
  `sch_employees`
  are stored physically as
  `db2_users`,
  `db2_cmn_branches`,
  `db2_sch_service_categories`,
  `db2_sch_services`,
  `db2_sch_employees`,
  etc.
- this means production is not using different business tables;
  it is using the same old schema behind a DB prefix
- live role data on the server currently includes at least:
  `صلاحيات الادمن`
  `مدير ملعب`
  `صلحيات محدده`
- live stadium-manager setup examples confirmed the real operational chain:
  1. create a `db2_users` record with `user_type = 1`
  2. attach role through `db2_sec_user_roles`
  3. create branch in `db2_cmn_branches`
  4. attach user to branch through `db2_sec_user_branches`
  5. create category in `db2_sch_service_categories`
  6. create services in `db2_sch_services`
  7. create employee rows in `db2_sch_employees`
  8. attach services to employees through `db2_sch_employee_services`
  9. define time windows in `db2_sch_employee_schedules`
- important production insight:
  the real evening/after-midnight split is currently modeled through employee records and their schedules,
  not through a separate dedicated stadium flag
- production examples found on server:
  branch `ملاعب الهدف`
  branch `ملاعب الجزيره`
  category `كرة قدم`
  services like
  `سداسي 1`,
  `ملعب سباعي`,
  `1 ملعب`,
  `2 ملعب`,
  `3 ملعب`
  and employees named like
  `حجز مسائي`
  and
  `حجز ليلي من 12 الى 2`
  or
  `حجز ليلي من 12الى`
- this confirms that the manager app cannot be considered booking-ready after only saving branch info;
  it must eventually support:
  category creation,
  service creation,
  and at least one schedule-aware employee setup

Required reading order for any new AI:

1. `AI_QUICKSTART.md`
2. `AGENTS.md`
3. `PROJECT_CONTEXT.md`
4. latest relevant work log entry
5. if the task relates to stadium-manager subscriptions, read `SUBSCRIPTION_SYSTEM_SPEC.md`

## 2. Primary Goals

- Provide a production-ready booking experience for end users.
- Provide operational tooling for stadium managers to manage bookings and customers.
- Keep business logic aligned across customer and manager applications through a shared backend contract.
- Preserve project knowledge across future tasks so changes are based on real system understanding rather than isolated edits.

## 3. Current Workspace Roots

Accessible now:

- `goal_master`
- `goal_master_admin`
- `goal_master/server_mirror/web.goalmasters.online`
- `goal-master-web`

Not accessible now:

- Admin Panel web source
- Database schema and migrations
- Full backend repository in isolated local form

## 4. Available Applications

### 4.1 Customer Mobile Application

Repository: `goal_master`

Observed functional areas:

- Splash + onboarding
- Authentication
- Home
- Booking
- Balance
- Card / payment flow
- Notifications
- Profile
- Layout / navigation
- Additional section named `more`

### 4.2 Stadium Managers Mobile Application

Repository: `goal_master_admin`

Observed functional areas:

- App start state + onboarding
- Authentication
- Dashboard / analysis
- Booking list and filtering
- Add booking
- Booking details
- Booking status updates
- Deposit / payment confirmation flow
- Customer creation / selection
- Monthly booking management
- Notifications
- Profile / customer management
- Layout / navigation

Inference from code:

- `goal_master_admin` behaves like a mobile operations app for stadium managers.
- It is not the same thing as the server-side admin panel mentioned by the project owner.

### 4.3 Website Source Mirror

Local path:

- `server_mirror/web.goalmasters.online`

Remote source path discovered on server:

- `/home/goalmasters-web/htdocs/web.goalmasters.online/public/GoalMaster`

Observed characteristics:

- Laravel 9 project
- PHP requirement `^8.2`
- Frontend assets built with Laravel Mix / Webpack
- `composer.json` and `package.json` are present
- The mirrored copy was pulled without `.env`
- The mirrored copy excludes `vendor`, `vendor2`, `vendor3`, `node_modules`, and server archive artifacts

Important deployment structure note:

- The vhost document root on the server is `.../web.goalmasters.online/public`
- Inside that document root there is a nested Laravel app folder named `GoalMaster`
- The top-level `public/index.php` on the server currently contains only `phpinfo();`
- This means the current production website structure needs careful review before any deployment changes

### 4.4 Website GitHub-Ready Working Copy

Local path:

- `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`

Purpose:

- keep a clean working tree for website development
- separate raw imported server files from source-control preparation
- serve as the intended base for a dedicated GitHub repository

Current preparation state:

- initialized as a local Git repository
- connected to GitHub repository `git@github.com:ayoub6600/goal-master-web.git`
- initial commit pushed to `main` on 2026-08-02
- `.env` not present
- `public/uploadfiles` removed from this copy
- runtime cache/session/debug files removed from this copy
- dependency folders still excluded and not present
- added `README.md` and `DEPLOYMENT_NOTES.md`

Current local runtime notes observed on 2026-08-02:

- Local Laravel setup was successfully run from `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`
- Local development database is currently `sqlite` at:
  `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web/database/database.sqlite`
- The site was successfully served locally at:
  `http://127.0.0.1:8000`
- Admin login was verified locally through the web login flow and redirected successfully to `/home`
- The app needs runtime directories under `storage/framework` present locally for sessions and compiled views
- Composer dependencies are installed locally in the working copy
- Local JWT auth is configured for the website API, so `/api/login` works for local mobile-app testing
- A reproducible demo data seeder exists at:
  `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web/database/seeders/DemoStadiumManagerSeeder.php`
  This seeder creates one demo stadium manager, one demo club/branch, two demo fields/services, two employees, branch hours, employee schedules, and their mappings
- Booking-related API responses are not type-stable across all fields:
  values such as `service_amount`, `paid_amount`, `due`, and some IDs may arrive as JSON numbers or strings depending on endpoint and query path
- Booking failures caused by insufficient user wallet balance are now expected to return a business error payload with HTTP `400` and a readable `message`, not a generic HTTP `500`
- `Api/Booking/BookingController::getBookingInfo()` previously assumed `getDataInfo()` always returned an array; local fixes now guard against `JsonResponse` being returned for missing bookings
- The local API booking flow previously used `serviceBookings()->attach(...)` against `sch_service_bookings`, but that table is a real booking table with auto-increment `id`, not a pivot table; the local API path now persists booking rows with `hasMany()->createMany(...)` to avoid duplicate-id integrity failures
- Customer notifications are not schema-uniform:
  some booking-related notifications use `data.id`,
  while `UserNotification` uses `data.booking_id`;
- stadium-manager setup bootstrap now exposes real setup progress flags:
  `has_branch_profile`,
  `has_category_setup`,
  `has_service_setup`,
  `has_employee_setup`,
  `can_start_booking`,
  and `next_step_label`
  so the mobile manager app can stop assuming that branch creation alone means the account is booking-ready
  client notification parsing must normalize both to avoid showing booking id `0` or opening booking details with an invalid id
- The customer no-internet recovery flow now validates real internet reachability, not just network presence, and `NoInternetView` closes itself when connectivity is restored and the user retries
- Customer online wallet top-up flow originally had no reliable server-side idempotency:
  repeated `transaction-store` requests could create duplicate balance rows unless guarded by a payment reference or duplicate-detection logic
- Web admin user management already contained a partial wallet-management UI skeleton:
  `resources/views/user_management/user.blade.php`
- Admin user management now also contains subscription assignment controls for non-admin system users.
- Current local admin subscription assignment endpoints:
  `GET /manager-subscription`
  `POST /manager-subscription`
- Current local subscription assignment persistence:
  latest active/current manager subscription is tracked in
  `manager_subscriptions`
  with history preserved by marking older records `is_current = 0`
- First real enforcement layer is now implemented in the website/admin backend:
  non-admin system users with subscriptions are checked against plan limits when creating:
  branches,
  services/fields,
  and employees
- Current enforced limits:
  `max_branches`,
  `max_fields`,
  `max_staff`
- Current enforcement behavior:
  admin bypasses subscription limits;
  non-admin system users must have an active or trialing current subscription
  or creation is blocked with a business error message
- Feature-flag enforcement has now started as a second layer:
  `allow_monthly_bookings`,
  `allow_reports`,
  `allow_web_access`
- Current feature-flag behavior:
  monthly-booking routes are blocked when `allow_monthly_bookings = 0`
  dashboard/report routes are blocked when `allow_reports = 0`
  and system-user access to the admin web panel is blocked at route level when `allow_web_access = 0`
- Current UX handling:
  if reports are disabled but web access is allowed,
  opening `/home` redirects the manager to `booking.calendar`
  with an explanatory error message
  and `public/js/custom/user_management/user.js`
- Manager self-onboarding now has a first real setup API slice for the mobile manager app:
  `GET /api/manager/setup/bootstrap`
  and
  `POST /api/manager/setup/first-venue`
- The new manager-setup bootstrap payload now returns:
  setup completion state,
  wallet summary,
  recent wallet transactions,
  and available zones for first-venue creation
- In Goal Master business structure,
  the first stadium setup is now persisted as:
  one real `cmn_branch`,
  one default `sch_service_category`,
  and N initial `sch_services`
  based on the manager-entered field count
- For this onboarding slice,
  the entered stadium description is currently stored as branch address fallback text
  and copied into the initial service remarks,
  because `cmn_branches` has no dedicated description column in the current schema
- Manager wallet preparation is now considered part of onboarding:
  the setup screen can read current wallet balance before first-venue creation,
  even if the active plan is still in a free trial period
  but it was add-only and did not yet support direct withdrawals or mandatory descriptions before this task
- Manager wallet onboarding is now promoted to its own API/UI slice:
  `GET /api/manager/wallet/summary`
  and
  `GET /api/manager/wallet/transactions`
  now back a dedicated manager-wallet screen in the mobile app
- As of Monday, August 10, 2026,
  manager wallet top-up is now partially implemented end-to-end for the mobile manager app:
  `POST /api/manager/wallet/confirm-topup`
  stores a manager credit transaction in `cmn_user_balances`
  and the Flutter manager app now opens a dedicated online-payment webview flow from the wallet screen
- Current manager top-up persistence rules:
  wallet credits are stored through the manager user's morph relation to `cmn_user_balances`
  with:
  `balance_type = 1`,
  `type = credit`,
  and description shaped as:
  `manager_online_topup[:reference]`
- Current manager-wallet test baseline on local data:
  manager user id `33`
  successfully received a tested top-up of `7`
  on Monday, August 10, 2026,
  and the wallet transaction list returned that record through:
  `GET /api/manager/wallet/transactions?page=1`
- Manager profile consistency note:
  for manager accounts,
  `GET /api/user/profile`
  must expose
  `zone_id`
  and
  `club_id`
  the same way login does,
  otherwise the app can wrongly keep the account in setup mode after venue creation
- As of Sunday, August 9, 2026, the canonical website repo path should be treated as:
  `/Users/ayoubbelhaj/Documents/GitHub/goal-master-web`
  and not the older duplicate:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
- As of Sunday, August 9, 2026, VS Code terminal support for the website repo is now localized:
  `.vscode/settings.json`
  prepends:
  `.codex/bin`
  to PATH for that workspace,
  and `.codex/bin/php` wraps Homebrew PHP with:
  `E_DEPRECATED` and `E_USER_DEPRECATED` suppressed.
  Practical effect:
  inside VS Code, from the website repo, the user can type:
  `php artisan serve`
  and get a cleaner Laravel startup on PHP `8.4.8` without changing the global system PHP command.

## 5. High-Level Architecture

Both local apps follow a similar layered Flutter architecture:

1. `lib/core`
   Shared infrastructure inside each app:
   routing, network layer, error handling, styles, dependency injection, utilities, storage helpers, reusable widgets.
2. `lib/features`
   Feature-first modules.
3. `data`
   Models and repositories.
4. `presentation`
   Views, widgets, Cubits/BLoCs, and UI state.

Common architectural patterns:

- Flutter application
- Feature-based foldering
- `flutter_bloc` / Cubit for state management
- `go_router` for routing
- `get_it` for dependency injection
- `dio` for API access
- Shared preferences for persisted app state
- Local notifications through `flutter_local_notifications`
- Real-time notifications through Socket.IO

## 6. Folder Structure Overview

### 6.1 `goal_master`

Top-level relevant folders:

- `lib/core`
- `lib/features`
- `lib/utils`
- `assets`
- platform folders: `android`, `ios`, `web`, `linux`, `macos`, `windows`
- `test`

Main feature folders:

- `auth`
- `balance`
- `booking`
- `card`
- `home`
- `layout`
- `more`
- `notification`
- `onboarding`
- `profile`
- `splash`

### 6.2 `goal_master_admin`

Top-level relevant folders:

- `lib/core`
- `lib/features`
- `lib/utils`
- `assets`
- platform folders: `android`, `ios`, `web`, `linux`, `macos`, `windows`
- `test`

Main feature folders:

- `auth`
- `booking`
- `home`
- `layout`
- `monthly_booking`
- `notification`
- `onbording`
- `profail`
- `splach`

Important note:

- The admin app contains naming inconsistencies such as `onbording`, `profail`, and `splach`.
- These are existing codebase realities and should be treated carefully in future edits.

### 6.3 `server_mirror/web.goalmasters.online`

Top-level relevant folders now available locally:

- `public`
- `public/GoalMaster`
- `public/GoalMaster/app`
- `public/GoalMaster/bootstrap`
- `public/GoalMaster/config`
- `public/GoalMaster/database`
- `public/GoalMaster/public`
- `public/GoalMaster/resources`
- `public/GoalMaster/routes`
- `public/GoalMaster/storage`
- `public/GoalMaster/tests`

### 6.4 `goal_master_web`

This is the flattened Laravel project root prepared for repository use.

Top-level relevant folders:

- `app`
- `bootstrap`
- `config`
- `database`
- `public`
- `resources`
- `routes`
- `storage`
- `tests`

Important note:

- This copy is intentionally cleaner than the raw server mirror and is the preferred starting point for Git work.
- It was later moved out of `goal_master` into the sibling top-level folder `goal_master_web` so the local structure matches `goal_master` and `goal_master_admin`.

## 7. Technologies In Use

### Shared across both apps

- Flutter
- Dart
- `flutter_bloc`, `bloc`
- `go_router`
- `dio`
- `get_it`
- `socket_io_client`
- `flutter_local_notifications`
- `cached_network_image`
- `flutter_screenutil`
- `google_fonts`
- `flutter_svg`
- `oktoast`
- `infinite_scroll_pagination`
- `shared_preferences`

### Customer-specific notable packages

- `flutter_secure_storage`
- `google_maps_flutter`
- `geocoding`
- `location`
- `webview_flutter`
- `moamalat_payment`
- `share_plus`

### Manager-specific notable packages

- `chucker_flutter`
- `dropdown_search`
- `searchable_paginated_dropdown`
- `fl_chart`
- `percent_indicator`
- `path_provider`

### Website-specific notable packages and libraries

- Laravel Framework `^9.0`
- `tymon/jwt-auth`
- `spatie/laravel-medialibrary`
- `maatwebsite/excel`
- `barryvdh/laravel-dompdf`
- `paypal/paypal-checkout-sdk`
- `stripe/stripe-php`
- `twilio/sdk`
- Vue 2
- Laravel Mix 5

## 8. Startup and Navigation

### 8.1 Customer app startup

Key file: `lib/main.dart`

Observed behavior:

- Initializes shared preferences.
- Initializes secure storage service.
- Registers DI via `setupServiceLocator()`.
- Initializes local notifications.
- Requests notification permission.
- Starts app with `MaterialApp.router`.
- Uses Arabic locale by default.
- Uses `SplashView` as initial route.

Customer startup decision logic:

- `SplashView` reads `PrefKey.login`.
- Empty value routes to onboarding.
- `"true"` routes to home.
- Other values route to login.

### 8.2 Manager app startup

Key files:

- `lib/main.dart`
- `lib/core/routing/appstart_state.dart`

Observed behavior:

- Initializes shared preferences.
- Registers DI.
- Initializes local notifications.
- Monitors internet connectivity.
- Computes initial route through `AppStartCubit`.

Manager startup decision logic:

- If onboarding not seen: onboarding.
- If login flag is not `"true"` or `userId` is missing/zero: login.
- Otherwise: home.

## 9. Dependency Injection

Both apps use `get_it` with a similar setup:

- Register `Dio`
- Register `DioConsumer`
- Register feature repositories as singletons

Customer app registered repos:

- `AuthRepoImpl`
- `ProfileRepoImp`
- `BookingRepoImp`
- `AnalysisRepoImp`
- `CardRepoImp`
- `BalanceRepoImp`
- `NotificationRepo`

Manager app registered repos:

- `AuthRepoImpl`
- `ProfileRepoImp`
- `BookingRepoImp`
- `AnalysisRepoImp`
- `MonthlyBookingRepoImp`
- `NotificationRepo`

## 10. Networking and API Structure

Shared API base URL currently hardcoded in both apps:

- `https://web.goalmasters.online/api/`

Notification socket endpoint used by both apps:

- `https://socket.goalmasters.online`

### 10.1 Common API architecture

Core files:

- `lib/core/databases/api/api_consumer.dart`
- `lib/core/databases/api/dio_consumer.dart`
- `lib/core/databases/api/api_consumer_extension.dart`
- `lib/core/databases/api/end_points.dart`

Observed behavior:

- `DioConsumer` sets the base URL and request headers.
- Authorization header is rebuilt from shared preferences before requests.
- Repository methods call `ApiConsumer` methods.
- `ApiConsumerExtension` wraps requests in `Either<Failure, T>`.

### 10.2 Authentication-related endpoints observed

Shared/common:

- `login`
- `register`
- `resend-otp`
- `verify`
- `change-password`
- `user/refresh`
- `user/profile`
- `user/update`
- `user/change-password-user`
- `user/delete`

Important implementation note:

- The stored value under `PrefKey.fcmToken` is being used as the bearer auth token in both apps.
- The key name suggests FCM, but the code uses it as the main API token.

### 10.3 Customer app API areas observed

- Wallet / transaction:
  `user/wallet/transaction-store`, `user/wallet/send-money`, `user/wallet/transaction`
- Card / balance:
  `user/card/charge`, `user/card/balance`
- User analysis:
  `user/analysis`
- Booking:
  `user/booking/history`, `user/booking/get-info`, `user/booking/cancel-booking`, `user/booking/store-booking`, `user/booking/fillter-new-booking`
- Notifications:
  `user/notifications/get-notification`, mark one, mark all

### 10.4 Manager app API areas observed

- Dashboard:
  `manager/dashboard/analysis`
- Booking status updates:
  `manager/booking/change-service-booking-status`
- Booking deposit flow:
  `manager/booking/depoist-money`
- Customer creation:
  `manager/customer-create`
- Monthly bookings:
  `user/booking/getMonthlyBookingList`, `user/booking/updateMonthlyBooking`
- Booking list:
  `user/booking/all`

### 10.5 API structure still missing

Not yet available locally:

- Formal backend API documentation
- Request/response contract documentation
- Server-side validation rules
- Role/permission matrix
- Admin panel endpoints

## 11. Data Storage

### Customer app

- `SharedPreferenceUtil` stores app flags and primitive values.
- `StorageService` wraps `SharedPreferences` plus `FlutterSecureStorage`.
- `AuthManager` uses secure storage for auth token and shared preferences for serialized user data.

Observed mismatch:

- Some code paths use `AuthManager` and `StorageService`.
- Other active paths rely directly on `SharedPreferenceUtil` and `PrefKey.fcmToken`.
- This means auth persistence currently has more than one pattern in the codebase.

### Manager app

- Uses `SharedPreferenceUtil`.
- No separate secure storage abstraction was observed in the same form as the customer app.

## 12. Key Models Identified

### Authentication

- `LoginModel`
- `UserData`
- `User`
- `VerifyOtpModel`
- `ResetTokenResponse`

### Booking domain

- Customer app:
  `Booking`, `CancelBookingResponse`, `CategoryModel`, `ClubResponce`, `Location`, `Employee`, `Service`, `TimeslotModel`
- Manager app:
  `BookingItemResponce`, `BookingDetails`, plus the same shared selector models above

### Payment / finance

- Customer app:
  `TransactionsResponse`, `PaymentSession`

### Notification

- `NotificationResponse`
- `NotificationItem`

### Dashboard / analysis

- Customer app:
  `AnalysisModel`, `BannerModel`, `BookingSlotsResponse`
- Manager app:
  `DashBoardResponse`, `BannerModel`, `BookingSlotsResponse`

### Monthly booking

- Manager app:
  `MonthlyBookingResponse`

## 13. Core Functional Flows

### 13.1 Authentication Flow

Customer app:

1. User enters phone number + password.
2. `AuthRepoImpl.login()` posts to `login`.
3. Response token is saved in shared preferences under `PrefKey.fcmToken`.
4. Login state is tracked through `PrefKey.login`.
5. Splash determines next route from saved state.
6. Token refresh uses `user/refresh` through `TokenInterceptor`.

Manager app:

1. User enters username + password.
2. `AuthRepoImpl.login()` posts to `login`.
3. Response token is saved in shared preferences under `PrefKey.fcmToken`.
4. App start decision uses `onboardingSeen`, `LOGIN`, and `USERID`.
5. Token refresh also uses `user/refresh`.

### 13.2 Booking Flow

Customer app:

1. User loads zones.
2. User selects club/branch.
3. User selects category.
4. User selects service.
5. User selects employee.
6. User loads available time slots by branch, employee, service, and date.
7. User submits booking with payment type, service date, and time range.
8. Backend either returns direct success data or a payment return URL for non-cash paths.

Manager app:

1. Manager can filter bookings by date range, branch, employee, customer, status, or booking ID.
2. Manager opens booking details.
3. Manager can cancel a booking.
4. Manager can update booking status.
5. Manager can add a new booking, optionally linking a customer and payment/deposit details.
6. Manager can register deposit/payment state.
7. Manager can manage monthly bookings separately.

### 13.3 Notification Flow

Shared observed pattern:

1. App loads paginated notifications from REST API.
2. App also connects to `socket.goalmasters.online` using Socket.IO.
3. On socket connect, the app emits `register` with the user ID.
4. Incoming `notification` events are inserted directly into the paging list.
5. Local notification is shown through `flutter_local_notifications`.
6. User can mark one or all notifications as read through REST endpoints.

## 14. Authentication and Session Handling Risks

Important current realities:

- Auth token is stored under a misleading key name: `FCMTOKEN`.
- Customer app mixes `AuthManager`/secure storage and direct shared preferences token handling.
- Customer token refresh failure currently does not force navigation to login because redirect logic is commented out.
- Manager token refresh failure clears preferences and marks login false.
- For local iOS simulator testing on August 2, 2026, both mobile apps were temporarily pointed to:
  `http://127.0.0.1:8000/api/`
- Customer iOS local testing required allowing non-HTTPS requests in:
  `goal_master/ios/Runner/Info.plist`
- `google_fonts` caused runtime `AssetManifest.json` crashes on the current Flutter/iOS simulator environment, so active usage was removed from both mobile apps for local stability.
- Customer booking-related models required defensive JSON parsing because the local Laravel API returns some numeric fields such as `price`, `salary`, `commission`, and `target_service_amount` as integers while the app expected strings.

These are not changes to make automatically. They are system behaviors that must be understood before future auth edits.

## 15. Known Issues and Codebase Risks

Observed directly from the local codebase:

- Naming inconsistencies:
  `onbording`, `profail`, `splach`, `club_responce`
- Files with suspicious names:
  `booking_items_details.dart.dart`, `verify_otp_model..dart`, `data..dart`, `user..dart`
- Temporary or duplicate-looking files exist:
  files ending in `copy.dart`
- Import paths with encoded leading spaces exist around `booking_details_cubit`
- Automated test coverage is effectively absent beyond default `widget_test.dart`
- Customer repository had pre-existing git modifications at discovery time:
  `ios/Flutter/AppFrameworkInfo.plist`, `ios/Podfile.lock`, `ios/Runner.xcodeproj/project.pbxproj`, `pubspec.lock`
- Manager `pubspec.yaml` places many runtime packages under `dev_dependencies`, which is structurally unusual and should be handled cautiously later
- The website currently runs locally on PHP `8.4.8`, while the application targets Laravel 9 and emits deprecation warnings during CLI and HTTP execution
- Several website migrations and seeders assume MySQL-style behavior or contain hard-coded assumptions that are unsafe for local SQLite execution without guard logic
- The Laravel `mysql` connection for the website has a hard-coded table prefix `db2_`, while multiple historical migrations insert raw SQL into unprefixed table names, so local MySQL migration behavior needs careful review before relying on it
- The website runtime can fail if these directories are absent:
  `storage/framework/sessions`
  `storage/framework/views`
  `storage/framework/cache/data`
- Local booking availability for the manager-app API path was hardened on Tuesday, August 11, 2026:
  it now checks overlap by
  `service + employee + date + time range`
  and treats
  `Pending`, `Processing`, `Approved`, and `Done`
  as blocking states, so manager-created bookings now lock the slot like the web flow instead of allowing the same hour to be booked again through overlap gaps
- Customer-app branch selection on Tuesday, August 11, 2026 exposed another local API-shape issue:
  newly created branches can return nullable
  `lat` and `long`
  from `/api/list/club`,
  so the customer Flutter model for club/branch data must not assume those fields are always non-null strings
- Customer-app category selection on Tuesday, August 11, 2026 exposed the same nullability pattern one step later:
  `/api/list/category`
  returns a nested `cmn_branch` object, and that nested branch can also contain
  `lat = null`
  and
  `long = null`,
  so `CategoryModel` and its nested branch model must also stay null-safe instead of assuming every branch string field is present
- Mobile local-run risk:
  both apps are currently configured against the local backend URL rather than production
- Customer app local-run risk:
  several API models were written with overly strict string casts and can break when backend numeric fields are returned as integers
- Manager app local-run risk:
  booking list and booking details models also need tolerant parsing because backend money fields and some scalar values are not consistently typed
- `google_fonts` is currently unsafe in this workspace's Flutter/iOS simulator path and should not be reintroduced casually without retesting on the active Flutter toolchain
- Customer registration local-backend note:
  the active API registration path is `routes/api.php -> Api\Auth\AuthController::create`, not the classic web `RegisterController`
- Local SQLite note:
  `users.email` is currently `NOT NULL`, so API-side customer registration must populate `email` even when the mobile UI does not collect it explicitly
- Manager booking local-backend note:
  `saveBooking()` may successfully persist a booking before non-critical post-commit side effects run, so notification or WhatsApp failures must not be allowed to masquerade as booking-save failures
- Customer wallet local-backend note:
  `cmn_user_balances` now includes a local `description` column added on `2026-08-02` to support admin charge/withdraw reasons and online top-up reference tracking
- Admin wallet local-backend note:
  direct admin wallet adjustments must keep `cmn_user_balances.type` within the existing enum
  `credit`, `recharge`, `transfer`, `balance`
  and should store operator-entered human reasons in `description` instead of inventing new `type` values;
  direct wallet charge should also emit a customer WebSocket notification
- Wallet notification UX note:
  customer notification details can no longer assume every notification is a booking;
  wallet notifications now use a separate details presentation driven by notification `data.type`
- Admin wallet operations note:
  a dedicated admin web page now exists for financial transactions at:
  `wallet-transactions`
  and the user list provides a per-user transactions entry beside wallet management
- Local notification delivery note:
  the customer app currently has two notification paths:
  1. Socket.IO client connected to `https://socket.goalmasters.online`
  2. REST polling against local `user/notifications/get-notification`
  In the current local website `.env`, `BROADCAST_DRIVER=log`, so true backend WebSocket broadcasting is disabled locally unless broadcast infrastructure is configured;
  local wallet/admin notification testing therefore depends on persisted database notifications plus app polling fallback

## 16. Important Technical Decisions to Preserve

- Treat the project as production software, not as a disposable coding exercise.
- Do not assume backend absence in GitHub means missing implementation.
- Do not change APIs before tracing all callers.
- Do not change models before checking downstream UI, Cubits, repos, and request/response parsing.
- Prefer small, explicit, low-risk changes.
- Before any future implementation task:
  1. Read this file.
  2. Read the latest entry in `CODEX_WORK_LOG.md`.
  3. Check git status in the affected repo or repos.
  4. Assess cross-project impact.
  5. Present a short plan before editing.

## 17. Database Structure

Not available yet.

When backend access becomes available, document at minimum:

- Main tables
- Keys and relationships
- Booking-related tables
- User and manager role tables
- Notification tables
- Payment and transaction tables
- Audit/logging structure

## 18. Backend / Server Knowledge To Add Later

When accessible, extend this file with:

- Full backend architecture
- Deployment model
- Environment breakdown
- API contract details
- Background jobs / queue behavior
- Notification generation path
- Payment lifecycle on the server
- Admin panel structure

## 20. Server Import Notes

Website import completed on 2026-08-02 with these constraints:

- Imported from server `72.60.39.196` using `root` access
- Source discovered under `/home/goalmasters-web/htdocs/web.goalmasters.online/public/GoalMaster`
- Local mirror stored under `goal_master/server_mirror/web.goalmasters.online`
- Excluded from mirror:
  `.env`, `vendor`, `vendor2`, `vendor3`, `node_modules`, `archive.zip`, generated cache PHP files, and storage logs

This local mirror should be treated as the starting point for preparing a clean GitHub-ready website repository.

GitHub-ready website preparation completed later on 2026-08-02 with these additional constraints:

- originally prepared under `github_ready/web.goalmasters.online`
- later moved to `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
- converted to Laravel project root layout for repository work
- removed production upload data from `public/uploadfiles`
- removed runtime debug/session/view cache files from `storage`
- initialized as a standalone local Git repository
- published to GitHub repository `ayoub6600/goal-master-web`

## 19. Working Notes For Future Codex Sessions

- This file is the persistent project memory for the currently visible Goal Master workspace.
- The authoritative local understanding currently comes from `goal_master` and `goal_master_admin`.
- If backend files are introduced later, append their context here instead of rewriting the document from scratch.
- Never store secrets, passwords, API keys, or private credentials in this file.

## 21. GitHub Terminal Access

As of 2026-08-02:

- This device has a dedicated GitHub SSH key configured for terminal Git operations.
- The key is associated with GitHub user `ayoub6600`.
- SSH authentication to `git@github.com` was verified successfully from the terminal.
- Local SSH config was set so `github.com` uses the dedicated key by default on this device.

Practical implication:

- Codex can now use terminal Git over SSH for clone, fetch, pull, push, and remote setup on repositories that the GitHub account `ayoub6600` can access.

Current limitation:

- GitHub CLI `gh` is still not installed, so GitHub API workflows such as repo creation through `gh` are not yet available from terminal by default.

## 22. Local Mobile Runtime Snapshot

Verified on Sunday, August 2, 2026:

- Customer app repository:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master`
- Manager app repository:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin`
- Backend/API local runtime:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_web`
  served at `http://127.0.0.1:8000`

iOS simulator targets used:

- Customer app:
  `iPhone 17`
- Manager app:
  `iPhone 17e`

Most recent local run behavior:

- Customer app launched successfully after removing active `google_fonts` usage and hardening booking model parsing.
- Manager app launched successfully against the same local backend.
- Both apps surfaced the expected iOS notification permission prompt on fresh install.
- Demo manager credentials intended for the manager app remain:
  username `manager_demo`
  password `12345678`
- Customer API registration was verified locally on Sunday, August 2, 2026 after fixing API-side email population for mobile-created users.
- Manager local booking save for a cash booking was verified at API level on Sunday, August 2, 2026 after:
  1. fixing null-safe post-booking notification flow for customers without linked `users` accounts, and
  2. surfacing backend `data` messages in the manager app instead of the generic validation toast

## 23. Offline / Retry Architecture Note

As of Sunday, August 2, 2026:

- Customer app offline handling should be treated as centralized behavior.
- `ConnectionCubit` is the authority for online/offline state.
- `NoInternetView` should appear as an overlay from the app root in:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
  instead of replacing the full app tree or being pushed from low-level networking code.
- `dio_consumer.dart` must not push `NoInternetView` directly on `DioExceptionType.connectionError`.
  That older pattern caused stuck offline screens that only disappeared after killing and reopening the app.
- If retry logic regresses in the future, inspect:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/main.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/connection_cubit.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/view/no_internet_view.dart`
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master/lib/core/databases/api/dio_consumer.dart`
  before changing button callbacks in isolation.

## 24. Subscription Rollout In Manager Mobile App

As of Sunday, August 9, 2026:

- The backend now exposes manager subscription metadata to API consumers on:
  `/api/login`
  `/api/user/profile`
  `/api/manager/dashboard/analysis`
- The manager mobile app now reads:
  `current_subscription`
  and
  `subscription_features`
  from the authenticated manager payload.
- The first mobile-facing subscription behaviors now implemented are:
  - monthly booking lock awareness
  - reports/dashboard lock awareness
  - visible current plan summary on the manager home screen
- API enforcement was also extended for manager-mobile routes:
  - `/api/user/booking/getMonthlyBookingList`
  - `/api/user/booking/updateMonthlyBooking`
  - `/api/manager/dashboard/analysis`
- Important local environment note:
  the Laravel local `.env` required a valid JWT secret before manager mobile login could work in the current local clone.
  This was fixed locally on Sunday, August 9, 2026.

## 25. Manager Self-Signup Phase 1

As of Sunday, August 9, 2026:

- The project now has a dedicated stadium-manager self-signup API flow.
- New public API endpoint:
  `/api/manager/public-subscription-plans`
  returns active public plans for app onboarding.
- New manager signup API endpoint:
  `/api/manager/register`
  creates:
  a manager `SystemUser`,
  assigns `Operator` role,
  creates a current subscription,
  and
  returns JWT login data plus subscription metadata.
- The older `/api/register` route should still be treated as the legacy website/customer registration path,
  not the preferred base for manager onboarding.
- `AuthController::GetDetails()` is now null-safe for managers who have no branch or club yet.

Manager app architecture added for this phase:

- dedicated feature module:
  `/Users/ayoubbelhaj/Documents/GitHub/goal_master_admin/lib/features/manager_onboarding`
- responsibilities split into:
  models,
  repo,
  plans cubit,
  signup cubit,
  flow view,
  and small UI widgets

Manager app UX changes in this phase:

- login screen now exposes:
  `ليس لديك حساب؟ أنشئ حساب مدير ملعب`
- signup flow now:
  fetches live plans from backend,
  supports monthly/yearly switch,
  lets the manager choose a plan,
  and
  submits account details separately from the old register screen
- the signup email field now gives a lightweight `gmail.com` suggestion as soon as the user starts typing after `@`
- new manager accounts that still have no `zone_id` and no `club_id` are now treated as setup-pending accounts in the manager app
- home, profile, and drawer now show a setup-oriented manager experience for those new accounts instead of the old booking-first manager UI
- a dedicated local-first screen now exists for those accounts:
  `إضافة الملعب الأول`
  with fields for:
  stadium name,
  region,
  description,
  number of fields,
  and
  image selection

Important implementation note:

- Manager self-signup now auto-logs the new manager in immediately after successful registration.
- The account may still have:
  no branch,
  no club,
  and
  no stadium setup yet,
  so future onboarding work must keep post-signup home flow safe for that empty-state account.

Important local runtime note:

- `lib/main.dart` was corrected so Flutter binding initialization and `runApp` now happen inside the same zone.
  This removed the noisy `Zone mismatch` startup assertion during local manager-app runs.

Known remaining gap after this phase:

- unauthenticated startup still triggers some older background calls:
  token refresh
  and
  notification polling
  before login is established
- future auth cleanup should stop those calls when no token exists

New confirmed onboarding mechanic for manager self-setup:

- after manager self-signup, the correct production-like path is now:
  1. save branch
  2. save first category
  3. save services / fields
  4. create booking channels for
     evening
     and
     after midnight
  5. link each service to one or both channels
- in this project, these booking channels are technically stored as `SchEmployee` rows with schedules.
  They are not necessarily literal human employees.
  They often act as operational time buckets such as:
  `حجز مسائي`
  `حجز بعد منتصف الليل`

Local manager setup API now supports:

- `GET /api/manager/setup/bootstrap`
- `POST /api/manager/setup/first-venue`
- `POST /api/manager/setup/booking-periods`
- `POST /api/manager/setup/catalog`

Current manager-app setup screen behavior:

- the same setup screen now handles:
  branch data
  and then links out to separate follow-up steps
- the new dedicated follow-up step added on Wednesday, August 12, 2026 is:
  `فترات الحجز`
  where the manager can explicitly manage:
  `حجز مسائي`
  and
  `حجز بعد منتصف الليل`
  with their own start and end times
- as of Wednesday, August 12, 2026, this screen is also the place where each service is explicitly linked to one or both booking periods
- this matters because showing the period name alone in Flutter is not enough;
  `/api/user/booking/time-slot`
  only works when the selected service is actually linked through
  `sch_employee_services`
  to the operational employee row that represents that period
- catalog bootstrap now returns:
  current category
  current services
  and
  current operational booking channels
- operational booking channels now also return:
  `designation_name`
  `start_time`
  `end_time`

Current unresolved booking investigation state:

- structural setup is now closer to the real production mechanism
- confirmed local branch `test1` with `branch_id = 5` had this exact failure:
  `حجز بعد منتصف الليل`
  appeared in the manager app
  but service `ملعب 1`
  was only linked to the evening channel in `sch_employee_services`
- after linking the service to both periods, the same local timeslot API began returning valid slots for the after-midnight channel:
  `00:00 -> 01:00`
  `01:00 -> 02:00`
  `02:00 -> 03:00`
- the old extra invalid slot after the end of the schedule was also removed from
  `BookingController::getServiceTimeSlot()`
- but the following still need a separate debugging pass after this linking fix:
  duplicate booking rows,
  slot not always locking after approval,
  and admin-panel mismatch for some app-created bookings

Customer-app booking parsing note:

- on Wednesday, August 12, 2026, more customer booking models were hardened against nullable and mixed-type backend payloads
- affected model families:
  service,
  employee,
  nested branch,
  designation,
  and booking history
- reason:
  the current backend list APIs do not consistently guarantee strict string-only or int-only values for all fields, especially around:
  `lat`
  `long`
  `address`
  dates,
  image fields,
  and nested objects
- if a future booking screen crashes with a `Null` / `String` / `int` parsing error, first inspect the corresponding Flutter model before assuming the booking logic itself is broken

Booking lock normalization note:

- on Wednesday, August 12, 2026, the booking-lock bug was traced to mixed date/time storage in local booking rows
- some rows stored:
  `date` as `Y-m-d 00:00:00`
  instead of `Y-m-d`
  and
  `start_time` / `end_time`
  as full datetime strings instead of time-only values
- backend save flow now normalizes stored booking values before insert
- backend availability checks now compare with:
  `whereDate(...)`
  and
  `whereTime(...)`
  so older mixed-format rows are still respected as conflicts
- confirmed locally via live API that booked evening slots for branch `5` / service `8` now return:
  `is_available: 0`

Local-payment approval verification note:

- on Thursday, August 13, 2026, the local-payment closing rule was verified directly with a future booking on:
  Friday, August 14, 2026
- exact tested setup:
  branch `5`
  service `8`
  employee `6`
  slot:
  `20:00 -> 21:00`
- confirmed behavior:
  1. before creating the local-payment booking, the slot was open
  2. while the booking remained in:
     `Processing`
     as a local-payment request waiting for manager approval, the slot still stayed open
  3. after changing that same booking to:
     `Approved`
     the slot became blocked in backend availability logic
  4. the live local API:
     `POST /api/list/timeslot`
     also returned that slot with:
     `is_available: 0`
- conclusion:
  the backend rule currently matches the intended business behavior for:
  `الدفع عند الوصول`
  where waiting requests do not lock the slot,
  but approved bookings do

Manager payment settings note:

- the manager app now includes a dedicated side-menu entry:
  `إعدادات الدفع`
- this screen exposes the:
  `الدفع عند الوصول`
  toggle and is still governed by subscription permissions
- if the current branch does not allow local payment, the setting should remain disabled and the customer app should hide or reject that method accordingly

App force-update system note:

- On Friday, August 21, 2026, the backend/admin first slice for app update control was added in `goal-master-web`.
- The system uses the `app_update_rules` table to control app-version policy per:
  `app_key`
  and
  `platform`.
- Supported app keys are:
  `customer`
  and
  `manager`.
- Supported platforms are:
  `ios`
  and
  `android`.
- The public mobile API contract is:
  `POST /api/app-version/check`
- Request fields:
  `app`,
  `platform`,
  `version_name`,
  `build_number`.
- Response tells the app:
  `update_required`,
  `force`,
  `mode`,
  `deadline_at`,
  latest/minimum versions and store/message fields.
- Update modes:
  `none`
  means no update prompt,
  `soft`
  means optional update,
  `deadline`
  means optional until `force_after`, then forced,
  `force`
  means forced immediately for outdated versions.
- Version comparison prefers numeric build numbers when both current and target builds are present, and falls back to semantic `version_name` comparison.
- Only one active rule should exist per app/platform; saving an active rule deactivates sibling active rules for the same app/platform.
- Mobile integration:
  - Customer app calls the endpoint with `app=customer`.
  - Manager app calls the endpoint with `app=manager`.
  - Both apps read native `version_name` and `build_number` through `package_info_plus`.
  - The startup check is fail-open: if the endpoint is unavailable, app startup continues normally.
  - If the backend returns `force=true`, the update overlay cannot be dismissed. If it returns an optional update, the user can choose `لاحقًا`.
  - The update UI is an app-level overlay, not a normal dialog, so it remains visible above router/navigation/login state after startup.
- Force-update source-of-truth decision:
  - The backend/admin `app_update_rules` table remains the source of truth for update policy.
  - Firebase Remote Config is a common global option, but for Goal Master the admin-controlled backend is preferred because app/platform rules must be managed from the existing admin panel with operational visibility.
  - Firebase Remote Config can be added later as an emergency fallback/cache layer, not as a replacement for the admin rules.

Admin designation clarification:

- `Designation` in admin is only a classification label for an operational booking row.
- It does not by itself create the evening / after-midnight split.
- The real split depends on:
  1. the operational `SchEmployee` row
  2. its linked services
  3. its schedule
- The two important operational labels currently used by this project are:
  `حجز مسائي`
  and
  `حجز بعد منتصف الليل`

## 26. Persistent Venue Data Access And Self-Service Subscription Management

As of Sunday, August 16, 2026:

- The manager-app drawer previously only exposed the venue/category/services setup screen (`AddFirstVenueView`, route `kAddFirstVenue`) while the account still had `needsVenueSetup == true`. Once setup finished, that entry vanished from the drawer with no other way to reach it, so a manager could not go back and edit branch, category, service, or channel data later.
- This is now fixed by adding a permanent drawer entry "بيانات الملعب" (near "فترات الحجز") in the normal post-setup drawer branch that opens the same `AddFirstVenueView`. That screen already prefills from `manager/setup/bootstrap` and already supports resubmitting branch and catalog data, so no separate "edit mode" was needed. The screen title changed from "تهيئة مدير الملعب" to "بيانات الملعب" to reflect that it is a durable settings screen, not a one-time onboarding step.
- A new self-service subscription management capability now exists end to end:
  - Backend: `GET /api/manager/subscription/current` and `POST /api/manager/subscription/change` (`ManagerSubscriptionSelfController`), reusing the same subscription lifecycle math as manager self-signup (`ManagerSignupService`). Changing plan deactivates the current `manager_subscriptions` row and creates a new current one; this same endpoint is used both to renew the same plan and to switch to a different one.
  - Manager app: new feature module `manager_subscription` and screen `ManagerSubscriptionView` (route `kManagerSubscription`), reachable from a new drawer entry "الاشتراك" placed next to "بيانات الملعب" and "فترات الحجز" (present in both the setup-pending and normal drawer branches).
- Important: this work is implemented and passed `flutter analyze` / `php -l`, but has not yet been exercised against a running local server or the manager app in a simulator, and is not yet committed to git in either `goal-master-web` or `goal_master_admin`. Treat it as unverified end-to-end until that happens.
