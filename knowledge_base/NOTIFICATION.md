# Notifications

The notification subsystem has **three surfaces** that you should keep separate in your head:

1. **In-app inbox + preferences** (HTTP, all platforms) — list, read state, settings.
2. **In-app banner** (all platforms) — a styled overlay shown *inside* the app when a notification arrives while the app is foregrounded.
3. **OS tray push** (FCM, Android only) — system notifications shown when the app is **backgrounded or killed**.

They share one concept: an `action_route` string that is a GoRouter path the user is sent to when they tap a notification (inbox row, in-app banner, or tray notification).

---

## ⭐ CURRENT ARCHITECTURE (updated 2026-05-31) — read this first

The detailed sections below were written against an earlier version and have **drifted**. Where they conflict, this section wins. What actually happens today:

### Foreground vs background — the key change
- **Foreground (app open): we do NOT render an OS tray notification.** Instead `FirebaseMessaging.onMessage` just emits an `IncomingPushPayload` on `PushMessagingService.onForegroundPush` (`push_messaging_service.dart:203`). `main.dart` listens and shows a **styled in-app banner** (`in_app_push_banner.dart`) so the user isn't hit by a system heads-up while actively using the app.
- **Background / killed:** unchanged — `firebaseMessagingBackgroundHandler` (separate isolate) still renders the **OS tray** notification.

### In-app banner works on every platform (polling fallback)
- FCM foreground push only fires on Android. To make the banner work on **iOS/web/Android-without-a-live-push**, `NotificationAlertService` (`notification_alert_service.dart`) **polls `/notifications` every 20 s** while authenticated and emits any row it hasn't seen before on `onNewNotification`.
- `main.dart` listens to **both** sources (`onForegroundPush` + `onNewNotification`) and **dedupes by notification id** (`_banneredIds`) so the same notification never banners twice.
- First poll only records a **baseline** (existing inbox) — it does NOT banner the backlog. Only notifications arriving after start pop.
- Poller is started/stopped by auth state (`_syncPollerToAuth`) and `pollNow()` is called on app resume for snappy feedback.

### Tapping anything = mark read
- Tapping the **in-app banner**, an **inbox row**, or an **OS tray notification** all mark the notification read (tap = engagement) and then deep-link. Tray taps carry both the route *and* the id (payload is JSON `{route, id}`, see `_showLocal` / `_decodeTapPayload`) precisely so the tap can mark-read, not just navigate.
- Merely *showing* a banner does NOT mark read.

### The bell badge is now live (old bug #4 fixed)
- `NotificationBellButton` (`shared_top_bars.dart`) subscribes to `PushMessagingService.onForegroundPush` (new push) and `NotificationAlertService.onChanged` (a read happened elsewhere) and refreshes on app resume. The badge updates without navigating.

### Pagination is now cursor-based (old bug #5 fixed)
- `NotificationApi.fetchFeed({limit, before})` uses a **`before` cursor**, not `offset`. `NotificationPage` carries `nextCursor`/`hasMore`. This avoids the duplicate/skip races offset pagination had.

### Blocked-permission surface now exists (old bug #6 partially fixed)
- `PushMessagingService.isPushBlocked()` reads `getNotificationSettings()`; the Preferences screen uses it to show a "blocked at the system level" banner. (Earlier text saying "no UI surface exists" is outdated.)

