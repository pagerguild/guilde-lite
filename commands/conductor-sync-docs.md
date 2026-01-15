---
description: Synchronize documentation with implementation state
argument-hint: "[all|track:ID|file:path] [--check|--generate]"
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Task"]
---

# /conductor-sync-docs Command

Ensures documentation stays synchronized with implementation, updating READMEs, API docs, architecture diagrams, and changelogs.

## Documentation Hierarchy

```
docs/
├── README.md                 # Project overview
├── CHANGELOG.md              # Version history
├── ARCHITECTURE.md           # System architecture
├── tutorials/                # Step-by-step guides
│   └── *.md
└── [topic]/                  # Topic-specific docs
    └── *.md

conductor/
├── product.md                # Product definition
├── tech-stack.md             # Technology decisions
├── workflow.md               # Workflow conventions
└── tracks/
    └── TRACK-ID/
        ├── spec.md           # Track specification
        └── plan.md           # Implementation plan
```

## Usage

```
/conductor-sync-docs                    # Sync all documentation
/conductor-sync-docs track:MULTI-001    # Sync specific track docs
/conductor-sync-docs --check            # Check sync status only
/conductor-sync-docs --generate         # Generate missing docs
```

## Sync Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOC SYNC PROCESS                              │
│                                                                   │
│  1. Inventory                                                     │
│     ┌───────────┐ ┌───────────┐ ┌───────────┐                   │
│     │   Code    │ │   Docs    │ │  Diagrams │                   │
│     │  Changes  │ │  Current  │ │  Current  │                   │
│     └───────────┘ └───────────┘ └───────────┘                   │
│            ↓                                                      │
│  2. Compare                                                       │
│     ┌─────────────────────────────────────────────┐              │
│     │  Identify stale documentation               │              │
│     │  Find missing documentation                 │              │
│     │  Detect broken links                        │              │
│     └─────────────────────────────────────────────┘              │
│            ↓                                                      │
│  3. Update                                                        │
│     ┌───────────┐ ┌───────────┐ ┌───────────┐                   │
│     │   README  │ │    API    │ │   Arch    │                   │
│     │   Update  │ │   Docs    │ │  Diagrams │                   │
│     └───────────┘ └───────────┘ └───────────┘                   │
│            ↓                                                      │
│  4. Verify                                                        │
│     ┌─────────────────────────────────────────────┐              │
│     │  Validate links                             │              │
│     │  Check completeness                         │              │
│     │  Report status                              │              │
│     └─────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Actions

### Inventory Phase

Scan for documentation needs:

1. **Code changes:**
   ```bash
   # Recent changes
   git diff --name-only HEAD~10

   # API files
   find . -name "*.go" -o -name "*.py" -o -name "*.ts" | xargs grep -l "func\|def\|export"
   ```

2. **Existing docs:**
   ```bash
   find docs -name "*.md"
   find conductor -name "*.md"
   ```

3. **Architecture diagrams:**
   ```bash
   find . -name "*.mermaid" -o -name "*.puml"
   ```

### Compare Phase

Identify sync needs:

| Check | Method |
|-------|--------|
| Stale README | Compare code features vs README sections |
| Missing API docs | Compare exported functions vs documentation |
| Outdated diagrams | Compare architecture vs diagram content |
| Broken links | Validate all markdown links |

### Update Phase

For each documentation type:

#### README Updates

1. Update feature lists based on code
2. Update installation instructions if dependencies changed
3. Update usage examples if API changed
4. Update badges and status

#### API Documentation

1. Extract function signatures
2. Generate/update OpenAPI specs
3. Update endpoint documentation
4. Regenerate SDK docs if applicable

#### Architecture Diagrams

1. Check component accuracy
2. Update data flow diagrams
3. Regenerate C4 diagrams if needed
4. Update deployment diagrams

#### Track Documentation

1. Update spec.md with implementation details
2. Update plan.md progress
3. Sync with conductor/tracks.md

### Verify Phase

