<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">GeoGami — REST API Reference</h1>

<p align="center">
  All HTTP endpoints of the GeoGami server (<a href="https://github.com/geogami-team/origami-backend">origami-backend</a>).<br/>
  For the real-time layer, see the <a href="SOCKETIO_REFERENCE.md">Socket.IO Event Reference</a>.
</p>

---

The API is served by Express on port **3000** (same server that hosts Socket.IO). All bodies are JSON (`Content-Type: application/json`) unless noted; the body-size limit is 50 MB. This reference was written against the route and controller sources — each table states the actual auth requirement enforced in code.

## Table of contents

- [Authentication model](#authentication-model)
- [`/user` — accounts & auth](#user--accounts--auth)
- [`/game` — game definitions](#game--game-definitions)
- [`/track` — gameplay recordings](#track--gameplay-recordings)
- [`/file` — media upload & download](#file--media-upload--download)
- [`/appversion` — client version check](#appversion--client-version-check)
- [Conventions and gotchas](#conventions-and-gotchas)

---

## Authentication model

- **JWT bearer tokens.** Authenticated endpoints expect `Authorization: Bearer <token>`. Tokens are issued by `POST /user/login` and renewed with `POST /user/refresh-auth` (refresh tokens are stored per user and individually revocable).
- **Roles.** Some endpoints additionally require a role: `admin`, `contentAdmin`, `trackAccess`, `scholar` (see the [Glossary](GLOSSARY.md#platform--access)). In the tables below: *JWT* = any authenticated user; *JWT + roles(...)* = listed roles only; *public* = no auth.
- **Email verification.** Login succeeds even with an unconfirmed email but returns `needsEmailVerification: true`; the client is expected to route the user to the verification page instead of the app.

**Login example:**

```http
POST /user/login
{ "username": "<username or email>", "password": "..." }

→ 200 { "code": "Authorized", "message": "...", "user": {…}, "token": "<JWT>", "refreshToken": "..." }
→ 401 { "code": "Unauthorized", "message": "Wrong username or password" }
```

## `/user` — accounts & auth

### Registration & session

| Method | Path | Auth | Body / params | Returns |
|---|---|---|---|---|
| POST | `/user/register` | public | `{name, email, username, password}` — username ≥ 5 chars, password ≥ 8 | `{success, msg}`; sends verification email; `400` on validation or duplicate username/email |
| POST | `/user/login` | public | `{username, password}` — `username` accepts username **or** email | `{code, message, user, token, refreshToken}` (+ `needsEmailVerification` if unconfirmed) |
| POST | `/user/refresh-auth` | public | `{token: <refreshToken>}` | `{code, message, data:{user}, token, refreshToken}` — rotates both tokens |
| GET | `/user/logout` | — | — | Legacy session logout; redirects to `/` (JWT clients just discard tokens) |
| GET | `/user/confirm-email` | public | query params from the emailed link | Confirms the address; promotes `unconfirmedEmail` → `email` |
| POST | `/user/request-password-reset` | public | `{email: {email: "<address>"}}` (note the nesting) | Emails a verification code |
| POST | `/user/password-reset` | public | `{newPassword, email, verificationCode}` | Sets the new password |

### Own account (JWT)

| Method | Path | Auth | Body / params | Returns |
|---|---|---|---|---|
| GET | `/user/myuser` | JWT | — | Current user document |
| PUT | `/user/profile` | JWT | profile fields (own `_id` only) | Updated user |
| POST | `/user/changepass` | JWT | `{oldPassword, newPassword}` | Confirmation |
| POST | `/user/change-mail` | JWT | `{mail}` | Sends confirmation link to the **new** address; address switches only after the link is opened |
| POST | `/user/resend-verification` | JWT | — | Resends the verification email; **60 s cooldown** per user (`429` with `retryAfter` when hit) |
| POST | `/user/delete-me` | JWT | — | Deletes own account |
| GET | `/user/games` | JWT | — | Games created by the caller (`contentAdmin`: all visible games); hidden (`isVisible: false`) games excluded |

### User administration — JWT + roles(`admin`, `contentAdmin`)

| Method | Path | Body / params | Returns |
|---|---|---|---|
| GET | `/user/user/` | — | All users |
| GET | `/user/user/:id` | — | One user; `404` if missing |
| POST | `/user/user/` | user fields | Creates a user (password hashed, verification email sent) |
| PUT | `/user/user/:id` | fields to update | Updated user |
| PUT | `/user/update-role` | `{_id, roles: [<role>]}` | Sets the user's role (single role; replaces the list) |
| DELETE | `/user/user/:id` | — | Deletes the user |
| POST | `/user/user/:id/resend-verification` | — | Resends verification on the user's behalf; regenerates the token so old links die |
| POST | `/user/user/:id/trigger-password-reset` | — | Emails a reset code to the user |
| GET | `/user/user/:id/games` | — | `{user, games: [...]}` — the user's games incl. per-game `tracksCount` |

## `/game` — game definitions

| Method | Path | Auth | Body / params | Returns |
|---|---|---|---|---|
| GET | `/game/all` | public | — | **Published** games only (public game list). Drafts excluded |
| GET | `/game/allmultiplayer` | public | — | **Published** multiplayer games |
| GET | `/game/allwithlocs` | public | — | **Published** games with their locations (map overview) |
| GET | `/game/drafts` | JWT | — | **Draft** (unpublished) games visible to the caller: `admin`/`contentAdmin` get *every* draft (Drafts tab); any other user gets *their own* drafts (My Games + draft badge) |
| GET | `/game/:id` | public | — | One full game definition (tasks, settings) |
| GET | `/game/usergames` | JWT + roles(`admin`, `contentAdmin`, `trackAccess`, `scholar`) | — | Games the caller can **evaluate**: games they created, games shared with them (email in `sharedWith`), games they **instruct** (a track's `instructor` is them), or games with a track **shared** with them — only those with ≥ 1 *visible* track. **Not filtered by publish state** (drafts can be evaluated/shared). Used by the dashboard |
| POST | `/game/` | JWT | full game definition | Created game. The app saves new games as drafts (`isPublished: false`) |
| PUT | `/game/` | JWT — owner, co-author (`editors`), or `admin` | game incl. `_id` | Updated game; `405` if not authorized |
| PUT | `/game/:id/publish` | JWT — owner, co-author (`editors`), or `admin` | `{isPublished: true \| false}` | Publish a draft or move a published game back to draft; `405` if not authorized |
| PUT | `/game/delete/:id` | JWT — owner or `admin`/`contentAdmin` | — | **Soft delete**: sets `isVisible: false` (data and tracks remain; the game disappears from lists). Co-authors **cannot** delete |
| POST | `/game/:id/share` | JWT — creator or `admin` | `{emails: ["a@b.c", …]}` | Grants **track** access; rejects the owner's own email and unregistered addresses |
| DELETE | `/game/:id/share` | JWT — creator or `admin` | `{emails: [...]}` | Revokes track access |
| GET | `/game/:id/share` | JWT — creator or `admin` | — | Current list of track-shared emails |
| POST | `/game/:id/editors` | JWT — creator or `admin` | `{emails: ["a@b.c", …]}` | Adds **co-authors** (`editors`): may edit + publish + see tracks. Rejects owner/unregistered emails |
| DELETE | `/game/:id/editors` | JWT — creator or `admin` | `{emails: [...]}` | Removes a co-author |
| GET | `/game/:id/editors` | JWT — creator or `admin` | — | Current list of co-author emails |

> Route-ordering note (for contributors): `/game/:id` is a wildcard and is registered **last**; new specific routes must be added before it.

## `/track` — gameplay recordings

The JSON structure of tracks is documented field by field in the [Track Data Reference](TRACK_DATA_REFERENCE.md).

| Method | Path | Auth | Body / params | Returns |
|---|---|---|---|---|
| GET | `/track/all` | JWT + roles(`admin`, `contentAdmin`, `trackAccess`, `scholar`) | — | All tracks |
| GET | `/track/gametracks/:id` | JWT + roles(same) | game id | Tracks of one game the caller may see (dashboard's session list). Scoped per caller — see *Track access* below |
| GET | `/track/:id` | JWT + roles(same) | track id | One full track, if the caller may see it (see *Track access* below) |
| GET | `/track/waypoints/:id` | JWT + roles(same) | track id | Only the track's waypoints |
| GET | `/track/waypointswithevents/:id` | JWT + roles(same) | track id | Waypoints + events |
| POST | `/track/` | **none** ⚠️ | full track document (`game` must be a valid game id; optional `instructor` = a real user id for class plays) | `201 {message, content: <saved track>}`; `400` if `instructor` is present but not a real user |
| PUT | `/track/` | **none** ⚠️ | `{_id, playerNo, waypoints, events, players, device}` | Multiplayer: writes the player's data into slot `playerNo − 1` of the shared track |
| POST | `/track/:id/share` | JWT — track owner or `admin` | `{emails: [...]}` | Shares one track; owner = the track's `instructor`, else its game's creator |
| DELETE | `/track/:id/share` | JWT — track owner or `admin` | `{emails: [...]}` | Revokes a track share |
| GET | `/track/:id/share` | JWT — track owner or `admin` | — | Current list of shared-with emails |

> ⚠️ `POST /track` and `PUT /track` have **no auth middleware** — any client can submit or modify (multiplayer) tracks. The UI does send its JWT, but the server doesn't check it. See [gotchas](#conventions-and-gotchas).

> Route-ordering note (for contributors): the `/track/:id/share` routes are registered **before** the `/track/:id` wildcard.

### Track access (class sharing)

A track started from an instructor's **class QR** carries an `instructor` (the sharing user's id); such *class tracks* belong to that instructor, not the game creator. A per-track `sharedWith` (emails) grants extra viewers. The read endpoints above resolve visibility as:

| Caller | Sees |
|---|---|
| full `admin` | every track |
| game creator / game-share recipient | only non-class tracks (no `instructor`) |
| instructor | only tracks where `instructor` is them |
| per-track share recipient | only tracks listing them in `sharedWith` |

`contentAdmin` has **no** special track visibility — it is treated like any other user (owner-based access only). Indexes on `Track.instructor` and `Track.sharedWith` back these lookups.

## `/file` — media upload & download

Files are stored in MongoDB **GridFS**, sorted into buckets by MIME type (`photos`, `audios`, `videos`, `misc`).

| Method | Path | Auth | Body / params | Returns |
|---|---|---|---|---|
| POST | `/file/upload` | **none** ⚠️ | `multipart/form-data`, field name **`file`** | `{message, filename}` — the `filename` is what you pass to the GET endpoints |
| GET | `/file/image/:file` | public | stored filename | The image (task photos, answer photos) |
| GET | `/file/audio/:file` | public | stored filename | Audio file |
| GET | `/file/video/:file` | public | stored filename | Video file |

## `/appversion` — client version check

| Method | Path | Auth | Returns |
|---|---|---|---|
| GET | `/appversion/current` | public | `{message, content: <current version info>}` — used by clients to prompt for updates |

## Conventions and gotchas

- **Mixed error styles.** Older handlers use the legacy `res.send(status, body)` form and some auth failures return `200` with `{success: false}` rather than an error status (e.g. login with a non-string username). Don't rely on the status code alone — check the body.
- **`405` means "not owner".** Game update/delete return `405` (Method Not Allowed) when the caller isn't the owner or an admin — semantically a `403`.
- **Soft deletes.** `PUT /game/delete/:id` only hides the game (`isVisible: false`); tracks and the definition stay in the database.
- **Draft vs. published (`isPublished`).** Public lists (`/game/all*`) only return *published* games. The creator publishes their own game via `PUT /game/:id/publish` — there is no admin curation step. The flag has three states: missing → **published** (legacy games, so no migration was needed), `true` → **published**, `false` → **draft** (only set on games created after this feature shipped). `isVisible` (soft-delete) is orthogonal. Sharing and evaluation (`/game/usergames`, `/game/:id/share`) ignore publish state, so a draft can be shared and played via a share link before it is published.
- **Nested reset payload.** `POST /user/request-password-reset` expects `{email: {email: "..."}}`, not a flat field.
- **Unauthenticated writes.** `POST /track`, `PUT /track`, and `POST /file/upload` enforce no authentication (tracked as a known issue). Anything else that mutates data requires a JWT.
- **Public game definitions.** `GET /game/:id` and the `/game/all*` lists are public by design (games are playable without an account); only *track* data is role-protected.

---

**Related:** [Developer Overview](DEVELOPER_OVERVIEW.md) · [Socket.IO Event Reference](SOCKETIO_REFERENCE.md) · [Track Data Reference](TRACK_DATA_REFERENCE.md) · route sources: `src/routes/` in [origami-backend](https://github.com/geogami-team/origami-backend)

**Contact:** Spatial Intelligence Lab (SIL), Institute for Geoinformatics, University of Münster — geogami(at)uni-muenster.de — <https://geogami.uni-muenster.de>
