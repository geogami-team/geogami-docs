<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">How-to: Run a Virtual Study Session</h1>

<p align="center">
  Running participants through a virtual-world GeoGami game — in the lab or remotely.<br/>
  Background reading: <a href="PLATFORM_OVERVIEW.md">Researcher Overview</a> · <a href="HOWTO_CREATE_A_GAME.md">How-to: Create a Game</a>
</p>

---

## Checklist before the session

- [ ] The game is created, piloted end to end, and plays in the intended virtual world.
- [ ] Study device ready: the GeoGami app (tablet/laptop/browser) — the 3D world opens **embedded in the app**, so one device is enough for standard sessions.
- [ ] Stable internet: the app, the 3D view, and the server sync in real time during play.
- [ ] Your **participant-ID scheme** is decided: the player name entered at game start is the participant identifier in all data.
- [ ] Optional: keyboard/mouse for desktop play (most comfortable for participants), or the headset prepared (see below).

## Running a participant (single-player)

1. In the app, go to **Play game** and select your game.
2. Enter the **player name** — use your participant ID (e.g. `P07`). Names must be unique among *currently running* sessions; if the app reports the name as taken, a session with that name is still open.
3. Press **Play**. The virtual environment opens inside the app and connects automatically — there is nothing to pair or type.
4. Hand over to the participant. Controls in the 3D world:

   | Action | Input |
   |---|---|
   | Move | `W`/`A`/`S`/`D` or arrow keys (single-touch controls on tablets) |
   | Look around | Mouse / touch-drag |
   | Jump | `Space` |
   | Settings | `Esc` |

5. The participant works through the tasks; the map, questions, and answers live in the app while the avatar moves through the 3D world. The route and all answers are **recorded automatically** — no action needed from you.
6. When the last task is done the 3D view closes by itself and the track uploads to the server.
7. **Before dismissing the participant**, verify the track arrived: open the dashboard (evaluate page), select the game, and check that a session with the participant's name is listed.

## Multiplayer sessions

- Each participant enters their player name **and the shared game code**; all clients join the same session.
- Wait until the app shows all players joined before starting — the game is locked to the player count set at creation.
- All players of one run end up in **one shared track** (per-player arrays); see the [Track Data Reference](TRACK_DATA_REFERENCE.md#multiplayer-tracks) before analyzing.
- Be aware of two open server issues for multiplayer virtual games: concurrent multiplayer games currently share one avatar-sync room ([origami-backend#100](https://github.com/geogami-team/origami-backend/issues/100)) and spawn positions are fixed ([#102](https://github.com/geogami-team/origami-backend/issues/102)) — avoid running two multiplayer VE studies at the same time until these are resolved.

## Playing with a VR headset

For immersive setups, the virtual environment can run on a VR headset instead of the embedded view:

1. Install the headset-capable build of the virtual environment on the VR-ready machine (see the [VE releases page](https://github.com/origami-team/geogami-virtual-environment/releases/latest); release notes state which worlds and platforms each build supports).
2. Run the GeoGami app on a separate device as usual (it remains the map/task display and the recorder).
3. Start the game in the app with the participant's name; the headset client joins the same session.
4. Plan extra pilot time: comfort, play area, and frame rate vary by machine — and brief participants on motion sickness as part of your ethics protocol.

## Remote participants

Virtual games also work fully remotely: the participant runs the app (web version) on their own computer, the 3D world opens embedded, and the track uploads to the server like in the lab. Do a tech-check call first (browser, performance, input device), and stay on a video call during the session for instructions.

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| "Name already in use" | A session with that player name is still open — use a fresh ID or wait for the stale session to drop |
| 3D world doesn't open | Check the connection; reload and restart the game entry — re-enter the same player name |
| Avatar doesn't move on the map | The real-time sync dropped; restart the run (tracks of aborted runs may lack the final task — see [caveats](TRACK_DATA_REFERENCE.md#caveats-and-gotchas)) |
| Track missing in the dashboard | The game wasn't finished (the upload happens at game end); the local device copy can serve as backup ([where](TRACK_DATA_REFERENCE.md#getting-track-files)) |

**Next:** [Export & analyze the data](HOWTO_ANALYZE_TRACKS.md)
