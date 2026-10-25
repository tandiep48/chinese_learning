# Plan: Port YiChinese learner UI/logic → Flutter (`chinese_learning`)

_Last updated: 2026-10-25_

## The reality this plan is built on

`chinese_learning` is a **Flutter/Dart** app and today it is a bare `flutter create`
scaffold (`lib/main.dart` only, default test, pubspec has just `cupertino_icons` +
`flutter_lints`). The source `yi-chinese-manage` is **Next.js/React/TypeScript**.

**No code copies across** — this is a rewrite:

| Web (source)                                    | Flutter (target)                         |
| ----------------------------------------------- | ---------------------------------------- |
| React components (`.tsx`) + CSS                 | Widgets + `ThemeData`                    |
| Hooks (`usePassage`, `useVocab`) + `lib/api/*`  | Riverpod providers + Dart service classes |
| TS interfaces (`lib/types/*`)                   | Dart model classes (`fromJson`)          |
| `fetch(..., credentials:"include")`             | `dio` + `Authorization: Bearer`          |

What **does** carry over for free: the **API contract** (endpoints and JSON shapes) and
the **design language** (the learner brand palette + type scale in
`yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}`). Two caveats, both verified
against the current learner code and detailed below: (1) only the auth endpoints use the
`{success, data}` envelope — the lesson-study reads are **legacy raw JSON**; (2)
`tokens.css` holds TWO palettes — the `/manage` admin slate/indigo set and the learner
`--brand-*` sage/teal set — and this app mirrors the learner one only.

## Decisions locked in

- **Scope:** thin learner vertical slice first (not full parity, not `/manage`).
- **UI fidelity:** native-idiomatic Material 3; reuse brand colors/typography, adapt
  layout/navigation to native patterns.
- **Auth:** add a mobile token endpoint to the Flask backend (non-breaking, alongside
  the existing session-cookie auth).
- **Stack:** Riverpod + go_router + dio.
- **Core flow:** Lesson study (login → home → lesson study).
- **Backend work:** done in `Learning/` on `dev_version_2.0` as part of this effort.
- **API target during dev:** local Flask.
- **i18n:** scaffold localization infra, ship one language for now.

## The slice

**Login → Home (minimal) → Lesson study.**

Lesson study end-to-end: browse books (`/api/lesson/books`) → pick a lesson/passage →
read the passage lines (hanzi / pinyin / translation) with tappable word popups and a
lesson summary. Deliberately **excludes the graded trainer**
(`/api/lesson/start|submit`) — that is a later slice.

---

## Phase 0 — Backend: add mobile token auth (`Learning/`, `dev_version_2.0` branch)

Cookie sessions are painful on mobile. The cheap, **non-breaking** path, confirmed
against the actual code:

1. **New endpoint** `POST /api/auth/token` in
   `Learning/web_app/routes/auth/auth_routes.py`: same credential check as `api_login`
   (reuses `get_user_by_username` + `check_password_hash`), returns `{ token, user }`.
   Sign the token with **`itsdangerous.URLSafeTimedSerializer`** (already installed via
   Flask — **no new dependency**, no JWT lib needed), payload = `user_id`, with expiry.
2. **One `@login_manager.request_loader`** added at `Learning/web_app/app.py:64` (right
   after `user_loader`): reads `Authorization: Bearer <token>`, verifies
   signature/expiry, returns the same `User` via `get_user_by_id`.

   → This single hook makes **every existing `@login_required` route** accept the token
   transparently. No per-route changes; session auth for the web keeps working.
3. Tests in `web_app/tests` following the suite's no-conftest conventions (valid token,
   expired, tampered, missing header).

**Deliverable:** the mobile app authenticates once, sends a Bearer header on every call,
and all lesson/dashboard endpoints just work.

## Phase 1 — Flutter foundation

- Add deps: `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`,
  `flutter_localizations` + `intl`.
- Scaffold the folder layout from **UI styling & folder conventions** above: `core/`,
  `shared/{widgets,styles}/`, `l10n/`, and one folder per module under `features/`, each
  with its own `data/ providers/ screens/ widgets/ styles/` split (rules 1 & 4).
- `core/env.dart`: base URL with Android-emulator mapping (`10.0.2.2:5000`) vs iOS sim
  (`localhost:5000`) + run instructions.
- `core/theme/app_theme.dart`: Material 3 `ThemeData` seeded from `tokens.css` — colors
  and common text sizes **only** (rule 3). Everything else lives in module/shared styles.
- `core/router.dart`: `go_router` with an auth redirect guard; routes `/login`, `/`
  (home), `/books`, `/books/:code`, `/lesson/:passageId`.

## Phase 2 — API + models layer

- `core/api/api_client.dart`: `dio` instance with base URL and a request interceptor
  injecting the Bearer token. **The web uses TWO response shapes, so the client must too:**
  the auth endpoints (`/api/auth/*`, web `apiFetch`) return the `{success, data}` envelope;
  every lesson-study read (`/api/lesson/*`, `/api/user/dashboard-current-lesson`, web
  `legacyApiFetch`) returns **raw JSON** with the payload nested under a key
  (`books` / `passages` / `passage` / `vocab` / `grammar`). So the client needs an envelope
  path AND a raw path — do NOT blind-unwrap `{success, data}` on the raw reads. A 401 throws
  a typed `ApiException` → Unauthenticated on either path.