### Per-category channels + collapse keys (added 2026-05-31)
- **Multiple Android channels**, one per mutable preference category, replace the old single `tripwise_default` channel. Defined in `push_messaging_service.dart`: `tripwise_transactions` (Bookings & payments), `tripwise_chats` (Messages), `tripwise_trips` (Trip reminders), `tripwise_promos` (Promotions, `defaultImportance` so no heads-up). `_channelForType(type)` maps the server `type` → channel (MESSAGE→chats, TRIP→trips, PROMO→promos, BOOKING/SYSTEM/unknown→transactions), mirroring `notifications.service.ts` `TYPE_TO_PREF` so OS-level mute matches the in-app toggles. `_registerChannels()` creates all four **and deletes** the legacy `tripwise_default` so it stops appearing in system settings. Channel ids are permanent on-device — migrate, never rename.
- **Collapse keys / grouping**: the server payload now carries an optional `collapse_key`. `createNotification({collapseKey})` → `PushPayload.collapseKey` → both `android.collapseKey` (FCM offline-collapse) and a `collapse_key` field in `data`. The client (`_showLocal`) uses it as a stable tray id **and** Android `tag` so a newer notification with the same key replaces the previous one instead of stacking; without a key each notification keeps a unique id (original behaviour). `groupKey` is set to the channel id so same-channel rows stack under one summary. **`directMessages.sendMessage` passes `collapseKey: 'msg:<conversationId>'`** — a burst of chat messages in one thread collapses to a single latest row. (Replaces the old "No grouping/threading" gap for the tray; the inbox list still shows every row.)

### Top-up / withdraw UX (changed 2026-05-31)
- `wallet_loyalty_screen.dart` no longer shows the bottom "Top-up successful." / "Withdrawal successful." snackbar. The balance updates inline via `setState`, and on success it calls `NotificationAlertService.pollNow()` so the server-created notification surfaces as the **in-app banner immediately** rather than on the next 20 s poll tick. (The `_showWalletFlowNotice` helper is still used for the "Add a payment card first." validation notice.)

### Quick source map (current)
| Concern | File |
|---|---|
| FCM init, foreground stream, tray render, permission, token | `lib/services/push_messaging_service.dart` |
| Cross-platform polling fallback + `onChanged` signal | `lib/services/notification_alert_service.dart` |
| In-app banner overlay | `lib/widgets/in_app_push_banner.dart` |
| HTTP API (feed/summary/read/prefs) | `lib/services/notifications_api.dart` |
| App-level wiring (banner dedupe, deep link, tap→read) | `lib/main.dart` |
| Inbox list / preferences screens | `lib/screens/notification_inbox_screen.dart` / `notifications_screen.dart` |
| Bell + badge | `lib/widgets/shared_top_bars.dart` (`NotificationBellButton`) |
| Device token registration | `lib/services/devices_api.dart` |

