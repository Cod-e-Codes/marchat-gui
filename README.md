# marchat GUI Client

Cross-platform desktop client for the [marchat](https://github.com/Cod-e-Codes/marchat) chat server: WebSocket chat, file sharing, optional E2E encryption, and admin tools. Theme ids match the Flutter app and TUI: `system`, `patriot`, `retro`, and `modern`.

**Status:** Companion client.

## Relationship to marchat

This is an optional graphical companion for the main [marchat](https://github.com/Cod-e-Codes/marchat) project.

- The terminal client in `marchat` remains the reference client and protocol source.
- This Go/Fyne client targets protocol compatibility with [PROTOCOL.md](https://github.com/Cod-e-Codes/marchat/blob/main/PROTOCOL.md).
- Themes and behavior are aligned with the broader client ecosystem where practical.
- Plugin registry defaults and catalog come from [marchat-plugins](https://github.com/Cod-e-Codes/marchat-plugins).

**Also see:** [marchat_flutter](https://github.com/Cod-e-Codes/marchat_flutter) (primary GUI focus).

## Features

- Real-time WebSocket messaging (same protocol as `PROTOCOL.md` in the server repo)
- File sharing with configurable size limits
- End-to-end encryption with the shared marchat keystore
- Window themes aligned with Flutter: `system`, `patriot`, `retro`, `modern` (Fyne maps these to light/dark/default)
- Optional admin features when connected with a valid admin key
- 12/24 hour time display
- Audio notification options (with mention-only mode)
- Code snippets via markdown code fences
- Auto-reconnect with exponential backoff
- Persists settings to the same `config.json` as other marchat clients (`GetConfigPath` in `client/config`)

## Requirements

- Go 1.25.9 or later (aligned with the main [marchat](https://github.com/Cod-e-Codes/marchat) module)
- A running marchat server (see the server repo [QUICKSTART.md](https://github.com/Cod-e-Codes/marchat/blob/main/QUICKSTART.md))

## Dependencies

- [Fyne v2](https://fyne.io/) (GUI)
- [Gorilla WebSocket](https://github.com/gorilla/websocket)
- [github.com/Cod-e-Codes/marchat](https://github.com/Cod-e-Codes/marchat) (`client/config`, `client/crypto`, `shared`)

## Branding

The marchat wordmark and logo are copied from the main repo into `assets/marchat-transparent.png` and `assets/marchat-transparent.svg`. The **window and application icon** (task switcher, title bar, packaged Android icon) use the embedded PNG. The in-app **About** dialog is text only. The Android build script (`build-android.sh`) passes the same file to `fyne package` as `-icon`.

## Installation

```bash
go build -o marchat-gui .
```

## Configuration

### Interactive setup

Run with no arguments to open the connection form:

```bash
./marchat-gui
```

On first launch, the form is pre-filled from the standard marchat client `config.json` if it already exists (same as the TUI).

### Configuration options

- **Username** (required)
- **Server URL** (default `ws://localhost:8080/ws`)
- **Admin** (optional) with **Admin key** when the server requires it
- **E2E** (optional) with keystore **passphrase** and optional **global E2E key** field (sets `MARCHAT_GLOBAL_E2E_KEY` in-process; see the main repo docs for key distribution)
- **Theme** (`system` | `patriot` | `retro` | `modern`)

### Keystore location

Uses the same resolution as the official client (`config.GetKeystorePath()`): typically `keystore.dat` under the marchat config directory (for example `%APPDATA%\\marchat` on Windows).

## Usage

### Chat commands

```
:clear              Clear chat history
:time               Toggle 12/24h time format
:bell               Toggle notification sounds
:bell-mention       Toggle mention-only notifications
:code               Open code snippet dialog
:sendfile [path]    Send a file
:savefile <name>    Save a received file
:theme <name>       Set theme: system, patriot, retro, modern, or legacy light / dark
```

### Admin commands

```
:cleardb            Clear message database
:backup             Backup database
:stats              Show database statistics
:kick <user>        Kick a user
:ban <user>         Ban a user
:unban <user>       Remove a ban
:allow <user>       Allow a user (override kick)
:forcedisconnect <user>  Force disconnect
```

### File size limits

Same as the server and other clients, via environment (evaluated in this client for outbound files):

- `MARCHAT_MAX_FILE_BYTES` (takes precedence)
- `MARCHAT_MAX_FILE_MB` if bytes not set

Default cap is 1MB when neither is set.

## Encryption

1. Enable E2E in the form and provide the keystore passphrase.  
2. Set the global key through the form or `MARCHAT_GLOBAL_E2E_KEY` in the environment before starting the app, per the main repo.  
3. Keystore files are compatible with the TUI and other official clients.

## Admin features

Admins on the allowlist, with a valid key, can use the Admin menu, user list selection, and `:`-prefixed admin commands as in the main client.

## Keyboard notes

- **Enter** (implementation varies by platform): use the Send button or the menu if Enter inserts a newline instead of sending.
- For multiline input, your OS/Fyne key bindings apply.

## Logging

Debug logs append to `marchat-gui-debug.log` in the working directory.

## Environment variables

| Variable | Purpose |
|----------|--------|
| `MARCHAT_GLOBAL_E2E_KEY` | Global E2E key material (base64), same as other clients |
| `MARCHAT_MAX_FILE_BYTES` / `MARCHAT_MAX_FILE_MB` | Outgoing file size limits |
| `MARCHAT_CONFIG_DIR` | Override the config directory (same as TUI) |

## Connection behavior

- Pings, reconnect with backoff (max 30s)
- In development, TLS verify may be disabled in the dialer; use `wss://` with a proper cert for production
- On each successful connect, the transcript is cleared so the server’s history replay stays authoritative (see `PROTOCOL.md`)

## Build (smaller binary)

```bash
go build -ldflags="-s -w" -o marchat-gui .
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
