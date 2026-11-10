# Upgrading Lato Storage

Version-specific notes. For the generic upgrade steps see the [README](README.md#upgrading).

## 3.2.0

- Blob links expire and download as attachments. New config `blob_url_expires_in` (default 12 hours).
- The cleaner asks for confirmation and cannot run twice at the same time.
- `PreloadDashboardDataJob` always returns a complete data hash and releases its lock after each run.

## Lato 3.25 compatibility

Requires Lato 3.25.0 or newer. Install the Lato session migration before deployment (`rails lato:install:migrations && rails db:migrate`): sessions become revocable database records and existing sessions are invalidated, so every user signs in again.