- `core/api/validators.dart`: shared `fromJson` validation helpers (`requireString`,
  `requireInt`, `optString`, `asList`, …) used by every model (rule 6).
- Dart models, each in its **owning module** under `data/models/` (hand-translated from
  `lib/types/lesson.ts`, `book.ts`, `user.ts`): `AuthUser`, `LearnerBookSummary/Detail`,
  `PickerPassage`, `LessonPassageDetail` + `LessonPassageLine`, `LessonVocabRow`. Each
  `fromJson` **validates** required fields/types via the helpers and throws
  `ValidationException` on bad data — no blind casts (rule 6). NOTE this is **stricter than
  the web**: its learner reads (`lib/api/learner/*`) cast JSON straight to the
  `lib/types/*` interfaces with no runtime check. The web's Zod validators
  (`lib/api/schemas/*`, built on `pagination.ts`) guard **request bodies** for the newer
  `.../query` endpoints, not responses — so rule 6 ports that boundary discipline to the
  response side.

## Phase 3 — Auth flow

- `AuthRepository` (login via `/api/auth/token`, store token, `/api/auth/me` on launch,
  logout).
- `authProvider` (Riverpod `AsyncNotifier`) mirroring `AuthProvider.tsx`'s mount-check.
- `LoginScreen` (native Material form). Router redirects unauthenticated users here.

## Phase 4 — Home (minimal)

Scoped down from the web's rich dashboard. First pass = greeting + **"Continue where you
left off"** card (`GET /api/user/dashboard-current-lesson`) that deep-links into lesson
study, plus a Books entry point.

**Deferred:** stats charts (`/api/user/{global-stats, learned-words-last-3-days,
time-learned-last-3-days}`), recommendations. (`dashboard-current-lesson` is paged:
`?page=&page_size=`.)

## Phase 5 — Lesson study (the proof)

- `LessonRepository`:
  - `getLearnerBooks` → `/api/lesson/books`
  - `getLearnerBook` → `/api/lesson/book/:code`
  - `getPassages` → `/api/lesson/passages?hsk_level=`
  - `getLessonPassageDetail` → `/api/lesson/passage/:id`
  - `getLessonPassageVocab` → `/api/lesson/vocab/:id`
  - (grammar panel `/api/lesson/grammar/:id` optional in this slice)
- Screens: `BooksScreen` (list + skeleton loading + empty state), `BookDetailScreen`
  (lessons/parts), `LessonStudyScreen` (passage lines: hanzi + pinyin + translation).
- `WordPopup` → native modal bottom sheet (tappable tokens → vocab lookup), porting the
  behavior of `WordPopup.tsx`.
- Audio playback of `audio_key` and stroke-order: **stubbed/deferred** (buttons present,
  wired in a later slice).

---

## UI styling & folder conventions (governs every phase)

These rules apply to all Flutter code written in this port. Flutter has no CSS — a
"style file" is a Dart file that holds only style values (`TextStyle`, `Color`,
`BoxDecoration`, `EdgeInsets`, radii, etc.), never widgets.

### 1. Each module is its own folder

Every feature (module) lives in `lib/features/<module>/`. A module never reaches into
another module's folder — cross-module needs go through `shared/` or `core/`. One module
per concern: `auth`, `home`, `lessons`.

### 2. Styles belong to the module; shared design goes to a shared folder

Each module owns its styles under `lib/features/<module>/styles/`. When two or more
modules genuinely share the same design (same card, same list row, same section header),
that style is promoted to `lib/shared/styles/` and both modules import it — never
copy-pasted. Rule of thumb: duplicated in a 2nd module → move it to `shared/styles/`.

### 3. The global/public file holds only colors and text sizes — the most common ones

`lib/core/theme/app_theme.dart` is the only global style surface. It defines **just** the
color palette (seeded `ColorScheme`) and the common text sizes (the base type scale). It
does **not** hold component decorations, per-screen spacing, or one-off styles — those live
in module/shared style files. Keep it small.

Seed it from the **learner brand palette only**, verified in
`yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}`. `tokens.css` also defines a
`/manage` admin palette (slate bg `#f1f5f9`, indigo accent `#6366f1`, text `#0f172a`) —
**do not use it.** The learner values:

- Primary (sage): `#576856`, hover `#455544`; page background (mint) `#cbe2d4`; card
  `#ffffff`; secondary surface `#f0f4f1`; body text `#576856`, muted `#738a72`.
- Home/dashboard variant (teal, high-contrast): primary `#007a61`, hover `#00634f`,
  background `#eef6df`, text `#111111`. The site header / nav is this teal `#007a61`.
- Status: success `#10b981`, warning `#f59e0b`, danger `#ef4444`.
- Font: **Roboto-first** stack (Latin stays Roboto; CJK glyphs swap to the user's hanzi
  font — that runtime swap is deferred in this slice, so just ship Roboto).