> Everything below is the original deep dive. Still useful for the inbox/prefs,
> the backend trigger map, preference enforcement, and the **still-open backend
> bugs** (#1 demo-user recipient, #2 preference categories not enforced, etc.).
> Just mentally apply the corrections above to the client-side push details.

---

## 1. In-app inbox + preferences

### UI screens

- `lib/screens/notification_inbox_screen.dart` — the inbox list at route `/notification_inbox`.
  - Paginated via offset/limit (`_pageSize = 12`), infinite scroll triggers when within 400px of the bottom.
  - Pull-to-refresh resets offset to 0.
  - Header shows `All notifications (total) • N unread`.
  - "Mark all read" button in the AppBar (only when `_unreadCount > 0`).
  - Settings cog (top-right) → navigates to `/notifications` (the preferences screen).
  - Tapping a row: **optimistically** marks it read locally, then fires `markRead(id)` in the background via `unawaited(...)`. Then `context.push(actionRoute)` if it exists.
  - Empty state: `notifications_off_rounded` icon + "You're all caught up".
- `lib/screens/notifications_screen.dart` — the **preferences** screen at route `/notifications`.
  - Loads `NotificationPreferences` once, edits in local state, persists on "Save Preferences" button.
  - Sections: Notification Channels (Push, Email) → Trip & Travel (Trip Reminders, Booking Updates) → Social & Messages (Messages, Promotions).
  - Note the route naming is confusing: `/notifications` is **settings**, `/notification_inbox` is the **list**. Don't swap them.

### Shared widget

- `lib/widgets/notification_tile.dart` — `NotificationTile`.
  - Renders `AppNotification`, picking icon + colors from `notification.type`:
    - `BOOKING` → ticket icon, primary palette
    - `TRIP` → luggage icon, tertiary palette
    - `MESSAGE` / `PROMO` → chat / tag, secondary palette
    - `SYSTEM` (default) → info, neutral surface
  - Unread state: light primary tint background + bolder title + small dot on the right.

### Models — `lib/models/notification_feed.dart`

- `AppNotification`: `id, type, title, body, read, actionRoute, createdAt, timeLabel`.
  - `type` is a string enum (string, not Dart `enum`): `BOOKING | TRIP | MESSAGE | PROMO | SYSTEM`.
  - `timeLabel` is **pre-formatted by the server** (e.g. `"2h ago"`, `"Yesterday"`, `"May 12"`). The client does **not** format dates — keep it that way.
  - `actionRoute` is nullable; an in-app GoRouter path when present.
- `NotificationPage`: pagination envelope — `items, total, unreadCount, hasMore, nextOffset`.
- `NotificationSummary`: `unreadCount, total` (returned by mutation endpoints so the badge updates without a refetch).
- `NotificationPreferences`: 6 booleans — `push, email, tripReminders, bookingUpdates, messages, promotions`. Defaults: all true except `promotions`.

### API client — `lib/services/notifications_api.dart`

All under `/notifications` on the backend:

| Method | Path | Returns |
|---|---|---|
| GET | `/notifications?limit=&offset=` | `NotificationPage` |
| GET | `/notifications/summary` | `NotificationSummary` (for badge polling) |
| POST | `/notifications/:id/read` | `NotificationSummary` |
| POST | `/notifications/read-all` | `NotificationSummary` |
| GET | `/notifications/preferences` | `NotificationPreferences` |
| PUT | `/notifications/preferences` | `NotificationPreferences` (echo of saved state) |

Errors: `NotificationApiException` — surfaces the server's `message` field directly to the UI (mirrors `WalletApiException`).

---

## 2. Push delivery (FCM, Android-only)

### Why "Android-only"

`PushMessagingService.isSupported` returns true only when `!kIsWeb && Platform == android`. iOS and web are **intentionally out of scope** — see the comment at the top of `lib/services/push_messaging_service.dart`. All push code is a no-op on other platforms.

### Why "data-only" messages

The backend sends FCM **data messages** (not notification messages). Keys: `type, title, body, action_route, notification_id`. Reason:

- Foreground: Android does not auto-display data messages — we render them ourselves via `flutter_local_notifications`. This gives a consistent look in every app state.
- We always have the `action_route` to deep-link from, regardless of state.

### Files

- `lib/services/push_messaging_service.dart`
  - `AndroidNotificationChannel('tripwise_default', ...)` — single channel for all notifications.
  - `firebaseMessagingBackgroundHandler` (top-level, `@pragma('vm:entry-point')`) — runs in a **separate isolate** when the app is killed/backgrounded; must reinitialize Firebase + the local-notifications plugin itself.
  - `PushMessagingService.initialize({onDeepLink})`:
    1. Initializes Firebase if not already.
    2. Initializes `flutter_local_notifications` and creates the channel.
    3. Registers the background handler.
    4. Requests POST_NOTIFICATIONS permission (Android 13+) — denial is fine, app keeps working.
    5. Subscribes to `onMessage` (foreground) → renders a local notification.
    6. Subscribes to `onMessageOpenedApp` (tap while backgrounded) → calls `onDeepLink(action_route)`.
    7. Checks `getInitialMessage` (tap that cold-started the app) → calls `onDeepLink`.
  - `getToken()` and `onTokenRefresh` — used by auth/device registration.
- `lib/services/devices_api.dart` — `DeviceApi.registerToken(token, platform: 'android')` POSTs to `/devices`; `unregisterToken` DELETEs. Both are **best-effort** — failures are swallowed (logged in debug) so push problems never crash app start or sign-in flow.

### Wiring in `lib/main.dart`

- `rootNavigatorKey` (line ~49) lets `handleDeepLink` navigate from outside the widget tree.
- `_pendingDeepLink` (line 87) buffers a deep link that arrives **before** the router exists (cold start from a killed-state tap); flushed in `MyApp.build`'s first post-frame callback (~line 443).
- `handleDeepLink(route)` (line 109): rejects anything that doesn't start with `/` (action_route safety — server can't deep-link arbitrary URLs). Uses `_router.go(route)` (not `push`) so the tap lands the user **on** the target, not stacked on top of whatever was open.
- Push init runs **after** `runApp` (line 425):
  - `runApp` first → UI is responsive, router is mounted, pending deep link can flush.
  - Then `PushMessagingService.initialize(onDeepLink: handleDeepLink)`.
  - Then `_authSessionStore.syncPushToken()` registers the current token with `/devices`.
  - `onTokenRefresh` → re-register, but **only if authenticated** (avoids leaking a token for a signed-out device).
