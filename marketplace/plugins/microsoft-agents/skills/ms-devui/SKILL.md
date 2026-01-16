---
name: ms-devui
description: |
  Use when developing and testing Microsoft Agent Framework agents locally.
  Triggers: "DevUI", "agent testing", "local development", "agent debugging", "test harness".
  NOT for: Production deployment or AG-UI web interfaces.
---

# Microsoft Agent DevUI

Expert guidance for using DevUI to develop and test agents locally.

## What is DevUI?

DevUI is a development interface for testing agents without building a full UI:

- **Interactive chat** for testing agent responses
- **Tool visualization** to see tool calls and results
- **State inspection** for debugging agent state
- **Request/response logging** for detailed analysis
- **Performance profiling** built-in

## Quick Start

### Enable DevUI

```python
from agent_framework import ChatAgent
from agent_framework.devui import DevUI

class MyAgent(ChatAgent):
    system_prompt = "You are a helpful assistant."

    @ai_function
    def search(self, query: str) -> str:
        """Search for information."""
        return f"Results for: {query}"

# Start DevUI server
if __name__ == "__main__":
    agent = MyAgent()
    devui = DevUI(agent)
    devui.run(port=8080)

# Visit http://localhost:8080
```

### CLI Mode

```bash
# Run agent with DevUI
python -m agent_framework devui my_agent:MyAgent --port 8080

# Or with hot reload
python -m agent_framework devui my_agent:MyAgent --reload
```

## DevUI Features

### Chat Interface

```
┌─────────────────────────────────────────────────────┐
│  Agent: MyAgent                        [Settings] │
├─────────────────────────────────────────────────────┤
│                                                     │
│  User: What's the weather in Seattle?              │
│                                                     │
│  Agent: Let me search for that...                  │
│                                                     │
│  ┌─ Tool Call ─────────────────────────────────┐   │
│  │ search("weather Seattle")                    │   │
│  │ Result: "Sunny, 68°F"                       │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Agent: The weather in Seattle is sunny and 68°F.  │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [Type your message...]                   [Send]   │
└─────────────────────────────────────────────────────┘
```

### State Inspector

View and modify agent state in real-time:

```python
from agent_framework.devui import DevUI, StateInspector

class StatefulAgent(ChatAgent):
    def __init__(self):
        self.user_preferences = {}
        self.conversation_context = {}

# DevUI automatically exposes these for inspection
devui = DevUI(
    agent,
    inspectors=[
        StateInspector("user_preferences"),
        StateInspector("conversation_context"),
        StateInspector("memory")
    ]
)
```

### Tool Testing Panel

Test individual tools in isolation:

```
┌─────────────────────────────────────────────────────┐
│  Tool Tester                                        │
├─────────────────────────────────────────────────────┤
│  Tool: [search ▼]                                   │
│                                                     │
│  Parameters:                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │ query: [weather in Seattle               ]   │   │
│  │ limit: [10                               ]   │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  [Execute Tool]                                     │
│                                                     │
│  Result:                                            │
│  ┌──────────────────────────────────────────────┐   │
│  │ {                                            │   │
│  │   "results": [...],                          │   │
│  │   "count": 5,                                │   │
│  │   "latency_ms": 234                          │   │
│  │ }                                            │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Request/Response Viewer

```
┌─────────────────────────────────────────────────────┐
│  Request Log                              [Clear]   │
├─────────────────────────────────────────────────────┤
│  ▼ Request #1 (2.3s)                               │
│    ├─ Input: "What's the weather?"                 │
│    ├─ Model: gpt-4o                                │
│    ├─ Tokens: 150 prompt, 45 completion            │
│    ├─ Tool Calls:                                  │
│    │   └─ search("weather") → "Sunny, 68°F"        │
│    └─ Output: "The weather is sunny and 68°F."    │
│                                                     │
│  ▶ Request #2 (1.1s)                               │
│  ▶ Request #3 (0.8s)                               │
└─────────────────────────────────────────────────────┘
```

## Configuration

### DevUI Options

```python
from agent_framework.devui import DevUI, DevUIConfig

config = DevUIConfig(
    # Server settings
    host="0.0.0.0",
    port=8080,

    # Features
    enable_tool_tester=True,
    enable_state_inspector=True,
    enable_request_log=True,
    enable_profiler=True,

    # Security (for shared environments)
    require_auth=False,
    auth_token="dev-token-123",

    # Development
    hot_reload=True,
    reload_dirs=["./agents", "./tools"],

    # Logging
    log_level="DEBUG",
    log_requests=True,
    log_responses=True
)

