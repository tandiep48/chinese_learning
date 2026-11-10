# Plan: Port YiChinese learner UI/logic → Flutter (`chinese_learning`)

_Last updated: 2026-11-03_

## The reality this plan is built on

`chinese_learning` is a **Flutter/Dart** app and today it is a bare `flutter create`
scaffold (`lib/main.dart` only, default test, pubspec has just `cupertino_icons` +
`flutter_lints`). The source `yi-chinese-manage` is **Next.js/React/TypeScript**.

**No code copies across** — this is a rewrite:

| Web (source)                                   | Flutter (target)                          |
| ---------------------------------------------- | ----------------------------------------- |
| React components (`.tsx`) + CSS                | Widgets + `ThemeData`                     |
| Hooks (`usePassage`, `useVocab`) + `lib/api/*` | Riverpod providers + Dart service classes |
| TS interfaces (`lib/types/*`)                  | Dart model classes (`fromJson`)           |
| `fetch(..., credentials:"include")`            | `dio` + `Authorization: Bearer`           |

What **does** carry over for free: the **API contract** (endpoints and JSON shapes) and
the **design language** (the learner brand palette + type scale in
`yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}`). Two caveats, both verified
against the current learner code and detailed below: (1) only the auth endpoints use the
`{success, data}` envelope — the lesson-study reads are **legacy raw JSON**; (2)
`tokens.css` holds TWO palettes — the `/manage` admin slate/indigo set and the learner
`--brand-*` sage/teal set — and this app mirrors the learner one only.

## Decisions locked in

- **Scope:** thin learner vertical slice first (not full parity, not `/manage`).
- **UI fidelity:** ~~native-idiomatic Material 3~~ → **match the web** (revised
  2026-11-01). The web is already phone-responsive and users know that layout, so port
  the learner CSS (layout, spacing, component styles) faithfully rather than
  re-interpreting it with native patterns. Still Flutter widgets + the brand palette,
  but the web's mobile layout is the reference. Phases 1–5 were built native-idiomatic
  and get a restyle pass (Slice R-UI).
- **Auth:** add a mobile token endpoint to the Flask backend (non-breaking, alongside
  the existing session-cookie auth).
- **Stack:** Riverpod + go_router + dio.
- **Core flow:** Lesson study (login → home → lesson study).
- **Backend work:** done in `Learning/` on `dev_version_2.0` as part of this effort.
- **API target during dev:** local Flask.
- **i18n:** scaffold localization infra; **ship Vietnamese now** as the default/focus
  language (revised 2026-11-01). Keep the EN infra and add `app_vi.arb`; default locale
  VI; the reader shows `meaning_vn` / `translation_vi` first. The runtime CJK hanzi-font
  swap stays deferred.

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
- Approved R5a lesson trainer mockup: `mockup/approve design/lesson_trainer_typing/{code.html,DESIGN.md,screen.png}`

---

# Post-slice roadmap — building out the full learner app

_Added 2026-11-01._ Phases 0–5 shipped the **thin vertical slice** (login → minimal
home → lesson-study **reading** view). That was intentional: the home is the
scoped-down Phase 4, and everything below was in the plan's "Explicitly deferred"
list. This roadmap turns the deferred surface into prioritized, independently
reviewable slices. It is **planning only** — nothing here is built yet.

## Where the web learner app actually is (the gap)

The web home (`app/learner/page.tsx` → `components/page/learner/home/HomeShell.tsx`)
is **not a stats dashboard**. It is a tabbed shell — **Lesson / Review / Recommend**
tabs, each running its activity in place — plus a **current-lesson rail** and, inside
a lesson part, a **milestone bar**. Learning statistics live on **`/learner/profile`**,
not the home. So "the dashboard looks different" is really three separate gaps:
the **HSK browse path**, the **milestone study flow**, and the **home activity tabs**
(Review/Recommend) — on top of profile/stats, grammar, translation, exam, pinyin and
competition.

**Milestone = the 6-step lesson study flow** (`MilestoneBar.tsx`), not a widget:

1. Vocab Summary · 2. Vocab Learner · 3. Vocab Trainer · 4. **Lesson Summary** ·
2. Lesson Learner · 6. Lesson Trainer. **We built only step 4** (the reader). The
   other five are the graded trainers / flashcard learners the slice deferred.

## Slices (each independently reviewable; sizes S/M/L)

### Slice R-UI — Web-match restyle + Vietnamese default (retrofit) · M

Foundational, because it sets the design system every later slice follows. Phases 1–5
were built native-idiomatic; this pass re-skins them to the web's phone layout and
makes Vietnamese the default.

- **Design port:** translate the learner CSS — `app/styles/{tokens.css,
learner-theme.css}` and the per-screen stylesheets (`books.css`, `lesson-picker.css`,
  `lesson-summary.css`, `home-shell.css`, `word-popup.css`, …) — into the module
  `styles/` files, matching layout, spacing, radii, card/toolbar/button styling and the
  teal header (`#007a61`). Extend `app_theme.dart` only where it stays colors+sizes.
- **Screens retrofit:** login, home, books, book detail, lesson study, word popup.
- **Vietnamese:** add `app_vi.arb` (translate all keys), set default locale to VI in
  `MaterialApp`, and switch the reader to `translation_vi` / `meaning_vn` first (EN
  fallback). Keep EN as the secondary locale.
- **Reference:** the web is mobile-first (sm 480 · md 768 …); emulate its ≤480 layout.

### Slice R0 — Audio & stroke order (cross-cutting) · S

Wire the buttons already stubbed in the reader and word popup. Lesson-line audio and
vocab audio play from GCS (`/lesson_audio/*`, `/audio/*` redirects); stroke order
needs a hanzi-writer equivalent.

- **Deps:** `just_audio` (or `audioplayers`) + a stroke-order package or a WebView of
  hanzi-writer. **Native setup** (iOS background-audio flag, Android INTERNET).
- **Why first:** small, unblocks the reading UX everywhere.

### Slice R1 — HSK browse flow (parallel to Books) · S–M

Second browse path: **HSK1–6 (+7–9) → lesson → part**, mirroring the web picker's HSK
tab. Group `/api/lesson/passages?hsk_level=` rows into lessons/parts by parsing
`H<level>_<lesson>_<part>`.

- **Endpoints:** `/api/lesson/passages` (have), `/api/lesson/picker-progress?hsk_level=`
  (optional progress).
- **Port:** `lib/lessons/lessons.ts` grouping helpers + `HSK_LEVELS` metadata
  (`lib/types/constants`); reuse `LessonStudyScreen`.
- **Screens/routes:** `HskLevelsScreen` (`/hsk`), `HskLessonsScreen` (`/hsk/:level`);
  add an HSK/Books switch on home.
- **Defer:** HSK1 special-cases — the pinyin passage `H1_1_1` and Numbers part
  `H1_5_99` (`PINYIN_PASSAGE_ID`, `NUMBER_PART_ID`).

### Slice R2 — Progress & milestone display (read-only) · S–M

Progress bars on books/HSK lessons and a **milestone bar** on the study screen showing
step 4/6 and which steps are done. Display-only until the trainer steps land (R5).

- **Endpoints:** `/api/lesson/picker-progress?hsk_level=`, `/api/lesson/milestone`.
- **Widgets:** `PickerProgress` bars (shared), `MilestoneBar` (lessons module).

