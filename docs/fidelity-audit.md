# Web ↔ Flutter fidelity backlog (learner app)

Single source of truth for everything in the Flutter learner app that still
differs from the web (`yi-chinese-manage`) in **layout** or **logic**. Work items
top-down; tick the box and note the commit when done.

**Rule (decided 2026-11-13):** the web CSS/behaviour is the reference. The
approved trainer mockup only governs the trainer's own chrome where it already
exists.

**Method / confidence.** Source-level comparison of web TSX + CSS against the
Flutter widgets/styles, plus an endpoint diff. No screenshots or device runs.
`[C]` = confirmed in code on both sides · `[V]` = needs visual or device
verification · `[N/A]` = web-only (desktop) behaviour, intentionally skipped.

Effort: **S** < ½ day · **M** ≈ 1 day · **L** multi-day / touches several modules.

---

## A. Done (analyzer clean, device check pending `[V]`)

- [x] **A1 Milestone bar** → `milestone.css` (34px badges, outlined pending, teal
  + 1.12 scale current, numbers kept, connector margin/22%).
- [x] **A2 Milestone nav** → Previous / Next on passive steps 1, 2, 4, 5.
- [x] **A3 HSK level grid** → 3/2/1 columns at ≤700/≤440, web card sizing,
  Continue panel above grid (shared `RecentLessonPanel`).
- [x] **A4 HSK lesson list** → cover image, progress bars, count pill, back link,
  web header + search; opens part page; HSK1 L1 → pinyin guide.
- [x] **A5 HSK part page** `/hsk/:level/:lesson` → lesson-colour header, part rows
  with progress, Grammar + Translation entries, `saveRecentLearning`.

---

## B. Logic gaps (behaviour the web has and the app lacks)

Highest value first.

- [x] **B1 · L · Lesson flow continuation** (done in `milestone_screen.dart`: next part, Grammar, Translation, confirm, next lesson; master trainers still B2; HSK1 pinyin/number-part fix-ups not applied to the part list; trainer Quit now steps back like the web). Web `LessonFlow` drives the six-step
  milestone through **every part** of the lesson, then **Grammar → Translation →
  next lesson**, in place from one Previous/Next bar. Flutter's milestone ends at
  step 6 and pops (`milestone_screen.dart`: "cross-part advance deferred").
  Needs: part list context, next-part roll, grammar/translation phases, next
  lesson. `[C]`
- [x] **B2 · L · End-of-lesson master trainers** (done: `MasterTrainerStage`; lesson trainer takes `passageIds` (master mode), vocab resolves the union via `resolveWordsFor`; both now reusable for B3). After the last part the web
  offers confirm → **Master Vocab trainer** → confirm → **Master Lesson trainer**
  (each skippable) before Grammar. Needs lesson-wide (multi-passage) support in
  both trainers (`passage_ids`), which Flutter's `VocabTrainerPage` (words list)
  and `LessonTrainerPage` (single `passageId`) do not have. `[C]`
- [x] **B3 · L · Whole-lesson Exam entry** (done: `lesson_exam.dart`; Exam row on the HSK part page → chooser → skill picker → lesson-wide trainer; web routes are not needed, the screen is pushed directly) on the part page: `ExamEngineChooser`
  (vocab / lesson) → `TrainTypePicker` → lesson-wide trainer. Shares B2's
  multi-passage trainer work; Flutter already has a vocab `showTrainTypePicker`.
  Also covers web routes `lesson-training` and `vocab-training-batch`. `[C]`
- [x] **B4 · M · Home Lesson tab runs the lesson in place** (done: `LessonFlowView` mounted in `lesson_tab.dart`; the old Browse HSK/Books entry cards were dropped as the web has none; no tab-switch guard until B5). Web `LessonTab`
  mounts `LessonFlow` inside the dashboard (+ `?step=` resume); Flutter's tab is a
  Continue card + two entry cards that push `/lesson/:id`. Depends on B1. `[C]`
- [x] **B5 · M · Mid-session guards** (done: home tab bar + nav drawer; Previous/Quit inside the flow unchanged, as on the web). Web blocks switching home tabs while a
  graded trainer runs (`learner-home-guard` stay/leave dialog) and shows a
  "leave session" confirm from the sidebar nav (`nav.leave_session_*`). Flutter has
  neither. `[C]`
