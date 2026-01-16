---
name: ms-agent-types
description: |
  Use when implementing different agent types in Microsoft Agent Framework.
  Triggers: "ChatAgent", "BaseAgent", "WorkflowAgent", "A2A agent", "custom agent class".
  NOT for: Non-Microsoft agent frameworks or simple single-agent scenarios.
---

# Microsoft Agent Types

Expert guidance for implementing different agent types in Microsoft Agent Framework.

## Core Agent Types

### 1. ChatAgent (Most Common)

The standard agent type for conversational AI:

```python
from agent_framework import ChatAgent, ai_function

class MyAssistant(ChatAgent):
    """A helpful assistant for customer support."""

    system_prompt = """
    You are a customer support specialist.
    Be helpful, professional, and concise.
    """

    model = "gpt-4o"  # Or "claude-3-opus", "gemini-1.5-pro"

    @ai_function
    def search_knowledge_base(self, query: str) -> str:
        """Search internal documentation for answers."""
        # Implementation
        return search_results

    @ai_function
    def create_ticket(self, title: str, description: str) -> dict:
        """Create a support ticket in the system."""
        return {"ticket_id": "TICKET-123", "status": "created"}
```

**Key Features:**
- Built-in conversation memory
- Automatic tool calling
- Streaming support
- Multi-turn dialogue handling

### 2. BaseAgent (Low-Level Control)

For custom agent implementations needing full control:

```python
from agent_framework import BaseAgent
from agent_framework.types import Message, Response

class CustomAgent(BaseAgent):
    """Low-level agent with custom message handling."""

    async def handle_message(self, message: Message) -> Response:
        """Process a single message with full control."""
        # Custom preprocessing
        preprocessed = self.preprocess(message)

        # Custom model invocation
        result = await self.invoke_model(preprocessed)

        # Custom postprocessing
        return self.postprocess(result)

    def preprocess(self, message: Message) -> Message:
        # Add context, modify content, etc.
        return message

    def postprocess(self, result: Response) -> Response:
        # Filter, transform, validate output
        return result
```

**Use When:**
- Need custom message preprocessing
- Implementing non-standard protocols
- Building agent adapters
- Maximum flexibility required

### 3. WorkflowAgent (Orchestration)

For agents that coordinate multi-step workflows:

```python
from agent_framework import WorkflowAgent, workflow_step

class ProcessingAgent(WorkflowAgent):
    """Agent that processes documents through multiple stages."""

    @workflow_step(order=1)
    async def extract_data(self, document: str) -> dict:
        """Extract structured data from document."""
        return extracted_data

    @workflow_step(order=2)
    async def validate_data(self, data: dict) -> dict:
        """Validate extracted data."""
        return validated_data

    @workflow_step(order=3)
    async def transform_data(self, data: dict) -> dict:
        """Transform data to target format."""
        return transformed_data

    @workflow_step(order=4)
    async def store_results(self, data: dict) -> str:
        """Store processed results."""
        return "Processing complete"
```

**Key Features:**
- Automatic step sequencing
- Built-in checkpointing
- Error recovery per step
- Progress tracking

### 4. A2A Agent (Agent-to-Agent)

For agents that communicate with other agents:

```python
from agent_framework import A2AAgent
from agent_framework.a2a import AgentCard, AgentDirectory

class CollaborativeAgent(A2AAgent):
    """Agent that delegates to specialized agents."""

    # Define agent card for discovery
    agent_card = AgentCard(
        name="Coordinator",
        description="Coordinates tasks across specialist agents",
        capabilities=["planning", "delegation", "synthesis"]
    )

    async def delegate_task(self, task: str, target_agent: str) -> str:
        """Delegate a task to another agent."""
        # Find agent in directory
        agent = await self.directory.find_agent(target_agent)

        # Send task via A2A protocol
        result = await agent.send_task(task)

        return result

    async def receive_task(self, task: str, from_agent: str) -> str:
        """Handle task from another agent."""
        # Process delegated task
        return await self.process(task)
```

**Key Features:**
- Agent discovery via directory
- Secure agent-to-agent communication
- Task delegation protocol
- Result aggregation