### Slice R3 — Profile & learning stats · M

The web's statistics surface (`/learner/profile`): global stats, 3-day activity,
learned-vocab list, and account/preferences.

- **Endpoints:** `/api/user/{global-stats, learned-words-last-3-days,
time-learned-last-3-days, profile-summary}`, `/api/user/learned-vocab/query`,
  and settings `/api/user/{hanzi-font, hanzi-script, ui-language}`.
- **Screens:** `ProfileScreen` (stat cards + simple charts), `SettingsScreen`.
- **Deps:** a chart lib (`fl_chart`) — **new dependency**.

### Slice R4 — Home activity tabs (Review + Recommend) · M

Rebuild the home as the web shell: **Lesson / Review / Recommend** tabs + current-lesson
rail. The tab _chrome_ is small; the tab _contents_ depend on R5/R6.

- **Review (SRS):** `/api/vocab/{review/count, review/query, submit-batch,
review-recent/query, has_history}`.
- **Recommend:** `/api/practice/recommend`, practice history/sessions.
- **Depends on** the trainer engine (R5) for the actual activities.

### Slice R5 — Trainer engine + milestone steps (the big one) · L, multi-slice

The core learning loop. Split into sub-slices:

- **R5a — Lesson trainer:** `/api/lesson/{start, submit, part-complete}`; task types
  `listening | meaning | typing | reorder` (4 widgets — `LessonTrainerPage` +
  `ChoiceTask/TypingTask/ReorderTask`).
  - **Approved UI design:** Use the approved mockup in
    `mockup/approve design/lesson_trainer_typing/` (`code.html`, `DESIGN.md`, `screen.png`)
    instead of a direct web CSS port for the lesson trainer shell and typing task:
    - **Top action bar:** Dual 40×40 (`rounded-lg`) header buttons — left solid teal
      (`#007a61`) menu button with white icon, right white bordered (`#e5e7eb`) lesson
      settings button with teal icon.
    - **6-step milestone header:** Horizontal connected step track (`2px` `#576856`/25% line)
      with `28×28` circular numbered badges — completed/inactive steps in sage (`#576856`),
      active step (Step 6) in bright teal (`#007a61`) with a `4px` `#007a61`/20% focus ring,
      followed by a left-aligned step caption (`Bước 6/6 · Luyện bài` in `#738a72`).
    - **Task progress bar:** Thin `6px` rounded track (`#f3f4f6`) with teal fill (`#007a61`)
      and right-aligned muted task counter (`Nhiệm vụ X/Y`).
    - **Outer task card:** Mint container (`#cbe2d4`, border `#afcfbd`, `rounded-2xl`,
      padding `16–20px`) with centered bold instruction header (e.g. `Nhập câu sau bằng tiếng Trung:`).
    - **Inner prompt / feedback card (`TypingTask`):** Nested rounded card (`14px` radius,
      `16px` padding) that shifts to error state (`#fef2f2` bg, `#dc2626` border) on wrong
      submission, containing:
      1. Centered bold prompt sentence (`18px`).
      2. `54px`-tall white input box (`rounded-xl`, border `#e2dcd5`, `18px` Noto Sans SC
         text with teal `#007a61` caret/focus).
      3. Centered bold red correction feedback (`✕ <hanzi> (<pinyin>)` in `#dc2626`) when
         incorrect.
    - **Sticky bottom control bar:** Fixed bottom bar (`bg-white`, top border `#e5e7eb`,
      subtle upward shadow) with two actions: outlined sage exit button (`Thoát Phiên Học`
      with logout icon, border `#576856`/40%, text `#576856`) and flex-1 solid sage primary
      action button (`Tiếp Tục` / `Kiểm Tra`, bg `#576856`, hover `#4a5849`, white text,
      `rounded-xl`).
- **R5b — Vocab learner:** flashcard/card viewers (steps 2 & 5).
- **R5c — Vocab trainer:** the ~11 question-type widgets (`MCOptions`, `Reorder`,
  `BlankedContent`, `ImageOptions`, `KeyButtons`, `TrueFalse`, `T5*`, `Type2/6Group`,
  `SingleGroup`) + `/api/vocab/{words, submit-batch}`.
- **R5d — Milestone runner:** orchestrate the 6 steps (soft gating, replayable),
  `/api/lesson/milestone`.

### Slice R6 — Remaining surfaces · varies

- **Grammar panel** on the study screen — `/api/lesson/grammar/:id` · S.
- **Translation** list — `/api/translation/lesson` · S.
- **Exam** flow · M. **Pinyin lessons** (basic/advanced, special content) · M.
- **Competition / learn-together** (realtime, `SocketIO`) — `/api/competition/rooms` +
  `socket_io_client` dep · L.
- **Full i18n** (ship VI alongside EN; wire `ui_language` + the CJK hanzi-font swap).

## Recommended order & rationale

1. **R-UI Web-match restyle + VI** — do first: it sets the design system and default
   language every later slice inherits, and directly answers the "looks different"
   feedback.
2. **R0 Audio/stroke** — small, improves what already exists.
3. **R1 HSK browse** — quick win; completes browse parity with the web.
4. **R2 Progress/milestone display** — cheap, makes the app feel alive.
5. **R3 Profile/stats** — self-contained read-only; this is the real "dashboard".
6. **R5 Trainer engine** — the heart of the app; largest, so sequence R5a→R5d.
7. **R4 Review/Recommend tabs** — land once R5 provides the activities.
8. **R6 Remaining surfaces** — grammar/translation first (cheap). **Competition is
   OUT for this phase** (deferred, see below).

## Resolved scope decisions (2026-11-01)

- **(a) UI:** **match the web** (phone-responsive layout), not native-idiomatic — the
  locked-in decision above is revised and Slice R-UI implements it.
- **(b) Language:** **ship Vietnamese now** as the default/focus language (EN kept as
  secondary) — folded into Slice R-UI; R6 i18n is just the remaining polish.
- **(c) Competition / learn-together (realtime, SocketIO):** **held off** for this
  phase. It stays in R6 as explicitly deferred; no `socket_io_client` work now.

---

# Next up — Navigation shell + HSK picker + tabbed dashboard

_Added 2026-11-08._ Testing the shipped slice surfaced three gaps against the web
learner app: **no navigation shell** (the app has only an `AppBar` + logout icon,
no sidebar), **no HSK selection page**, and a **home that is the minimal Phase-4
card** rather than the web's tabbed dashboard. This section turns those three into
an ordered, independently-reviewable build sequence. It folds in and supersedes the
roadmap's Slice R1 (HSK) and the home half of Slice R4; the navigation shell is
**new** — the original plan routed with a bare `AppBar` and never had a nav surface.

**Scope decisions locked (2026-11-08):**

- **(d) Dashboard =** port the web's **tabbed home** (`HomeShell.tsx`): a
  **Lesson / Review / Recommend** tab bar + the current-lesson rail. Review and
  Recommend **ship as stubs** now (their real contents are the SRS/trainer slices
  R4/R5); the Lesson tab reuses what exists.
- **(e) Sidebar =** faithful port of the web's **hamburger drawer** (the web's
  mobile `LearnerSidebar` form), not a bottom nav bar.
- Everything here is **Vietnamese-first** per decision (b); add keys to both
  `app_vi.arb` and `app_en.arb`.

