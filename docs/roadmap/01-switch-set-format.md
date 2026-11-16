# Plan 1: Switch set format mid-match (final tie-break / super tie / mini set)

- **Status:** Not started
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

## Open questions

- Bracket notation for super tie results (`[10-8]`): adopt it everywhere, or keep `10-8`?
- Should *Pro set* / *Normal set* be in the submenu, or only the short formats?
