# Daily Claude Message

This repository provides a helper script that switches between multiple Claude Code configurations using [`cc-account-switcher`](https://github.com/ming86/cc-account-switcher) and sends a simple message through the `claude` CLI. It is meant to be deployed on a server and scheduled via `cron`.

## Prerequisites

- [`cc-account-switcher`](https://github.com/ming86/cc-account-switcher) installed and configured with one or more Claude Code profiles.
- The `claude` command-line interface installed and authenticated for each profile you intend to use.
- A POSIX-compatible shell (tested with `bash`).

## Configuration

The automation is implemented in `scripts/daily_claude.sh`. Before wiring it into cron, set the following environment variables in the shell that invokes the script:

- `CLAUDE_ACCOUNTS` (required): Comma-separated list of `cc-account-switcher` account identifiers (email or numeric index), e.g. `CLAUDE_ACCOUNTS="work@example.com,personal@example.com"`.
- `CLAUDE_MESSAGE` (optional): Message text to send. Defaults to `"Hello from the Claude daily cron job."`.
- `CLAUDE_CMD` (optional): The Claude CLI executable name. Defaults to `claude`.
- `CLAUDE_ARGS` (optional): Additional arguments passed to the Claude CLI. Example: `CLAUDE_ARGS="chat --model claude-3-sonnet"`.
- `CC_SWITCH_CMD` (optional): Override to the `cc-account-switcher` executable if it is not on `PATH`. Defaults to `ccswitch` or `ccswitch.sh` if either is available.

Example manual run:

```bash
CLAUDE_ACCOUNTS="work@example.com,personal@example.com" \
CLAUDE_MESSAGE="Daily status ping." \
CLAUDE_ARGS="chat --model claude-3-5-sonnet" \
scripts/daily_claude.sh
```

The script pipes the message text to `claude`, so adapt `CLAUDE_ARGS` to match the CLI syntax used in your environment.

## Cron Scheduling

To run the script every day at 05:30, create a cron entry similar to the following (adjust the path as needed):

```
30 5 * * * CLAUDE_ACCOUNTS="work@example.com,personal@example.com" CLAUDE_MESSAGE="Daily status ping." /usr/local/bin/scripts/daily_claude.sh >> /var/log/claude-cron.log 2>&1
```

If you prefer to keep the environment variables in a separate file, you can source it:

```
30 5 * * * . /opt/claude/env.sh && /opt/claude/scripts/daily_claude.sh >> /var/log/claude-cron.log 2>&1
```

Use absolute paths in cron entries, and make sure the script has execute permissions (`chmod +x scripts/daily_claude.sh`).

The script leaves the last-used Claude Code configuration active after each run. If switching back to a specific profile is required, append the desired `"$CC_SWITCH_CMD" --switch-to <identifier>` command at the end of the script.
