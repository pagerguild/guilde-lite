---
name: ms-ag-ui
description: |
  Use when building web interfaces for Microsoft Agent Framework agents.
  Triggers: "AG-UI", "agent UI", "agent web interface", "SSE streaming", "human-in-the-loop UI".
  NOT for: CLI-only agents or backend-only implementations.
---

# Microsoft AG-UI Integration

Expert guidance for building web interfaces with AG-UI (Agent-User Interface) protocol.

## What is AG-UI?

AG-UI is a protocol for connecting AI agents to web-based user interfaces:

- **Server-Sent Events (SSE)** for real-time streaming
- **Standardized message format** for agent-UI communication
- **Human-in-the-loop** support for approvals and input
- **Tool execution visualization** showing agent actions

## Quick Start

### Backend Setup

```python
from agent_framework import ChatAgent
from agent_framework.ag_ui import AGUIServer, AGUIConfig

class MyAgent(ChatAgent):
    system_prompt = "You are a helpful assistant."

    @ai_function
    def search(self, query: str) -> str:
        """Search for information."""
        return search_results

# Create AG-UI server
config = AGUIConfig(
    cors_origins=["http://localhost:3000"],
    enable_streaming=True,
    enable_tool_visualization=True
)

server = AGUIServer(MyAgent(), config=config)

# Run server
if __name__ == "__main__":
    server.run(host="0.0.0.0", port=8000)
```

### Frontend Connection

```typescript
import { AGUIClient } from '@agent-framework/ag-ui-client';

const client = new AGUIClient({
  endpoint: 'http://localhost:8000',
  onMessage: (message) => {
    console.log('Agent:', message.content);
  },
  onToolCall: (tool) => {
    console.log('Tool:', tool.name, tool.arguments);
  },
  onToolResult: (result) => {
    console.log('Result:', result);
  },
  onError: (error) => {
    console.error('Error:', error);
  }
});

// Send message
await client.send('What is the weather today?');

// Close connection
client.close();
```

## SSE Streaming Protocol

### Event Types

| Event | Description | Payload |
|-------|-------------|---------|
| `message_start` | Agent begins response | `{id, role}` |
| `content_delta` | Streaming text chunk | `{delta, index}` |
| `message_end` | Agent completes response | `{id, stop_reason}` |
| `tool_call_start` | Tool execution begins | `{id, name, arguments}` |
| `tool_call_end` | Tool execution completes | `{id, result}` |
| `error` | Error occurred | `{code, message}` |
| `approval_request` | Human approval needed | `{id, prompt, options}` |

### Raw SSE Format

```
event: message_start
data: {"id": "msg_123", "role": "assistant"}

event: content_delta
data: {"delta": "Let me ", "index": 0}

event: content_delta
data: {"delta": "search for that...", "index": 1}

event: tool_call_start
data: {"id": "tool_456", "name": "search", "arguments": {"query": "weather"}}

event: tool_call_end
data: {"id": "tool_456", "result": "Sunny, 72°F"}

event: content_delta
data: {"delta": "The weather is sunny and 72°F.", "index": 2}

event: message_end
data: {"id": "msg_123", "stop_reason": "end_turn"}
```

## Human-in-the-Loop

### Approval Requests

```python
from agent_framework import ChatAgent
from agent_framework.ag_ui import requires_approval

class ControlledAgent(ChatAgent):

    @ai_function
    @requires_approval(
        prompt="This will delete {count} records. Continue?",
        options=["Approve", "Reject", "Review Details"]
    )
    def delete_records(self, filter: dict) -> str:
        """Delete records matching filter (requires approval)."""
        count = self.db.count(filter)
        self.db.delete(filter)
        return f"Deleted {count} records"
```

### Frontend Handling

```typescript
const client = new AGUIClient({
  endpoint: 'http://localhost:8000',
  onApprovalRequest: async (request) => {
    // Show UI for approval
    const userChoice = await showApprovalDialog({
      message: request.prompt,
      options: request.options
    });

    // Send response back
    await client.sendApproval(request.id, userChoice);
  }
});
```

### Input Requests

```python
from agent_framework.ag_ui import request_input

class InteractiveAgent(ChatAgent):

    @ai_function
    async def process_order(self, order_id: str) -> str:
        """Process an order with user confirmation."""
        order = self.get_order(order_id)

        # Request additional input from user
        confirmation = await request_input(
            prompt=f"Confirm shipping to {order.address}?",
            input_type="text",
            placeholder="Type 'yes' to confirm"
        )

        if confirmation.lower() == "yes":
            return self.ship_order(order)
        return "Order cancelled"
```