devui = DevUI(agent, config=config)
```

### Multi-Agent DevUI

```python
from agent_framework.devui import MultiAgentDevUI

# Test multiple agents in one interface
devui = MultiAgentDevUI([
    ("Researcher", ResearchAgent()),
    ("Writer", WriterAgent()),
    ("Reviewer", ReviewerAgent())
])

devui.run(port=8080)
```

### Workflow DevUI

```python
from agent_framework.devui import WorkflowDevUI
from agent_framework.workflows import SequentialBuilder

workflow = (
    SequentialBuilder()
    .add_agent(agent1)
    .add_agent(agent2)
    .add_agent(agent3)
    .build()
)

# Visualize workflow execution
devui = WorkflowDevUI(workflow)
devui.run(port=8080)
```

## Testing Patterns

### Manual Testing

```python
# Interactive testing with DevUI
devui = DevUI(agent)
devui.run(port=8080)

# Open browser to http://localhost:8080
# - Test various inputs
# - Inspect tool calls
# - Check state changes
```

### Automated Test Scenarios

```python
from agent_framework.devui import TestScenario, run_scenarios

scenarios = [
    TestScenario(
        name="Basic greeting",
        input="Hello!",
        expected_contains=["hello", "hi", "greetings"]
    ),
    TestScenario(
        name="Weather query",
        input="What's the weather?",
        expected_tool_calls=["search"],
        expected_contains=["weather", "temperature"]
    ),
    TestScenario(
        name="Error handling",
        input="Do something impossible",
        expected_error=False
    )
]

# Run scenarios and generate report
results = run_scenarios(agent, scenarios)
print(results.summary())
```

### Load Testing

```python
from agent_framework.devui import load_test

results = await load_test(
    agent,
    requests=[
        "What's the weather?",
        "Tell me a joke",
        "Search for Python tutorials"
    ],
    concurrency=10,
    duration=60  # seconds
)

print(f"Requests/sec: {results.requests_per_second}")
print(f"P50 latency: {results.p50_latency}ms")
print(f"P99 latency: {results.p99_latency}ms")
print(f"Error rate: {results.error_rate}%")
```

## Debugging Tools

### Breakpoints

```python
from agent_framework.devui import breakpoint

class DebugAgent(ChatAgent):

    @ai_function
    async def complex_operation(self, data: str) -> str:
        """Operation with debug breakpoint."""
        processed = self.preprocess(data)

        # Pause execution and inspect in DevUI
        await breakpoint(
            message="After preprocessing",
            locals={"processed": processed}
        )

        result = await self.analyze(processed)
        return result
```

### Step-Through Execution

```python
from agent_framework.devui import DevUI

devui = DevUI(
    agent,
    step_mode=True  # Pause after each tool call
)
```

### Memory Inspection

```python
from agent_framework.devui import MemoryInspector

devui = DevUI(
    agent,
    inspectors=[
        MemoryInspector(
            show_conversation=True,
            show_vector_memory=True,
            show_summary=True
        )
    ]
)
```

## Integration with IDEs

### VS Code Extension

```json
// .vscode/launch.json
{
    "configurations": [
        {
            "name": "Debug Agent with DevUI",
            "type": "python",
            "request": "launch",
            "module": "agent_framework",
            "args": ["devui", "my_agent:MyAgent", "--port", "8080"],
            "env": {
                "AGENT_DEBUG": "true"
            }
        }
    ]
}
```

### PyCharm Configuration

```
Run Configuration:
- Script: -m agent_framework
- Parameters: devui my_agent:MyAgent --port 8080 --reload
- Working directory: $ProjectDir$
```

## Best Practices

### 1. Use Hot Reload During Development

```bash
# Auto-reload on code changes
python -m agent_framework devui my_agent:MyAgent --reload

# Or in code
devui = DevUI(agent, hot_reload=True)
```

### 2. Test Edge Cases

```python
# Test with various inputs
test_cases = [
    "",                      # Empty input
    "a" * 10000,            # Very long input
    "🎉" * 100,             # Unicode/emoji
    "<script>alert(1)</script>",  # Injection attempts
    None,                    # Null handling
]
```

### 3. Profile Before Production

```python
from agent_framework.devui import DevUI, Profiler

devui = DevUI(
    agent,
    profiler=Profiler(
        track_memory=True,
        track_cpu=True,
        track_tokens=True
    )
)
```

## Related

- `ms-agent-types` skill - Agent implementation
- `ms-ag-ui` skill - Production web interfaces
- `ms-observability` skill - Telemetry integration
- [DevUI Docs](https://learn.microsoft.com/en-us/agent-framework/guides/devui)