Validate documentation:

```bash
# Check links
bash scripts/doc-sync-check.sh links

# Check completeness
bash scripts/doc-sync-check.sh completeness

# Check freshness
bash scripts/doc-sync-check.sh freshness
```

## Sync Report

```
═══════════════════════════════════════════════════════════════════
DOCUMENTATION SYNC REPORT
═══════════════════════════════════════════════════════════════════

Summary
──────────────────────────────────────
Total files scanned: 47
Documentation files: 23
Diagrams: 5

Status
──────────────────────────────────────
✓ Up to date:     18
⚠ Needs update:    4
✗ Missing:         1

Needs Update
──────────────────────────────────────
docs/REVIEW-PIPELINE.md
  - New agents added: pr-test-analyzer
  - Last updated: 2026-01-10

docs/TELEMETRY-SETUP.md
  - New metrics added: agent_latency_p99
  - Last updated: 2026-01-13

conductor/tracks/MULTI-001/plan.md
  - Phase 8 completed but not reflected in summary
  - Last updated: 2026-01-14

.claude/rules/quality-gates.md
  - New gates added via hookify rules
  - Last updated: 2026-01-12

Missing
──────────────────────────────────────
docs/CONDUCTOR-COMMANDS.md
  - Suggested: Document conductor-* commands
  - Related code: .claude/commands/conductor-*.md

Links
──────────────────────────────────────
✓ Valid links: 89
✗ Broken links: 0

═══════════════════════════════════════════════════════════════════
```

## --check Mode (Dry Run)

Shows what would be updated without making changes:

```
User: /conductor-sync-docs --check

Claude: Checking documentation sync status...

        ⚠ 4 files need updates (use without --check to apply)
        ✗ 1 file missing (use --generate to create)

        See full report above.
```

## --generate Mode

Creates missing documentation:

```
User: /conductor-sync-docs --generate

Claude: Generating missing documentation...

        Creating: docs/CONDUCTOR-COMMANDS.md
        ✓ Template generated
        ✓ Content populated from command files

        Review and customize the generated file.
```

## Automated Hooks

Doc sync integrates with:

1. **hookify doc-sync-reminder:**
   - Triggers when editing API/config files
   - Reminds to run /conductor-sync-docs

2. **PreCommit hook:**
   - Checks for stale documentation
   - Warns before committing

3. **PostToolUse hook:**
   - Tracks documentation changes
   - Suggests sync when code changes accumulate

## Example Workflow

```
User: /conductor-sync-docs

Claude: Scanning documentation...

        ═══════════════════════════════════════════════════════════════════
        DOCUMENTATION SYNC REPORT
        ═══════════════════════════════════════════════════════════════════

        4 files need updates, 1 file missing

        Updating documentation:
        ✓ docs/REVIEW-PIPELINE.md - Added pr-test-analyzer section
        ✓ docs/TELEMETRY-SETUP.md - Updated metrics list
        ✓ conductor/tracks/MULTI-001/plan.md - Updated summary table
        ✓ .claude/rules/quality-gates.md - Added hookify gate references

        Creating missing documentation:
        ✓ docs/CONDUCTOR-COMMANDS.md - Generated from command files

        ═══════════════════════════════════════════════════════════════════
        SYNC COMPLETE
        ═══════════════════════════════════════════════════════════════════

        Updated: 4 files
        Created: 1 file
        Links validated: 94/94

        Commit these changes? (y/n)
```

## Related Commands

- `/conductor-setup` - Initialize conductor infrastructure
- `/conductor-status` - View all tracks and progress
- `/conductor-checkpoint` - Create checkpoint commits
- `/docs-sync` - General documentation sync (non-conductor)
- `/review-all` - Code review pipeline

## Related Files

- `scripts/doc-sync-check.sh` - Documentation validation script
- `.claude/rules/documentation-standards.md` - Documentation standards
- `.claude/hookify.doc-sync-reminder.local.md` - Doc sync reminder hook
