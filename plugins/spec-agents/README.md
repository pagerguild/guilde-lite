# Spec Agents

Specification building agent for creating detailed specs and acceptance criteria.

## Features

- **Requirement analysis**: Analyze and structure feature requirements
- **Architecture design**: Create system architecture blueprints
- **Component specification**: Define detailed component breakdowns
- **Interface definition**: Specify API contracts and data flows
- **Test strategy planning**: Create comprehensive test coverage plans
- **Risk identification**: Identify potential implementation risks

## Installation

```bash
claude plugin install spec-agents@guilde-plugins
```

## Usage

### Agents

#### `spec-builder`

**Model Tier:** Sonnet (balanced analysis)
**Invocation:** `Task tool with subagent_type="Plan"`

Use for:
- Planning new features
- Designing system architecture
- Creating implementation roadmaps
- Defining API contracts
- Establishing test strategies

**Example Invocation:**
```
Task tool:
  subagent_type: "Plan"
  prompt: "Design the implementation plan for a user notification system with email, SMS, and push support"
  model: "sonnet"
```

## Output Format

The spec-builder returns structured specifications including:

- **Component breakdown**: Modular decomposition of the system
- **Interface definitions**: API contracts and data types
- **Data flow diagrams**: Mermaid diagrams showing data movement
- **Implementation sequence**: Ordered steps for development
- **Test coverage plan**: Testing strategy and coverage targets
- **Risk assessment**: Potential issues and mitigations

## Integration

Works with:
- `context-explorer` - Pre-research for understanding codebase
- `backend-architect` - Implementation guidance
- `tdd-orchestrator` - Test planning and TDD workflow

## Example Output Structure

```markdown
# Implementation Specification

## Overview
[Feature description and goals]

## Components
1. Component A
   - Responsibility
   - Interfaces
   - Dependencies

2. Component B
   - Responsibility
   - Interfaces
   - Dependencies

## Data Flow
[Mermaid diagram]

## Implementation Sequence
1. Phase 1: Foundation
2. Phase 2: Core Logic
3. Phase 3: Integration

## Test Strategy
- Unit tests: 80% coverage target
- Integration tests: Key flows
- E2E tests: Critical paths

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| ... | ... | ... | ... |
```

## When to Use

- Before starting any significant feature development
- When requirements need clarification and structure
- For creating conductor track specifications
- When designing APIs or system integrations
