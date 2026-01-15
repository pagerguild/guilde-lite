# Documentation Standards

Guidelines for maintaining documentation in guilde-lite.

---

## Documentation Hierarchy

```
CLAUDE.md                    # Project memory (AI-first)
├── conductor/
│   ├── product.md          # Product definition
│   ├── tech-stack.md       # Technology choices
│   ├── workflow.md         # Execution protocol
│   └── tracks.md           # Work tracking
├── docs/
│   ├── MULTI-AGENT-WORKFLOW.md    # Architecture
│   └── *.md                       # Detailed guides
└── .claude/
    ├── context.md          # Session state
    └── rules/              # Modular rules
```

---

## When to Document

### Always Document
- Public APIs (functions, classes, endpoints)
- Architecture decisions (ADRs)
- Breaking changes
- Non-obvious behavior
- Configuration options

### Skip Documentation For
- Self-explanatory code
- Internal implementation details
- Temporary/prototype code
- Test files (test names should be docs)

---

## Documentation Types

### 1. Code Comments
```python
# WHY, not WHAT
# Bad: Increment counter
# Good: Track retry attempts for exponential backoff

def retry_request():
    # Exponential backoff to avoid overwhelming the server
    # during recovery from outages
    ...
```

### 2. Docstrings
```python
def create_user(email: str, name: str) -> User:
    """Create a new user account.

    Args:
        email: User's email address (must be unique)
        name: Display name for the user

    Returns:
        The created User object with generated ID

    Raises:
        ConflictError: If email already exists
        ValidationError: If email format is invalid
    """
```

### 3. README Files
- Every significant directory should have README.md
- Explain purpose, usage, and structure
- Include quick start examples

### 4. Architecture Decision Records
```markdown
# ADR-001: Use PostgreSQL for Primary Data Store

## Status: Accepted

## Context
We need a reliable, scalable database...

## Decision
Use PostgreSQL 16 with pgvector extension...

## Consequences
- Pro: Strong ACID guarantees
- Pro: Native vector support
- Con: More complex than SQLite
```

---

## Sync Requirements

### Code Changes Require Doc Updates When:
- Adding new public API
- Changing existing API signature
- Modifying configuration options
- Updating dependencies
- Changing architecture

### Validation
Run `bash scripts/doc-sync-check.sh` to verify:
- CLAUDE.md has Project State section
- conductor/tracks.md exists
- Active track has plan.md
- Progress markers match reality

---

## Markdown Standards

### Headings
- Use `#` hierarchy (max 4 levels)
- Title case for main headings
- Sentence case for subheadings

### Code Blocks
- Always specify language for syntax highlighting
- Use `bash` for shell commands
- Use `yaml`, `json`, `toml` for configs

### Tables
- Use for structured comparisons
- Include header row
- Align columns with pipes

### Links
- Use relative paths for internal links
- Use descriptive link text (not "click here")

---

## AI-Specific Guidelines

### For CLAUDE.md
- Put Project State FIRST (progressive disclosure)
- Keep critical rules at top
- Link to detailed docs instead of duplicating

### For Context Files
- Use YAML frontmatter for structured data
- Include timestamps
- Track what changed, not just what exists
