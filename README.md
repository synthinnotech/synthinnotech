# SynthInnoTech

A Flutter + Firebase company‑management app. Runs on the Firebase **free
(Spark)** plan.

## Modules

| Area | What it does |
|---|---|
| **Auth** (`lib/modules/auth`) | Email/password sign‑in, admin‑creates‑staff, forgot password, change password, live `AuthGate` routing, role‑based access (admin / manager / employee / intern) |
| **Dashboard** | Finance overview, project/team stats, quick actions, recent activity |
| **Projects** | CRUD, progress slider, status, budget/spend, tasks + Gantt timeline, task assignment |
| **My Tasks** | Every task assigned to you, grouped by overdue / today / upcoming / done |
| **People** | Staff directory, search, role filter, profiles |
| **Finance** | Income/expense ledger, category breakdown, chart |
| **Attendance** | Check in / out, personal history, team view for managers |
| **Leave** | Request leave, manager approvals, status tracking |
| **Announcements** | Company feed (admins post, everyone reads) |
| **Notes** | Personal + shared notes |
| **Chat** | 1:1 messaging with on‑device notifications |
| **Notifications** | Persisted activity feed |

## Getting started

```bash
flutter pub get
flutter run
```

Firebase setup (rules deployment is required for anything to load/save) and
first‑admin bootstrap are in **[SETUP.md](SETUP.md)**.
Contributor notes are in **[CLAUDE.md](CLAUDE.md)**.

## Project layout

```
lib/
  core/       Db access, error type, RBAC, feedback  (no Flutter deps beyond material)
  modules/    auth, attendance, leave, announcements, notes, tasks, profile
  model/ service/ view/ view_model/ widget/   projects · people · finance · home · chat
firestore.rules · firestore.indexes.json · storage.rules
functions/    optional chat‑push Cloud Function (needs Blaze)
```
