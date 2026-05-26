# Notification system — testing playbook

How to actually verify the notification subsystem works on the running app.
Pairs with [NOTIFICATION.md](NOTIFICATION.md) (what the system is) — this file
is the "how do I exercise it" companion.

---

## Pre-flight

### Surfaces vs. what you need

| Surface | Works on | Needs |
|---|---|---|
| Inbox screen, bell badge, Preferences screen | iOS sim, web, Android, macOS | Just a running backend + logged-in user |
| OS-level banner / lock screen heads-up / cold-start deep link | **Android only** | `android/app/google-services.json` + `trip_wise_be/secrets/firebase-service-account.json` (both gitignored) |
| Without Firebase credentials | All platforms | Backend gracefully no-ops the push transport — inbox rows still appear, no banners |

**Bottom line:** you can test ~90% of the system on any device by watching the inbox + bell. The remaining 10% (OS banner, lock screen, killed-state deep link) needs a real Android emulator with Firebase wired up.

### Accounts you'll want

The system is per-user, so most flows need at least two accounts:

| Role | Why |
|---|---|
| **Customer** (USER / PLANNER role) | Books, plans trips, sends messages |
| **Provider** (PROVIDER role) | Receives booking / listing / payout notifications |
| **Admin** (ADMIN role) | Approves listings, applications, payouts, cancellation refunds |

Register accounts through the app's `/register` flow, then promote roles via Mongo if needed:

```js
// in mongosh
db.users.updateOne({ email: 'provider@test.dev' }, { $set: { role: 'PROVIDER' } })
db.users.updateOne({ email: 'admin@test.dev' }, { $set: { role: 'ADMIN' } })
```

For a provider account to receive notifications about a specific listing, the listing's `provider_id` must point at a Provider doc whose `user_id` is the provider's User `_id`. Easiest path: use the seeded `demoProviderId` and ensure `db.providers.findOne({_id: '51bbb04b-...'}).user_id` matches a real user's `_id`.

### Boot

```bash
# Backend
cd ~/Documents/trip_wise_be && npm run dev
# Watch for: "[scheduler] 3 jobs scheduled: ..."
# (If you see "[push] Firebase disabled ..." — that's OK; inbox still works.)

# Frontend
cd ~/Documents/trip_wise && flutter run -d <device>
```

### Get a bearer token for curl

Seeded users (`alex.thompson@tripwise.dev` etc.) have **no password** — bootstrap doesn't set one. Register a fresh test account once:

```bash
# One-time register (response already contains a token, so this also logs you in)
curl -X POST http://localhost:4000/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"fullName":"Test User","email":"test@tripwise.dev","password":"test1234"}'
```

Then for any subsequent shell session:

```bash
TOKEN=$(curl -s -X POST http://localhost:4000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@tripwise.dev","password":"test1234"}' \
  | jq -r .token)
echo "$TOKEN"   # sanity: should print a long string, not blank
```

`$TOKEN` is per-terminal. If `curl ... /test-push` returns `{"message":"Authentication required"}`, your token variable is empty (new tab, expired session, etc.) — re-run the login.

---

## 5-minute smoke test

Just enough to confirm the system is alive end-to-end. Do this every time you change something in the notification path.

1. **Log in** as any user.
2. From any top-bar bell icon, **tap the bell** → inbox opens.
3. From a separate terminal, fire a test push for that user:
   ```bash
   curl -X POST -H "Authorization: Bearer $TOKEN" \
     http://localhost:4000/api/devices/test-push
   ```
4. **Inbox should show** a fresh unread row "Test notification — If you see this as a banner, push is working. 🎉".
5. **Bell badge should show** a "1" without you navigating.
6. **Tap the inbox row** → should deep-link to `/notification_inbox` (the test action_route).
7. Pop back to the inbox. Row should be **read** (no bold, no dot).

Pass = all six checkpoints in under five minutes. Fail any → check `flutter run` logs and backend stdout.

---

## Full test pass

Group A through G. Each section can run independently; do them all on a release pass.

### A. Inbox + bell basics (~5 min)

| Test | Expected |
|---|---|
| Open inbox on a brand-new user | Empty state: "You're all caught up" + bell-off icon |
| Fire `test-push` 15 times in a row | All 15 land. Header shows "(15)". Bell shows "15". |
| Scroll past 12 rows | Auto-loads next page via cursor pagination (no duplicates, no skips). Watch for a brief spinner. |
| Pull to refresh | First page reloads. Counts update. |
| Tap "Mark all read" | All rows go from bold→normal, dots disappear, header shows "0 unread", bell badge vanishes. |
| Tap an unread row | Row goes read immediately (optimistic). Server is synced in the background. Deep-link follows. |
| Bell badge cap | Once `unread > 99`, badge shows "99+". |

### B. Deep-link routing (~5 min, Android needed for the tray-tap path)

