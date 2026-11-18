# Plan 2: Training mode

- **Status:** **Done**, merged in [#156](https://github.com/pedrorijo91/garmin-padel/pull/156) (not released yet). Built as designed, with the proposals taken for the open questions, except that the maintainer chose to **save unfinished drills with their score so far** (`TB [4-3]`); see [Implementation notes](#implementation-notes).
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

All answered by the maintainer in #156:

- ~~Should free play have *any* input on Up/Down?~~ Nothing, so it can't be pressed by accident.
- ~~Ask for the point rule up front, or always use Golden in training?~~ Always Golden.
- ~~Lap field vs. a longer session field?~~ Lap field only; training writes no session score.
- ~~Unfinished drills: drop them or record them?~~ Recorded with their score so far, no marker (`TB [4-3]`), counting for nobody (maintainer decision).

## Implementation notes

What was built, and where it differs from the design above:

- **Model:** `MatchConfig.FORMAT_FREE (5)` and a `MatchConfig.training` flag. `PadelMatch` builds a training `MatchEngine` with `UNLIMITED_SETS`, no super tie and **default format `FORMAT_FREE`**, so `setFormat = FORMAT_DEFAULT` means free play and `resetAfterSetFinish()` returns to free play by itself. `engineForFormat(FORMAT_FREE)` is the base `SetEngine`, which scores nothing (no new class). `MatchEngine` gained `currentFormat()`, `isFreePlay()`, `isTraining()` (= default format is `FREE`), `canUndo()` and `segmentLabel()`.
- **Free play:** `incP1` / `incP2` go through one `incSide()`: in free play they return `false` without an undo entry (in a match's warm-up they still end the warm-up). `getServingSide()` returns -1 in training free play.
- **Warm-up (plan 5) is now a `FREE` segment:** `MatchStatus.phase` / `PHASE_*` were removed. `startWarmUp()` sets `setFormat = FORMAT_FREE`, `isWarmingUp()` is "free play and not training", `endWarmUp(now)` sets it back to `FORMAT_DEFAULT`. Its rules are unchanged (lap, undo stack cleared, serving kept and switchable, indicator hidden by the view). Training ignores the warm-up flag: free play already is the warm-up.
- **Start / Next / End drill** all reuse `MatchEngine.switchSetFormat(format, now)` (End drill = `FORMAT_FREE`, via `PadelMatch.endDrill()`). In training it always starts a new segment: one lap, `segmentStartTime = now`, and `firstServer = -1` / `gamesPlayed = 0`, all after the undo entry is pushed, so undo restores them. **Maintainer decision:** an unfinished drill is **saved with its score so far**, with its prefix and no marker (`TB [4-3]`, `MS 4-3`, `4-3` for a set; such a score can't be a finished drill), but it counts for nobody (`p1Sets` / `p2Sets` unchanged). This differs from plan 1, where a set dropped by *Switch to* in a match isn't recorded. `switchSetFormat` writes it to the history after the undo entry, so undo removes it, and only when a point was played (`isSetStarted()`). Finish during a drill lists it the same way (`getHistoricalScores()`). Drill → drill is one undo entry and one lap.
- **Undo and free play:** leaving a free-play segment (Start drill, and the warm-up as before) **clears the undo stack**, because that segment is already a lap. So undo can go back into a drill (after End drill / Next drill / a won drill) but never into a finished free-play period. A wrongly chosen drill is fixed with Next drill or End drill.
- **Results:** `resetAfterSetFinish()` prefixes training results with `MatchEngine.drillName()`: `TB [7-5]`, `ST [10-8]`, `MS 6-4`; a full set stays `6-3` (as in the plan). Drills won are `p1Sets` / `p2Sets`. `getHistoricalScores()` lists a started drill in progress with its score so far, so Finish during a drill records it too.
- **Time:** `MatchStatus.segmentStartTime` (seconds, `Time.now().value()`; setter, copied in `copy()`). It is set at every segment start (session start, set or drill won, switch, warm-up end), in matches too, for plan 3. `MatchEngine` never reads the clock: `incP1(now)`, `switchSetFormat(format, now)`, `endWarmUp(now)` and `startSession(now)` take it; `PadelMatch` reads `Time.now()` and passes it in. `PadelMatch.getSegmentSeconds()` gives the free-play timer.
- **FIT:** FIT limits from the Connect IQ docs for `Session.createField`: an app may write **256 bytes of developer data per message**, and a field on a *record* message at most 32 bytes. The session message uses 108 bytes (`game_score` 50, `app_version` 50, steps 4, errors 2, warm-up 2), so the session field could grow to about 190, but a per-lap field scales with any number of drills. Built the **lap field** `lap_score` (ID 5, `MESG_TYPE_LAP`, `:count => 16`, label "Lap Score", `displayInActivityLaps`), created only for training sessions in `initMatch()`. `GarminpadelApp.lapSession(label)` writes the label (cut with `fitString(label, LAP_STRING_MAX)`, 15 characters) just before `addLap()`: the drill's result, `Free`, or the score so far of a drill ended early (`TB [4-3]`, or `TB [0-0]` / `MS 2-2` for one ended before any point); `saveSession()` labels the last lap the same way. **Maintainer decision: training writes no session `game_score`**, so nothing is ever cut; the laps are the record. (First built as a summary, `Drills 2-1: TB [7-5] / ...`, which filled the 49 characters after 3 or 4 drills.) `scoreString()` in `fitUtils.mc` still builds that summary for the watch's Finish menu. Training sessions are named "Padel training".
- **Known limitation: lap after undo.** A lap is written as soon as a segment ends (drill won, End drill, Next drill), and Connect IQ can't remove or relabel a lap. Undoing the winning point (or End / Next drill) brings the drill back, but its lap stays; when the drill ends again a second lap is written. Example: `TB [7-0]`, undo, then `TB [7-1]` gives two laps, while the score has only `TB [7-1]`. Plan 1 accepted the same for a switched set. A fix would need to delay the lap until the result can't be undone any more (e.g. until the next drill starts), which moves the lap boundary away from the real end of the drill; the maintainer chose to keep it as is (PR #156).
- **UI:** "Training" in the Game Mode menu. Its confirm screen shows "Free play + drills", "Drills: TB, ST, mini, set", "Serve marker: off", "Score: Golden Point", then **Start training**; no Warm-up line and no First serve step (`MenuFirstServeDelegate.startMatch(-1)`). Options in training come from `ScoreDelegate.pushTrainingOptionsMenu()`: free play has Start drill, Undo (only if `canUndo()`), Unforced error, Finish, Cancel; a drill has End drill (sub-label `Saves [4-3]` once points are played, or `Back to free play`), Next drill, Undo last point, Unforced error, Switch server, Finish, Cancel. Start / Next drill open plan 1's submenu (`pushSwitchFormatMenu` in `ScoreOptionsMenuDelegate`) with the title changed and a **Set** item added. "Switch to" is never shown in training (`canSwitchSetFormat()` is false).
- **Score screen:** top label `Drills: x - y` in training (`Training` while no drill has finished and the session is in free play); in free play the middle shows `Free play` and the score line the segment's `m:ss`. A won drill vibrates (two pulses) and shows its result in the court-change banner for 2.5 s (`GarminpadelApp.onDrillWon`; the banner text can now be a plain string).
- **Tests:** `source/tests/testTraining.mc` (14; the last one checks the lap label limit): preset; starts in free play (no score, no undo entry, no lap, no serving); super tie drill to `ST [10-7]` and back to free play, with its laps and lap labels; End drill saves a 4-3 tie-break as `TB [4-3]` without giving it to anyone (and an untouched drill isn't written); undo after End drill restores 4-3 and the drill carries on; mini set starts 2-2 and returns to free play; a set drill has no prefix; Next drill (one lap per change, partial saved as `TB [4-3]`, mini starts 2-2, undo back through both drills); undo never goes back into free play; serving off by default, reset per drill inside the undo entry; segment time with a controlled clock (on `MatchEngine` directly); unforced errors in free play and drills; lap labels within 15 characters. `testWarmUp.mc` now checks `setFormat` instead of `phase`. 149/149 pass with `-l 3` on fenix847mm, fr245, instinct2 and venusq2.

## Decisions (confirmed by the maintainer in #156)

- Up/Down in free play do nothing.
- The point rule is fixed to Golden point, like the other presets (not asked).
- Per-lap field built; training writes no session `game_score` (maintainer decision); matches keep it at 49 characters.
- ~~Unfinished drills dropped~~: the maintainer chose to save them with their score so far (`TB [4-3]`), counting for nobody.
- Starting a drill from free play can't be undone (the free-play lap is already written).
- A set drill has no prefix (`6-3`).
- Training has no Warm-up line and no First serve step.
- A lap can't be undone: an undone drill result keeps its lap, and the drill gets a second one when it ends again (kept as is; see Known limitation above).
