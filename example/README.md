# Example app

Runs the whole kit against an in-memory fake backend (`lib/fake_backend.dart`).

## First run

This folder has only `lib/` and `pubspec.yaml`. Generate the platform folders once:

```bash
cd example
flutter create . --project-name example
flutter pub get
flutter run
```

## What to try

| Flow | How |
|---|---|
| Phone OTP | Any number of 8+ digits, code `123456` |
| Wrong OTP | Any other code shows the failure message |
| Resend timer | Wait 30s on the code step |
| Email sign-in | Any email, password 8+ chars; `wrongpass` fails |
| Email register | Tap "Create one"; `taken@example.com` fails |
| Theme | Settings -> Appearance -> Light / Dark / System |
| Profile | Edit the name and Save |
| Sign out | Profile or Settings -> Sign out |

To use a real backend, replace the two overrides in `main.dart` with your own
`AuthRepository` / `ProfileRepository` (see `../doc/supabase_adapter.md`).