- `AuthSessionStore.syncPushToken()` (lines 149–154 in `auth_session_store.dart`) is called from multiple places: login, register, restore. `unregisterToken` is called on sign-out (~line 219) — so signing out severs push delivery on that device.

### Routes registered (in `main.dart`)

- `/notifications` → `NotificationsScreen` (preferences) — line 337
- `/notification_inbox` → `NotificationInboxScreen` (the list) — line 341

---

## Status (deep dive, snapshot 2026-05-26)

### 1. User ownership / auth scoping — ✅ now real

Earlier the system was pinned to `env.demoUserId` (no login). That changed when auth landed. As of 2026-05-26:

- `src/routes/index.ts:42` mounts `router.use('/notifications', requireAuth, notificationsRoutes)`. Same for `/devices`. `requireAuth` (in `src/middlewares/auth.ts`) reads `Authorization: Bearer <token>`, resolves it via `resolveAuthToken`, and populates `req.auth.userId` — or 401s.
- Every notifications/devices controller uses `req.auth!.userId`. So **inbox rows, unread counts, preferences, and device-token registrations are all per-authenticated-user.**
- `NotificationPreference._id === user_id` (one doc per user, idempotent `ensureDefaultPreferences`). `Notification.user_id` scopes the feed. `DeviceToken._id === FCM token` with `user_id` foreign key — re-registering the same physical device under a different account reassigns ownership cleanly.
- Frontend lifecycle (`lib/services/auth_session_store.dart`):
  - On login / register / restore-from-storage → `syncPushToken()` registers the current FCM token under the now-authenticated user (line 149).
  - On logout → `_unregisterPushToken()` DELETEs the token (line 215) so push to that device stops. Then `ApiClient.setAuthToken(null)`.
  - `_authSessionStore` is `Listenable` and feeds GoRouter's redirect — unauthenticated users get bounced to `/register`.
- **Stale comments to ignore** (the code is correct, the comments lag):
  - `src/services/notifications.service.ts:6-7` says *"No auth yet — pin the demo user"*. False — the service takes `userId` from the controller, which gets it from `req.auth`.
  - `src/services/devices.service.ts:5` says *"Scoped to env.demoUserId (no auth yet)"*. Same — `userId` is now passed in.
  - Worth scrubbing these on the next pass.
- **Real bug**: `src/services/orders.service.ts:475` — when a provider changes a booking's order status, the notification's `userId` is **hardcoded to `env.demoUserId`** instead of the real booking owner (`booking.user_id`). The inline comment explains why the agent did it (*"In this no-auth prototype the inbox is pinned to env.demoUserId"*) — but auth has since landed, so the comment is wrong AND the code is wrong. Real users won't get their booking-status notifications. This needs a fix: look up `booking.user_id` from the BookingItem → Booking and notify that user.

### 2. Notification surface coverage

What "kind of notification" is actually wired vs. not:

