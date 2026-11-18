# Plan 2: Training mode

- **Status:** Not started
- **Size:** Medium
- **Depends on:** [Plan 1: Switch set format](01-switch-set-format.md), **done in #155**. It provides `MatchStatus.setFormat`, `MatchConfig.FORMAT_*`, `MatchEngine.engineForFormat`, `SuperTieSetEngine(7 / 10)`, `SetEngine.formatResult` and `MatchEngine.switchSetFormat`. Read plan 1's [Implementation notes](01-switch-set-format.md#implementation-notes) before starting.
- **Needed by:** [Plan 3: Timed tournament](03-timed-tournament.md), which reuses the free-play segment as the break between rounds.
- **GitHub:** none yet
- Shared context and constraints: [roadmap README](README.md)

## User need

> In training it is very common to alternate between exercises without score and exercises with score: usually a tie-break or super tie-break, sometimes a set or a mini set. Sometimes we also end training with a final super tie-break. Today there is no training mode at all.

## Concept

A training session is a sequence of **segments** (see the "shared idea" in the [roadmap README](README.md)):

- **Free play** (`FORMAT_FREE`): no score. Up/Down do nothing. The time is still recorded.
- **Drill** (scored): tie-break, super tie-break, mini set or set, using the formats from plan 1.

The user moves between them from the Options menu. When a drill is won it ends by itself and the session goes back to free play.

## Design

### Model

1. **`FORMAT_FREE`.** Add it to the set-format constants from plan 1. In `MatchEngine`, while the current format is `FREE`:
   - `incP1` / `incP2` do nothing and return `false`, **without** pushing an undo entry.
   - `isInTieBreak` / `isInSuperTieBreak` return false.
   - This can be a tiny `FreeSetEngine` whose `scorePoint` returns false, or a check in `MatchEngine`. Pick whichever is less code.
2. **Training sessions default to `FREE`.** Add a `MatchConfig` flag such as `training` (or a "default format" of `FREE`) so that after every finished segment the next one is `FREE`, not a normal set. With plan 1's code: `MatchEngine`'s default format becomes `FREE` for training, and `setFormat` holds the chosen drill. `resetAfterSetFinish()` already puts `setFormat` back to `FORMAT_DEFAULT`, so a won drill returns to free play by itself.
3. **`endSegment()` (stop a drill early).**
   - Plan 1's `switchSetFormat` **drops** a started set without recording anything (the maintainer asked for that in matches; a first `"4-3*"` version was removed). Proposal for drills: do the same, so an unfinished drill is not recorded and not given to anyone. If drill scores should be kept, write the partial result with a marker (e.g. `"TB [4-3]*"`) instead; see Open questions.
   - Reset scores and games and go back to `FREE`.
   - Push an undo entry first, so this can be undone.
   - Reuse `switchSetFormat`: it already pushes an undo entry, resets games and points, applies the new engine's initial games and adds a lap when the set had started. Ending a drill is a switch to `FORMAT_FREE`.
   - **Drill → drill:** `endSegment(nextFormat)` (or a separate `startSegment(format)` that ends the current drill first) does the same, but goes straight to the chosen drill instead of `FREE`. It is one undo entry and one lap, with no free-play segment in between.
4. **Drill results.** A won drill still increments `p1Sets` / `p2Sets`, so "drills won" can be shown. History entries should say what the drill was, so the saved score can be read later. Plan 1 writes tie-breaks with brackets (`[7-5]`, `[10-8]`), which can't tell a long tie-break (`[12-10]`) from a super tie, so add a prefix: e.g. `TB [7-5]`, `ST [10-8]`, `MS 6-4`, `6-3`. Prefixes keep the string short (see the FIT limit below).
5. **Match never ends by itself.** Use `numberOfSets = UNLIMITED_SETS`; the user presses Finish.
6. **Point rule.** Training drills still need a point rule for game-based formats. Ask for it (default Golden), the same way presets do.

### Warm-up

[Plan 5](05-warm-up-lap.md) adds a warm-up phase at the start of every match, as its own lap. In this plan's model, that warm-up is just a `FREE` segment. If plan 5 was built first, replace its `phase` field with the segment format here, and keep its rule that undo never goes back into a finished free segment (a lap can't be removed once it is added).

### Serving indicator (plan 4, already on `master`)

- In free play, `getServingSide()` should return -1 (nothing drawn).
- Drills are short and players often decide the server per drill, so the indicator should be **off by default in training**: skip the "First serve" step for the Training mode, leave `firstServer = -1`, and let **Options → Switch server** turn it on during a drill (it already does that when the server is unknown).
- When a drill ends, reset `firstServer` to -1 and `gamesPlayed` to 0, so the next drill starts without a stale server. Do it inside the undo entry for ending the drill, so undo brings both back.

### Laps and recording