## Agent Configuration

### Model Selection

```python
class MyAgent(ChatAgent):
    # Azure OpenAI
    model = "azure/gpt-4o"
    model_config = {
        "azure_endpoint": "https://my-resource.openai.azure.com/",
        "api_version": "2024-02-01"
    }

    # Or direct OpenAI
    model = "gpt-4o"

    # Or Anthropic
    model = "claude-3-opus"

    # Or local model
    model = "ollama/llama3"
```

### Memory Configuration

```python
from agent_framework.memory import (
    ConversationMemory,
    VectorMemory,
    SummaryMemory
)

class MemoryAgent(ChatAgent):
    # Short-term conversation memory
    memory = ConversationMemory(
        max_turns=20,
        include_system=False
    )

    # Or long-term vector memory
    memory = VectorMemory(
        embedding_model="text-embedding-3-small",
        max_results=10,
        similarity_threshold=0.7
    )

    # Or summarizing memory for long conversations
    memory = SummaryMemory(
        summarize_every=10,
        summary_model="gpt-4o-mini"
    )
```

### Tool Configuration

```python
from agent_framework import ChatAgent, ai_function, tool_config

class ToolAgent(ChatAgent):

    @ai_function
    @tool_config(
        requires_confirmation=True,  # Human approval required
        timeout=30,                   # Max execution time
        retry_count=3,                # Auto-retry on failure
        cache_ttl=300                 # Cache results for 5 min
    )
    def dangerous_operation(self, params: dict) -> str:
        """Operation requiring human approval."""
        return execute_operation(params)
```

## Agent Lifecycle

### Initialization

```python
class LifecycleAgent(ChatAgent):

    async def on_initialize(self):
        """Called when agent is created."""
        self.db = await Database.connect()
        self.cache = await Cache.initialize()

    async def on_start(self):
        """Called when agent starts processing."""
        await self.load_context()

    async def on_stop(self):
        """Called when agent stops."""
        await self.save_state()

    async def on_shutdown(self):
        """Called when agent is destroyed."""
        await self.db.disconnect()
        await self.cache.close()
```

### Error Handling

```python
class ResilientAgent(ChatAgent):

    async def on_error(self, error: Exception, context: dict):
        """Handle errors during execution."""
        if isinstance(error, RateLimitError):
            await asyncio.sleep(60)
            return RetryAction()
        elif isinstance(error, ToolError):
            return FallbackAction(
                message="Tool unavailable, trying alternative..."
            )
        else:
            return EscalateAction(
                message=f"Error: {error}",
                notify_human=True
            )
```

## Best Practices

### 1. Single Responsibility

```python
# Good - focused agent
class BillingAgent(ChatAgent):
    """Handles billing inquiries only."""

    @ai_function
    def get_invoice(self, invoice_id: str) -> dict: ...

    @ai_function
    def process_payment(self, amount: float) -> dict: ...

# Bad - god agent
class DoEverythingAgent(ChatAgent):
    """Handles billing, support, sales, HR..."""
    # Too many responsibilities
```

### 2. Clear System Prompts

```python
# Good - specific and actionable
system_prompt = """
You are a billing specialist at Acme Corp.
You can: check invoices, process payments, apply discounts.
You cannot: issue refunds over $100 (escalate to manager).
Always: verify customer identity before account changes.
Format: Use bullet points for itemized responses.
"""

# Bad - vague
system_prompt = "You help with billing stuff."
```

### 3. Typed Tool Parameters

```python
from pydantic import BaseModel, Field

class TicketRequest(BaseModel):
    title: str = Field(..., min_length=5, max_length=100)
    priority: Literal["low", "medium", "high", "critical"]
    category: str
    description: str = Field(..., max_length=2000)

@ai_function
def create_ticket(self, request: TicketRequest) -> dict:
    """Create support ticket with validated input."""
    return create_in_system(request)
```

## Related

- `ms-workflows` skill - Multi-agent workflow patterns
- `ms-observability` skill - Agent telemetry
- `agent-architect` agent - Design agent systems
- [Agent Types Docs](https://learn.microsoft.com/en-us/agent-framework/concepts/agent-types)