- [x] **B6 · M · Trainer quit-confirm modal + Success popup** (done; confetti on a perfect score not ported). Web `TrainerShell`
  has a quit-confirm modal and `SuccessPopup` (complete / perfect, accuracy,
  correct, tasks). Flutter has no dialogs in the trainers (Quit exits directly) and
  shows a recap instead. `[C]`
- [x] **B7 · M · Trainer action in milestone nav** (done via `TrainerActionScope`; Previous mid-session is unguarded until B5). Web portals the trainer's
  Check/Next into the milestone navbar (Quit · Previous · Check/Next, trainer
  bottom bar removed). Flutter trainers keep their own bottom bar on steps 3 & 6,
  so Previous/Next is missing there. `[C]`
- [x] **B8 · M · Study sidebar** (done as a bottom sheet opened from a floating button in the lesson flow; parts + progress, Exam, Grammar, Translation) (`LessonSidebar`): part selection, exam stats,
  jump anywhere in the lesson. Absent in Flutter. A drawer/bottom-sheet on the
  reader is the mobile form. `[C]`
- [x] **B9 · M · Profile: review practices** (done: `review_panel.dart`; no question-audio pause toggle). `ReviewPanel` +
  `ReviewSessionDetail` (`POST /api/practice/history/query`,
  `GET /api/practice/history/:id`) — endpoints unused in the app. `[C]`
- [x] **B10 · M · Profile: avatar upload + change password** (done; `image_picker` added, iOS `NSPhotoLibraryUsageDescription` set; run `flutter pub get` with Developer Mode on). `AvatarModal`
  (`POST /api/user/avatar`, multipart) and `PasswordForm`
  (`POST /api/user/change-password`); plus `GET /api/user/profile-summary` to
  refresh avatar/HSK badge. None exist in the app. Needs `image_picker` (native
  permission config). `[C]`
- [x] **B11 · S · Word popup "Add to list".** Web `WordPopup` has a save toggle
  (`saveEnabled` / `isSaved` / `onToggleSave`); Flutter popup has only
  Listen + Stroke. Confirm the save endpoint in `LessonSummary` (`toggleSaved`)
  first. `[C]`
- [x] **B12 · S · Reader actions — N/A.** The web hides the Learn/Train footer inside the milestone (`hideActions`), and Flutter's reader only exists as milestone step 4, so nothing to port. (Original note:) `LessonSummary` shows "Learn this lesson"
  (hidden for book lessons) and "Train this lesson" buttons when not inside the
  milestone. Missing in Flutter's standalone reader. `[C]`
- [x] **B13 · S · Part progress/“completed” markers in Books.** Web book lesson
  page shows `✓ Completed` per part and `done/total` counts on lessons; Flutter
  book card has the count, check detail rows `[V]`.

---

## C. Layout gaps

- [x] **C1 · M · Books 3-step flow.** Web: books grid → `/books/:code` (lesson
  cards, `done/total`) → `/books/:code/:lesson` (part list, `✓ Completed`).
  Flutter: books grid → detail with **inline-expand** lesson tiles
  (`book_detail_screen.dart`). Same fix as A4/A5 (reuse `PickerHeader`,
  `PickerBackLink`, part rows). `[C]`
- [ ] **C2 · S · Picker polish.** Header colour for HSK lesson list vs web,
  lesson-card hover/lift `[N/A]`, empty/error text colours, search focus ring
  (4px @15%) `[V]`.
- [~] **C3 · M · Trainer chrome (reviewed: the differences — progress track colour/border, counter size, task-card radius/shadow, missing topbar subtitle — come from the approved mockup, left as is; confirm before changing) vs `lesson-trainer.css` / `trainer-shell.css`.**
  Header layout, task card, progress bar, subtitle, counter. The mockup governs
  where approved; diff the rest. `[V]`
- [x] **C4 · M · Reader + word popup** (CSS values already matched; fixed: pinyin/meaning hidden by default, Auto Play Stop toggle, playing-line highlight + scroll-follow, toolbar padding) (`lesson-study.css`, `lesson-summary.css`,
  `word-popup.css`): toolbar, line card, popup sizing. `[V]`
