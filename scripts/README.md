# Scripts

Bootstrap and maintenance scripts will live here.

Rules:
- idempotent where practical
- fail loudly
- support dry-run for destructive/system operations
- do not hide Fedora/Asahi package operations behind opaque magic
- keep install and update paths understandable

The bootstrap should eventually turn a fresh Fedora Asahi Minimal installation into sn0w using this repository as source of truth.
