<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">How-to: Export and Analyze Track Data (R / Python)</h1>

<p align="center">
  From the dashboard download to a tidy data frame.<br/>
  The complete format documentation is the <a href="TRACK_DATA_REFERENCE.md">Track Data Reference</a> — keep it next to this guide.
</p>

---

## 1. Choose your export

| You want… | Use |
|---|---|
| Quick per-task tables, comparisons, plots | The dashboard's built-in **CSV/PNG exports** (per tab) — no coding needed ([Dashboard User Guide](https://github.com/geogami-team/geogami-dashboard/blob/HEAD/docs/USER_GUIDE.md)) |
| Full control: custom measures, statistics, GIS | The **raw JSON tracks** — dashboard sidebar → select sessions → **Download** (zip, one file per session) |

The file name encodes game name, player name(s), and start time — it is your **participant identifier** (there is no separate ID field).

## 2. Load a track

A track has three parts you'll use: `waypoints` (the route), `events` (task lifecycle + answers), and metadata (`start`, `end`, `players`, `device`). Two things to handle on load — both explained in the [reference](TRACK_DATA_REFERENCE.md): **multiplayer files nest one level deeper** (per-player arrays), and **waypoints without a position fix** should be skipped.

### Python

```python
import json
import pandas as pd

with open("track.json") as f:
    track = json.load(f)

# Multiplayer files store per-player arrays — pick a player (here: player 1)
multi = bool(track.get("isMultiplayerGame"))
waypoints = track["waypoints"][0] if multi else track["waypoints"]
events    = track["events"][0]    if multi else track["events"]

wp = pd.DataFrame(
    {
        "time": w["timestamp"],
        "lat":  w["position"]["coords"]["latitude"],
        "lng":  w["position"]["coords"]["longitude"],
        "accuracy": w["position"]["coords"].get("accuracy"),
        "task": w.get("taskNo"),
        "category": w.get("taskCategory"),
    }
    for w in waypoints
    if w.get("position") and w["position"].get("coords")
)
wp["time"] = pd.to_datetime(wp["time"])
```

### R

```r
library(jsonlite)
library(dplyr)
`%||%` <- function(a, b) if (is.null(a)) b else a  # built into R >= 4.4

track <- fromJSON("track.json", simplifyVector = FALSE)

multi     <- isTRUE(track$isMultiplayerGame)
waypoints <- if (multi) track$waypoints[[1]] else track$waypoints
events    <- if (multi) track$events[[1]]    else track$events

wp <- bind_rows(lapply(waypoints, function(w) {
  if (is.null(w$position) || is.null(w$position$coords)) return(NULL)
  tibble(
    time     = w$timestamp,
    lat      = w$position$coords$latitude,
    lng      = w$position$coords$longitude,
    accuracy = w$position$coords$accuracy %||% NA,
    task     = w$taskNo %||% NA,
    category = w$taskCategory %||% NA
  )
}))
wp$time <- as.POSIXct(wp$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")
```

## 3. Extract the answers

Answers are events of type `ON_OK_CLICKED`, `PHOTO_SELECTED`, or `MULTIPLE_CHOICE_SELECTED`; each carries the active task's full definition. With `multipleTries` enabled a task can have several answer events — keep all of them or only the last, depending on your question.

```python
ANSWER_EVENTS = {"ON_OK_CLICKED", "PHOTO_SELECTED", "MULTIPLE_CHOICE_SELECTED"}

answers = pd.DataFrame(
    {
        "time":      e["timestamp"],
        "task":      e.get("task", {}).get("name"),
        "task_type": e.get("task", {}).get("type"),
        "correct":   e.get("correct"),
        # shape depends on the task's answer type — see the Track Data Reference
        "answer":    e.get("answer"),
    }
    for e in events
    if e["type"] in ANSWER_EVENTS
)
last_answers = answers.groupby("task", sort=False).last().reset_index()
```

The `answer` column's contents vary by answer type (`distance` for position tasks, `clickDirection` for map-direction tasks, …) — the [payload table](TRACK_DATA_REFERENCE.md#answer-payload-shapes-in-on_ok_clicked) lists every shape and what `correct` means for each (e.g. ±30° for directions, the task's `accuracy` for positions).

## 4. Per-task measures

**Durations** — segment by `INIT_TASK` events:

```python
inits = [e for e in events if e["type"] == "INIT_TASK"]
durations = pd.DataFrame({
    "task":  [e["task"]["name"] for e in inits],
    "start": pd.to_datetime([e["timestamp"] for e in inits]),
})
durations["end"] = durations["start"].shift(-1).fillna(pd.to_datetime(track["end"]))
durations["seconds"] = (durations["end"] - durations["start"]).dt.total_seconds()
```

**Route length** — haversine over consecutive waypoints of one task (filter poor GPS fixes first; in real-world games drop points with `accuracy` above ~20–30 m):

```python
import numpy as np

def route_length_m(g):
    lat, lng = np.radians(g["lat"].values), np.radians(g["lng"].values)
    dlat, dlng = np.diff(lat), np.diff(lng)
    a = np.sin(dlat/2)**2 + np.cos(lat[:-1]) * np.cos(lat[1:]) * np.sin(dlng/2)**2
    return float((2 * 6371000 * np.arcsin(np.sqrt(a))).sum())

route = wp.groupby("task").apply(route_length_m).rename("route_m")
```

**Map-interaction effort** — the `interaction` counters (`panCount`, `zoomCount`, rotation) reset at each task start, so the values on a task's **last waypoint** are that task's totals.

## 5. Watch out for

The full list lives in the [caveats section](TRACK_DATA_REFERENCE.md#caveats-and-gotchas) — the ones that bite most often in analysis:

- **Virtual games:** coordinates are pseudo lat/lng derived from Unity scene units (distances are "virtual metres"; comparable within a world, not to GPS), and `position.timestamp` is always `0` — use the waypoint's own `timestamp`.
- **Old exports** (before mid-2026) contain a top-level `answers: null` — ignore it; answers are in `events`.
- **Aborted runs** may lack `FINISHED_GAME`; decide an inclusion rule before analyzing.
- **Photos** in answers are URLs into the GeoGami server (`/file/image/<filename>`); download them while you have a valid session, or use the dashboard's Pictures tab.

## Citing GeoGami

If you publish with GeoGami data, cite the project via the DOI on the [main repository](https://github.com/geogami-team/geogami) (Zenodo: `10.5281/zenodo.5384903`) and see `CITATION.cff` there.
