<p align="center">
  <img src="https://raw.githubusercontent.com/origami-team/geogami/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">GeoGami Documentation</h1>

<p align="center">
  Cross-component documentation for the <strong>GeoGami</strong> location-based game platform,<br/>
  published as a <a href="https://www.mkdocs.org/">MkDocs</a> site (Material theme).
</p>

---

## What's here

The documentation source lives in [`docs/`](docs/). Each page is plain Markdown and is readable directly on GitHub, or as a rendered site once published.

| Audience | Start with |
|---|---|
| **Researchers & study leaders** | [Platform Overview](docs/PLATFORM_OVERVIEW.md), then the [how-to guides](docs/HOWTO_CREATE_A_GAME.md) |
| **Developers** | [Developer Overview](docs/DEVELOPER_OVERVIEW.md), [REST API](docs/API_REFERENCE.md), [Socket.IO](docs/SOCKETIO_REFERENCE.md), [Track Data](docs/TRACK_DATA_REFERENCE.md) |

## Editing

Just edit the Markdown in [`docs/`](docs/) and open a PR — no build step required to contribute. The [`nav`](mkdocs.yml) in `mkdocs.yml` controls the site's menu order; add new pages there.

## Building locally (optional)

Only needed to preview the rendered site.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve            # live preview at http://127.0.0.1:8000/
mkdocs build --strict   # production build into ./site (also validates links)
```

## Publishing (Docker image)

On every push to `main`, a GitHub Actions workflow ([`.github/workflows/registry-build-publish.yml`](.github/workflows/registry-build-publish.yml)) renders the site into a small nginx image and publishes it to the GitHub Container Registry, mirroring the backend and dashboard repos:

```
ghcr.io/geogami-team/geogami-docs:latest
```

The image serves the static site on port 80. Pull and run it (e.g. on the university server):

```bash
docker pull ghcr.io/geogami-team/geogami-docs:latest
docker run -d -p 8080:80 --name geogami-docs ghcr.io/geogami-team/geogami-docs:latest
```

Build and run the image locally to verify a change before pushing:

```bash
docker build -t geogami-docs .
docker run --rm -p 8080:80 geogami-docs   # http://localhost:8080/
```

## License

MIT — see the parent project for citation information.
