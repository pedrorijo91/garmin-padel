# Plan 1: Switch set format mid-match (final tie-break / super tie / mini set)

- **Status:** **Built**, in review in [#155](https://github.com/pedrorijo91/garmin-padel/pull/155) (for [#146](https://github.com/pedrorijo91/garmin-padel/issues/146)), not merged or released yet. Rebased on the warm-up lap (plan 5, #154). The user's decisions below changed the design: the switch works at any moment of the match, not only at the start of a set. See [User decisions](#user-decisions-override-the-design-below) and [Implementation notes](#implementation-notes).
- **Size:** Small–medium
- **Depends on:** nothing
- **Needed by:** [Plan 2: Training mode](02-training-mode.md), [Plan 3: Timed tournament](03-timed-tournament.md)
- **GitHub:** [#146 "Allow to start tie or super tie"](https://github.com/pedrorijo91/garmin-padel/issues/146)
- Shared context and constraints: [roadmap README](README.md)

## User need

> During friendly matches we sometimes finish a set close to the end of the time slot, so we decide to play a final super tie-break. Today we have to stop the activity and start a new one.

Issue #146 adds that players sometimes choose a **tie-break**, a **super tie-break**, or a **mini set** instead.

## Current behaviour and why it doesn't work

- `MatchEngine.getCurrentSetEngine()` *derives* the set format. It is `decidingSetEngine` (super tie) only when the match is limited, sets are tied and exactly one set is left. Otherwise it is `defaultSetEngine`. You can't say "the next set is a super tie".
- `MatchEngine.resetAfterSetFinish()` formats the result from `isInSuperTieBreak` / `isInTieBreak`:
  - A standalone 7-point tie-break would be recorded as `"0-0 (5)"`.
  - After a super tie it **skips `resetScores()`**. That is fine today, because a super tie always ends the match. In an Unlimited match that continues afterwards, the tie points would carry into the next set.
- No standalone 7-point tie-break engine exists. `GamesSetEngine` has a tie-break only *inside* a set.

## User decisions (override the design below)

Made by the maintainer before the build. Where they differ from the design sections below, these win.

1. **Only in Friendly and Custom matches.** The tournament presets (Tournament, Tournament super, Pro Set Tournament) don't show the option. It is a `MatchConfig` flag set by `GameModes` and the custom flow, not a check on the mode name in the UI.
2. **Only three formats:** Tie-break (first to 7, win by 2), Super tie-break (first to 10, win by 2), Mini set (starts 2-2). No Normal / Pro / Default items.
3. **Available at any moment of the match**, not only at the start of a set. The Options item is "Switch to", not "Next set format".
   - If the current set has no points played yet (games at the engine's initial value, points 0, tie points 0): only the current set's format changes. Nothing is recorded.
   - Otherwise: the unfinished set is **dropped**: nothing is written to the score, and it is **not** awarded to anyone (sets unchanged). Games and points are reset, a lap is added (`lapSession()`) and the chosen format starts immediately. (First built as a `"4-3*"` entry in the score; the user then asked for nothing to be stored on a switch.)
   - A game in progress is discarded and doesn't count in `gamesPlayed`.
   - The switch pushes an undo entry first, so undo restores the dropped set exactly. A lap can't be removed once added; that is accepted.
   - After the chosen format finishes, the next set goes back to the match's default format.
   - Switching again while in a switched format is allowed, with the same rules.
   - **Assumption:** switching mid-set *replaces* the current set; it doesn't *decide* it. See [Open questions](#open-questions).
4. **Super tie results use brackets everywhere:** `"[10-8]"`, including the existing best-of-3 super tie decider. A standalone 7-point tie-break also uses brackets: `"[7-5]"`.

## Design

### Model

1. **Set format constants.** Add a constant set, in `MatchConfig` or a new small `SetFormats` class, that covers every segment format the roadmap needs:
   `FORMAT_DEFAULT (-1)`, `FORMAT_NORMAL`, `FORMAT_PRO`, `FORMAT_MINI`, `FORMAT_TIE_BREAK`, `FORMAT_SUPER_TIE`.
   Plans 2 and 3 will add `FORMAT_FREE` and `FORMAT_TIMED`. Reuse the existing `SET_TYPE_*` values where they map one to one.
2. **Store the chosen format in `MatchStatus`** as `nextSetFormat` (default `FORMAT_DEFAULT`). Use a setter (9-argument constructor limit) and copy it in `copy()`, so **undo restores it**.
   - Choosing a format before the first point and then undoing that point must keep the choice. It is set without a point being scored, so the "choose format" action itself should push an undo entry. Then "undo" right after choosing reverts the choice, which matches what users expect.
3. **`MatchEngine.getCurrentSetEngine()`**: if `nextSetFormat != FORMAT_DEFAULT`, return the engine for that format. Otherwise use the current logic. Build the engines lazily or keep a small cache, to save memory.
4. **Clear the override when the set finishes**, in `resetAfterSetFinish()`, so the following set goes back to the default.
5. **Standalone tie-break engine.** Give `SuperTieSetEngine` a constructor parameter `target` (10 for super tie, 7 for tie-break), e.g. `new SuperTieSetEngine(7)`.
   - Decide what `isInTieBreak` / `isInSuperTieBreak` return for target 7. The view needs to tell them apart for its label. Suggested: a 7-point standalone returns `isInTieBreak = true` and `isInSuperTieBreak = false`, and has no games.
6. **Move result formatting into the engine.** Add `SetEngine.formatResult(status) as String`:
   - `GamesSetEngine`: `"6-4"`, or `"7-6 (5)"` when the set went to a tie-break.
   - `SuperTieSetEngine`: `"10-8"` (super tie) or `"7-5"` (tie-break). Consider brackets, `"[10-8]"`, which is the usual way to write a match tie-break. That would change how the existing best-of-3 super tie is recorded too, so decide on purpose and update `testSuperTie` / `testHistory`.
   - `resetAfterSetFinish()` then calls `formatResult` and **always** calls `resetScores()` unless the match is over. Check that `EndView` and the saved score don't rely on tie scores surviving after the match ends.
7. **Initial games:** `applyInitialGames()` must use the engine for the *next* set after the override is applied, so a mini set chosen as the next set starts at 2-2.
   - Setting the override at 0-0 must also apply initial games immediately (mini set → 2-2).
   - Switching *away* from mini set must reset games from 2-2 back to 0-0.
8. **Match end:** no changes to `isMatchOver()`.
   - Unlimited (Friendly): the user presses Finish.
   - Best-of-3 at 1-1 with super tie off: choosing super tie makes it the 3rd set, and the match ends by itself.

### When the user may change the format

- **MVP:** only at the **start of a set**: games equal to the engine's initial games, all points 0, tie scores 0. This covers the user's case ("we finished a set, then decided").
  - If someone already played a point, they can undo it and then switch.
  - Expose `MatchEngine.canChangeSetFormat()` for the UI.
- **Later (plan 2 needs it):** switch mid-set, recording the partial set as e.g. `"2-1*"`. Not part of this plan.

### UI

1. ~~Move the duplicated Options menu into one helper~~: done in #152 (`ScoreDelegate.pushOptionsMenu()`). Add the new item there.
2. When `canChangeSetFormat()` is true, add the item **"Next set format"**. It opens a submenu: *Tie-break*, *Super tie-break*, *Mini set*, *Normal set*, *Pro set* (optional), *Default*. Mark the current choice in the sublabel.
3. `ScoreView`:
   - Standalone tie-break: hide the "Games:" line and show `Tie: x - y`.
   - Super tie: unchanged (`Super: x - y`).
4. Optional: show a short note (e.g. "Next: Super tie") in the games label while the override is pending and the set hasn't started.

### Recording

- No new FIT fields. The result string goes into history as usual, and the set still causes a lap.

### Serving indicator (plan 4, team level, already on `master`)

The serving indicator must stay correct with the new formats:
- A standalone tie-break / super tie counts as **one game** in the team alternation once won. `MatchEngine.scorePoint` already adds 1 to `gamesPlayed` for any set won. Keep that check **right after** `setEngine.scorePoint(...)` and before `resetAfterSetFinish()`, so the initial games of the next set (mini set 2-2) are never counted.
- Inside a standalone tie-break, `getServingSide()` uses the tie-point rotation only if `isInTieBreak()` or `isInSuperTieBreak()` is true. So the 7-point standalone engine must return true from one of them for the whole set (see Design step 5).
- Setting or clearing the override at 0-0 can change games (mini set 2-2 → 0-0). That happens outside `scorePoint`, so it must **not** touch `gamesPlayed`.

## Test plan (`source/tests/`)

- Unlimited, normal set 6-3, then override super tie, then play to 10-8: history is `["6-3", "10-8"]` (or bracketed, see above); the match is not over; the next set is normal; tie scores are 0.
- Same with a 7-point tie-break, including 7-5 and 8-6 (win by 2).
- Override to mini set after a normal set: games start at 2-2, the set is won at 6-x, and the following set starts at 0-0.
- Best-of-3 at 1-1 with super tie off, override super tie: the match ends after it.
- Undo: undo the first point of an overridden set → the override is still there; undo right after choosing → the override is gone; undo across the set boundary of an overridden set restores the in-progress tie scores.
- `canChangeSetFormat()` is false after one point and true again after undoing it.
- Court-change vibration still fires every 6 points in a standalone tie and super tie (needs a test hook or a manual check).
- Serving (`testServing.mc`): in a standalone tie-break and super tie, the team due to serve serves point 1, then serve changes every 2 points; after it is won the next set starts with the other team; choosing a mini set override at 0-0 doesn't change who serves.
- All existing tests still pass, especially `testSuperTie`, `testHistory`, `testUndoMatch` and `testServing`.

## Acceptance criteria

- In Friendly mode, after finishing a set, a user can pick *Super tie-break* from Options, play it, and save one activity whose score reads like `6-4 / 3-6 / 10-8`.
- Same for *Tie-break* and *Mini set*.
- Undo behaves as described above.
- README "Functionalities", "How to use" and "Match rules reference" are updated.

## Implementation notes

What was built, and where it differs from the design above (mostly because of the [user decisions](#user-decisions-override-the-design-below)):

- **Format constants:** `MatchConfig.FORMAT_DEFAULT (-1)`, `FORMAT_NORMAL (0)`, `FORMAT_PRO (1)`, `FORMAT_MINI (2)` (the same values as `SET_TYPE_*`), `FORMAT_TIE_BREAK (3)`, `FORMAT_SUPER_TIE (4)`. Plans 2 and 3 add `FORMAT_FREE` / `FORMAT_TIMED` here.
- **State:** `MatchStatus.setFormat` (setter, copied in `copy()`), named for the *current* set, not `nextSetFormat`, because the switch applies now. `FORMAT_DEFAULT` = the config decides (the default set type, or the deciding super tie at 1-1 / 2-2 with one set left). `resetAfterSetFinish()` puts it back to `FORMAT_DEFAULT`.
- **Engines:** `MatchEngine` now takes `(sets, gameEngine, defaultFormat, superTie)` and builds every engine with `engineForFormat(format)`. The engine for a chosen format is built on first use and cached in one slot. `PadelMatch` no longer builds set engines.
  - `SuperTieSetEngine(target)`: 10 = super tie (`isInSuperTieBreak` true), 7 = standalone tie-break (`isInTieBreak` true). Both are true for the whole set, so the serving rotation and the court-change vibration (every 6 tie points) work unchanged.
  - New `SetEngine` methods: `hasGames()` (false for the tie-break sets), `isUntouched(status)` (games at the initial value, no game points, no tie points) and `formatResult(status, finished)`: `"6-4"`, `"7-6 (5)"` (only when `finished`), `"[10-8]"`.
- **`MatchEngine.switchSetFormat(format)`** (exposed on `PadelMatch`): returns if the match is over; pushes an undo entry; resets games and scores (a started set is dropped, nothing recorded); sets the format; applies the new engine's initial games (mini set 2-2, or back to 0-0); adds a lap only if the set had started (`isSetStarted()`, i.e. not `isUntouched`). `gamesPlayed` is never changed by it.
- **`resetAfterSetFinish()`** now always resets scores unless the match is over. Before, it skipped `resetScores()` after any super tie, which would have carried tie points into the next set of an Unlimited match. A match that ends still keeps its final tie points (as before).
- **`getHistoricalScores()`** (used for the finish menu, end screen and the saved `game_score`) adds the set in progress: its games once they differ from the initial games (so a mini set at an untouched 2-2 is no longer listed as `"2-2"`), or `"[a-b]"` for a tie-break set with points. Before, a deciding super tie in progress wasn't listed at all.
- **Flag:** `MatchConfig.formatSwitch`, off by default. `GameModes` sets it for Friendly; `MenuGameModeDelegate` copies it from the preset; `MenuNumberSetsDelegate` (first step of the custom flow) sets it on. `PadelMatch.canSwitchSetFormat()` reads it.
- **UI:** Options → **Switch to** (sub-label `Tie / super tie / mini`, or `Drops 4-3` once points are played, from `currentSetResult()`). Its submenu has *Tie-break* (`First to 7`), *Super tie-break* (`First to 10`) and *Mini set* (`Starts 2-2`). The submenu is handled by `ScoreOptionsMenuDelegate` too, to avoid a new class on low-memory devices. No confirmation step: undo covers mistakes. Strings are in `resources/strings/strings.xml`.
- **Score screen:** for a set without games (`!currentSetHasGames()`) the games line is empty and the score line is `Super: x - y` or `Tie: x - y`. No layout changes.
- **No "Next: …" note** on the score screen: the switch applies immediately, so the score screen already shows the new format.
- **Tests:** `source/tests/testSwitchFormat.mc` (12 tests: super tie after a set and back to the default format; tie-break win by 2; mini set (starts 2-2, an untouched 2-2 isn't "started", switching away resets it); a chosen super tie ending a best of 3; a mid-set switch drops the set (games, and a switched super tie); undo (of the switch, of the first point after it, across the end of a chosen super tie); an abandoned set in a Custom best of 3 falls back to the deciding super tie; no switch after the match ends; serving in a switched tie-break (the abandoned game doesn't count) and after a mini switch; preset flags; with the warm-up (laps, undo never back into it)), plus `testHistory.mc` (`7-6 (5)`, super tie `[3-2]` in progress and `[10-8]` final) and `fitString` in `matchUtilsTest.mc`. Overlapping checks were trimmed after review. 136/136 pass with `-l 3` on fenix847mm, fr245, instinct2 and venusq2.
- **Court-change vibration:** not unit-tested (it calls the app directly; no test hook was added). Checked in the simulator: the banner shows at 3-3 in a switched super tie.

## Open questions

- ~~Bracket notation for super tie results (`[10-8]`)~~: adopted everywhere, including the deciding super tie and the standalone 7-point tie-break.
- ~~Should *Pro set* / *Normal set* be in the submenu?~~ No, only the three short formats.
- **Replace or decide?** Switching mid-set *replaces* the current set: the unfinished set counts for nobody. The user may have meant "decide the current set with a tie-break now" (e.g. at 4-3, play a tie-break and the winner takes the set, recorded as `5-3` or `4-3 [7-5]`). Not built; confirm with users.
- **Lap after undo:** undoing a mid-set switch restores the score, but the lap added by the switch stays in the FIT file.
- **FIT string length:** `game_score` is created with `:count => 50`, so it holds 49 characters. A longer string makes `setData` fail with a System Error that `try/catch` can't catch (checked in the simulator: 49 work, 50 crash), so the app stopped and the activity wasn't saved. A long Friendly (about 9 sets) could hit it, even before this plan. `saveSession` now cuts the string to 49 characters with `fitString` (`source/model/fitUtils.mc`), keeping the earliest sets; the later sets are then missing from the saved score. Plan 2's per-lap field would keep them all.
