# Roadmap: planned features

This folder holds design plans for planned features. Each plan is meant to be picked up later, by a human developer or a coding agent, without needing the conversation that produced it. Each one includes the user need, the relevant code, the design decisions with reasons, open questions, a test plan and acceptance criteria. When a plan (or part of one) ships, its file keeps an "Implementation notes" section saying what was built and where it differs from the design.

Written 2026-11-16 against `master` at v2.6.0 (`f77f3e7`); updated after the team-level serving indicator ([#152](https://github.com/pedrorijo91/garmin-padel/pull/152), `ccda76d`), the CI device matrix ([#153](https://github.com/pedrorijo91/garmin-padel/pull/153), `d89c9bb`) the warm-up lap ([#154](https://github.com/pedrorijo91/garmin-padel/pull/154), `a0e4cef`), the set-format switch ([#155](https://github.com/pedrorijo91/garmin-padel/pull/155), `7a18093`) and training mode ([#156](https://github.com/pedrorijo91/garmin-padel/pull/156)) were merged. None of these is in a release yet (`master` is `2.7.0.beta`). Code references use class and function names, not line numbers. If code has moved, search for the name.

| # | Plan | Size | Depends on | GitHub | Status |
|---|------|------|------------|--------|--------|
| 1 | [Switch set format mid-match](01-switch-set-format.md) (final tie-break / super tie / mini set) | S–M | — | [#146](https://github.com/pedrorijo91/garmin-padel/issues/146) | **Done**, merged in [#155](https://github.com/pedrorijo91/garmin-padel/pull/155) (`7a18093`, not released yet). Switch to tie-break / super tie / mini set at any moment, Friendly and Custom only; a started set is dropped, not recorded. |
| 2 | [Training mode](02-training-mode.md) (free play + scored drills) | M | 1 | — | **Done**, merged in [#156](https://github.com/pedrorijo91/garmin-padel/pull/156) (not released yet). Training preset: free play, Start / Next / End drill (tie-break, super tie, mini set, set), one lap per segment with a per-lap `lap_score` field; an unfinished drill is saved with its score so far (`TB [4-3]`) but counts for nobody. The warm-up is now a `FREE` segment. |
| 3 | [Timed tournament](03-timed-tournament.md) (time-limited sets, breaks) | M–L | 1, 2 (free/break segment) | [#27](https://github.com/pedrorijo91/garmin-padel/issues/27) (closed; "timed tournament" item never built) | Not started |
| 4 | [Serving indicator](04-serving-indicator.md) (which team serves, then which player) | team S–M, player M | none | [#66](https://github.com/pedrorijo91/garmin-padel/issues/66), [#101](https://github.com/pedrorijo91/garmin-padel/issues/101) (both closed by #152) | **Team level done**, merged in [#152](https://github.com/pedrorijo91/garmin-padel/pull/152) (not released yet; last release v2.6.0). Player level (which of the two partners serves) not started, and no open issue tracks it. |
| 5 | [Warm-up as its own lap](05-warm-up-lap.md) | S | none (becomes a `FREE` segment once 2 lands) | — | **Done**, merged in [#154](https://github.com/pedrorijo91/garmin-padel/pull/154) (`a0e4cef`, not released yet). Default is Yes (`MenuWarmUpDelegate.WARM_UP_DEFAULT`), still open for the maintainer to confirm. |

Update the **Status** column and the plan's own "Status" section when work starts or lands.

## Recommended order

```
[done] 4 Serving indicator (team)
                    └──► 4 (player)

[done]  1 Switch set format ──► [done] 2 Training mode ──► 3 Timed tournament
                                      ▲
                                      └── [done] 5 Warm-up lap (now a FREE segment)
```

1. ~~**Plan 4 (team level)**~~: done in #152.
2. ~~**Plan 1**~~: done in #155 (for #146). It introduced the key refactor: the format of the current set lives in `MatchStatus.setFormat` (`MatchConfig.FORMAT_*`) and is no longer derived from the fixed config. Plans 2 and 3 are built on it. The switch already works mid-set (the partial set is dropped, not recorded), which plan 2 needs.
3. ~~**Plan 5 (warm-up lap)**~~: done in #154. Its warm-up phase became a `FREE` segment in plan 2.
4. ~~**Plan 2**~~: done in [#156](https://github.com/pedrorijo91/garmin-padel/pull/156). Adds `FORMAT_FREE`, the Training preset (Start / Next / End drill), `MatchStatus.segmentStartTime` and the per-lap `lap_score` field.
5. **Plan 3 (next)** reuses the free segment as the break between rounds and adds the timer.
6. **Plan 4 (player level)**: show which of the serving team's two players serves, not only which team. Partners alternate their service games and may change the order between sets (see the plan's "Design: player level"). It builds directly on the team-level code and can be done at any time.

## The shared idea: a session is a sequence of segments

Today a match is "N sets of one type, plus an optional super-tie decider". All of plans 1–3 need a more general model:

> A session is a sequence of **segments**. Each segment has a **format**: normal set, pro set, mini set, tie-break (7), super tie-break (10), timed set, or free play / break / warm-up (no score).

- Plan 1 lets the user switch the **current** segment to another format at any moment (done in #155; the unfinished segment is dropped, not recorded).
- Plan 2 adds the `FREE` format and makes "choose next format" the main way to use the app.
- Plan 3 adds the `TIMED` format and uses `FREE` for breaks.
- Plan 5 starts every match with a warm-up, which is a `FREE` segment since plan 2.
- **Laps:** each segment should be its own FIT lap. Today a lap is added when a set is won, when the warm-up ends (plan 5), when a started set is dropped by switching format (plan 1) and at every training segment change (plan 2).
- **Serving:** the serving indicator (plan 4) counts `gamesPlayed` across the whole session. Segments that are a new "match" (a training drill, a tournament round) need to decide whether to reset it and ask who serves first again (see plans 2 and 3).

Plan 1 laid the base for this: the current format is `MatchStatus.setFormat`, with `MatchConfig.FORMAT_*` constants and `MatchEngine.engineForFormat(format)`. Plans 2 and 3 add `FORMAT_FREE` and `FORMAT_TIMED` there instead of new booleans.

## How the code works today (needed context)

Monkey C (Garmin Connect IQ) watch app. `minApiLevel` 2.4.0, about 78 devices in `manifest.xml`.

**Model (`source/model/`)**
- `PadelMatch`: thin facade used by views and delegates. Builds a `MatchEngine` from a `MatchConfig`.
- `MatchConfig`: number of sets (`UNLIMITED_SETS = 20`), set type (normal / pro / mini), super tie on or off, point rule (golden / advantage / silver / star), `FORMAT_*` constants and the `formatSwitch` flag (plan 1), the `warmUp` flag (plan 5), the `training` flag (plan 2).
- `GameModes`: the presets (Tournament, Tournament super, Pro set, Friendly, Training) mapped to a `MatchConfig`, plus the summary lines shown on the confirm screen.
- `MatchEngine`: owns `MatchStatus` and the undo stack (`MAX_UNDO = 5`, each entry is a full `MatchStatus.copy()`).
  - `getCurrentSetEngine()` uses `MatchStatus.setFormat` when it isn't `FORMAT_DEFAULT` (plan 1). Otherwise it picks `decidingSetEngine` (super tie) when sets are tied with one set left, or `defaultSetEngine`. Engines are built by `engineForFormat(format)`.
  - `switchSetFormat(format)` (plan 1): undoable; drops a started set (not recorded), resets games and points, adds a lap.
  - `scorePoint()` delegates to the set engine. Right after that call (before any set cleanup) it adds 1 to `gamesPlayed` if the games total changed or a set was won. When a set is won it then calls `resetAfterSetFinish()`, which writes the result string (`SetEngine.formatResult`), resets games and scores, sets the format back to default, applies initial games (mini set 2-2), sets `segmentStartTime`, and then calls `Application.getApp().lapSession(result)`.
  - Segments (plan 2): `currentFormat()` (the chosen format or the default), `isFreePlay()`, `isTraining()` (default format `FORMAT_FREE`). In free play `incP1` / `incP2` score nothing and push no undo entry (in a match's warm-up they end it). Methods that start a segment take `now` (seconds); `PadelMatch` reads `Time.now()` and passes it in. `switchSetFormat(format, now)` also does training's Start / Next / End drill (End drill = `FORMAT_FREE`); leaving free play clears the undo stack.
  - Warm-up (plan 5): `startWarmUp()` / `isWarmingUp()` / `endWarmUp()`. While warming up, the first Up/Down press ends the warm-up without scoring, adds a lap and clears the undo stack.
  - Court-change vibration in tie-breaks: every 6 tie points, through `onTieBreakCourtChange()`.
  - Serving (plan 4, team level): `setFirstServer(side)`, `switchServer()` (undoable) and `getServingSide()`, which returns -1 when the server is unknown or the match is over. The serve turn is `gamesPlayed`, plus `(tiePoints + 1) / 2` while `isInTieBreak()` or `isInSuperTieBreak()`.
- `SetEngine` (stateless; mutates the `MatchStatus` it is given):
  - `GamesSetEngine(gameEngine, gamesToWin, tieBreakAt, initialP1, initialP2)` is the base of `NormalSetEngine` (6, 6), `ProSetEngine` (9, 8) and `MiniSetEngine` (6, 5, starts 2-2).
  - `SuperTieSetEngine(target)`: first to `target` (10 = super tie, 7 = standalone tie-break), win by 2, no games. Results are written `[10-8]`.
- `GameEngine` (stateless): Golden, Advantage, Silver, Star point.
- `MatchStatus`: sets, games, point index, tie scores, history strings, unforced errors, deuce revert count, `firstServer` and `gamesPlayed` (plan 4), `setFormat` (plan 1; `FORMAT_FREE` = free play or the warm-up), `segmentStartTime` (plan 2). **The constructor is limited to 9 arguments** (older devices such as marqgolfer), so new fields are added with setters and copied in `copy()`, as `firstServer` / `gamesPlayed` are. Anything that must survive **undo** has to live here.
- `Sides`: `SIDE_P1 = 0` (us, Up button, top half of the screen), `SIDE_P2 = 1` (them, Down button, bottom half). `Sides.other(side)` replaced the old `otherSide()` helpers in the engines.

**App, views and delegates**
- `GarminpadelApp` (`source/garminpadelApp.mc`): holds the config, match and `ActivityRecording.Session`. `initMatch()` starts the session (recording starts there). `saveSession()` writes FIT developer fields with IDs 0–4: `game_score` (string, **count 50**, so 49 characters; cut with `fitString` in `model/fitUtils.mc`), `steps`, `app_version`, `unforced_errors`, and `warmup_seconds` (only when the match had a warm-up, plan 5). Also handles laps (`getLapCount()` is a test seam), the court-change / "Match started" banner and vibration.
- `ScoreView` + `resources*/layouts/scores.xml`: text labels `setsLabel`, `gamesLabel`, `scoreLabel`, steps/HR, clock. A 1 s `Timer` created in `onLayout` refreshes the view. Instinct devices have their own layout folders. After `View.onUpdate(dc)` it draws the serving indicator (`drawServingIndicator`: an arc on round screens, an edge bar otherwise, moved clear of the Instinct sub-screen), then the court-change banner.
- `ScoreDelegate`: Up/Down (or tapping the top/bottom half) scores. Enter or long-press opens the Options menu, built once in `pushOptionsMenu()`; add new items there. During the warm-up it opens `pushWarmUpOptionsMenu()` instead (Start match, Switch server, Finish activity, Cancel), and in training `pushTrainingOptionsMenu()` (plan 2: Start drill / End drill / Next drill ...). Back opens the Finish menu.
- `ScoreOptionsMenuDelegate`: undo (with confirmation), unforced error, switch server, switch to (plan 1; also handles its submenu), finish.
- Setup menus: `delegates/menu/*` (game mode → confirm with a "Warm-up: Yes / No" line, or custom: sets → set type → super tie → score → warm-up). Both flows end with `MenuFirstServeDelegate` ("First serve: Us / Them / Skip"), whose `onSelect` calls `initMatch()`, sets the first server and pushes the score screen. **That is where recording starts.** It always calls `initMatch()`, so reusing the menu mid-session (plans 2, 3 and 5) needs a variant that doesn't.

**Tests and CI**
- Unit tests live in `source/tests/` (`(:test)` functions, helpers in `testingUtils.mc`, e.g. `playSet`, `playSetTo6All`). Serving rules are covered in `testServing.mc`.
- CI also runs the strict type check (`-l 3`); it rejected a nullable value in `scoreView.mc` during #152, so build with the same level locally.
- CI (`.github/workflows/ci.yml`) builds and runs the tests on **fenix847mm, fr245, instinct2 and venusq2** (since #153), using the `ghcr.io/matco/connectiq-tester` Docker image.
- UI changes must also be checked by hand in the simulator on at least one round device (fenix/forerunner), one rectangular device (venusq2) and one Instinct (black and white, odd layout).

## Constraints that apply to every plan

- **Undo:** any new state that changes during play must be in `MatchStatus` and copied in `copy()`, or undo will silently break.
- **9-argument constructor limit** on `MatchStatus`: use setters.
- **Memory:** older devices (fr245, vivoactive4, marqgolfer, descentmk1) have small app memory. Prefer extending existing classes and parameterizing engines over adding many new classes or resources.
- **Keep the score screen simple.** The maintainer has repeatedly avoided UI that breaks across many devices (see #6 and #66). Prefer drawing relative to `dc` size over per-device layout files.
- **FIT `game_score` holds 49 characters** (`:count => 50` includes the terminator). A longer string makes `setData` crash with an uncatchable System Error and the activity is lost, so `saveSession` cuts it with `fitString`. Sessions with many segments hit the cut, so training writes each segment's result to a per-lap string field, `lap_score` (ID 5, `MESG_TYPE_LAP`, 16 bytes), through `lapSession(label)`. FIT limits (Connect IQ `Session.createField` docs): 256 bytes of developer data per message per app, 32 bytes per data field on a record message. The session message uses 108 bytes today.
- **Strings:** user-facing text goes in `resources/strings/strings.xml`. Existing menus use some hard-coded strings; new code should prefer resources.
- **README:** update the user-facing "Functionalities", "How to use" and "Match rules reference" sections when a feature ships.
