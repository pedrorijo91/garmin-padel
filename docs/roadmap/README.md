# Roadmap: planned features

This folder holds design plans for planned features. Each plan is meant to be picked up later, by a human developer or a coding agent, without needing the conversation that produced it. Each one includes the user need, the relevant code, the design decisions with reasons, open questions, a test plan and acceptance criteria. When a plan (or part of one) ships, its file keeps an "Implementation notes" section saying what was built and where it differs from the design.

Written 2026-11-16 against `master` at v2.6.0 (`f77f3e7`); updated after the team-level serving indicator was merged ([#152](https://github.com/pedrorijo91/garmin-padel/pull/152), `ccda76d`). Code references use class and function names, not line numbers. If code has moved, search for the name.

| # | Plan | Size | Depends on | GitHub | Status |
|---|------|------|------------|--------|--------|
| 1 | [Switch set format mid-match](01-switch-set-format.md) (final tie-break / super tie / mini set) | S–M | — | [#146](https://github.com/pedrorijo91/garmin-padel/issues/146) | Not started |
| 2 | [Training mode](02-training-mode.md) (free play + scored drills) | M | 1 | — | Not started |
| 3 | [Timed tournament](03-timed-tournament.md) (time-limited sets, breaks) | M–L | 1, 2 (free/break segment) | [#27](https://github.com/pedrorijo91/garmin-padel/issues/27) (closed; "timed tournament" item never built) | Not started |
| 4 | [Serving indicator](04-serving-indicator.md) (which team serves, then which player) | team S–M, player M | none | [#66](https://github.com/pedrorijo91/garmin-padel/issues/66), [#101](https://github.com/pedrorijo91/garmin-padel/issues/101) (both closed by #152) | **Team level done**, merged in [#152](https://github.com/pedrorijo91/garmin-padel/pull/152) (not released yet; last release v2.6.0). Player level (which of the two partners serves) not started, and no open issue tracks it. |
| 5 | [Warm-up as its own lap](05-warm-up-lap.md) | S | none (becomes a `FREE` segment once 2 lands) | — | Not started |

Update the **Status** column and the plan's own "Status" section when work starts or lands.

## Recommended order

```
[done] 4 Serving indicator (team)
                    └──► 4 (player)

1 Switch set format ──► 2 Training mode ──► 3 Timed tournament
                               ▲
                               └── 5 Warm-up lap (standalone now, folds into FREE segment later)
```

1. ~~**Plan 4 (team level)**~~: done in #152.
2. **Plan 1 next.** It introduces the key refactor: the format of the current set lives in `MatchStatus` and is no longer derived from the fixed config. Plans 2 and 3 are built on it. It must keep the serving indicator right for standalone tie-breaks (see plan 1).
3. **Plan 5 (warm-up lap)** is small and independent. It can be built at any time. If it lands before plan 2, design its warm-up phase so plan 2 can replace it with a `FREE` segment.
4. **Plan 2** adds the unscored "free" segment and "end drill".
5. **Plan 3** reuses the free segment as the break between rounds and adds the timer.
6. **Plan 4 (player level)**: show which of the serving team's two players serves, not only which team. Partners alternate their service games and may change the order between sets (see the plan's "Design: player level"). It builds directly on the team-level code and can be done at any time.

## The shared idea: a session is a sequence of segments

Today a match is "N sets of one type, plus an optional super-tie decider". All of plans 1–3 need a more general model:

> A session is a sequence of **segments**. Each segment has a **format**: normal set, pro set, mini set, tie-break (7), super tie-break (10), timed set, or free play / break / warm-up (no score).

- Plan 1 lets the user choose the format of the **next** segment.
- Plan 2 adds the `FREE` format and makes "choose next format" the main way to use the app.
- Plan 3 adds the `TIMED` format and uses `FREE` for breaks.
- Plan 5 starts every match with a warm-up, which is a `FREE` segment once plan 2 exists.
- **Laps:** each segment should be its own FIT lap. Today the only lap is added when a set is won, so lap 1 also contains the warm-up (plan 5).
- **Serving:** the serving indicator (plan 4) counts `gamesPlayed` across the whole session. Segments that are a new "match" (a training drill, a tournament round) need to decide whether to reset it and ask who serves first again (see plans 2 and 3).

Keep this in mind when implementing plan 1. Name things so that adding formats later does not need another refactor. For example, use a `SetFormat` constant set in `MatchConfig` (or a new `SetFormats` class), not a boolean like `forceSuperTie`.

## How the code works today (needed context)

Monkey C (Garmin Connect IQ) watch app. `minApiLevel` 2.4.0, about 78 devices in `manifest.xml`.

**Model (`source/model/`)**
- `PadelMatch`: thin facade used by views and delegates. Builds a `MatchEngine` from a `MatchConfig`.
- `MatchConfig`: number of sets (`UNLIMITED_SETS = 20`), set type (normal / pro / mini), super tie on or off, point rule (golden / advantage / silver / star).
- `GameModes`: the presets (Tournament, Tournament super, Pro set, Friendly) mapped to a `MatchConfig`, plus the summary lines shown on the confirm screen.
- `MatchEngine`: owns `MatchStatus` and the undo stack (`MAX_UNDO = 5`, each entry is a full `MatchStatus.copy()`).
  - `getCurrentSetEngine()` picks `decidingSetEngine` (super tie) only when sets are tied with one set left. Otherwise it uses `defaultSetEngine`. **The set format is derived, not stored**, which is what plan 1 changes.
  - `scorePoint()` delegates to the set engine. Right after that call (before any set cleanup) it adds 1 to `gamesPlayed` if the games total changed or a set was won. When a set is won it then calls `resetAfterSetFinish()`, which writes the result string, resets games and scores, and applies initial games (mini set 2-2), and then calls `Application.getApp().lapSession()`.
  - Court-change vibration in tie-breaks: every 6 tie points, through `onTieBreakCourtChange()`.
  - Serving (plan 4, team level): `setFirstServer(side)`, `switchServer()` (undoable) and `getServingSide()`, which returns -1 when the server is unknown or the match is over. The serve turn is `gamesPlayed`, plus `(tiePoints + 1) / 2` while `isInTieBreak()` or `isInSuperTieBreak()`.
- `SetEngine` (stateless; mutates the `MatchStatus` it is given):
  - `GamesSetEngine(gameEngine, gamesToWin, tieBreakAt, initialP1, initialP2)` is the base of `NormalSetEngine` (6, 6), `ProSetEngine` (9, 8) and `MiniSetEngine` (6, 5, starts 2-2).
  - `SuperTieSetEngine`: first to 10, win by 2, no games.
- `GameEngine` (stateless): Golden, Advantage, Silver, Star point.
- `MatchStatus`: sets, games, point index, tie scores, history strings, unforced errors, deuce revert count, `firstServer` and `gamesPlayed` (plan 4). **The constructor is limited to 9 arguments** (older devices such as marqgolfer), so new fields are added with setters and copied in `copy()`, as `firstServer` / `gamesPlayed` are. Anything that must survive **undo** has to live here.
- `Sides`: `SIDE_P1 = 0` (us, Up button, top half of the screen), `SIDE_P2 = 1` (them, Down button, bottom half). `Sides.other(side)` replaced the old `otherSide()` helpers in the engines.

**App, views and delegates**
- `GarminpadelApp` (`source/garminpadelApp.mc`): holds the config, match and `ActivityRecording.Session`. `initMatch()` starts the session (recording starts there). `saveSession()` writes FIT developer fields with IDs 0–3: `game_score` (string, **count 50**), `steps`, `app_version`, `unforced_errors`. Also handles laps, the court-change banner and vibration.
- `ScoreView` + `resources*/layouts/scores.xml`: text labels `setsLabel`, `gamesLabel`, `scoreLabel`, steps/HR, clock. A 1 s `Timer` created in `onLayout` refreshes the view. Instinct devices have their own layout folders. After `View.onUpdate(dc)` it draws the serving indicator (`drawServingIndicator`: an arc on round screens, an edge bar otherwise, moved clear of the Instinct sub-screen), then the court-change banner.
- `ScoreDelegate`: Up/Down (or tapping the top/bottom half) scores. Enter or long-press opens the Options menu, built once in `pushOptionsMenu()`; add new items there. Back opens the Finish menu.
- `ScoreOptionsMenuDelegate`: undo (with confirmation), unforced error, switch server, finish.
- Setup menus: `delegates/menu/*` (game mode → confirm, or custom: sets → set type → super tie → score). Both flows end with `MenuFirstServeDelegate` ("First serve: Us / Them / Skip"), whose `onSelect` calls `initMatch()`, sets the first server and pushes the score screen. **That is where recording starts.** It always calls `initMatch()`, so reusing the menu mid-session (plans 2, 3 and 5) needs a variant that doesn't.

**Tests and CI**
- Unit tests live in `source/tests/` (`(:test)` functions, helpers in `testingUtils.mc`, e.g. `playSet`, `playSetTo6All`). Serving rules are covered in `testServing.mc`.
- CI also runs the strict type check (`-l 3`); it rejected a nullable value in `scoreView.mc` during #152, so build with the same level locally.
- CI (`.github/workflows/ci.yml`) builds and runs the tests on **fenix847mm only**, using the `ghcr.io/matco/connectiq-tester` Docker image.
- UI changes must also be checked by hand in the simulator on at least one round device (fenix/forerunner), one rectangular device (venusq2) and one Instinct (black and white, odd layout).

## Constraints that apply to every plan

- **Undo:** any new state that changes during play must be in `MatchStatus` and copied in `copy()`, or undo will silently break.
- **9-argument constructor limit** on `MatchStatus`: use setters.
- **Memory:** older devices (fr245, vivoactive4, marqgolfer, descentmk1) have small app memory. Prefer extending existing classes and parameterizing engines over adding many new classes or resources.
- **Keep the score screen simple.** The maintainer has repeatedly avoided UI that breaks across many devices (see #6 and #66). Prefer drawing relative to `dc` size over per-device layout files.
- **FIT `game_score` is a 50-char string.** Sessions with many segments (plans 2 and 3) will overflow it. See plan 2 for the proposed per-lap field. FIT developer-field size limits must be checked before changing it.
- **Strings:** user-facing text goes in `resources/strings/strings.xml`. Existing menus use some hard-coded strings; new code should prefer resources.
- **README:** update the user-facing "Functionalities", "How to use" and "Match rules reference" sections when a feature ships.