- Type ramp (`--font-size-*`, px): 12 / 14 / 16 (body) / 18 / 20 / 24 / 32 / 40 / 48 / 64
  (display & hanzi). Spacing is a 4px scale; layout is mobile-first (sm 480 · md 768 ·
  lg 1024 · xl 1280).

### 4. Style files and UI files live in separate folders

Within every module, UI and style are physically separated:

- UI → `screens/` (full pages) and `widgets/` (module-local widgets)
- Style → `styles/`

A widget imports its styles from the `styles/` folder; a widget file never defines
`TextStyle`/`Color`/decoration constants inline.

### 5. Each module is documented with a comment

Every module's primary files open with a header doc-comment (`///`) stating the module's
purpose and what it talks to (which API endpoints / which web source it was ported from).
At minimum the module's repository and main screen carry this header; every other file
opens with a one-line `///` describing its role.

### 6. API items are validated

Every model's `fromJson` validates input, it does not blindly cast: required fields must
be present and correctly typed, or it throws a typed `ValidationException` (caught and
surfaced as a clean error state, never a raw crash). Shared validation helpers live in
`lib/core/api/validators.dart` (e.g. `requireString`, `requireInt`, `optString`,
`asList`). This is deliberately **stricter than the web**, whose learner reads cast JSON
straight to `lib/types/*`; it ports the Zod boundary-validation the web applies to request
bodies (`yi-chinese-manage/lib/api/schemas/*`) onto the response side.

### Resulting folder layout

```text
lib/
├── core/
│   ├── env.dart                    # base URL + emulator/sim host mapping
│   ├── router.dart                 # go_router + auth guard
│   ├── api/
│   │   ├── api_client.dart         # dio + Bearer interceptor + envelope unwrap
│   │   ├── api_exception.dart      # typed API errors (incl. 401 → Unauthenticated)
│   │   └── validators.dart         # shared fromJson validation helpers (rule 6)
│   └── theme/
│       └── app_theme.dart          # GLOBAL: colors + common text sizes ONLY (rule 3)
├── shared/
│   ├── widgets/                    # cross-module UI (buttons, cards, skeleton, empty state)
│   └── styles/                     # cross-module styles shared by 2+ modules (rule 2)
├── l10n/                           # localization infra (one language shipped)
└── features/
    ├── auth/                       # module (rule 1)
    │   ├── data/
    │   │   ├── auth_repository.dart
    │   │   └── models/
    │   │       └── auth_user.dart      # fromJson + validation (rule 6)
    │   ├── providers/
    │   │   └── auth_provider.dart
    │   ├── screens/                    # UI (rule 4)
    │   │   └── login_screen.dart
    │   ├── widgets/                    # UI (rule 4)
    │   └── styles/                     # STYLE, separate from UI (rules 2 & 4)
    │       └── login_styles.dart
    ├── home/                       # same shape: data/ providers/ screens/ widgets/ styles/
    └── lessons/                    # same shape: data/ providers/ screens/ widgets/ styles/
```

No barrel files — import concrete paths (consistent with the web project's convention).

---

## Explicitly deferred (not in this slice)

Realtime competition (`SocketIO`), graded lesson/vocab trainers, practice question types
(~10 widgets), SRS vocab review, stroke-order animation, audio/TTS, profile/stats charts,
full multi-language i18n, and the entire `/manage` admin surface.

## Suggested commits (small & focused)

- **Backend** (`Learning/` `dev_version_2.0`): (1) token endpoint, (2) request_loader + tests.
- **Flutter** (`chinese_learning/` `dev`): no commits until reviewed, per the project's
  CLAUDE.md 3.3. Logical units: foundation, theme, api client + models, auth, home,
  lesson study — each reviewed before any commit.

## Open questions to resolve before building

1. **Browse hierarchy** — confirm mobile is **Books → lessons → passage** (not
   HSK-level → lesson). Verify against `LearnerBookDetail` + the web books page.
2. **Token expiry/refresh** — simplest is a long-lived signed token (~30 days), re-login
   on expiry, no refresh-token machinery in this slice. Confirm acceptable.

## Key source references

- Web API client (`apiFetch` enveloped + `legacyApiFetch` raw):
  `yi-chinese-manage/lib/api/client.ts`
- Web auth context: `yi-chinese-manage/components/auth/AuthProvider.tsx`
- Lesson/book/dashboard API (all `legacyApiFetch`, raw-keyed JSON):
  `yi-chinese-manage/lib/api/learner/{lessons,books,dashboard}.ts`
- Lesson/book/user types: `yi-chinese-manage/lib/types/{lesson,book,user}.ts`
- Request-body Zod validators (for `.../query` endpoints): `yi-chinese-manage/lib/api/schemas/*`
- Flask auth routes (`api_login` :77, `get_user_by_username` :31):
  `Learning/web_app/routes/auth/auth_routes.py`
- Flask login manager (`login_manager` :59, `@user_loader` :62 — add `request_loader`
  right after): `Learning/web_app/app.py:59-66`
- Design tokens + learner theme: `yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}`