| Test | Expected |
|---|---|
| Inbox row tap with `actionRoute = /wallet_loyalty` | App navigates (replace-semantics) to wallet. |
| Inbox row tap with `actionRoute = null` | Tap marks the row read; no navigation. |
| Inbox row tap with `actionRoute = "evil.example.com"` (manually insert into Mongo) | Tap marks read; **no navigation** — the `startsWith('/')` check rejects it. |
| Foreground push tap (Android) | Banner appears → tap → app jumps to the `action_route`. |
| Cold-start push tap (Android) | App fully closed. Tap a notification in the tray → app launches and lands on the deep-link target (the `_pendingDeepLink` buffer in `main.dart` flushes after first frame). |

### C. Preferences screen (~3 min)

| Test | Expected |
|---|---|
| Open `/notifications` (the settings, not the inbox) | Push toggle + 4 category toggles (Trip Reminders, Booking Updates, Messages, Promotions). **Email toggle is gone.** |
| Toggle Push off → Save | "Preferences saved" snackbar. |
| With Push off, fire `test-push` | Inbox row appears (badge goes to 1) — **no OS banner**. |
| Toggle "Messages" off → Save → send a chat message from another user → check inbox | Inbox row still written (always). On Android, **no push banner**. |
| (Android 13+) Deny notification permission at the OS level → reopen the Preferences screen | Red "Notifications blocked" banner above the Push toggle. Push toggle disabled. Subtitle says "Blocked at the system level — see banner above". |

### D. Per-user scoping (~5 min)

| Test | Expected |
|---|---|
| Log in as user A → fire `test-push` → see badge | Badge increments for A. |
| Log out → log in as user B (same device) | Badge resets to B's count. A's notifications are NOT visible. |
| Log out user B | On Android, the device's FCM token is unregistered (`DELETE /api/devices`). Subsequent pushes to B don't land on this device. |
| User A logs back in | Token re-registers under A. A's pushes land again. |
| In Mongo: `db.notifications.find({user_id: '<A>'}).count()` vs the inbox `total` | They match. |

### E. All event triggers — verify each in turn

Each row below is one notification trigger. The "How to fire" column is the minimum reproducible step on the running app. Recipients are who should see the inbox row.

| Trigger | How to fire | Recipient | Inbox title |
|---|---|---|---|
| `wallet.topUp` | Wallet & Loyalty → Top up → submit | actor | "Top-up successful" |
| `wallet.withdraw` | Wallet & Loyalty → Withdraw → submit | actor | "Withdrawal complete" |
| `trips.createTrip` | Trip planner → New trip → save | actor | "Trip created" |
| `trips.addTripItem` | Trip planner → add an activity | actor | "Activity added to your trip" |
| `checkout.submitCheckout` (customer-side) | Service details → Book now → checkout | actor | "Booking request received" |
| `checkout.submitCheckout` (**provider-side**) | Same checkout → log in as the listing's provider | listing provider | "New booking request" |
| `orders.updateOrderStatus` | As provider in Order Manager, change status → log in as the booking owner | **booking owner** (fixed) | "Booking {STATUS}" |
| `myTrips.requestCancellation` | My Trips → tap booking → Cancel | actor | "Cancellation request sent" |
| `adminCancellations.review` (reject) | Admin → Refunds → Reject | booking owner | "Cancellation request rejected" |
| `adminCancellations.review` (approve) | Admin → Refunds → Approve | booking owner | "Cancellation approved" |
| `adminListings.review` (approve) | Admin → Listing approvals → Approve | provider | "Listing approved" |
| `adminListings.review` (reject) | Admin → Listing approvals → Reject (with reason) | provider | "Listing rejected" |
| `providerApplications.review` (approve) | Admin → Provider approvals → Approve | applicant | "You're now a provider on Tripwise" |
| `providerApplications.review` (reject) | Admin → Provider approvals → Reject | applicant | "Provider application not approved" |
| `adminPayouts.payProviderForPeriod` | Admin → Provider payouts → Pay | provider | "Payout received" |
| `providerVip.upgradeToElite` | VIP services → upgrade to Elite | actor | "Elite plan activated" |
| `directMessages.sendMessage` | Direct messaging → send a message | every non-sender participant | conversation title |
| `devices.testPushHandler` | `curl POST /api/devices/test-push` | actor | "Test notification" |

That's 18 distinct event paths. After each one, check both:
- `GET /api/notifications/summary` shows the expected `unreadCount`
- The inbox screen shows the new row at the top

### F. Scheduler jobs (~3 min)

The three cron jobs run on a wall-clock (`18:00`, `09:00`, `10:00` server-local). Don't wait — fire manually via the dev helper.

```bash
# Set up: trip with start_date == tomorrow's YYYY-MM-DD (UTC)
# Easiest: create a trip via the planner with that date, or:
TOMORROW=$(date -u -v+1d +%Y-%m-%d)  # macOS
# TOMORROW=$(date -u -d "+1 day" +%Y-%m-%d)  # Linux
mongosh tripwise_db --eval "db.trips.updateOne({_id: 'trip-XXX'}, {\$set: {start_date: '$TOMORROW'}})"

# Fire the job
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/scheduler/run/trip-1d
# → { "ok": true, "job": "trip-1d" }

# Check that user's inbox
curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/api/notifications | jq '.items[0]'
# → "Your trip starts tomorrow"
```

