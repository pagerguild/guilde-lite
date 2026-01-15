# conductor-workflows

Slash commands for orchestrating multi-phase implementation workflows using the conductor pattern.

## Commands

| Command | Description |
|---------|-------------|
| `/conductor-setup` | Initialize conductor infrastructure |
| `/conductor-new-track` | Create a new track with spec and plan |
| `/conductor-implement` | Execute implementation workflow |
| `/conductor-checkpoint` | Create phase checkpoints |
| `/conductor-status` | Show track and phase status |
| `/conductor-sync-docs` | Synchronize documentation |

## Usage

```bash
# Initialize conductor in a project
/conductor-setup init

# Create a new feature track
/conductor-new-track FEATURE-001 "Add user authentication"

# Start implementation
/conductor-implement FEATURE-001

# Check progress
/conductor-status
```

## Installation

```bash
# Add the marketplace
claude plugin marketplace add ./marketplace

# Install this plugin
claude plugin install conductor-workflows@guilde-plugins
```
