# Manual device QA checklist — learner app

Hand-run verification for everything ported into the Flutter learner app. The
automated `flutter test` suite covers the pure logic; this covers what it can't —
real API calls, audio, stroke rendering, the realtime socket, and the UI. Run it
on a device/emulator against a running backend.

Legend: `[ ]` to do · note the build/device/date at the top of a run.

---

## 0. Setup (do once per run)

- [ ] Backend running: in `Learning/web_app`, `python app.py` (port 5000); DB reachable.
- [ ] Device reachable to the backend:
  - **Android emulator** — default works (`API_BASE_URL` falls back to `10.0.2.2:5000`).
  - **Physical device / other** — launch with
    `--dart-define=API_BASE_URL=http://<host-LAN-ip>:5000`.
- [ ] Windows desktop build only: Developer Mode on (plugin symlinks).
- [ ] Audio prerequisites: device volume up; **Android** has a Chinese (zh-CN) TTS
      voice installed (for advanced-pinyin TTS); **iOS** uses the built-in voice.
- [ ] iOS against a non-TLS local backend: ATS exception present in `Info.plist`.
- [ ] A test learner account available (or create one in §1).
- [ ] Competition (§16) needs **two** devices/accounts signed in to the same backend.

---

## 1. Auth — login / register / session

- [ ] Launch signed-out → lands on **Login**.
- [ ] Login with bad credentials → inline error, stays on Login.
- [ ] Login with a valid account → lands on Home.
- [ ] Kill & relaunch the app → **auto-logs in** (token persisted), no Login shown.
- [ ] From Login tap **"Register here"** → Register screen.
- [ ] Register: password < 8 chars → inline hint, no submit.
- [ ] Register with an existing username/email → server "already exists" error inline.
- [ ] Register a fresh username/email/password → account created **and** signed in
      (lands on Home without a second login).
- [ ] From Register tap **"Log in here"** → back to Login.
- [ ] Drawer → **Logout** → returns to Login; relaunch stays signed out.

## 2. Home / dashboard

- [ ] Greeting shows the username.
- [ ] **Lesson / Review / Recommend** tab bar present; switching tabs works.
- [ ] Lesson tab shows the current lesson (if any) and opens it.
- [ ] Review tab shows the review **count badge**; list loads.
- [ ] Recommend tab loads (or a clean empty state with no history).

## 3. Library (HSK · Books · Exam · Practice)

- [ ] Open the drawer → **Library**; four tabs: HSK, Books, Exam, Practice.
- [ ] **HSK** tab: HSK 1–6 grid → tap a level → lessons list.
- [ ] **Books** tab: saved books list → tap a book → its lessons.
- [ ] **Exam** tab: HSK 1–6 grid → level → exam lessons.
- [ ] **Practice** tab: HSK 1–6 grid → `/practice/:level` lessons → launches the runner.

## 4. Lesson browse → milestone

- [ ] HSK level → pick a lesson/part → opens the **milestone** screen.
- [ ] The step bar shows all steps; gating prevents skipping ahead where expected.
- [ ] Back/exit returns to the lesson list.

## 5. Milestone study steps

- [ ] **Word summary** tab lists the part's vocabulary; tapping a word shows the popup.
- [ ] **Lesson summary** tab lists the lines.
- [ ] **Flashcards** step: flip cards; audio plays on the front where available.
- [ ] **Lesson-card** / **reading** step renders lines; line audio plays.
- [ ] Completing a step advances the bar; Continue/finish reaches the next step.

## 6. Vocab trainer (incl. listening)

- [ ] Reaches the vocab-trainer step (or via Vocabulary → Start Training, §15).
- [ ] **Typing** activity: type the word; wrong attempt shows feedback; correct advances.
- [ ] **Reading** match: tap word → meaning; correct pair locks green, wrong flashes red;
      board must be fully matched to Continue.
- [ ] **Listening** match: left column shows **speaker buttons** (not characters); tapping
      one **plays the word audio**; match audio → meaning; homophones are never in the
      same group (no two identical-sounding buttons).
- [ ] Group counter increments; recap shows correct/missed; **Retry** re-runs missed words.

## 7. Lesson trainer (incl. listening)

- [ ] **Meaning** (multiple-choice): pick an option; correct green / wrong red; Next advances.
- [ ] **Listening** task: audio **autoplays on load**; a **replay** button re-plays;
      the sentence is hidden until answered, then revealed.
- [ ] **Typing** task: type the sentence; punctuation/space differences are accepted.
- [ ] **Reorder** task: arrange the chips into the correct order.
- [ ] Skip works; recap shows score; **Retry** re-runs missed tasks; finish advances.

## 8. Practice runner (question types)

- [ ] Launch from the Practice tab (§3) and from Recommend (§14).
- [ ] Single/multiple-choice, true/false, key-button and **image** options all render.
- [ ] **Audio** questions play the clip; **image-for-audio** questions show images.
- [ ] Reorder-chips and fill-the-blank (type-6) questions work.
- [ ] Per-group checking + feedback; navigation between questions; final recap with the
      correct score and result tier (trophy/check/chart/retry).

