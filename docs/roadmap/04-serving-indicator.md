# Plan 4: Serving indicator (team, then player)

- **Status:** Not started
- **Size:** Team level small–medium; player level medium
- **Depends on:** nothing. It's easier after [plan 1](01-switch-set-format.md), so standalone tie-breaks and super ties are handled from the start.
- **GitHub:**
  - [#66 "serving team indication"](https://github.com/pedrorijo91/garmin-padel/issues/66): the original user request, with UI ideas (colour on colour screens, bold on black-and-white screens).
  - [#101 "display who is serving"](https://github.com/pedrorijo91/garmin-padel/issues/101): a semicircle on the serving team's side, or quarter circles for each player. Includes a sketch, and links the maintainer's private design drawings.
  - [#6](https://github.com/pedrorijo91/garmin-padel/issues/6): the first attempt, dropped because the UI got complicated across many devices.
- Shared context and constraints: [roadmap README](README.md)

## User need

> The app doesn't show which team or player is serving. This has been a problem since the app was created, but I haven't found a simple way to show it in the UI. The order inside a team may change between sets.

From #66: users read the score out loud and get the order wrong when the opponents are serving (the server's score should be said first). An indicator next to the serving team's score fixes that.

## Padel serving rules the model must follow

- Serve alternates between **teams** every game.
- Within a team, the two players alternate their service games, so the rotation over 4 games is A1, B1, A2, B2.
- At the **start of each set**, each team may choose which of its players serves first, so **the order inside a team can change between sets**. Which team serves first is not chosen again; the alternation simply carries on.
- **Tie-break / super tie-break:** the player whose turn it is serves point 1. After that, serve changes every **2** points, and the player rotation continues.
- **After a tie-break set**, the team that served first in the tie-break *receives* first in the next set. That is the same as counting the tie-break as one game in the team alternation.
- Players keep the same court side (right/"drive" or left/"revés") for the whole set. This lets the app identify players **by side** instead of by name.

## Design: team level (do this first)

### Model

New `MatchStatus` fields (setters, copied in `copy()`, so undo works):

| Field | Meaning |
|---|---|
| `firstServer` | `SIDE_P1`, `SIDE_P2`, or `-1` = unknown (indicator hidden) |
| `gamesPlayed` | games actually played in the match: +1 for every game won, +1 for every tie-break or super tie (inside a set or standalone) |

How the serving team is worked out:
- Serving team for a normal game = `firstServer` if `gamesPlayed` is even, otherwise the other team.
- In a tie-break or super tie with `n = p1Tie + p2Tie` points played: the first point is served by the team due to serve (`T0`). Then turn index `t = (n + 1) / 2` (integer division); the serving team is `T0` if `t` is even, otherwise the other team.
- Mini set starts at 2-2: those games were **not played**, so don't count them. That's why a counter is needed instead of `p1Games + p2Games`.

Expose `MatchEngine.getServingSide() as Number` (-1 if unknown) and pass it through `PadelMatch`.

Where the counter is updated:
- `GamesSetEngine.scorePoint` when a game is won, or `MatchEngine` after the call. Keep `GameEngine` stateless.
- When a tie-break or super tie set is won: +1 (the whole tie-break counts as one game for team alternation).
- Plans 2 and 3: a new drill or round can **reset** `firstServer` to unknown, or ask again.

### Input

- In the setup flow, just before "Start match": **"First serve: Us / Them / Skip"**. *Skip* hides the indicator, which keeps things working for people who don't want it.
- Options menu item **"Fix server"** (or "Switch serving team") to correct a mistake mid-match. It flips `firstServer`, with an undo entry pushed first.

### UI

Proposal: an **arc along the screen edge on the serving team's half**.
- The top half is us and the bottom half is them, which matches Up/Down and the tap areas in `ScoreDelegate.onTap`.
- Draw it in `ScoreView.onUpdate` *after* `View.onUpdate(dc)`, using only `dc.getWidth()` / `dc.getHeight()`, so **no per-device layout files** are needed.
- Round screens: thick arc (`setPenWidth` + `drawArc`) on the top or bottom half of the edge.
- Rectangular screens (venusq2) and Instinct (semi-octagon screen, separate layouts in `resources-instinct*`): a thick bar along the top or bottom edge instead. Branch on `System.getDeviceSettings().screenShape`.
- White (or the theme colour) so it works on black-and-white screens. Optionally a colour accent where colours are available.
- **Verify** that `Dc.drawArc` and `Dc.setPenWidth` are available at `minApiLevel` 2.4.0. If not, guard them with `has`, or fall back to the text marker below.
- Check that the arc doesn't overlap the steps/heart icons (`steps_icon` at x=15%, `heart_icon` at x=75%, y=70%) or the court-change banner.

**Fallback** (if the arc proves fragile on some devices): put a marker inside the existing `scoreLabel` text, e.g. `Score: •15 - 30` or `Score: 15 - 30•`. It can't break any layout, but it is less clear.

## Design: player level (second step)

### Model

- `MatchStatus.firstPlayerP1`, `firstPlayerP2`: which court side (0 = right/drive, 1 = left/revés) serves first for that team **in the current set**. Default 0. They stay the same across sets unless the user changes them.
- Also store `gamesPlayedAtSetStart`, so the turn index within the set is `i = gamesPlayed - gamesPlayedAtSetStart` (plus tie-break turns while in a tie-break).
- Serving player of team T at turn `i`: the team's own turn count is `k = i / 2` (integer division), and the player is `(firstPlayerT + k) % 2`.

### Input

Asking at every set start would interrupt scoring, so:
- The default is that the order continues as before.
- Options item **"Change serve order"**: flips the order of our team (or a submenu: our team / their team) **for the current set**. Push an undo entry first.
- Optional: at a set's first game, a brief, dismissible hint "Same serve order?". Only add it if users ask.

### UI

- Quarter arcs (#101 sketch): the serving team's half split in two; the serving player's quarter is filled and the partner's is outline or dim.
- Left quarter = left-side player, right quarter = right-side player, as seen by the wearer. Confirm this matches the drawing in #101.

## Optional extra: service side

The server serves from the right (deuce) side when the total points played in the game is even, and from the left otherwise. A small arrow or dot on the arc could show this. Only add it if it fits cleanly.

## Test plan

- Team: with `firstServer = P1`, games 1..N alternate P1, P2, P1, …; across a set boundary (6-4, so 10 games) the next set starts with P1.
- Tie-break at 6-6 (12 games, so `T0 = P1`): point 1 P1, points 2-3 P2, points 4-5 P1, …; after a 7-x tie-break the next set starts with **P2**.
- Super tie (decider, or standalone from plan 1): same point rotation; team due next starts.
- Mini set at 2-2: the first game is served by the team due according to games actually played, not 2+2.
- Undo restores the serving side, including across a game won and a set won.
- `firstServer = -1` → `getServingSide()` returns -1 and nothing is drawn.
- Player level: with `firstPlayerP1 = 0`, P1's service games in the set go 0, 1, 0, …; changing the order for the next set swaps them; tie-break turns continue the rotation.

## Acceptance criteria

- With "First serve: Us", the indicator is always on the correct half through a full best-of-3 with a tie-break and a super tie, and stays correct after undos.
- Looks right (no overlap, readable) in the simulator on: one round AMOLED (e.g. fenix847mm / fr265), one round MIP (fr245), venusq2, and Instinct 2.
- Skipping the first-serve question gives exactly today's screen.
- README updated with a screenshot.

## Open questions

- Arc vs. text marker as the default: decide after a simulator prototype on the devices above.
- Should "Who serves first?" be asked for presets too, or only when a setting turns the feature on? Proposal: ask every time, with *Skip* as the quick default.
- Player level: is the opponents' serving player useful to show, or only our own team's?
