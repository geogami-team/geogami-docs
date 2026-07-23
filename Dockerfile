# syntax=docker/dockerfile:1

# ---- build stage: render the MkDocs site to static HTML ----
FROM python:3.12-slim AS build
WORKDIR /docs
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# --strict fails the build on any broken link or bad anchor.
RUN mkdocs build --strict

# ---- serve stage: tiny nginx image with just the static site ----
FROM nginx:alpine
COPY --from=build /docs/site /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
# nginx:alpine already runs nginx in the foreground by default.