## Tool Visualization

### Configure Tool Display

```python
from agent_framework.ag_ui import tool_display

class VisualAgent(ChatAgent):

    @ai_function
    @tool_display(
        icon="🔍",
        show_arguments=True,
        show_progress=True,
        show_result=True
    )
    def search_database(self, query: str) -> list:
        """Search database with visual progress."""
        # Progress updates sent automatically
        results = self.db.search(query)
        return results

    @ai_function
    @tool_display(
        icon="📊",
        show_arguments=False,  # Hide sensitive args
        show_result="summary"  # Show summary instead of full result
    )
    def analyze_data(self, data: list) -> dict:
        """Analyze data (hide raw details in UI)."""
        return analysis_result
```

### Progress Updates

```python
from agent_framework.ag_ui import progress_update

class LongRunningAgent(ChatAgent):

    @ai_function
    async def process_documents(self, files: list) -> str:
        """Process multiple documents with progress."""
        total = len(files)

        for i, file in enumerate(files):
            # Send progress update to UI
            await progress_update(
                current=i + 1,
                total=total,
                message=f"Processing {file}..."
            )
            await self.process_file(file)

        return f"Processed {total} documents"
```

## React Components

### Using AG-UI React SDK

```typescript
import {
  AGUIProvider,
  ChatWindow,
  ToolVisualization,
  ApprovalDialog,
  useAGUI
} from '@agent-framework/ag-ui-react';

function App() {
  return (
    <AGUIProvider endpoint="http://localhost:8000">
      <div className="agent-interface">
        <ChatWindow
          placeholder="Ask me anything..."
          showToolCalls={true}
        />
        <ToolVisualization />
        <ApprovalDialog />
      </div>
    </AGUIProvider>
  );
}

// Custom component using hook
function CustomChat() {
  const {
    messages,
    send,
    isStreaming,
    activeTools
  } = useAGUI();

  return (
    <div>
      {messages.map(msg => (
        <div key={msg.id}>{msg.content}</div>
      ))}
      {isStreaming && <div>Thinking...</div>}
      {activeTools.map(tool => (
        <div key={tool.id}>Running: {tool.name}</div>
      ))}
    </div>
  );
}
```

## Configuration Options

### Server Configuration

```python
from agent_framework.ag_ui import AGUIConfig

config = AGUIConfig(
    # CORS settings
    cors_origins=["http://localhost:3000", "https://myapp.com"],
    cors_methods=["GET", "POST"],

    # Streaming settings
    enable_streaming=True,
    heartbeat_interval=15,  # seconds

    # Tool visualization
    enable_tool_visualization=True,
    hide_sensitive_tools=["get_api_key", "access_secrets"],

    # Human-in-the-loop
    approval_timeout=300,  # seconds
    default_approval_action="reject",

    # Rate limiting
    rate_limit_requests=100,
    rate_limit_window=60,  # seconds

    # Authentication
    auth_required=True,
    auth_handler=verify_token
)
```

### Client Configuration

```typescript
const client = new AGUIClient({
  endpoint: 'http://localhost:8000',

  // Connection settings
  reconnectAttempts: 5,
  reconnectDelay: 1000,

  // Headers
  headers: {
    'Authorization': 'Bearer token123'
  },

  // Callbacks
  onConnect: () => console.log('Connected'),
  onDisconnect: () => console.log('Disconnected'),
  onReconnect: (attempt) => console.log(`Reconnecting (${attempt})`)
});
```

## Integration Patterns

### With Next.js

```typescript
// app/api/agent/route.ts
import { NextRequest } from 'next/server';
import { createAGUIHandler } from '@agent-framework/ag-ui-next';
import { MyAgent } from '@/agents/my-agent';

const handler = createAGUIHandler(MyAgent);

export async function POST(request: NextRequest) {
  return handler(request);
}

// app/chat/page.tsx
'use client';
import { AGUIProvider, ChatWindow } from '@agent-framework/ag-ui-react';

export default function ChatPage() {
  return (
    <AGUIProvider endpoint="/api/agent">
      <ChatWindow />
    </AGUIProvider>
  );
}
```

### With FastAPI

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from agent_framework.ag_ui import AGUIRouter

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add AG-UI router
app.include_router(
    AGUIRouter(MyAgent()),
    prefix="/agent"
)
```

## Related

- `ms-agent-types` skill - Agent implementation
- `ms-devui` skill - Development UI
- `ms-hosting` skill - Production hosting
- [AG-UI Docs](https://learn.microsoft.com/en-us/agent-framework/guides/ag-ui)
