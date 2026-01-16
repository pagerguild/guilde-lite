# Release Research

Release notes and changelog research for tracking upstream updates.

## Features

- **Multi-repository tracking**: Monitor releases from Claude Code, plugins, skills, and conductor
- **Version comparison**: Compare current vs latest versions with semantic versioning analysis
- **Impact analysis**: Map changes to affected project components
- **Prioritized recommendations**: Actionable update recommendations by priority
- **GitHub integration**: Uses GitHub MCP tools for release data

## Installation

```bash
claude plugin install release-research@guilde-plugins
```

## Usage

### Commands

#### `/research-releases`

Research latest releases from relevant repositories:

```bash
/research-releases           # Research all repositories
/research-releases all       # Research all repositories
/research-releases claude    # Focus on claude-code and anthropic repos
/research-releases conductor # Focus on conductor pattern
/research-releases plugins   # Focus on claude-plugins-official
/research-releases skills    # Focus on skills repository
```

### Skills

#### `release-researcher`

Auto-activates for:
- User asks to check for updates
- Starting a new development phase
- Periodic maintenance review
- Investigating compatibility issues

## Tracked Repositories

### Tier 1: Critical (Check Weekly)
| Repository | Impact Area |
|------------|-------------|
| `anthropics/claude-code` | Core CLI functionality |
| `anthropics/claude-plugins-official` | Plugin patterns, hooks |
| `gemini-cli-extensions/conductor` | Conductor pattern |

### Tier 2: Important (Check Monthly)
| Repository | Impact Area |
|------------|-------------|
| `anthropics/skills` | Skill packaging |
| `anthropics/anthropic-cookbook` | Agent patterns |
| `modelcontextprotocol/servers` | Tool integrations |

### Tier 3: Reference (Check Quarterly)
| Repository | Impact Area |
|------------|-------------|
| `jj-vcs/jj` | VCS integration |
| `mise-plugins/*` | Runtime management |

## Version Priority Matrix

| Version Jump | Breaking Changes | Priority |
|--------------|------------------|----------|
| Major (X.0.0) | Likely | Critical |
| Minor (0.X.0) | Possible | High |
| Patch (0.0.X) | Unlikely | Medium |
| Pre-release | Unknown | Low |

## Report Output

The research generates a structured report including:
- Executive summary with update counts
- Per-repository version comparison
- Changelog highlights
- Required actions with affected files
- Impact analysis matrix
- Recommended update order

## Impact Mapping

| Change Type | Affected Files |
|-------------|----------------|
| Hook API changes | `.claude/settings.json`, hookify rules |
| Skill format changes | `.claude/skills/*/SKILL.md` |
| Agent tool changes | `.claude/agents/*.md` |
| Plugin manifest changes | `.claude-plugin/plugin.json` |
| MCP protocol changes | `.mcp.json` |

## Configuration

Versions are tracked in `conductor/tech-stack.md` and compared against latest releases during research.
