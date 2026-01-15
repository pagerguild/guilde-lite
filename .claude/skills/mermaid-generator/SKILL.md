---
name: mermaid-generator
description: |
  Mermaid diagram generation expert. Activate when:
  - User asks to create flowcharts, sequence diagrams, or architecture diagrams
  - User mentions "mermaid", "diagram", "visualize flow", "sequence diagram"
  - Need to document system architecture or data flows
  - Creating documentation that benefits from visual representation
---

# Mermaid Diagram Generator

Expert at generating Mermaid diagrams for documentation.

## Supported Diagram Types

### 1. Flowcharts
```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

Use for:
- Process flows
- Decision trees
- Algorithm visualization
- User journeys

### 2. Sequence Diagrams
```mermaid
sequenceDiagram
    participant User
    participant API
    participant Database

    User->>API: Request
    API->>Database: Query
    Database-->>API: Result
    API-->>User: Response
```

Use for:
- API interactions
- Service communication
- Authentication flows
- Event sequences

### 3. Class Diagrams
```mermaid
classDiagram
    class User {
        +String name
        +String email
        +login()
        +logout()
    }
    class Order {
        +Int id
        +List items
        +calculate_total()
    }
    User "1" --> "*" Order : places
```

Use for:
- Domain models
- Data structures
- OOP designs
- Entity relationships

### 4. State Diagrams
```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing : submit
    Processing --> Completed : finish
    Processing --> Failed : error
    Failed --> Pending : retry
    Completed --> [*]
```

Use for:
- State machines
- Workflow states
- Order status flows
- Process lifecycles

### 5. Entity Relationship Diagrams
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "appears in"
```

Use for:
- Database schemas
- Data models
- Table relationships

### 6. Git Graphs
```mermaid
gitGraph
    commit
    branch feature
    checkout feature
    commit
    commit
    checkout main
    merge feature
    commit
```

Use for:
- Git workflows
- Branch strategies
- Release processes

## Best Practices

### Naming Conventions
- Use PascalCase for class/entity names
- Use descriptive labels for edges
- Keep node text concise (3-5 words max)

### Styling Guidelines
```mermaid
flowchart TD
    subgraph External["External Systems"]
        A[External API]
    end
    subgraph Internal["Internal Services"]
        B[Service A]
        C[Service B]
    end
    A --> B
    B --> C
```

- Group related nodes in subgraphs
- Use directional flow (TD = top-down, LR = left-right)
- Add comments for complex diagrams

### Common Patterns

**API Flow:**
```mermaid
flowchart LR
    Client --> Gateway --> Service --> Database
```

**Error Handling:**
```mermaid
flowchart TD
    A[Request] --> B{Validate}
    B -->|Valid| C[Process]
    B -->|Invalid| D[Return Error]
    C --> E{Success?}
    E -->|Yes| F[Return Result]
    E -->|No| G[Retry/Fail]
```

**Microservice Communication:**
```mermaid
flowchart TB
    subgraph Frontend
        UI[Web UI]
    end
    subgraph Backend
        API[API Gateway]
        Auth[Auth Service]
        Orders[Order Service]
        Payments[Payment Service]
    end
    subgraph Data
        DB[(Database)]
        Cache[(Redis)]
    end

    UI --> API
    API --> Auth
    API --> Orders
    API --> Payments
    Orders --> DB
    Auth --> Cache
```

## Generation Workflow

1. **Identify Diagram Type**: Choose the most appropriate diagram type for the content
2. **Extract Entities**: List all components, actors, or nodes
3. **Define Relationships**: Map connections and flows between entities
4. **Add Details**: Include labels, descriptions, and styling
5. **Validate Syntax**: Ensure Mermaid syntax is correct
6. **Test Rendering**: Verify diagram renders correctly

## Integration with Documentation

Place diagrams in:
- `docs/architecture/` for system architecture
- `docs/flows/` for process flows
- README.md for overview diagrams
- API docs for sequence diagrams

Reference diagrams in markdown:
```markdown
## Architecture Overview

See the system architecture diagram:

\`\`\`mermaid
flowchart TD
    ...
\`\`\`
```

## Commands

- `bash scripts/doc-sync-check.sh check <file>` - Check if diagram docs need updating
- `task docs:validate` - Validate all documentation including diagrams