Repeat for:
- `trip-7d` — needs a trip with `start_date == today + 7 days`
- `review` — needs a trip with `end_date == today - 3 days` AND `status: 'COMPLETED'`

**Idempotency check:** call the same job twice. The second call returns `{ok: true}` but creates **zero** new inbox rows — the deterministic id (`reminder-trip-start-1d-<tripId>-<ymd>`) makes the duplicate insert a no-op via the E11000 swallow path.

### G. Foreground live-update of the bell (Android only) (~1 min)

Pre-fix: the bell badge only refreshed on mount and on inbox-pop. Now it should bump immediately on foreground push.

1. On an Android emulator with Firebase configured, log in.
2. Navigate to any screen that shows the bell (Home, Trip Planner, Service Details).
3. From a second terminal: `curl -X POST -H "Authorization: Bearer $TOKEN" http://localhost:4000/api/devices/test-push`
4. **Watch:** the badge increments without you navigating, within ~1s. OS banner appears too.
5. Background the app, fire `test-push` again, foreground the app → `didChangeAppLifecycleState(resumed)` triggers a refetch — badge catches up.

---

## Edge cases worth poking at

| Case | How to provoke | Expected |
|---|---|---|
| Optimistic mark-read **rollback on server failure** | Kill backend → tap an unread row in the inbox → row goes read locally → backend stays down a few seconds → ... | After the silent retry fails, the row rolls back to unread and the count restores. |
| Client-side time label aging | Fire `test-push`. Inbox shows "Just now". Leave the screen open for 60+ seconds. | Label flips to "1m ago" without any refetch (Timer.periodic). |
| Pagination stability under concurrent inserts | Open the inbox at page 1. From curl, insert ~15 new notifications. Scroll down to load page 2. | No duplicates, no skips — cursor (`before=<createdAt>`) is anchored to the oldest row of page 1. |
| Category gate keeps inbox but suppresses push | Toggle "Promotions" off. (No promo trigger exists in code yet, so use the type override below.) | Inbox row written; no push banner on Android. |
| Push permission denied | On Android emulator, deny POST_NOTIFICATIONS at the OS prompt. Reopen Preferences. | Red "blocked" banner; Push toggle disabled. |
| Auth token expired mid-session | Wait past the session TTL (or delete the AuthSession in Mongo). | Next API call 401s → unauthorized interceptor → app bounces to `/register`. |
| Cold-start deep link buffer | Android emulator, kill app, fire a push targeting `/wallet_loyalty`, tap the tray notification. | App launches → lands on Wallet (not the default `/home`), because `_pendingDeepLink` flushed after first frame. |

---

## Tooling reference

### Bearer token

```bash
TOKEN=$(curl -s -X POST http://localhost:4000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@test.dev","password":"yourpass"}' | jq -r .token)
```

### Inbox & summary

```bash
# Full feed (latest 10)
curl -H "Authorization: Bearer $TOKEN" \
  'http://localhost:4000/api/notifications?limit=10'

# Just the badge counts
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/notifications/summary

# Mark one read
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/notifications/<id>/read

# Mark all read
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/notifications/read-all
```

### Preferences

```bash
# Read
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/notifications/preferences

# Update
curl -X PUT -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"push":true,"promotions":false}' \
  http://localhost:4000/api/notifications/preferences
```

### Debug helpers (NODE_ENV != production)

```bash
# Force a SYSTEM push to yourself
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/devices/test-push

# Run a scheduler job now
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://localhost:4000/api/scheduler/run/trip-1d    # or trip-7d, review
```

### Inspect a user's notifications in Mongo

```js
db.notifications.find({ user_id: '<user_id>' }).sort({ created_at: -1 }).limit(20).pretty()
db.notification_preferences.findOne({ _id: '<user_id>' })
db.device_tokens.find({ user_id: '<user_id>' })
```

---

## Known limitations

- **No automated tests.** `test/widget_test.dart` is still the Flutter counter-app template; running `flutter test` is meaningless until it's rewritten.
- **iOS / web push: no OS banners.** The inbox + bell still work; the foreground push stream is empty so the bell won't live-update from a tray tap. Tested via `flutter run -d chrome` or iOS sim verifies inbox UX only.
- **Scheduler wall-clock testing is impractical.** Use the `/api/scheduler/run/:job` helper. If you need to verify the cron string itself fires at the right time, edit the cron expression in `scheduler.service.ts` to `*/2 * * * *` temporarily.
- **Single-process scheduler.** If the backend ever runs more than one instance, every instance fires the cron — deterministic ids dedupe the inbox row, but real-money side effects of any future scheduled action would double-fire. Don't add side effects to scheduler jobs without a leader-election mechanism.
- **Provider account setup is manual.** Promoting a user to PROVIDER via Mongo + linking `Provider.user_id` correctly is the most common source of "why isn't this provider getting the notification" confusion. Check `db.providers.findOne({_id: <providerId>}).user_id` matches a real user.
