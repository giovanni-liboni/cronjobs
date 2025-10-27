# Daily Claude Message

This repository provides a helper script that switches between multiple Claude Code configurations using [`cc-switch`](https://github.com/HoBeedzc/cc-switch) and sends a simple message through the `claude` CLI. It is meant to be deployed on a server and scheduled via `cron`.

## Prerequisites

- [`cc-switch`](https://github.com/HoBeedzc/cc-switch) installed and configured with one or more Claude Code profiles.
- The `claude` command-line interface installed and authenticated for each profile you intend to use.
- A POSIX-compatible shell (tested with `bash`).

## Configuration

The automation is implemented in `scripts/daily_claude.sh`. Before wiring it into cron, set the following environment variables in the shell that invokes the script:

- `CLAUDE_ACCOUNTS` (required): Comma-separated list of `cc-switch` configuration names to use, e.g. `CLAUDE_ACCOUNTS="work,personal"`.
- `CLAUDE_MESSAGE` (optional): Message text to send. Defaults to `"Hello from the Claude daily cron job."`.
- `CLAUDE_CMD` (optional): The Claude CLI executable name. Defaults to `claude`.
- `CLAUDE_ARGS` (optional): Additional arguments passed to the Claude CLI. Example: `CLAUDE_ARGS="chat --model claude-3-sonnet"`.

Example manual run:

```bash
CLAUDE_ACCOUNTS="work,personal" \
CLAUDE_MESSAGE="Daily status ping." \
CLAUDE_ARGS="chat --model claude-3-5-sonnet" \
scripts/daily_claude.sh
```

The script pipes the message text to `claude`, so adapt `CLAUDE_ARGS` to match the CLI syntax used in your environment.

## Cron Scheduling

To run the script every day at 05:30, create a cron entry similar to the following (adjust the path as needed):

```
30 5 * * * CLAUDE_ACCOUNTS="work,personal" CLAUDE_MESSAGE="Daily status ping." /usr/local/bin/scripts/daily_claude.sh >> /var/log/claude-cron.log 2>&1
```

If you prefer to keep the environment variables in a separate file, you can source it:

```
30 5 * * * . /opt/claude/env.sh && /opt/claude/scripts/daily_claude.sh >> /var/log/claude-cron.log 2>&1
```

Use absolute paths in cron entries, and make sure the script has execute permissions (`chmod +x scripts/daily_claude.sh`).

The script leaves the last-used Claude Code configuration active after each run. If switching back to a specific profile is required, append the desired `cc-switch use <name>` command at the end of the script.