The three slices below are ordered by dependency: the shell first (it hosts the
other two), then the HSK picker, then the tabbed dashboard.

## Slice N1 — Navigation shell (hamburger drawer) · M · NEW

A persistent drawer wrapping every authenticated route, ported from
`components/layout/LearnerSidebar.tsx` (the mobile drawer branch only — the
desktop collapsible rail is web-specific and dropped).

- **New module** `lib/features/shell/` (rules 1 & 4): `screens/app_shell.dart`
  (a `Scaffold` with `AppBar` + `Drawer`), `widgets/nav_drawer.dart`,
  `styles/shell_styles.dart`. Nav metadata (label key, route, icon, enabled flag)
  as a small const list, mirroring the web `NAV_ITEMS`.
- **go_router:** wrap the authed routes in a `ShellRoute` (or `StatefulShellRoute`)
  so the drawer/app-bar persist across navigation and the body swaps. The hamburger
  is the `AppBar` leading button; teal header `#007a61` (home/dashboard variant,
  per theme rule 3), white-on-teal rows, active-row highlight (`bg white/20`).
- **Drawer items** (web `NAV_ITEMS` + account block). Port the labels to `nav.*`
  i18n keys; map FontAwesome → Material icons:
  | Item | Route | Icon (web → Material) | State now |
  | --- | --- | --- | --- |
  | Dashboard | `/` | `faGaugeHigh` → `Icons.dashboard` | **active** |
  | Library (HSK/Books) | `/library` | `faLayerGroup` → `Icons.layers` | **active** (Slice N2) |
  | Vocabulary | `/vocab` | `faBook` → `Icons.menu_book` | disabled (Slice R5) |
  | Recommend | `/recommend` | `faStar` → `Icons.star` | disabled (Slice R4/R5) |
  | Learn Together | — | `faUsers` → `Icons.groups` | **hidden** (R6, deferred) |
  - Account block (drawer footer, divider above): **profile** row (avatar + username;
    route disabled until Slice R3), **Settings** (opens a stub — the web
    `LearnerSettingsModal` hanzi/script/language controls are deferred), **Logout**
    (`faRightFromBracket` → `Icons.logout`, wired to `authNotifierProvider.logout`).
  - The web's `nav.hsk` label is **"Library"** (EN) — keep that wording; the route
    is the HSK/Books picker, not HSK-only.
- **Drop for now:** the web's `sessionActive` leave-confirm guard (`pendingHref`,
  `learner-nav-guard`) — that protects a running in-place activity, which only
  exists once the trainer slices land. Add it back with Slice R5.
- **Housekeeping (rule 2.4):** move the current `home_screen.dart` logout
  `IconButton` into the shell; the home `AppBar` goes away.

## Slice N2 — HSK selection page (Library picker) · S–M · (was Slice R1)

The second browse path beside Books, ported from `app/learner/hsk/page.tsx` +
`components/page/learner/picker/`.

- **Library screen** at `/library`: a top tab strip porting `LearningTabs.tsx`
  with **HSK | Books** only (**Practice / Exam tabs deferred** → R6). The HSK tab is
  `HskLevelsScreen`; the Books tab reuses the existing `BooksScreen` body.
- **`HskLevelsScreen`** (`/hsk`): grid of HSK1–6 (+7–9) level cards from a ported
  `HSK_LEVELS` const (web `lib/lessons/lessons.ts` / `lib/types/constants`), each
  card its brand `color`, cover image via the GCS URL helper with a text-label
  fallback (web `onError` behavior). Loading skeleton + empty state (rule 4.5).
- **`HskLessonsScreen`** (`/hsk/:level`): group `/api/lesson/passages?hsk_level=`
  rows into lessons/parts by parsing `H<level>_<lesson>_<part>` (port the
  `lib/lessons/lessons.ts` grouping helpers). Reuse `LessonStudyScreen` for a part.
- **Models/providers:** `HskLevel` model + a `hskLevelsProvider` / passages grouping
  provider in the `lessons` module; `fromJson` validated (rule 6).
- **Defer:** HSK1 special cases — pinyin passage `H1_1_1`, Numbers part `H1_5_99`
  (`PINYIN_PASSAGE_ID`, `NUMBER_PART_ID`); `picker-progress` bars (that is Slice R2).

## Slice N3 — Tabbed dashboard · M · (home half of Slice R4)

Rebuild the home as the web shell (`HomeShell.tsx` + `HomeTabs.tsx`), replacing the
minimal Phase-4 card.

- **`HomeTabs`** (port `HomeTabs.tsx`): a 3-tab bar **Lesson / Review / Recommend**
  (`home.tab_*` keys; icons `faBookOpen`/`faClockRotateLeft`/`faCompass` →
  `Icons.menu_book`/`Icons.history`/`Icons.explore`). Review tab carries a
  **words-due count badge** from `GET /api/vocab/review/count` (clamped to the
  review cap), fetched independently of the panel.
- **Lesson tab:** host the existing current-lesson card + Books/HSK entry points
  (the web `LessonTab` + `CurrentLessonPanel`); this is the one working tab.
- **Review tab / Recommend tab: stubs now** — a clean empty/"coming soon" state
  (rule 4.5). Real contents land with the SRS (R4) and trainer (R5) slices.
  `/api/practice/recommend` and the `/api/vocab/review/*` reads are **not** wired yet.
- **Signed-out note:** the web shows a sign-in prompt instead of tabs; the router
  guard already handles this, so the panel can assume an authed user.
- **Drop for now:** the `sessionActive` / `pendingTab` in-place-activity guard (same
  reason as N1) and the lesson-study sidebar dock — both are R5 concerns.

## Build order & review units

1. **N1 Navigation shell** — first; it hosts N2 and N3 and answers the "no sidebar"
   gap directly. One review unit.
2. **N2 HSK picker** — the Library destination the shell links to.
3. **N3 Tabbed dashboard** — the Dashboard destination; lands last since its
   Review/Recommend tabs are stubs pending R4/R5.

Per CLAUDE.md 3.3, no commits until each slice is reviewed. Suggested commits:
`feat(shell): navigation drawer`, `feat(lessons): HSK picker + Library tabs`,
`feat(home): tabbed dashboard shell`.

## New i18n keys (both `app_vi.arb` + `app_en.arb`)

`nav.dashboard`, `nav.hsk` (="Library"), `nav.vocabulary`, `nav.recommend`,
`nav.learn_together`, `nav.settings`, `nav.logout`, `nav.open_menu`;
`picker.select_hsk_level`, `picker.choose_level_subtitle`, `books.tab_hsk`,
`books.tab_books`; `home.tab_lesson`, `home.tab_review`, `home.tab_recommend`,
`home.tabs_label`, plus the stub-state strings for Review/Recommend. Source
English values are in `yi-chinese-manage/lib/i18n/en.json` (`nav`, `picker`,
`books`, `home` groups); translate to VI.

## Open questions