| Surface | Status | Where |
|---|---|---|
| **In-app inbox screen** (list / feed) | ✅ Wired | `lib/screens/notification_inbox_screen.dart` at route `/notification_inbox` |
| **In-app bell + unread badge** on top bars | ✅ Wired | `NotificationBellButton` in `lib/widgets/shared_top_bars.dart:163`. Self-contained — fetches `/notifications/summary` on mount and again after the inbox is popped (so reads there refresh the badge). Used in two top-bar variants (lines 109, 126). Renders count up to "99+". |
| **In-app preferences screen** | ✅ Wired | `lib/screens/notifications_screen.dart` at route `/notifications` |
| **Push: foreground banner** (app open) | ✅ Wired (Android) | `FirebaseMessaging.onMessage` → `_showLocal()` renders a local notification (data-only payload, so Android won't auto-display — we do). |
| **Push: background banner** (app backgrounded) | ✅ Wired (Android) | `firebaseMessagingBackgroundHandler` runs in a separate isolate, reinits Firebase + plugin, calls `_showLocal()`. |
| **Push: heads-up / lock screen** | ✅ (Android, implicit) | `AndroidNotificationDetails(importance: high, priority: high)` triggers heads-up + lockscreen visibility (Android default for `Importance.high`). No explicit `visibility:` setting — uses platform default. |
| **Push: cold-start tap → deep link** | ✅ Wired | `FirebaseMessaging.getInitialMessage()` at init. |
| **OS badge** (app icon dot) | ⚠️ Not configured | We don't set a number badge on the launcher icon. Android launchers vary; some show a dot automatically for unread channels, but we don't drive it explicitly. iOS would need `APNs badge` — out of scope. |
| **In-app overlay/toast** when push arrives while app is open | ⚠️ Indirect | We do *not* render a custom in-app snackbar/toast — we render an Android system tray notification even when foreground. So you see the OS heads-up banner, not a styled in-app card. |
| **iOS push** | ❌ Intentionally out of scope | `PushMessagingService._supported` returns `false` on iOS. No APNs cert, no `flutter_local_notifications` iOS config. |
| **Web push** | ❌ Intentionally out of scope | Same `_supported` guard rules it out; no Service Worker. |
| **Email** | ❌ Not wired | Preference flag exists (`prefs.email`), saved, but no email transport sends anything. Purely cosmetic. |
| **SMS** | ❌ Not in the system | |
| **Scheduled / local-only reminders** (e.g. "Your trip starts tomorrow") | ❌ Not implemented | The `tripReminders` pref exists, but no scheduler / cron / `flutter_local_notifications.zonedSchedule` driving it. |
| **Marketing / promotional pushes** | ❌ No transport | `promotions` pref exists (off by default); no campaign tooling. |

### 3. Notification trigger map (what causes a notification)

Every server-side event that calls `createNotification()`:

| Trigger (service.method) | type | title | actionRoute | Recipient |
|---|---|---|---|---|
| `wallet.topUp` | SYSTEM | "Top-up successful" | `/wallet_loyalty` | actor |
| `wallet.withdraw` | SYSTEM | "Withdrawal complete" | `/wallet_transactions` | actor |
| `trips.createTrip` | TRIP | "Trip created" | `/trip_planner_timeline?id=...` | actor |
| `trips.addTripItem` | TRIP | "Activity added to your trip" | `/trip_planner_timeline?id=...` | actor |
| `myTrips.requestCancellation` | BOOKING | "Cancellation request sent" | `/my_trips?status=upcoming` | actor |
| `checkout.submitCheckout` | BOOKING | "Booking request received" | `/payment_success?bookingId=...&paymentId=...` | actor |
| `orders.updateOrderStatus` | BOOKING | "Booking {STATUS}" | `/my_trips` | ⚠️ **`env.demoUserId` (BUG)** — should be the booking owner |
| `directMessages.sendMessage` | MESSAGE | conversation title (or "New message") | `/direct_messaging?conversationId=...` | every recipient except sender |
| `providerVip.upgradeToElite` | SYSTEM | "Elite plan activated" | `/vip_services` | actor |
| `adminCancellations.review` (reject) | BOOKING | "Cancellation request rejected" | `/my_trips?status=upcoming` | booking owner (correct — uses `booking.user_id`) |
| `adminCancellations.review` (approve) | BOOKING | "Cancellation approved" | `/wallet_loyalty` | booking owner |
| `devices.testPushHandler` (POST `/devices/test-push`) | SYSTEM | "Test notification" | `/notification_inbox` | actor (debug helper) |

#### Coverage gaps (what's missing — analysis 2026-05-26)

**Email transport: not implemented at all.** No SMTP/Sendgrid/Resend/etc. dep, no `sendEmail` function, no template system. `prefs.email` is persisted but never read. Either build it or strip the flag.

**No scheduler / background worker.** No `node-cron`, `agenda`, `bull`, or equivalent. Every notification today is fired synchronously off a request handler. Several preference flags assume a scheduler exists (notably `tripReminders`) — the flags are vestigial without it.

**High-value, low-cost gaps** (event already happens in code; just no `createNotification` call):
- **Provider notified on new booking** — `checkout.service.ts:446` notifies the customer but not `listing.providerId`. Combined with the existing `orders.updateOrderStatus`, this means providers have no signal that an order arrived.
- **Failed top-up / withdraw / payment / checkout** — success paths notify, failure paths are silent.
- **Listing approved/rejected** — admin reviews listings; the provider whose listing was reviewed isn't told.
- **Provider application approved/rejected** — same pattern.
- **Profile verification approved/rejected** — the verification screen exists; result doesn't flow back.

**High-value, needs-new-infra gaps** (scheduled jobs):
- **Trip starts tomorrow / today** — the entire reason `tripReminders` exists. Today the flag does nothing.
- **Activity starting in 1 hour** — timeline items have a `time` field, perfect signal.
- **Cancellation deadline approaching** — `BookingItem.cancellation_deadline` exists; users can silently lose refund eligibility.
- **"How was your stay? Leave a review"** — drives review volume, fires N days after trip completion.

A single `node-cron` setup + a `scheduler.service.ts` would unlock all four. Maybe ~100 lines.

**Medium-value gaps**:
- Welcome notif on register
- VIP plan expiry / downgrade (today only the upgrade notifies)
- Payout request approved / paid (provider finance flow exists; no notif)
- Daily provider summary ("3 new bookings yesterday")

**Account/security gaps** — these typically use email as the primary channel, so they're blocked on the missing email transport:
- Email verification (no flow at all)
- Password reset (no flow at all)
- New-device login alert
- Password-changed confirmation
- Suspicious-activity alert

**Marketing / re-engagement** — the `promotions` flag has no consumer. Needs campaign tooling (author + target + schedule), not just a transport. Out of scope for the prototype:
- Promotional pushes
- Abandoned-checkout reminder
- Personalized recommendations
- Re-engagement after N days inactive

**The four most embarrassing gaps right now**:
1. Providers receive no notifications at all for actions they need to react to (new bookings, listing approvals, payouts).
2. `tripReminders` preference is a lie — toggling it does nothing because no scheduler runs.
3. Failure paths are silent — only successes notify.
4. `prefs.email` is dead weight — no email transport exists.

### 4. Preference enforcement — ⚠️ partial

In `createNotification` (`notifications.service.ts:241`):

```ts
const prefs = await ensureDefaultPreferences(userId);
if (!prefs.push) return;       // ← only this gate runs
await sendPushToUser(userId, ...);
```

- ✅ **`prefs.push`** gates the FCM transport. If the user turns Push off, the inbox row is still inserted, but no banner is sent.
- ❌ **`prefs.email`** is saved but never read by code (no email transport exists).
- ❌ **`prefs.tripReminders` / `bookingUpdates` / `messages` / `promotions`** are saved but **never consulted** when creating a notification. The toggles on the Preferences screen are decorative — turning "Promotions & Offers" off does nothing to suppress a future promo notification (there's no promo trigger anyway, so the user doesn't notice today). Real category gating would need a switch on `input.type` inside `createNotification` mapping each type to a flag.

Also: the inbox row is **always** written, regardless of any preference. The `push` flag gates only the transport. This is intentional (matches the comment at `notifications.service.ts:261-262`) — your inbox doesn't go silent if you disable banners. Worth understanding before changing it.

### 5. Deep-link handling (end-to-end)

`actionRoute` is a server-decided GoRouter path that travels with the notification. Three deep-link entry points all funnel through the same handler:

```
foreground tap  → flutter_local_notifications onDidReceiveNotificationResponse (payload = action_route)
                                                                                       │
backgrounded   → FirebaseMessaging.onMessageOpenedApp (m.data['action_route'])         │
                                                                                       ├──→ handleDeepLink(route) in main.dart:112
cold-start tap → FirebaseMessaging.getInitialMessage() (m.data['action_route'])        │
                                                                                       │
inbox row tap  → context.push(route) directly                                          ←── NOT routed through handleDeepLink
```

Validation in `handleDeepLink` (`lib/main.dart:112`):
- Rejects null, empty, or any string that does **not** start with `/`. This is the **action_route safety net**: the server can't push an `http://attacker.com` deep link.
- If the router isn't mounted yet (cold start from killed state), the route is buffered in `_pendingDeepLink` (line 87) and flushed in `MyApp.build`'s first post-frame callback (~line 443).
- Uses `_router.go(route)` (replaces stack) — so the tap lands the user **on** the target, not stacked on whatever they were on.

⚠️ **Inconsistency**: the **inbox-row** tap uses `context.push(actionRoute)` (`notification_inbox_screen.dart:126`) instead of `handleDeepLink`. Consequences:
- It stacks instead of replacing.
- It does **not** apply the `startsWith('/')` safety check. Today the server only ever sets in-app paths, so it doesn't bite — but if a malformed `actionRoute` ever slipped through, it would. Easy fix: route the tap through `handleDeepLink` too.

URL-encoded query params (e.g. `/direct_messaging?conversationId=...`) are passed through verbatim. Target screens parse them off `state.uri.queryParameters`.

### 6. Permission handling

- **Android 13+ runtime permission** (`POST_NOTIFICATIONS`): asked once on first `PushMessagingService.initialize()` via `FirebaseMessaging.instance.requestPermission()` (`push_messaging_service.dart:102`).
- **Denial behavior**: silent. The app keeps working; FCM tokens still register; the inbox + bell still update; but banners just won't appear. There is **no UI surface** telling the user "you denied notifications, here's how to re-enable them" — no deep-link to system settings, no preference-screen warning banner, nothing.
- **Pre-Android-13**: the permission is implicit (granted at install); the runtime call is a no-op.
- **iOS / web**: never asked — `_supported` short-circuits the entire init.
- **Channels**: a single Android channel, `tripwise_default` (Importance.high) for everything. Users can't separately mute booking vs. promo vs. message at the OS level. Multi-channel split would be a future change if you want OS-level granular control.
- **Token refresh**: subscribed in `main.dart:430` — if FCM rotates the token, we re-register it under the current user (only when authenticated).
- **Service-account absence**: backend gracefully degrades. `src/config/firebase.ts:50` exports `isFirebaseEnabled = false` when no `secrets/firebase-service-account.json` is present, logs a one-time `[push] Firebase disabled — push is a no-op`, and **never throws**. The inbox keeps working in that mode; only the banner doesn't show up.

### 7. Known bug list (consolidated 2026-05-26)

Ordered by severity. The first three are confirmed bugs; the rest are edge cases / latent issues.

| # | Severity | Location | Summary |
|---|---|---|---|
| 1 | 🔴 high | `trip_wise_be/src/services/orders.service.ts:475` | Provider-driven booking-status change notifies hardcoded `env.demoUserId` instead of `booking.user_id`. Real booking owners never see their booking-status notifications. Fix: look up Booking via the BookingItem and use its `user_id`. |
| 2 | 🔴 high | `trip_wise_be/src/services/notifications.service.ts:241-275` | `createNotification` only gates on `prefs.push`. The other five preference flags (`email`, `tripReminders`, `bookingUpdates`, `messages`, `promotions`) are persisted but **never consulted by any code** — the Preferences UI toggles are decorative. Fix: add a `type → category` map and gate inside `createNotification`. Decide intentionally whether an unchecked category suppresses push only, push+inbox, or inbox only. |
| 3 | 🟠 med | `lib/screens/notification_inbox_screen.dart:124-127` | Inbox-row tap calls `context.push(actionRoute)` directly: (a) skips the `startsWith('/')` safety check that `handleDeepLink` enforces, (b) stacks instead of replaces, so behaviour differs from a tray-tap of the same notification. Fix: funnel through `handleDeepLink`. |
| 4 | 🟡 low | `lib/widgets/shared_top_bars.dart:174-197` | Bell badge only refreshes on mount + on inbox-pop. A push that arrives while the user is on any other screen does not update the badge count until they navigate. Fix: subscribe the bell to `FirebaseMessaging.onMessage` or refetch on `AppLifecycleState.resumed`. |
| 5 | 🟡 low | `notification_inbox_screen.dart:64` + `notifications.service.ts:132` | Offset-based pagination on a `created_at DESC` feed will duplicate or skip a row if a new notification arrives between page fetches. Fix: cursor pagination (`?before=<created_at>`). |
| 6 | 🟡 low | `lib/services/push_messaging_service.dart:102` + Preferences screen | If the Android 13+ permission dialog is denied, there is **no UI surface** anywhere in the app indicating it. The Preferences screen's Push toggle still appears active and toggling it does nothing. Fix: check `getNotificationSettings`, disable the toggle and show a "Notifications blocked at the system level — open settings" CTA. |
| 7 | 🟡 low | (cross-cutting) | Foreground push doesn't refresh the screen the user is already on. E.g. new message in the open conversation: OS banner appears, list doesn't append. Fix: expose a `Stream<PushPayload>` from `PushMessagingService` so domain screens can react. |
| 8 | 🟡 low | `notification_inbox_screen.dart:130-136` | `_markReadSilently` swallows errors with no reconciliation. If the server call 404s or fails, the client thinks the row is read but the server doesn't. Fix: rollback local state on failure, or rely on eventual `/summary` refresh to correct. |
| 9 | 🟡 low | `trip_wise_be/src/routes/devices.route.ts:12` | `POST /devices/test-push` is behind `requireAuth` only — any authenticated user can self-spam. Fix: gate behind `requireRole('ADMIN')` or a non-prod environment check before shipping. |
| 10 | 🟡 low | `notifications.service.ts:74` (`relativeLabel`) | `timeLabel` is computed at fetch time and never refreshes; a "Just now" row stays "Just now" until manual refresh. Cosmetic. Fix: compute on the client from `createdAt` with a 60s timer, or document and accept. |
| 11 | ⚪ doc-rot | `notifications.service.ts:6-7`, `devices.service.ts:5`, `orders.service.ts:471-473` | Stale comments claim "no auth yet, pin demo user". Auth has landed; only #1's code still matches the stale comment. Scrub the comments when fixing the others. |

### 8. Other gaps worth knowing about

- **No tests** for any of this.
- **No live badge updater** beyond the bell's on-mount + on-pop refresh. If a push arrives while you're on a screen, the bell badge doesn't increment until you navigate. (You'd see the OS banner, but the in-app count stays stale.) Could be fixed by listening to `FirebaseMessaging.onMessage` from the bell, or polling `/notifications/summary` on a timer / app-resume.
- **No pagination cursor** — pure offset. Fine at small N; risky if a user accumulates thousands of notifications.
- **`timeLabel` is computed at fetch time** by the server (`relativeLabel` in `notifications.service.ts:74`). It does **not** auto-refresh — a "2m ago" label stays "2m ago" until the user pulls-to-refresh.
- **No bulk delete / archive** — only mark-read and mark-all-read.
- **No grouping / threading** — every message in a conversation generates one row. Chatty conversations will flood the inbox.

## Design choices worth remembering

- **`actionRoute` is server-provided, not constructed client-side.** The server decides where a notification lands you. The client only validates that it starts with `/`.
- **Optimistic UI on mark-as-read.** The inbox flips a row to read locally and only fires the API in the background — transient errors don't block the UX (see `_markReadSilently` in `notification_inbox_screen.dart:130`).
- **Mutation endpoints return `NotificationSummary`.** This is so the badge / counts can update without an extra round-trip. Mirror this pattern if you add new endpoints.
- **`timeLabel` is server-formatted.** Don't reintroduce client-side relative-time formatting — it would drift from whatever the server uses elsewhere (emails, etc).
- **Data-only push + local rendering.** Means we control the look + always have the deep link. Trade-off: zero push on platforms where we haven't built the local-rendering glue (i.e. iOS/web today).
- **Push init is fire-and-forget after `runApp`.** Push must never block startup. If you add steps here, keep them best-effort.
