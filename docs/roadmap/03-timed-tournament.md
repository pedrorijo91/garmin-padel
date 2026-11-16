# Plan 3: Timed tournament

- **Status:** Not started
- **Size:** Medium–large
- **Depends on:** [Plan 1: Switch set format](01-switch-set-format.md) (per-set format in `MatchStatus`, `formatResult`) and [Plan 2: Training mode](02-training-mode.md) (the `FREE` segment, segment timer, per-segment laps and the lap score field)
- **GitHub:** [#27 "Allow different game modes"](https://github.com/pedrorijo91/garmin-padel/issues/27) lists "timed tournament (N games with X minutes each)". The issue is closed but this item was never built. A comment there also links a user email asking for "games per time or infinite set".
- Shared context and constraints: [roadmap README](README.md)

## User need

> Time-based tournaments: e.g. 90 or 120 minutes in total, made of 10, 15 or 20 minute **time-limited sets** that do not stop at 6 or 9 games; they continue until time is over. There may be short breaks between matches. The time limit isn't always a hard one: sometimes when time is up, the current game must be finished.

In these events each timed set is usually a separate "match" (often against different opponents), and the watch wearer wants **one** activity for the whole event.

## Concept

A tournament session is a sequence of segments (see the [roadmap README](README.md)):

```
[TIMED round 1] → [BREAK] → [TIMED round 2] → [BREAK] → ... → Finish
```

- **TIMED** segment: normal game scoring with no game cap and no tie-break. It ends when time is up, according to the end rule.
- **BREAK** segment: the `FREE` format from plan 2, showing a count-up timer and a "Start next round" action.

## Configuration

New game mode **"Timed tournament"**, with a short custom flow:

1. **Round length:** 10 / 15 / 20 min (maybe also 12 and 25, or a custom value).
2. **End rule:**
   - **Hard:** the round ends the moment time is up. The game in progress is not counted.
   - **Finish game:** when time is up, play continues until the current game is won. Then the round ends.
3. **Total length (optional):** 90 / 120 min / none. This is only informational: show the remaining total time and vibrate when it is reached. It never ends the session by itself.
4. **Point rule:** Golden by default, like the other presets.

Store these in `MatchConfig` (`roundDurationSec`, `timeEndRule`, `totalDurationSec`).

## Design

### Model

1. **`FORMAT_TIMED`** + **`TimedSetEngine`**: a `GamesSetEngine` with no `gamesToWin` / `tieBreakAt` cap (or a small subclass). `scorePoint` handles games normally but **never returns "set won" because of the games count**.
2. **Time state in `MatchStatus`** (setters, copied in `copy()`, so undo works):
   - `segmentStartTime`, the same field introduced in plan 2.
   - `timeUp` (Boolean): set when time is up and the end rule is *Finish game*.
3. **Ending a round:**
   - *Finish game*: once `timeUp` is true, the next **game won** in `TimedSetEngine.scorePoint` ends the round.
   - *Hard*: the round is ended by the **timer event**, not by a point. Add `MatchEngine.endTimedSegment(now)`, which pushes an undo entry, writes the result, resets and moves to `BREAK`.
   - Result string: the games as they stand, e.g. `"5-3"` or `"4-4"`; **draws are allowed**. The round winner (if any) increments `p1Sets` / `p2Sets` ("rounds won").
4. **Undo across the time limit:**
   - *Finish game*: undoing the game-winning point restores `timeUp = true` and the round is still in progress. This works for free because `timeUp` is in `MatchStatus`.
   - *Hard*: undoing `endTimedSegment` reopens the round in **overtime** (`timeUp = true`). The next game won then ends it, so the user isn't stuck if the time-up arrived by mistake mid-point.
5. **Time checks live in the model, the clock lives outside.**
   - Add `MatchEngine.tick(now)`: if the current segment is TIMED and `now - segmentStartTime >= roundDuration` and `!timeUp`, apply the end rule and return an event (`TIME_UP`, `ROUND_ENDED`) so the app can vibrate.
   - Tests call `tick` with made-up timestamps. **Don't read `Time.now()` inside the engine.**
   - **Also check before every point**, not only on timer ticks: the deadline can pass between two ticks (up to 1 s, more if the timer is late), and under *Hard* a point scored in that gap must not count. `ScoreDelegate` calls `match.tick(now)` before `incP1` / `incP2`; if it returns `ROUND_ENDED`, that press is not scored. Under *Finish game* the same call sets `timeUp` first, so a game won after the deadline ends the round.

### Timer

- Today the only timer is created in `ScoreView.onLayout` and only redraws the screen. Time-up must be detected **even when a menu is open** over the score screen. Move a 1 s `Timer.Timer` into `GarminpadelApp`, started in `initMatch()`, which calls `match.tick(now)` and then `WatchUi.requestUpdate()`.
- Older devices allow only a few timers at once. Reuse this one app timer for the redraw too, and remove the view's timer.
- Use a monotonic source for elapsed time (`System.getTimer()`, ms since boot) or the activity timer (`Activity.getActivityInfo().elapsedTime`). Wall-clock `Time.now()` can jump when the watch syncs.

### Breaks

- After a round ends, go to `FREE` (the "break"). Its timer counts up from 0.
- **"Start next round"** goes in the Options menu during a break. Consider also letting Up/Down start the next round, since there is nothing to score during a break. That needs a decision, because pressing by accident would start the round early.
- Break length is not configured; the user starts the next round when the organiser does.
- The session starts with a warm-up before round 1, using the mechanism from [plan 5](05-warm-up-lap.md).

### UI

- **During a round** (`ScoreView`):
  - Top: `Round 3` (or `Rounds: 2-0`).
  - **Countdown** `12:34`, shown large. After time is up with *Finish game*: `TIME` or `+0:23` (overtime), maybe in a different colour.
  - Games shown large, since they're the main number in this format, and the points.
  - The clock label is replaced by the remaining *total* time when one is configured.
- **At time up:** strong vibration (longer than the court-change one), plus a banner using the existing banner code.
- **Round ended:** vibration and a banner with the result, then the break screen.
- **Break screen:** `Break 1:12`, the last result, `Rounds: 2-1`, and a hint "Enter: next round".
- **Total time reached:** vibrate once and show a banner ("Tournament time over"). Nothing is ended automatically.

### Recording

- Every round and every break is a lap (from plan 2), with the round score in the per-lap field from plan 2.
- Session `game_score`: the round results, truncated as designed in plan 2.

### Serving (plan 4 team level is on `master`)

- Each round is a new match, often against new opponents. When a round starts, reset `gamesPlayed` to 0 and ask "First serve: Us / Them / Skip" again (from the break screen's "Start next round").
- Reuse the menu from `MenuFirstServeDelegate`, but **not its `onSelect` as is**: it calls `initMatch()`, which would start a new recording session. Add a variant (e.g. a flag or a callback) that only sets the first server and starts the round.
- During breaks, `getServingSide()` should return -1 (nothing drawn).

## Test plan (deterministic, with made-up timestamps)

- `tick` before the round length: nothing happens.
- Hard: `tick` at the round length → the round ends with the current games (`3-2`), the game in progress is thrown away, the state is `FREE`, and P1 rounds = 1.
- Hard: a point pressed after the deadline but before the next timer tick → the round ends with the games as they were at the deadline; that point is not counted.
- Finish game: `tick` at the length → `timeUp`, round still running; the next point that wins a game ends it; a point that doesn't win a game does not.
- Draw `4-4` → no one's round count goes up; history `"4-4"`.
- Undo after a Hard end → back in the round with `timeUp = true`.
- Undo the game-winning point after time-up (Finish game) → round running again, `timeUp` still true.
- Starting the next round resets games, scores and `timeUp`, and sets a new `segmentStartTime`.
- No games cap: 10-0 in games doesn't end the round.

## Acceptance criteria

- A user can configure 15-minute rounds with *Finish game*, play 6 rounds with breaks across about 100 minutes, and save one activity. Each round and break is a lap, and all round results can be read in Connect.
- Time-up is detected and vibrates even with the Options menu open.
- Undo works across the time limit as described.
- README updated.

## Open questions

- Should the *Hard* rule count the game in progress when one side is ahead in points? Proposal: no. Discard it; that is the common rule.
- Some formats play a deciding point or game on a draw at time-up. Support it later as a third end rule, "Finish game, and play one more on a draw"?
- Should total duration also have a "stop after current round" option?
- Pause or resume the round timer (injury, ball lost over the fence)? Proposal: not in the first version.