1. **Library landing** — confirm the sidebar "Library" entry should open the
   **HSK/Books tabbed picker** (HSK tab default), rather than two separate drawer
   entries. (Assumed yes — matches the web's `LearningTabs`.)
2. **Vocabulary / Recommend drawer entries** — show them **disabled/greyed** now
   (signalling what's coming) vs **hidden** until their slices ship. (Assumed:
   disabled for Vocabulary & Recommend, hidden for Learn Together.)

## Key source references (this section)

- Sidebar: `yi-chinese-manage/components/layout/LearnerSidebar.tsx` (+ `learner-nav.css`),
  `app/learner/layout.tsx`.
- HSK picker: `app/learner/hsk/page.tsx`, `app/learner/hsk/[level]/page.tsx`,
  `components/page/learner/picker/{LearningTabs,RecentLessonPanel,PickerProgress}.tsx`
  (+ `lesson-picker.css`, `learning-tabs.css`); grouping/`HSK_LEVELS` in
  `lib/lessons/lessons.ts`.
- Tabbed home: `components/page/learner/home/{HomeShell,HomeTabs,LessonTab,ReviewTab,RecommendTab,CurrentLessonPanel}.tsx`
  (+ `home-shell.css`); `hooks/home/useLearnerHome.ts`.
- i18n source: `yi-chinese-manage/lib/i18n/{en,vi}.json`.

### What N1–N3 shipped

- **N1** — navigation drawer (`lib/features/shell/`): teal hamburger drawer,
  Dashboard + Library active, Vocabulary/Recommend disabled, Settings **stub**,
  Logout wired; `/` nested in a `ShellRoute` via `AppShell`.
- **N2** — Library (`/library`, HSK | Books tabs), HSK level grid, `/hsk/:level`
  lessons with search; `BooksView` extracted. HSK1 pinyin/number cases deferred.
- **N3** — tabbed dashboard: Lesson / Review / Recommend; Lesson tab works,
  Review/Recommend are "coming soon" stubs.

---

# Next up (round 2) — the in-lesson learning flow: settings/language + the milestone trainers

_Added 2026-11-08._ With browse + dashboard in place (N1–N3), this round builds
what happens **inside** an HSK lesson part: the six-step **milestone** study flow
and the **settings/language** surface the drawer already points at. It sequences
the roadmap's **R3** (settings subset) and **R5** (trainers + milestone), framed
as buildable slices on top of N1–N3.

**Scope decisions locked (2026-11-08):**

- **(f) First:** **settings/language** (smallest, self-contained) — it fills the
  N1 drawer Settings stub and makes VI/EN switchable at runtime.
- **(g) Trainer flow = milestone-wrapped.** Opening an HSK lesson part shows the
  6-step **milestone bar**; each step runs its activity in place, faithful to the
  web `MilestoneRunner`. We build the shell first, then fill the steps.
- Vietnamese-first throughout; add keys to both ARBs.

## The six-step milestone (the target shape)

One HSK (or book) lesson part runs as six steps (`MilestoneRunner.tsx` /
`useLessonMilestone`), each reusing one web component:

| # | Step | Web component | Kind | Status after N1–N3 |
| - | --- | --- | --- | --- |
| 1 | Vocab Summary | `WordSummary` | passive (Continue) | to build (N8) |
| 2 | Vocab Learner | `FlashcardStudy` | passive | to build (N8) |
| 3 | Vocab Trainer | `VocabTrainerPage` | graded | to build (N7) |
| 4 | **Lesson Summary** | `LessonSummary` | passive | **done — the reader (N2/slice 5)** |
| 5 | Lesson Learner | `LessonCardStudy` | passive | to build (N8) |
| 6 | Lesson Trainer | `LessonTrainerPage` | graded | to build (N6) |

Passive steps (1, 2, 4, 5) complete on **Continue**; graded steps (3, 6) record
themselves and advance after their recap. Gating is **soft** — the bar's segments
jump to any step. State comes from `GET /api/lesson/milestone`; a part finishes via
`POST /api/lesson/part-complete`.

## Slices (ordered by the locked sequence)

### Slice N4 — Settings & language · S–M · (roadmap R3 subset) — FIRST

Fills the N1 drawer **Settings** stub with a real screen and makes the UI language
switchable at runtime. Ported from `components/layout/LearnerSettingsModal.tsx` +
`lib/api/learner/userSettings.ts`.

- **Language switch (VI/EN):** the app already ships both locales; add a
  `localeProvider` (Riverpod) that drives `MaterialApp.locale`, persisted locally
  (`flutter_secure_storage` / prefs) **and** to the server via
  `POST /api/user/ui-language`; seed from `AuthUser.uiLanguage` on launch.
- **Hanzi script + font:** persist via `POST /api/user/{hanzi-script,hanzi-font}`
  and store on the user; the **runtime CJK font swap stays deferred** (Slice R-UI
  note) — this slice saves the preference, it doesn't re-render glyphs yet.
- **Screen:** `features/settings/` module — `SettingsScreen` (a form of selects /
  segmented controls) reached from the drawer (replace the stub `comingSoon`
  with `context.push('/settings')`); route `/settings` pushed over the shell.
- **Endpoints:** `GET/POST /api/user/ui-language`, `POST /api/user/hanzi-script`,
  `POST /api/user/hanzi-font`. `AuthUser` already carries all three fields.
- **i18n:** `nav.settings` exists; add the settings screen's own keys.

### Slice N5 — Milestone shell (soft-gated runner) · M · (roadmap R5d-first)

Turn the lesson part from "the reader only" into the **6-step milestone frame**,
with the reader living as step 4 and the other five steps as "coming soon" panels
until N6–N8 fill them.

- **New module** `features/milestone/`: `MilestoneRunner` (hosts the active step
  + Continue/Quit chrome) and `MilestoneBar` (6 numbered segments + connectors +
  "Bước N/6 · <title>" caption), ported from `MilestoneBar.tsx` /
  `MilestoneRunner.tsx`. Use the **approved milestone-bar design** already
  documented in this plan's Slice R5a note (28×28 badges, sage/teal states).
- **Routing:** `/lesson/:passageId` becomes the milestone runner (reader = step 4);
  accept `?step=` to deep-link a step. Books parts reuse the same runner.
- **State:** `features/milestone/data/milestone_repository.dart` →
  `GET /api/lesson/milestone`; `lessonMilestoneProvider`. Passive-step Continue and
  part completion → `POST /api/lesson/part-complete`.
- **This slice:** only **step 4 is live**; steps 1/2/3/5/6 render a stub step panel
  ("coming soon") so the bar, navigation and gating are all exercised end-to-end.
- **Defer:** cross-part "Next rolls to the next part" advance (web `passageIds`
  path) — single-part first.

### Slice N6 — Lesson Trainer (step 6) · L · (roadmap R5a)

The graded lesson trainer — the core loop, and the one with an **approved mockup
set** to port rather than re-deriving from web CSS.

- **Module** `features/lesson_trainer/`: `LessonTrainerPage` (runner shell + sticky
  bottom bar), the four task widgets — `ChoiceTask` (listening + meaning MCQ),
  `TypingTask`, `ReorderTask` — and `LessonTrainerRecap`.
- **API:** `POST /api/lesson/start` → `{ session_id, tasks: LessonTask[] }`;
  per-answer `POST /api/lesson/submit`; `POST /api/lesson/part-complete`. Model
  `LessonTask` (`type` listening|meaning|typing|reorder; `content`,
  `correct_answer`, `options?`, `tokens?`/`shuffled_tokens?`, `pinyin?`,
  `audio_key?`), `fromJson` validated (rule 6).
- **Approved UI (use these, not a CSS port):**
  - `mockup/approve design/lesson_trainer_typing/{code.html,DESIGN.md,screen.png}`
    (typing task — the shell, milestone header, task card, sticky bar; already
    transcribed in this plan's R5a note).
  - `.stitch/designs/lesson-trainer-{choice,listening,typing,reorder,recap,popup}-mobile.html`
    (+ `.png`) — the choice/listening/reorder tasks, the recap, and the result popup.
- **Audio:** listening tasks need line audio → bring in **Slice R0 (audio)** here
  or just before (`just_audio`, native flags). Mark typing/reorder playable without
  it so the slice can land audio-last.
- **Wire into N5:** step 6 mounts `LessonTrainerPage`; on recap-done the runner
  re-reads the milestone and advances.

### Slice N7 — Vocab Trainer (step 3) · L (multi-slice) · (roadmap R5c)

The largest piece: the vocabulary trainer and its question-type widgets.

- **Module** `features/vocab_trainer/`: `VocabTrainerPage` + `VocabTrainerRecap`,
  and the question types ported incrementally from
  `components/page/learner/practice/question-types/` (`MCOptions`, `Reorder`,
  `BlankedContent`, `ImageOptions`, `KeyButtons`, `TrueFalse`, `T5*Group`,
  `Type2/6Group`, `SingleGroup`) + the simpler `vocab-training/{MatchActivity,
  TypingActivity}`.
- **API:** `/api/vocab/{words, submit-batch}` (batch the answers like the web
  Phase-0 seam); `lookup-batch` for popups.
- **Split:** land `MCOptions`/`TrueFalse`/`TypingActivity` first (cover most tasks),
  then the grouped/visual types. Image/`ImageOptions` and audio types depend on
  Slice R0.
- **Wire into N5:** step 3 mounts `VocabTrainerPage`.

### Slice N8 — Learners & summaries (steps 1, 2, 5) · M · (roadmap R5b)

The passive flashcard/summary steps that round out the milestone.

- `WordSummary` (step 1 — vocab list for the part), `FlashcardStudy` (step 2 —
  vocab flashcards), `LessonCardStudy` (step 5 — lesson-line cards). All passive:
  Continue completes the step.
- Reuse `/api/lesson/vocab/:id` (have) and the lesson passage detail (have); vocab
  flashcard audio and stroke order depend on Slice R0.
- **Wire into N5:** steps 1/2/5 replace their stub panels.

## Build order & rationale

1. **N4 Settings/language** — first (locked): small, self-contained, finishes the
   N1 drawer and unlocks runtime VI/EN.
2. **N5 Milestone shell** — the frame every trainer plugs into; step 4 already real.
3. **N6 Lesson Trainer** — has approved mockups (lowest design risk of the trainers).
4. **N7 Vocab Trainer** — largest; sequence its question types.
5. **N8 Learners/summaries** — fill the remaining passive steps.
6. **Slice R0 (audio)** — cross-cutting; pull in with N6 (listening) at the latest.

**Still deferred this round:** grammar/translation panels (R6), profile & stats
(R3 remainder — the "dashboard" number cards), exam/pinyin/competition (R6), the
HSK1 pinyin/number special-cases, and picker progress bars (R2).

## Key source references (round 2)

- Milestone: `components/page/learner/milestone/{MilestoneBar,MilestoneRunner}.tsx`
  (+ `milestone.css`); `hooks/lesson/{useLessonMilestone,useLessonOverview}.ts`;
  `lib/api/learner/milestone.ts`.
- Lesson trainer: `components/page/learner/lesson-training/{LessonTrainerPage,
  ChoiceTask,TypingTask,ReorderTask,LessonTrainerRecap}.tsx` (+ `lesson-trainer.css`);
  `lib/api/learner/lessons.ts` (`startLessonSession`/`submitLessonAnswer`/
  `completeLessonPart`); `LessonTask` in `lib/types/lesson.ts`;
  `service/lesson_task_service.py` (`build_lesson_tasks`).
- Vocab trainer: `components/page/learner/vocab-training/*` +
  `components/page/learner/practice/question-types/*`; `lib/api/learner/vocab.ts`.
- Learners/summaries: `components/page/learner/{lesson/WordSummary,lesson/LessonSummary,
  vocab-learning/FlashcardStudy}.tsx`, `LessonCardStudy`.
- Settings/language: `components/layout/LearnerSettingsModal.tsx`,
  `lib/api/learner/userSettings.ts`, `components/i18n/I18nProvider.tsx`.
- Approved mockups: `mockup/approve design/lesson_trainer_typing/`,
  `.stitch/designs/lesson-trainer-*-mobile.html`.

---

# Next up (round 3) — Full learner parity: trainer completion, dashboard surfaces, secondary content, register, competition

_Added 2026-11-10._ A fresh gap audit of the shipped app vs. the web learner
(`app/learner/*`), **excluding `/manage`**, drives this round. Scope decision this
round: **close the remaining parity gap in full** — nothing below is deferred.

## Current reality (what is actually built, 2026-11-10)

More shipped than the earlier roadmap forecast. The **six-step milestone flow is
fully wired** — `milestone_screen.dart` mounts real widgets for every step, not
stubs: step 1 `WordSummaryView`, step 2 `FlashcardStudyView`, step 4
`LessonStudyView` (reader), step 5 `LessonCardStudyView`, step 3 `VocabTrainerPage`,
step 6 `LessonTrainerPage`. (The `milestone_screen.dart` header comment still says
"ships only step 4 live" — **stale, fix it**.) Also done: auth/login, shell+drawer,
tabbed home, Books, HSK/Library picker, settings + runtime VI/EN, lesson trainer
(choice/typing/reorder + recap).

So the remaining gap is narrower and specific:

| Web surface | Status now | This round |
| --- | --- | --- |
| Vocab trainer question types | **only 2 of 13** (`MatchActivity`, `TypingActivity`); the 11 `question-types/*` widgets unported | **P2** |
| Audio (listening tasks, vocab/lesson audio) | buttons stubbed app-wide | **P1** |
| Stroke order | stubbed; backend `/api/chinese_stroke_info` exists | **P1** |
| Profile & learning stats (`/learner/profile`) | not built | **P3** |
| Home **Review** tab (SRS) | "coming soon" stub | **P4** |
| Home **Recommend** tab | "coming soon" stub | **P5** |
| Grammar panel (`/learner/grammar`) | not built | **P6** |
| Translation (`/learner/translation`) | not built | **P7** |
| Exam (`/learner/exam`) | not built | **P8** |
| Pinyin lessons (basic/advanced) | not built | **P9** |
| Register / sign-up | login-only; backend `/api/auth/register` **exists** | **P10** |
| Competition / Learn Together (realtime) | not built; backend SocketIO exists but session-cookie auth | **P11** |

## Locked decisions (2026-11-10)

- **(h) Scope:** full parity — all rows above are IN this round. `/manage` stays out.
- **(i) Order:** **finish the core in-lesson loop first** (P1 audio/stroke, P2 vocab
  question types), then dashboard surfaces (P3–P5), then secondary content (P6–P9),
  then register (P10), then competition last (P11).
- **(j) Backend:** backend work in `Learning/` (`dev_version_2.0`) is **in scope**
  this round, as Phase 0 was — primarily the competition socket token-auth (P11).
- **(k) Stroke order:** **native** Flutter rendering (CustomPainter / stroke package)
  driven by `/api/chinese_stroke_info`, not a hanzi-writer WebView.
- **(l) Register:** **add** the mobile sign-up screen (backend endpoint already live).
- **(m) Competition:** **in** this round (reverses the earlier R6 deferral).

## Slices (ordered by the locked sequence)

### P1 — Audio & stroke order (cross-cutting) · S–M · (was Slice R0)

Wire the stubbed buttons in the reader, word popup, flashcards and trainer.

- **Audio:** `just_audio` (recommended) — play `audio_key` lines and vocab audio from
  GCS (`/lesson_audio/*`, `/audio/*` redirects). **Native setup required (human):**
  iOS background-audio mode, Android `INTERNET` (CLAUDE.md 1.4).
- **Stroke order (native):** a Flutter stroke renderer fed by `/api/chinese_stroke_info`
  — model + `strokeProvider`, `fromJson` validated (rule 6); a `StrokeOrderView`
  widget (CustomPainter animating the stroke paths). Evaluate `stroke_order_animator`
  or a custom painter; **flag any new dep for human setup**.
- **Unblocks** listening-type lesson-trainer tasks and vocab audio types in P2.

**Shipped (2026-11-10):** `core/media/gcs.dart` (GCS audio URL helpers mirroring
`lib/audio.ts`), `core/audio/audio_player.dart` (`just_audio` wrapper +
`audioPlayerProvider`). Wired: the reader's per-line play + Auto Play (all lines
in order) and the word-popup Listen button. Android INTERNET permission added.
**Stroke order:** `stroke_order_view.dart` (native `stroke_order_animator`,
Animate/Practice/Reset, per-character tabs) toggled from the word-popup Stroke
button; character paths fetched from the Hanzi Writer jsDelivr CDN at runtime
(`downloadStrokeOrder`) — the backend `/api/chinese_stroke_info` is **not** used
(counts only). i18n keys added to both ARBs. **Not yet wired** (their own slices):
flashcard/lesson-card audio buttons (new UI, not existing stubs) and the
listening lesson-trainer task (the trainer currently filters listening out — N6).
**Human setup:** Windows local builds need Developer Mode on (plugin symlinks);
iOS foreground playback needs no Info.plist change. Not runtime-tested on a device.

### P2 — Vocab trainer question types (complete step 3) · L, multi-slice · (roadmap R5c)

Port the 11 missing widgets from `components/page/learner/practice/question-types/`
into `features/vocab_trainer/widgets/`, reusing the existing page/recap/bottom-bar.

- **Batch 2a (text, no media):** `MCOptions`, `TrueFalse`, `BlankedContent`,
  `Reorder`, `KeyButtons`.
- **Batch 2b (grouped):** `SingleGroup`, `Type2Group`, `Type6Group`,
  `T5ReadingMatchGroup`.
- **Batch 2c (media — needs P1):** `ImageOptions` (images), `T5ListeningGroup` (audio).
- **Model/API:** extend `TrainerWord` / activity models for the new `type` payloads;
  `/api/vocab/{words, submit-batch}` already wired. Port `question-types/types.ts`
  + `Feedback.tsx` behavior. Each `fromJson` validated (rule 6).

**REFRAMED (2026-11-10):** this framing was wrong. The `question-types/*` widgets
are **not** part of the milestone vocab trainer — **milestone step 3 is already
complete** (`VocabTrainerPage` uses `MatchActivity`/`TypingActivity`, ported from
the web `vocab-training/`, and never touched `question-types/`). The 11 widgets
are building blocks of a separate ~1,900-line **Practice engine**
(`practiceEngine.ts` + `groupState.ts` + `PracticeRunner` + `QuestionGroup` + the
group layouts), driven by `/api/practice/*` — the backbone of **Recommend (P5),
Exam (P8) and Practice**. So P2 is **"build the Practice engine"** as a new
`features/practice/` module, not a change to step 3. Decision locked 2026-11-10:
build the Practice engine.

Build order inside P2:
- **P2-foundation (done 2026-11-10):** `features/practice/data/` — models
  (`practice_question.dart`: `PracticeCategory`/`PracticeQuestion`/`PracticeGroup`/
  `PracticeSessionData`, validated; `practice_answer_row.dart`), `practice_engine.dart`
  (classify/tokenize/score, pure), `group_state.dart` (`GroupUIState` + transitions),
  `practice_repository.dart` (`/api/practice/{<n>, <n>/<lesson>, .../<progress>, multi,
  submit}`). `flutter analyze` clean.
- **P2-runner (done 2026-11-10):** `screens/practice_runner_page.dart`
  (`PracticeRunnerPage` + `PracticeOptions`) — the full session state machine
  ported from `usePracticeEngine` (load → per-group answer state → Check → Finish/
  submit → result), one phone layout (topbar + question card + nav). `widgets/
  question_group.dart` dispatches by `classifyGroupLayout`. `widgets/practice_audio.dart`
  = shared `just_audio` controller + `AudioControl` (play/stop, ±5s, scrubber).
  `styles/practice_styles.dart`. Route `/practice/:level/:lesson` (`?category=&progress=`)
  added to `core/router.dart`.
- **P2-widgets (done 2026-11-10):** group layouts `single_group.dart`,
  `type2_group.dart`, `type6_group.dart`, `t5_reading_match_group.dart` (text +
  image modes), `t5_listening_group.dart`; building blocks in `option_widgets.dart`
  (`MCOptions`/`TrueFalse`/`KeyButtons`/`ImageOptions`), `reorder_chips.dart`,
  `blanked_content.dart`, `feedback.dart` (`QNum`/`AnswerFeedback`/`GroupFeedback`).
  `group_props.dart` = the `GroupCallbacks` contract. ~30 `practice.*` i18n keys in
  both ARBs. `flutter analyze` clean.
- **P2 remaining:** the launch surfaces are deferred to their slices — the
  Recommend picker (P5) and the Exam/Practice lesson pickers (P8) are what call the
  runner with real params; today it is reachable only by the `/practice/...` deep
  link. Han text renders plainly (CJK font swap still deferred). Not runtime-tested
  on a device.

### P3 — Profile & learning stats (the real dashboard) · M · (roadmap R3 remainder)

New module `features/profile/`, ported from `components/page/learner/profile/*`.

- **Endpoints:** `/api/user/{global-stats, learned-words-last-3-days,
  time-learned-last-3-days, profile-summary}`, `/api/user/learned-vocab/query`.
- **Screens:** `ProfileScreen` (stat cards + 3-day activity charts + learned-vocab
  list with loading/empty states, rule 4.5). Route `/profile`; enable the drawer
  profile row (currently disabled). **New dep:** `fl_chart` (flag for human setup).

**Shipped (2026-11-10):** `features/profile/` — models (`global_stats.dart`,
`activity_day.dart`, `learned_vocab.dart`, all validated), `profile_repository.dart`
+ `profile_providers.dart` (`/api/user/{global-stats, learned-words-last-3-days,
time-learned-last-3-days, learned-vocab/query}`), `ProfileScreen` (header from
`AuthUser` + Learning Statistics block + paginated Learned Words list),
`widgets/{mini_bar_chart,learning_statistics}.dart`, `profile_styles.dart`. Route
`/profile` added; the drawer **header** (avatar + username) now opens it. ~13
i18n keys in both ARBs. **No `fl_chart`** — the web's `MiniBarChart` is plain divs,
so the bars are Containers (no new dep / native setup). `flutter analyze` clean.
**Deferred:** the practice-review history panel (`ReviewPanel` → P4 Review) and the
account forms (avatar/password). `profile-summary` isn't fetched — the header reads
the in-memory `AuthUser`. Not runtime-tested on a device.

### P4 — Review tab (SRS) · M · (home half of roadmap R4)

Replace the Review stub in `features/home/widgets/review_tab.dart` with the real SRS
flow, ported from `components/page/learner/vocab-review/*`.

- **Endpoints:** `/api/vocab/{review/count, review/query, submit-batch,
  review-recent/query, has_history}`. The due-count badge is already fetched for the
  tab label — wire the panel body. Reuses P2 question-type widgets where shared.

**Shipped (2026-11-10) — CORRECTED:** the web Review tab is **watch-only**, not an
SRS grading engine — it has **no submit-batch** and reuses the vocab page's study
tools, not the P2 question-types. Built: `shared/data/vocab_row.dart` (`VocabRow` /
`VocabPage`, promoted so profile + review share it, rule 2; **profile's
`LearnedVocabRow` was migrated to it**); `features/review/` —
`review_repository.dart` (+ `reviewCountProvider`) over
`/api/vocab/{review-recent/query, review/query, review/count}`, `ReviewView`
(two tabs **Recent / Review**, 50/page ≤ 2 pages, numbered pager, reveal
pinyin/meaning toggles, per-word audio via the core player), `review_styles.dart`.
`home/widgets/review_tab.dart` now mounts `ReviewView`; the home **Review tab shows
the due-count badge** (`reviewCountProvider`). ~13 i18n keys in both ARBs.
`flutter analyze` clean. **Deferred:** stroke order in the review cards (the viewer
lives in the lessons module — promote to `shared/` when needed), and the profile
**practice-review history** panel (`ReviewPanel`, a separate `/api/practice/history`
surface). Not runtime-tested on a device.

### P5 — Recommend tab · M · (home half of roadmap R4)

Replace the Recommend stub (`recommend_tab.dart`), ported from
`components/page/learner/recommend/*`.

- **Endpoints:** `/api/practice/recommend` + practice history/sessions. Launches
  practice sessions that reuse the P2 vocab-trainer widgets.

**Shipped (2026-11-10):** `features/recommend/` — `recommended_practice.dart`
(validated), `recommend_repository.dart` (`getRecommendations` over
`/api/practice/recommend`; `getHasHistory` over `/api/vocab/has_history` to tell
new-user from empty), `RecommendView` (loading / error / empty / new-user / ready
states), `RecommendCard` (HSK + skill + category + status badges, progress +
question-count, recent-word focus, Start), `recommend_styles.dart`. Tapping a card
launches the **P2 `PracticeRunnerPage`** in `multi` mode with a one-item queue
(`PracticeMultiItem` level/lesson/progress/category); on return the feed reloads.
`home/widgets/recommend_tab.dart` now mounts `RecommendView`. ~19 i18n keys in both
ARBs. `flutter analyze` clean. **Deferred (mobile adaptation):** the web filter bar
(level/skill/category/status), the multi-select batch bar, and pagination — a tap
starts a single group. Not runtime-tested on a device.

### P6 — Grammar panel · S · (roadmap R6)

Grammar on the study screen / a grammar surface, ported from
`components/page/learner/grammar/*`. **Endpoint:** `/api/lesson/grammar/:id` (learner
grammar; `/api/admin/grammar_*` is manage — do not use).

**Shipped (2026-11-10):** in the **lessons** module (grammar is lesson-wide) —
`data/models/lesson_grammar.dart` (`LessonGrammarRule`, validated, + the
`splitGrammarSections` type-1 splitter), `getLessonGrammar` on `lesson_repository`
+ `lessonGrammarProvider`, `widgets/grammar_panel.dart` (renders types 1–5:
title / description / cn~vn example / context table or ref / dialogue,
language-aware VN↔EN with fallback), `screens/grammar_screen.dart` with
loading/error/empty states. Route `/grammar/:passageId`; the **milestone study
screen's app bar** gained a grammar action that opens it for the current passage.
3 i18n keys in both ARBs. `flutter analyze` clean. Not runtime-tested on a device.

### P7 — Translation · S · (roadmap R6)

`features/translation/` from `components/page/learner/translation/*`. **Endpoint:**
`/api/translation/lesson`.

**Shipped (2026-11-10):** in the **lessons** module (lesson-scoped, like grammar) —
`data/models/translation_row.dart` (`TranslationRow`, validated),
`getLessonTranslations(hskLevel, lesson)` on `lesson_repository` +
`lessonTranslationsProvider` (keyed by passage id, parsing `H<level>_<lesson>_…`),
`widgets/translation_drill.dart` (the flashcard drill — meaning in the UI language,
a Chinese input that highlights green on a match, reveal toggle, Prev / Shuffle /
Next, progress bar), `screens/translation_screen.dart` with loading/error/empty.
Route `/translation/:passageId`; the **milestone study screen's app bar** gained a
translate action beside grammar. ~9 i18n keys in both ARBs. `flutter analyze` clean.
Not runtime-tested on a device.

### P8 — Exam · M · (roadmap R6)

Exam flow from `app/learner/exam/*`. Endpoints under the learner exam/practice
blueprints — confirm exact routes against `lib/api/learner/*` when building.

**Shipped (2026-11-10):** exam is the shared practice pickers with
`category=exam`, and the **P2 runner already handles exam** — so this was just the
pickers. In the **practice** module: `widgets/exam_levels_view.dart` (HSK 1–6 grid,
body-only), `screens/exam_lessons_screen.dart` (+ `examLessonsProvider` over
`getLessons(level, exam)` → `/api/practice/<level>?category=exam`). Tapping a
lesson opens the P2 runner via `/practice/:level/:lesson?category=exam`. The
**Library** gained an **Exam** tab (`HSK | Books | Exam`) mounting `ExamLevelsView`;
route `/exam/:level` added. ~5 i18n keys in both ARBs. `flutter analyze` clean.
**Deferred:** the separate Practice (exercise) picker — the Recommend home tab
already launches practice sessions. Not runtime-tested on a device.

### P9 — Pinyin lessons · M · (roadmap R6)

Basic/advanced pinyin from `components/page/learner/pinyin/*` +
`app/learner/lesson/{basic,advanced}-pinyin`. Includes the deferred HSK1 special
cases (`PINYIN_PASSAGE_ID` `H1_1_1`, `NUMBER_PART_ID` `H1_5_99`).

**Shipped (2026-11-10) — BASIC:** in the **lessons** module —
`data/pinyin_data.dart` (the static basic grid + pronunciation hints, ported
1:1), `widgets/basic_pinyin_table.dart` (the 8-column initials/finals/tones grid;
tap a cell → recorded audio via the core player + a pronunciation-hint snackbar),
`screens/pinyin_guide_screen.dart` (Basic / Advanced toggle). Route `/pinyin`; a
**"Pinyin Guide" tile** tops the HSK 1 lesson list (the `PINYIN_PASSAGE_ID`
special case, surfaced). ~10 i18n keys in both ARBs. `flutter analyze` clean.
**Shipped (2026-11-10) — ADVANCED + NUMBERS:**
- **Advanced:** the 401-syllable matrix bundled as `assets/pinyin/advanced_pinyin_data.json`
  (loaded by `advancedPinyinProvider`), parsed into `AdvancedPinyinData`; tone
  helpers (`addTone`/`getTones`) ported into `pinyin_data.dart`.
  `widgets/advanced_pinyin_table.dart` renders the 3 horizontally-scrolling tables;
  tapping a syllable opens its four toned forms, tapping a tone speaks it via a new
  `core/audio/tts_service.dart` (**`flutter_tts`**, since these syllables have no
  recordings — matching the web's `speechSynthesis`). Wired into the guide's
  Advanced tab. **Native setup:** Android device TTS engine (install a Chinese
  voice if missing); iOS uses `AVSpeechSynthesizer` (no config).
- **Numbers:** the backend serves `H1_5_99` through the normal passage/vocab
  endpoints (`number_part.py` → vocab rows), so this is just an entry — a
  **"Numbers" tile** on the HSK 1 lesson list routing to `/lesson/H1_5_99` (the
  milestone shows the number vocab with audio). The HSK1 entry cards were
  generalized to `_Hsk1EntryTile`.

`flutter analyze` clean. New dep: `flutter_tts`. Not runtime-tested on a device.

### P10 — Register / sign-up · S

`RegisterScreen` in the `auth` module → `POST /api/auth/register` (**already live**,
`auth_routes.py:118`). Add a link from the login screen; mirror `app/learner/register`.
No backend work.

**Shipped.** `register_screen.dart` (username/email/password card, reuses
`LoginStyles` + two new footer-link styles); route `/register` with the redirect
guard extended to treat both `/login` and `/register` as the signed-out auth
screens. `AuthRepository.register` + `AuthNotifier.register`: the endpoint returns
the user over a cookie session but **no bearer token**, so register posts then does
a follow-up `/api/auth/token` login to obtain and persist the token (one step for
the caller, no backend change). Reciprocal switch links on both screens
(`noAccountPrompt`/`registerHere`, `haveAccountPrompt`/`loginHere`); password
min-length 8 validated client-side; server 409 ("user exists") surfaced inline.
i18n keys added EN+VI. `flutter analyze lib` clean.

### P11 — Competition / Learn Together (realtime) · L · (backend + Flutter)

Last and largest. Two parts:

- **P11-backend (`Learning/`, `dev_version_2.0`):** the socket authenticates via
  `flask_login.current_user` (session cookie) in `service/competition_socket.py`;
  mobile has no cookie. Authenticate the **SocketIO handshake via the Bearer token**
  (apply the Phase-0 `request_loader` / verify the token on `connect`). Tests for
  authed/unauthed socket connect.
- **P11-flutter:** `features/competition/` — `socket_io_client` dep (**native/human
  setup**), rooms list + realtime session UI, ported from
  `components/page/learner/competition/*`. **Endpoints:** `/api/competition/rooms` +
  socket events (`session_started`, `session_finished`, …) from `competition_socket.py`.

**Shipped.**

- **Backend (`Learning/`, `dev_version_2.0`):** added a `connect` handler in
  `service/competition_socket.py` (`authenticate_socket`): web clients keep their
  cookie session; mobile passes the signed bearer token via the socket.io `auth`
  option (or `Authorization` header), which it verifies with `load_auth_token` and
  binds via `login_user`, so all 11 existing `current_user` handlers work unchanged.
  Anonymous/tampered handshakes are rejected. Tests:
  `tests/service/test_competition_socket_auth.py` (4, green) — token-in-auth,
  token-in-header, anon-rejected, tampered-rejected.
- **Flutter `features/competition/`:** `socket_io_client: ^3.1.2`.
  - `data/models/competition_models.dart` (all 9 socket/REST shapes),
    `data/room_logic.dart` (pure port of `roomLogic.ts`: parse/group/summary/type
    options/collectRoomSettings/lessonItemKey),
    `data/competition_socket.dart` (typed socket wrapper; token in `auth` +
    header; polling+websocket transports to match the threading-mode backend),
    `data/competition_repository.dart` (createRoom / book-passages / book-words /
    resolveWords / saved-books).
  - `providers/competition_controller.dart` — one `ChangeNotifier` porting
    `useCompetitionRoom` + `useCompetitionSetup` + `useCompetitionSources` (the
    state machine, every room action, and the HSK/Book → Lesson → Part cascade).
  - `screens/` — `CompetitionPage` shell + `setup_view` / `lobby_view` /
    `section_view` / `waiting_view` / `ranking_view`; `widgets/` —
    `competition_multi_select` (grouped bottom-sheet picker), `ranking_list`;
    `styles/competition_styles.dart`.
  - The section trainer **reuses the solo trainers' widgets** — `TypingActivity` /
    `MatchActivity` (vocab) and `ChoiceTask` / `TypingTask` / `ReorderTask`
    (lesson) — answering straight over the socket.
  - Route `/competition`; drawer entry enabled (was the deferred "coming soon").
  - i18n: ~60 `competition*` keys EN+VI. `flutter analyze lib` clean.
  - **Divergences (noted):** vocab rooms build typing+reading only (the solo vocab
    trainer has no audio/listen yet), so the room's `activity_type` filter is not
    applied to vocab; listening lesson tasks are filtered out (audio-less, matching
    the solo lesson trainer); vocab answers report `response_time_ms: 0` (the solo
    vocab widgets don't track response time — the backend defaults it to 0).
  - **Native/human setup:** `socket_io_client` 3.x speaks Socket.IO v4 (compatible
    with Flask-SocketIO); Android INTERNET permission was added in P10; iOS local
    (`http://`) dev needs an ATS exception in `Info.plist` if testing against a
    non-TLS backend.

## Build order & review units

P1 → P2 (2a→2b→2c) → P3 → P4 → P5 → P6 → P7 → P8 → P9 → P10 → P11 (backend then
Flutter). Each slice is an independent review unit; **no commits until each is
reviewed** (CLAUDE.md 3.3). New deps to flag for human setup: `just_audio`, a stroke
package, `fl_chart`, `socket_io_client`.

## Housekeeping this round

- Fix the stale header comment in `milestone_screen.dart` (all six steps are live).
- Add i18n keys to **both** `app_vi.arb` + `app_en.arb` for every new surface;
  source EN values in `yi-chinese-manage/lib/i18n/en.json`.

## Key source references (round 3)

- Vocab question types: `components/page/learner/practice/question-types/*`,
  `components/page/learner/vocab-training/*`; `lib/api/learner/vocab.ts`.
- Profile/stats: `components/page/learner/profile/*`; `lib/api/learner/dashboard.ts`.
- Review/Recommend: `components/page/learner/{vocab-review,recommend}/*`;
  `lib/api/learner/{vocab,practice}.ts`.
- Grammar/Translation/Exam/Pinyin: `components/page/learner/{grammar,translation,pinyin}/*`,
  `app/learner/{exam,lesson}/*`.
- Register: `app/learner/register/page.tsx`; `Learning/web_app/routes/auth/auth_routes.py:118`.
- Competition: `components/page/learner/competition/*`;
  `Learning/web_app/service/competition_socket.py`, `routes/competition/competition_routes.py`.
- Stroke data: `Learning/web_app/routes/chinese_stroke_info/chinese_stroke_info_routes.py`.
