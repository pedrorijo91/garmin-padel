# Plan 5: Warm-up as its own lap

- **Status:** **Done**, merged to `master` in [#154](https://github.com/pedrorijo91/garmin-padel/pull/154) (`a0e4cef`); not in a release yet. The default (currently Yes) and the `warmup_seconds` field are still open for the maintainer to confirm; see [Implementation notes](#implementation-notes) and [Open questions](#open-questions).
- **Size:** Small
- **Depends on:** nothing. Can be built on its own now. Once [plan 2](02-training-mode.md) lands, the warm-up becomes just a `FREE` segment (see "Relation to other plans").
- **GitHub:** none yet
- Shared context and constraints: [roadmap README](README.md)

## User need

> When we start a match there is a warm-up period first. The app doesn't record it as a separate lap.

## Current behaviour (confirmed in code)

- Recording starts as soon as the user finishes setup: `GarminpadelApp.initMatch()` creates the session and calls `session.start()`. Since #152 it is called from `MenuFirstServeDelegate.onSelect` (the "First serve: Us / Them / Skip" step that ends both the preset and the custom flow), right before the score screen is pushed.
- The **only** place a lap is added is `MatchEngine.scorePoint()`, which calls `Application.getApp().lapSession()` when a set is won.
- So **lap 1 = warm-up + the whole first set**. Per-set stats in Garmin Connect (duration, heart rate, calories, steps, if laps are used for them) are wrong for set 1, and the warm-up can't be seen on its own.
- Users who start the app only *after* warming up don't see the problem, but then the warm-up isn't recorded at all. Users who start it before warming up get a lap 1 that's too long.

## Design

### Behaviour

1. After "Start match", recording starts as today, but the score screen opens in a **warm-up phase**:
   - The screen shows **"Warm-up"** and a count-up timer of the warm-up's length, plus heart rate and clock as today. Sets, games and score are hidden or show 0.
   - Up/Down **do not score**.
2. Ending the warm-up:
   - **Recommended:** the **first Up/Down press ends the warm-up and does not score a point.** It adds a lap, switches to the match phase, and gives a short vibration plus a banner "Match started". Nobody is scoring during warm-up, so the first press means "we're starting". This needs no menu.
   - Also an explicit **Options → "Start match"** item during warm-up, for users who prefer it, and for touch devices where a stray tap is likely.
   - Alternative to consider: the first press ends the warm-up **and** scores the point. Rejected for now: a press by accident during warm-up would then add a point too, and scoring the first point immediately is unusual.
3. **Skipping the warm-up:** if the user doesn't want it, they press Up/Down once at the start (that makes a lap of a few seconds). Better: a setup choice **"Warm-up: Yes / No"** (default Yes), shown in the confirm screen of presets and as a step in the custom flow. If No, start straight in the match phase as today.
4. **Back / Finish during warm-up:** same Finish menu as today. Saving an activity that only has a warm-up is allowed.

### Model

- Add a `phase` to `MatchStatus` (setter, copied in `copy()`): `PHASE_WARM_UP` or `PHASE_MATCH`. If plan 2 has landed, use `FORMAT_FREE` as the current segment format instead of a separate field.
- `MatchEngine.incP1` / `incP2` in `PHASE_WARM_UP`: switch to `PHASE_MATCH`, call `lapSession()`, and return `false` without scoring. Decide whether this pushes an undo entry (see below).
- Store `warmUpStartTime` (or the generic `segmentStartTime` from plans 2 and 3) so the screen can show the warm-up's length. Pass the current time in; don't read the clock inside the model.

### Undo

- A FIT lap can't be removed after it is added. So **undo must not go back into warm-up**: the warm-up → match change does **not** push an undo entry, and the undo stack starts empty in the match phase.
- Undo during warm-up does nothing (there is nothing to undo). Hide "Undo last point" from Options in warm-up.

### Recording

- Lap 1 = warm-up, lap 2 = set 1, and so on. Laps can't be named from Connect IQ, so users need to know that the first lap is the warm-up. Say so in the README.
- Optional: a session-level developer field `warmup_seconds` (UINT16 or UINT32), so the warm-up length shows in the activity details next to `game_score`. Field IDs 0–3 are used today (`game_score`, `steps`, `app_version`, `unforced_errors`), so use 4. Keep it optional; laps already show it.
- `steps` stays as it is (whole session).

### UI

- `ScoreView.onUpdate`: when in warm-up, set `setsLabel` to "Warm-up", `gamesLabel` to the elapsed time (`m:ss`) and `scoreLabel` to "" (or "Press to start"). This reuses existing labels, so no per-device layout changes are needed. Check on the Instinct layouts (`resources-instinct*`), where label positions differ.
- Options menu (`ScoreDelegate.pushOptionsMenu()`, the single builder added in #152): in warm-up, show "Start match" and "Finish activity". Hide "Undo last point" and "Unforced error". "Switch server" can stay.
- Serving indicator (plan 4 team level, on `master`):
  - Today "First serve" is asked **before** recording starts, as the last setup step. Simplest: keep it there, so the warm-up happens after the choice. During warm-up `getServingSide()` should return -1 (nothing drawn), and the indicator appears once the match phase starts. `gamesPlayed` is still 0 then, so serving is unaffected.
  - Teams often decide who serves at the end of the warm-up. If that matters, move the "First serve" question to the moment the warm-up ends. That needs a version of `MenuFirstServeDelegate` that doesn't call `initMatch()` (the session is already recording). Users who picked wrong can already fix it with **Options → Switch server**, so this is optional.

## Relation to other plans

- **Plan 2 (training):** a warm-up is just a `FREE` segment at the start. If plan 2 is built first, this plan is mostly "a match session starts with a FREE segment, and the first press ends it". If this plan is built first, design `phase` so it can later be swapped for the segment format, with the same lap and undo rules.
- **Plan 3 (timed tournament):** the session should also start with a warm-up before round 1, using the same mechanism.
- **Plan 1:** no conflict. **Switch to** is not in the warm-up Options menu, and a switch right after the warm-up (nothing played yet) adds no extra lap. `testSwitchFormat.mc` (`switchWithWarmUpTest`) checks both together.

## Test plan

- New match → `PHASE_WARM_UP`; `incP1` → no points scored, `PHASE_MATCH`, `lapSession` called once (needs a test seam, e.g. a counter in a test app or an injectable lap callback), and the undo stack is empty.
- The next `incP1` scores 15-0 as usual.
- Undo right after the warm-up ends does nothing (stack empty); it does not go back to warm-up.
- With "Warm-up: No" → starts in `PHASE_MATCH`, as today.
- Mini set default (2-2 initial games) still applies once the match phase starts.
- All existing tests pass. They create matches directly and must not be affected: default the phase to `PHASE_MATCH` when constructed in tests, or add the warm-up flag to `MatchConfig` with a default of `false` and turn it on only from the UI flow.

## Acceptance criteria

- Start a Friendly match, warm up for 5 minutes, press Up to start, play two sets, save. In Garmin Connect, lap 1 is about 5 minutes (warm-up), lap 2 is set 1 and lap 3 is set 2. The saved score is unchanged (`6-4 / 6-3`).
- The first press doesn't add a point.
- "Warm-up: No" behaves exactly like today.
- README updated (warm-up phase, what lap 1 means).

## Implementation notes

What was built, and where it differs from the design above:

- **Model:** `MatchStatus.phase` (`PHASE_MATCH = 0`, `PHASE_WARM_UP = 1`), set with a setter and copied in `copy()`. The new constructor sets `PHASE_MATCH`, so tests and "Warm-up: No" behave exactly as before. `MatchConfig.warmUp` defaults to `false`; only the setup menus turn it on, and `PadelMatch` then calls `MatchEngine.startWarmUp()`.
- **Ending the warm-up:** `MatchEngine.incP1` / `incP2` start with `if (isWarmingUp()) { endWarmUp(); return false; }`, so the press doesn't score. `endWarmUp()` (also behind Options → **Start match**) sets `PHASE_MATCH`, **clears the undo stack**, and calls `GarminpadelApp.onWarmUpEnd()`. That adds the lap, a 300 ms vibration and a 2 s "Match started" banner (it reuses the court-change banner, whose text is now a resource id held by the app). A second call does nothing.
- **Undo:** never goes back into the warm-up, as designed. Unlike the design, **Switch server stays usable during the warm-up**, and its undo entry is dropped when the warm-up ends. So the plan's "`getServingSide()` returns -1 in warm-up" became: `getServingSide()` is unchanged (so the Switch server sub-label and the flip work), and `ScoreView` doesn't draw the indicator while `isWarmingUp()`.
- **Timing:** the model holds no clock. `GarminpadelApp` stores `System.getTimer()` at `initMatch()` (only when warm-up is on) and when the warm-up ends. `getWarmUpSeconds()` is still counting during the warm-up, fixed after it ends, and -1 without a warm-up.
- **Screen:** `ScoreView.onUpdate` reuses the existing labels after the normal score text is set: `setsLabel` = "Warm-up", `gamesLabel` = "Press to start", `scoreLabel` = elapsed `m:ss` in the large font (the timer is the main number on screen). No layout files changed.
- **Options during the warm-up:** a separate builder, `ScoreDelegate.pushWarmUpOptionsMenu()`: Start match, Switch server, Finish activity, Cancel. `pushOptionsMenu()` only gained an early `return` into it. That keeps the change small next to plan 1, which edits the same builder.
- **Setup:** `MenuWarmUpDelegate` (new file). Presets: a line **"Warm-up: Yes / No"** on the confirm screen, above "Start match"; selecting it flips the value. Custom flow: its own step, **Warm-up: Yes / No**, after the score rule and before First serve. `MenuWarmUpDelegate.WARM_UP_DEFAULT` (currently `true`) is the only place the default is set. Presets apply it in `MenuGameModeDelegate`, and the custom step uses it for the menu focus.
- **First serve:** unchanged, still the last setup step before recording starts. During the warm-up the indicator is hidden; it appears with the first match point.
- **FIT:** built the optional session field **`warmup_seconds`** (ID 4, UINT16, unit `s`, label "Warm-up"). It is only written when the match had a warm-up; if saved during the warm-up it holds the time so far.
- **Tests:** `source/tests/testWarmUp.mc` (9): off by default; starts in warm-up; Up / Down end it without scoring and add exactly one lap (seam: `GarminpadelApp.getLapCount()`); Options → Start match (and a second call does nothing); undo after the warm-up doesn't go back (including a Switch server made during the warm-up); serving kept and switchable in warm-up; mini set 2-2 after warm-up; full 6-4 6-3 match = 3 laps and an unchanged score string.
- **Checked in the simulator** (SDK 9.3.0) on fenix847mm, fr265, fr255, instinct2 and venusq2 with a temporary harness (not committed) that calls the real setup, score and Options delegates and draws `ScoreView` into an off-screen bitmap with each device's layout. All warm-up texts and the banner fit on every device. An app-mode run on fenix847mm saved a FIT file with lap 1 = warm-up (42 s), lap 2 = set 1, lap 3 = set 2, `game_score` `6-4 / 6-3`, `warmup_seconds` 41. **No screenshots yet:** the Mac's screen was locked, so the simulator window couldn't be captured.
- **Plan 2:** `PHASE_WARM_UP` is the placeholder for a `FREE` segment. When plan 2 lands, `isWarmingUp()` becomes "current segment format is FREE", and `endWarmUp()` becomes ending a FREE segment, with the same lap and undo rules.

## Open questions

- Default "Warm-up: Yes" or "No"? Built as **Yes** (one constant to flip). Yes changes behaviour for existing users: their first press won't score. The screen says "Press to start", but it needs a note in the release notes.
- Should the first press end warm-up *and* score? Built as **no**.
- Is the `warmup_seconds` field worth it, or are laps enough? Built (cheap). Removing it means dropping one `createField` block and the `fitField id="4"` entry.
- Remember the last Warm-up choice between matches (`Application.Storage`) instead of resetting to the default each time? Not built.
- Move "First serve" to the end of the warm-up (teams often decide then)? Not built; Options → Switch server works during the warm-up.
