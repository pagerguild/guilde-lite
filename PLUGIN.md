# guilde-workflows Plugin

This repository contains a Claude Code plugin that provides multi-agent workflow orchestration, TDD enforcement, and conductor pattern commands.

## Quick Start

```bash
# From the guilde-lite directory
claude --plugin-dir .

# Or with full path
claude --plugin-dir /path/to/guilde-lite
```

## Installation

### Option 1: Session-Only (Development)

Load the plugin for the current session using the `--plugin-dir` flag:

```bash
# Navigate to project directory
cd /path/to/guilde-lite

# Start Claude Code with plugin loaded
claude --plugin-dir .
```

### Option 2: Shell Alias (Recommended for Regular Use)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Alias for guilde-lite development
alias claude-guilde='claude --plugin-dir /path/to/guilde-lite'
```

Then start sessions with:
```bash
claude-guilde
```

### Option 3: Multiple Plugin Directories

Load multiple local plugins:

```bash
claude --plugin-dir ./guilde-lite --plugin-dir ./other-plugin
```

### Validating the Plugin

Before loading, you can validate the plugin structure:

```bash
claude plugin validate /path/to/guilde-lite
```

## Available Commands

After loading the plugin, these slash commands are available (prefixed with `guilde-workflows:`):

| Command | Description |
|---------|-------------|
| `/guilde-workflows:conductor-setup` | Initialize conductor infrastructure |
| `/guilde-workflows:conductor-new-track` | Create a new implementation track |
| `/guilde-workflows:conductor-implement` | Work on implementing a track's phase |
| `/guilde-workflows:conductor-status` | View track status and progress |
| `/guilde-workflows:conductor-checkpoint` | Create checkpoint commits |
| `/guilde-workflows:conductor-sync-docs` | Synchronize documentation |
| `/guilde-workflows:tdd` | TDD workflow management |
| `/guilde-workflows:review-all` | Multi-stage code review pipeline |
| `/guilde-workflows:mise` | Mise runtime management |
| `/guilde-workflows:multi-agent` | Multi-agent workflow status |
| `/guilde-workflows:docs-sync` | Documentation synchronization |
| `/guilde-workflows:research-releases` | Research upstream releases |

## Plugin Structure

```
guilde-lite/
├── .claude-plugin/
│   └── plugin.json        # Plugin metadata
├── commands/              # Slash commands (12)
│   ├── conductor-*.md     # Conductor pattern commands
│   ├── tdd.md             # TDD workflow
│   ├── review-all.md      # Code review pipeline
│   └── ...
├── skills/                # Loadable skills (11)
│   ├── tdd-*-phase/       # TDD phase skills
│   ├── code-review-pipeline/
│   └── ...
├── agents/                # Agent definitions (13)
│   ├── code-reviewer.md
│   ├── architect-reviewer.md
│   └── ...
└── .claude/               # Project-specific config
    ├── rules/             # Quality rules
    └── hookify.*.local.md # Hookify rules
```

## Skills

Skills are loaded on-demand to provide specialized capabilities:

| Skill | Purpose |
|-------|---------|
| `tdd-red-phase` | Write failing tests |
| `tdd-green-phase` | Implement minimal passing code |
| `tdd-refactor-phase` | Clean up without changing behavior |
| `code-review-pipeline` | Multi-stage review orchestration |
| `mise-expert` | Runtime management expertise |
| `mermaid-generator` | Create Mermaid diagrams |
| `c4-generator` | Generate C4 architecture diagrams |
| `release-researcher` | Research upstream releases |

## Agents

Agents are specialized subprocesses for complex tasks:

| Agent | Tier | Purpose |
|-------|------|---------|
| `context-explorer` | haiku | Fast codebase exploration |
| `docs-researcher` | haiku | Research documentation |
| `spec-builder` | sonnet | Create specifications |
| `backend-architect` | sonnet | Backend design |
| `frontend-developer` | sonnet | Frontend implementation |
| `test-automator` | sonnet | Test generation |
| `code-reviewer` | opus | Thorough code review |
| `architect-reviewer` | opus | Architecture review |
| `security-auditor` | opus | Security analysis |

## Hookify Rules

The plugin includes pre-configured hookify rules in `.claude/`:

- `block-destructive` - Block dangerous commands
- `warn-secrets` - Warn on sensitive file edits
- `require-confirmation` - Require confirmation for risky ops
- `tdd-tests-first` - Remind to write tests first
- `tdd-auto-test` - Remind to run tests before stopping
- `doc-sync-reminder` - Remind to update docs
- `track-progress` - Remind to use TodoWrite

## Usage Examples

### Start a New Implementation Track

```
/guilde-workflows:conductor-new-track FEAT-001 "User Authentication" P1
```

### Work on Implementation

```
/guilde-workflows:conductor-implement FEAT-001
```

### Run Code Review

```
/guilde-workflows:review-all staged
```

### Check TDD Status

```
/guilde-workflows:tdd status
```

## Development

To modify the plugin:

1. Edit files in `commands/`, `skills/`, or `agents/`
2. Restart Claude Code to pick up changes
3. Test commands with `claude --plugin-dir .`

### Development Workflow

```bash
# Validate plugin after changes
claude plugin validate .

# Test in a new session
claude --plugin-dir .
```

## Troubleshooting

### Commands Not Found

If slash commands aren't available:

1. Ensure you started Claude Code with `--plugin-dir`
2. Verify plugin validates: `claude plugin validate .`
3. Check the plugin structure matches the expected format

### Plugin Not Loading

If the plugin doesn't load:

1. Check `.claude-plugin/plugin.json` exists and is valid JSON
2. Ensure `commands/`, `skills/`, `agents/` directories exist at root
3. Restart Claude Code after making changes

## Compatibility

- Claude Code version: >= 1.0.0
- Requires: mise, task (for full functionality)
- Optional: docker/orbstack (for database stack)