- [x] **C5 · M · Home** (done: pill tab bar, Review · Lesson · Recommend order with Review as default, as on the web; greeting kept although the web home has none; `reviewCountProvider` is now unused) (`home-shell.css`): tab bar, greeting, aside rail,
  recent panel spacing. `[V]`
- [x] **C6 · S · Word summary / flashcards / lesson-card study** (done: phone word summary; flashcards and lesson cards are now the web's typing cards — per-character glow, audio on arrival, Previous/Next/Audio+reveal/Show-hide/Shuffle/Stroke buttons — replacing tap-to-flip)
  (`word-summary.css`, `flashcards.css`, `lesson-study.css`). `[V]`
- [~] **C7 · M · Vocab select / filter / table / cards** (word cards now the web `.vcl-card` layout on both the selection page and the Review tab; Review tab gained Shuffle and the pill study buttons; no per-word selection exists on the web either; filter bar, pager and the card detail sheet not compared)
  (`vocab-select.css`, `vocab-filter-*.css`, `vocab-table.css`,
  `vocab-card-list.css`) and **Review tab**, which on the web *reuses* those same
  components (`selectable={false}`) while Flutter's `ReviewView` is its own list. `[V]`
- [~] **C8 · M · Practice / Exam pickers + runner** (level grid, lesson cards, question blocks, options and True/False restyled to the mint web look; lesson list is still one column (web: 1/2/3), and audio control, image options, reorder chips, topbar and result screen not compared) (`practice-select.css`,
  `practice-shell.css`, question types). All 12 question-type widgets exist;
  verify spacing/typography. `[V]`
- [x] **C9 · S · Recommend page/card/pagination** (done: filter bar, mint selectable cards with level-colour badges, 10-per-page pager, sticky Start Selected bar, new-user CTA) (`recommend-*.css`). `[V]`
- [~] **C10 · M · Profile layout + learning statistics** (header, HSK badge, email and tinted section cards done; statistics chart (`profile-stats.css`) not compared) (`profile-page.css`,
  `profile-stats.css`, `MiniBarChart`). `[V]`
- [~] **C11 · M · Competition (5 screens)** (panels, room bar, member / ranking / chat rows, buttons, inputs and the error box restyled to the sage web palette; screen layouts (setup/lobby grids, chat panel height) and the in-room trainer boards not compared) — structurally mirrored
  (lobby/chat/waiting/section/ranking, 36 strings); layout not compared. `[V]`
- [~] **C12 · S · Login / register**, grammar panel, translation panel, pinyin
  tables. (login already matched; grammar panel, translation drill and the flow breadcrumb done; register and pinyin tables not compared) `[V]`
- [x] **C13 · S · Library tab bar vs `learning-tabs.css`** (done: tab order is now HSK · Books · Practice · Exam, 20px tab padding). `[V]`

---

## D. Confirmed matching / intentionally different

- HSK level list is HSK 1–6 on **both** sides (no HSK 7–9 cards in the web).
- All lesson/vocab/practice **endpoints** the learner flows need exist in the app
  except the ones named in B9–B11 (`practice/history`, `user/avatar`,
  `user/change-password`, `user/profile-summary`, `vocab/lookup`).
- Practice question types: all 12 web components have a Flutter widget.
- Competition: realtime protocol implemented (websocket-only after the
  handshake fix).
- `[N/A]` desktop-only: hover lifts, `ScrollToTopButton`, `CardShortcutLegend`
  (keyboard shortcuts), collapsible desktop sidebar chrome.
- Settings is a screen in Flutter vs a modal on the web — acceptable.

---

## Suggested order

1. **C1** books 3-step (cheap, reuses A4/A5) and **B11/B12/B13** (small gaps).
2. **B6, B7** trainer chrome (quit modal, success popup, nav integration) —
   unblocks B1.
3. **B1 → B4** lesson flow continuation, then in-place home tab, **B5** guards.
4. **B2/B3** multi-passage trainers (largest; backend endpoints already accept
   `passage_ids`? — verify before starting).
5. **B9/B10** profile features; **B8** sidebar.
6. Visual sweeps C3–C13 with screenshots side by side (needs web screenshots at
   ≤480px for each surface).