- Every segment change (free → drill, drill → free, drill → drill) should call `lapSession()`, so Garmin Connect shows how long each segment took. Today a lap is only added when a set is won, in `MatchEngine.scorePoint`. Starting or ending a segment from the menu must add one too.
- **`game_score` holds 49 characters** (`:count => 50` in `GarminpadelApp.saveSession`; a longer string crashes with an uncatchable System Error). Since #155, `saveSession` cuts it with `fitString` (`source/model/fitUtils.mc`), keeping the earliest entries. A training session with 8 drills (`TB 7-5 / ST 10-8 / ...`) overflows it. Options:
  1. **Recommended:** add a **lap-level** string field (`FitContributor.MESG_TYPE_LAP`, e.g. `lap_score`) and set it just before each `addLap()`, so each drill's score sits on its own lap. Keep the session field as a short summary, e.g. "Drills 5-3".
  2. Increase `:count` on the session field. **Check the Connect IQ / FIT developer-field size limits first** (there are limits on a field's size and on the total developer-data size). Issue #32 ("does not save more than 3 sets?") is past evidence that this limit hurts.
  - Whatever is chosen, truncate on purpose (keep the last N entries) instead of letting the platform cut the string.

### UI

1. **Game mode menu** (`GameModes`, `MenuGameModeDelegate`): add **"Training"**. Its confirm screen shows e.g. "Free play + drills", "Score: Golden Point".
2. **Score screen in free play** (`ScoreView`):
   - Top: "Training" (or "Drills: 2 - 1" once at least one drill has finished).
   - Middle: "Free play" and the time elapsed in this segment (store the segment start time; see below).
   - Bottom: steps/HR and clock as today.
3. **Score screen during a drill:** the same as a match. Change the top label to "Drills: x - y" instead of "Sets: x - y".
4. **Options menu** (`ScoreDelegate.pushOptionsMenu()`, the single helper added in #152), in training:
   - In free play: **Start drill ▸** *Tie-break / Super tie-break / Mini set / Set*, Undo (only when there is an undo entry, e.g. right after End drill or a won drill; free-play presses push none), Unforced error, Finish.
   - During a drill: **End drill**, **Next drill ▸** *(same drill list)*, Undo, Unforced error, Finish. *Next drill* ends the current drill (partial result marked with `*`, as for End drill) and starts the chosen one directly, without going through free play.
   - Show "Switch to" (plan 1, gated by `MatchConfig.formatSwitch`) only outside training. In training, "Start drill" / "Next drill" replace it; they can share its submenu code in `ScoreOptionsMenuDelegate`.
5. **When a drill ends** (won): vibrate (reuse the `onTieBreakCourtChange` vibration pattern or similar) and show a banner with the result for about 2.5 s (reuse the court-change banner code in `ScoreView.onUpdate` / `GarminpadelApp.isCourtChangeBannerVisible`), then free play.
6. **Unforced errors** count during drills and free play alike.

### Segment timer

- Store `segmentStartTime` (from `Time.now().value()` or `System.getTimer()`) in `MatchStatus`, so undo across a segment boundary also restores it. Plan 3 needs the same field, so name it generically.
- Pass the current time into model methods instead of reading the clock inside the model, so tests can control time.

## Test plan

- Training starts in `FREE`: `incP1` does nothing, nothing is pushed to the undo stack, and history is empty.
- Start drill (super tie) → play to 10-7 → back in `FREE`; history `["ST 10-7"]`; P1 drills = 1.
- Start drill (tie-break), play 4-3, `endSegment()` → nothing recorded (or `["TB [4-3]*"]` if partial drills are kept); drills unchanged; `FREE`.
- Undo right after `endSegment()` restores the drill at 4-3 (Undo is reachable from the free-play menu).
- Mini set drill starts at 2-2 and goes back to `FREE` after it is won.
- Several drills back to back without free play in between (drill → drill via *Next drill*): the partial result is written with `*`, the new drill starts at 0-0 (or 2-2 for a mini set), exactly one lap is added per transition, and undo restores the previous drill.
- The score-string / lap-field formatting stays within its limit and truncates as designed.

## Acceptance criteria

- A user can start "Training", warm up in free play, run several drills of different formats, end one early, finish with a super tie, and save **one** activity.
- In Garmin Connect, each segment is its own lap and drill scores can be read (per lap or in the session summary).
- The Options menu shows only actions that make sense for the current state.
- README updated (new mode, how to use it, how scores are recorded).

## Open questions

- Should free play have *any* input on Up/Down (e.g. count rallies or "winners"), or nothing? Proposal: nothing, so it can't be pressed by accident.
- Ask for the point rule up front, or always use Golden in training?
- Lap field vs. a longer session field: decide after checking the FIT limits.
- Unfinished drills (End drill, Next drill, or Finish during a drill): drop them like plan 1's switch does (proposal), or record them with a `*` marker?