## 9. Exam

- [ ] Exam tab → level → lesson → runner opens in **exam** mode.
- [ ] Same question types behave as in §8; recap scores correctly.

## 10. Grammar & translation

- [ ] Open a lesson's **Grammar** screen → rules render (sections parsed).
- [ ] Open a lesson's **Translation** screen → the drill shows rows; reveal/compare works.

## 11. Pinyin guide

- [ ] Drawer/Library path to **Pinyin** (`/pinyin`).
- [ ] **Basic** tab: tap an initial/final/tone cell → **recorded audio** plays; hint shows.
- [ ] **Advanced** tab: 3 scrolling tables; tap a syllable → its four tones;
      tapping a tone **speaks it via TTS** (needs a zh-CN voice).
- [ ] **Numbers** entry tile → opens the numbers milestone (`H1_5_99`).

## 12. Profile & statistics

- [ ] Drawer header / `/profile` → profile screen with the user header.
- [ ] Learning statistics: the **mini bar chart** renders (learned-words / time).
- [ ] Learned-vocab list loads and **paginates** (scroll/next).

## 13. Review

- [ ] Home → Review tab (or review view): **Recent** and **Review** sub-tabs.
- [ ] Rows paginate; **reveal** toggles show pinyin/meaning; **audio** plays.
- [ ] The review **count** matches the badge on Home.

## 14. Recommend

- [ ] Recommend tab shows history-based cards (or a clean empty state with no history).
- [ ] Tapping a card **launches the practice runner** with that item (multi mode).

## 15. Vocabulary section

- [ ] Drawer → **Vocabulary** (`/vocab`).
- [ ] **Mode chips**: Free, Standard, Book, Unsure, Not-learned, Recent — each loads
      (history modes load immediately; filtered modes prompt for filters).
- [ ] **Standard**: HSK → Lesson → Part cascade; picking a part loads the table.
- [ ] **Book**: pick a saved book → Lesson → Part → table.
- [ ] **Search**: typing filters (debounced); clearing restores the current mode.
- [ ] **Pagination**: prev/next + page status; page changes reload.
- [ ] A word row plays **audio**; the **stroke** button opens the stroke-order sheet.
- [ ] **Flash Cards**: opens the flip-card deck of the current page's words.
- [ ] **Start Training**: the **skill picker** shows Typing / Listening / Reading
      (all on by default) → launches the vocab trainer with the chosen skills.

## 16. Competition — Learn Together (two accounts)

> Sign in on **two** devices (host + member) to the same backend.

- [ ] Drawer → **Learn Together** (`/competition`) → connects (no "could not connect").
- [ ] Host: Setup form — mode (Vocab/Lesson/Book), skill types, HSK/Book → Lesson → Part,
      max users, time limit → **Create Room**; lands in the lobby with a room code.
- [ ] Member device: the **Open Rooms** list shows the new room (live); **Join** works;
      or join by **room code**.
- [ ] Lobby: both members listed; **chat** messages appear on both devices in real time.
- [ ] Host: **Edit Settings** reopens the form and saves; **Start Session** begins for all.
- [ ] Section: the in-room trainer plays (vocab match incl. **listening**, or lesson tasks
      incl. **listening**); the **live scoreboard** updates as each player answers.
- [ ] Finishing shows the **Waiting** screen; when all finish (or time out) → **Ranking**.
- [ ] **Back to Lobby** returns the whole room to the lobby.
- [ ] Token auth: an anonymous socket (signed-out) cannot join (handled server-side).

## 17. Settings

- [ ] Drawer → **Settings**.
- [ ] Switch **UI language** VI ↔ EN → labels across the app change at runtime.
- [ ] Change **hanzi font / script** → persists (survives relaunch).

## 18. Cross-cutting

- [ ] **Audio**: at least one vocab-audio, one lesson-audio, one pinyin-audio and one
      TTS play actually produce sound.
- [ ] **Stroke order**: a character animates (data fetched from the hanzi-writer CDN —
      needs internet); Animate / Practice / Reset work.
- [ ] **Error/empty states**: stop the backend and open a data screen → a clean error
      (not a crash); restart and retry recovers.
- [ ] **i18n**: in Vietnamese, spot-check the new surfaces (vocab modes, competition,
      train picker, practice/exam labels) — no missing-key `[…]` placeholders.
- [ ] **Responsiveness**: phone portrait has no horizontal overflow; safe areas respected.

---

### Known divergences (expected, not bugs)

- Competition vocab rooms build all three skills regardless of the room's `activity_type`.
- Vocab-section training reports `response_time_ms: 0` (no response-time tiebreaker).
- Stroke data comes from the hanzi-writer CDN; advanced-pinyin audio is device TTS.
