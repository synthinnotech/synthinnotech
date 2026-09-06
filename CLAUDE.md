# CLAUDE.md

Guidance for working in this repo.

## What this is

**SynthInnoTech** — a Flutter company-management app backed by Firebase, built
to run on the **free (Spark)** plan. Features: dashboard, projects + tasks +
Gantt, staff directory, finance, team chat, notifications, attendance, leave
requests, announcements, notes.

## Commands

```bash
flutter pub get
flutter analyze          # must stay clean
flutter test
flutter run
```

Firebase rules/indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

See `SETUP.md` for the full setup / first-admin bootstrap.

## Architecture

Two layers coexist — don't fight it:

- **`lib/core/`** — framework-agnostic foundation. Everything DB-related goes
  through `Db` (`lib/core/data/db.dart`): typed collection refs, `Db.guard` /
  `Db.guardStream` (turn any failure into an `AppException`), and
  `Db.readDate` (tolerant Timestamp/ISO/epoch parser). Roles & permissions in
  `lib/core/rbac/app_role.dart` — **keep this matrix in sync with
  `firestore.rules`**. `Snack` gives services context-free user feedback.

- **`lib/modules/<feature>/`** — newer features, each self-contained
  (`data|application|presentation` or flat `model/service/view_model/screen`).
  `auth/` is the important one: `AuthRepository` is the only code that touches
  `FirebaseAuth`; `AuthGate` is the single routing brain (reacts to the auth
  stream — there is no manual "go to home after login").

- **`lib/{model,service,view,view_model,widget}/`** — the original MVVM
  feature code (projects, people, finance, home, chat). Still current. Its
  services follow the same rules as `core`: **never swallow errors**, return
  empty when `!Db.enabled`, wrap real calls in `Db.guard`.

`loginViewModelProvider` is a thin compatibility bridge over `authUserProvider`
— prefer `currentUserProvider` in new code.

## Hard rules

1. **No mock / demo / seed data.** When Firebase isn't configured, screens show
   empty states. Data only enters via the app's create flows or the Firebase
   console.
2. **No new Cloud Functions dependency.** Functions need Blaze. `functions/` is
   optional; anything essential must work client-side (see
   `AuthRepository.createStaffAccount`, `NotificationCenter`).
3. **Errors are surfaced, never hidden.** Services throw `AppException`;
   view-models catch and either set an `error` field or call `Snack.error`.
4. **Optimistic UI must roll back** on failure (see `FinanceViewModel`,
   `TasksViewModel`).
5. **Conserve Firestore reads.** List screens use one-shot `get()` +
   pull-to-refresh. Live `snapshots()` only for chat, notifications,
   announcements, today's attendance.
6. `flutter analyze` stays at **No issues found** and `flutter test` green
   before committing.

## Adding a feature

1. Model with `fromJson(Map, id)` / `toJson()`, dates via `Db.readDate`.
2. Service: static methods, `if (!Db.enabled) return const [];`, real work in
   `Db.guard(() async { ... })`, `Db.now` for timestamps.
3. A collection ref on `Db` + a matching block in `firestore.rules` + any
   composite index in `firestore.indexes.json`.
4. Riverpod `StateNotifier` (or `FutureProvider`) that catches `AppException`.
5. Gate write actions in the UI with `user.can(Permission.x)`.
