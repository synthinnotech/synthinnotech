# SynthInnoTech — Setup

Company management app (Flutter + Firebase). Runs entirely on the Firebase
**free (Spark)** plan.

## 1. Prerequisites

- Flutter 3.44+ (`flutter --version`)
- A Firebase project (this repo is wired to `synthinnotech-pvt`)
- Firebase CLI: `npm i -g firebase-tools` then `firebase login`

## 2. First run

```bash
flutter pub get
flutter run
```

If Firebase is reachable you'll see the sign-in screen. If it isn't configured
the app stays signed-out and every screen shows an empty state (there is **no**
mock/demo data).

## 3. Firebase configuration (once)

The app needs these enabled in the Firebase console for project
`synthinnotech-pvt`:

| Product | Where | Notes |
|---|---|---|
| **Authentication → Email/Password** | Authentication → Sign-in method | Required for login |
| **Cloud Firestore** | Firestore Database → Create database | Start in *production* mode — the rules below lock it down properly |
| Cloud Messaging | already enabled | for on-device notifications |

Then deploy the security rules and indexes from this repo:

```bash
firebase deploy --only firestore:rules,firestore:indexes
# optional, only if you use Cloud Storage for attachments later:
firebase deploy --only storage
```

> ⚠️ **This is the #1 cause of "nothing loads / nothing saves".** Until
> `firestore.rules` is deployed, a production-mode database denies every read
> and write, and the app will show empty lists and permission errors.

### Indexes

`firestore.indexes.json` covers the composite indexes the app needs (tasks by
project, notifications by user, leave by status, …). Queries also fall back to
client-side sorting, so a missing index degrades gracefully rather than hiding
data — but deploy them to avoid `failed-precondition` errors on larger data.

## 4. Create the first admin

There's no public sign-up. Bootstrap the first admin once:

1. In **Authentication → Users**, "Add user" with your email + a password.
2. In **Firestore**, create `users/<that-uid>` with at least:
   ```json
   { "name": "Your Name", "email": "you@company.com", "role": "admin", "is_active": true }
   ```
3. Sign in. From now on, **People → Add Member** creates staff logins for you
   (name, email, temporary password, role). Share the temp password; they
   change it from **Settings → Change Password**.

Roles: `admin` > `manager` > `employee` > `intern`. See
`lib/core/rbac/app_role.dart` and `firestore.rules` — the client and backend
use the same permission matrix.

## 5. Cloud Functions (optional — needs Blaze)

`functions/` contains one function that sends a push notification for chat
messages received while the app is backgrounded. Deploying **any** Cloud
Function requires the pay-as-you-go **Blaze** plan, so it's optional:

```bash
cd functions && npm install && cd ..
firebase deploy --only functions      # Blaze only
```

Without it, chat notifications still appear while the app is open (handled
client-side in `MainNavigationScreen`).

## 6. What lives where

```
lib/
  core/            data layer, errors, RBAC, feedback  (framework-agnostic)
  modules/
    auth/          sign in, register staff, forgot/change password, AuthGate
    attendance/    check in/out, history, team view
    leave/         requests + manager approvals
    announcements/ company feed (admin posts)
    notes/         personal + shared notes
    tasks/         "My Tasks" across all projects
    profile/       self-service profile editing
  model/ service/ view/ view_model/ widget/   original MVVM feature code
```

## 7. Free-plan notes

- Feature lists (people, projects, finance) use one-shot reads + pull-to-refresh
  to conserve the 50K reads/day quota. Only chat, notifications and
  announcements use live listeners.
- Notification fan-out for admin events is a client-side Firestore batch write
  (one doc per active user) — fine for small teams.
- No Cloud Storage is used; avatars are initials.
