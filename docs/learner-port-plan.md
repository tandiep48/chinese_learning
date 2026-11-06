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
