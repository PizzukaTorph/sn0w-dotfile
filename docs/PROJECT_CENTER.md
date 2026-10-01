# Project Center

Project Center is a thin orchestration surface for development projects.

## Project vs Project Session

A **Project** is persistent configuration. A **Project Session** is the live relationship between that project and the current desktop state.

Selecting a project from the launcher:

1. if inactive, create/start a session and allocate a Project workspace;
2. if already active, focus the existing workspace;
3. never create accidental duplicates.

## Candidate manifest

The manifest format is intentionally provisional until implementation begins.

```yaml
name: Underground
icon: ./assets/underground.svg
path: ~/Projects/underground-platform
editor: code

compose:
  file: docker-compose.yml

links:
  - name: Web
    url: http://localhost:3000
  - name: Studio
    url: http://localhost:3001

terminals:
  - name: Root
    cwd: .
  - name: API
    cwd: apps/api
```

## V1 operations

- Start / Stop / Restart project services
- Code
- Terminal
- Browser
- Logs
- Exec
- show Git branch/dirty state
- show service health and ports

## Explicit non-goals

- IDE replacement
- full Git client
- full Docker/Compose administration
- metrics/dashboard product
- project task runner ecosystem
