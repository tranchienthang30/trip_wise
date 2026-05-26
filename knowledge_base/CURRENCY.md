# Currency

The app is **USD only**. There is no multi-currency support and no live FX.
`currency: 'USD'` is set as a schema default on `Booking` and `PayoutRequest`
mongoose models, and the wallet response hardcodes `currency: 'USD'`.

## History — why "Vnd" names exist

The DB originally stored amounts in VND. The migration
`trip_wise_be/scripts/migrate-vnd-to-usd.js` (id `2026-05-25-vnd-to-usd`) was
run once on 2026-05-25:

- Divided every money field by `VND_PER_USD` (env, default 25,000) for these
  collections / fields: `activities.base_price`, `flights.base_price`,
  `rooms.base_price` (only if value > 2000 — guard against partial reruns),
  `room_inventory.price_override` (same guard), `bookings.{total_price,
  total_amount, discount_amount, final_amount}`, `booking_items.{price_per_unit,
  total_price, gross_amount, commission_amount, provider_net_amount,
  refund_amount}`, `payments.amount`, `wallets.balance`, `cards.balance`,
  `wallet_transactions.amount`,
  `provider_payout_requests.{amount, gross_amount, commission_amount}`.
- Force-set `currency: 'USD'` on `bookings` and `provider_payout_requests`.
- Nulled `priceLabel` inside `home_content.recommendedOverrides[]` so labels get
  re-rendered from converted prices.
- Recomputed `wallets.loyalty_points` from the converted invoice totals.
- Recorded itself in the `migration_meta` collection — running again is a
  no-op unless invoked with `--force`. **Never rerun without `--force` AND a
  reason; it will divide already-USD values by 25,000 a second time.**

After migration the DB stores USD, but **none of the code/field names were
renamed**. This is purely a naming legacy, not a functional bug.

## Where the `Vnd` naming still leaks

- **Backend wire format** (`trip_wise_be/src/services/wallet.service.ts`):
  the `GET /wallet` response keys `amountVnd`, `completedInvoiceVnd`,
  `pointsValueVnd` carry USD values.
- **Backend helpers**: `chat.service.ts:133` `formatVnd()`,
  `search.service.ts:124` `formatVnd()`,
  `providerDashboard.service.ts:48` `formatVnd()`,
  `home.service.ts:251` `formatVndPrice()` — every one of them emits a `$`
  symbol via `Intl.NumberFormat('en-US', { currency: 'USD' })`. Names are
  misleading; output is already USD.
- **Frontend**: previously `lib/utils/currency.dart` had `formatVnd()` as a
  thin alias for `formatUsd()`. Removed. Model fields renamed
  `*Vnd` → `*Usd`; JSON parse keys still read from `amountVnd` /
  `completedInvoiceVnd` / `pointsValueVnd` until the backend is renamed.

## Frontend formatting helpers — `lib/utils/currency.dart`

- `formatUsd(double?)` → `$1,234` (thousands-grouped, integer USD).
- `formatUsdCompact(double?)` → `$4.8K`, `$1.2M`, `$3B` (for calendar cells
  and other tight spots).
- `formatInt(num)` → `1,234` (no currency symbol — used for points counts).

Render rules:
- Money in screens: `formatUsd(value)`.
- Money in tight grids/cells: `formatUsdCompact(value)`.
- Never hardcode `$` in screen code — go through the helper so a future
  currency switch is one file to change.

## Recommended follow-up (not done — would touch the backend)

1. Rename `formatVnd*` helpers → `formatUsd*` in:
   `trip_wise_be/src/services/{chat,search,providerDashboard,home}.service.ts`.
2. Rename wallet response keys on the wire:
   `amountVnd` → `amountUsd`,
   `completedInvoiceVnd` → `completedInvoiceUsd`,
   `pointsValueVnd` → `pointsValueUsd`
   in `trip_wise_be/src/services/wallet.service.ts`.
3. Update the matching JSON keys in
   `trip_wise/lib/models/wallet_overview.dart` (`fromJson`) to read from the
   new keys, drop the explanatory comments left behind.

There are no backend tests asserting on the old keys, so the rename is safe
from a regression standpoint — it's just coordinated across two repos.
