---
name: ms-hosting
description: |
  Use when deploying Microsoft Agent Framework agents to production.
  Triggers: "agent hosting", "deploy agent", "ASP.NET Core", "production deployment", "agent service".
  NOT for: Local development or DevUI testing.
---

# Microsoft Agent Hosting

Expert guidance for hosting agents in production environments.

## Hosting Options

| Option | Best For | Scaling |
|--------|----------|---------|
| FastAPI | Python microservices | Horizontal |
| ASP.NET Core | .NET integration | Horizontal |
| Azure Container Apps | Serverless containers | Auto |
| Azure Functions | Event-driven | Auto |
| Kubernetes | Enterprise scale | Manual/HPA |

## FastAPI Hosting (Python)

### Basic Setup

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from agent_framework import ChatAgent
from agent_framework.hosting import AgentRouter

app = FastAPI(title="Agent Service")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create agent
class MyAgent(ChatAgent):
    system_prompt = "You are a helpful assistant."

# Add agent routes
app.include_router(
    AgentRouter(MyAgent()),
    prefix="/agent"
)

# Health check
@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### With SSE Streaming

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from agent_framework import ChatAgent
from agent_framework.hosting import create_sse_stream

app = FastAPI()
agent = MyAgent()

@app.post("/chat/stream")
async def chat_stream(request: ChatRequest):
    async def generate():
        async for chunk in agent.stream(request.message):
            yield f"data: {chunk.json()}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream"
    )
```

### Multi-Agent Service

```python
from fastapi import FastAPI
from agent_framework.hosting import AgentRegistry, AgentRouter

app = FastAPI()

# Register multiple agents
registry = AgentRegistry()
registry.register("support", SupportAgent())
registry.register("sales", SalesAgent())
registry.register("technical", TechnicalAgent())

# Dynamic routing
app.include_router(
    AgentRouter(registry),
    prefix="/agents"
)

# Usage: POST /agents/support/chat
# Usage: POST /agents/sales/chat
```

## ASP.NET Core Hosting

### Basic Setup

```csharp
// Program.cs
using AgentFramework;
using AgentFramework.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Add agent services
builder.Services.AddAgentFramework()
    .AddAgent<MyAgent>("assistant")
    .AddOpenTelemetry();

var app = builder.Build();

// Map agent endpoints
app.MapAgentEndpoints("/agent");
app.MapHealthChecks("/health");

app.Run();
```

### Agent Implementation

```csharp
// MyAgent.cs
using AgentFramework;

public class MyAgent : ChatAgent
{
    public override string SystemPrompt =>
        "You are a helpful assistant.";

    [Tool]
    public async Task<string> Search(string query)
    {
        // Implementation
        return $"Results for: {query}";
    }
}
```

### With Dependency Injection

```csharp
// Program.cs
builder.Services.AddScoped<IDatabase, Database>();
builder.Services.AddAgentFramework()
    .AddAgent<MyAgent>("assistant");

// MyAgent.cs
public class MyAgent : ChatAgent
{
    private readonly IDatabase _db;

    public MyAgent(IDatabase db)
    {
        _db = db;
    }

    [Tool]
    public async Task<User> GetUser(string userId)
    {
        return await _db.GetUserAsync(userId);
    }
}
```

## Container Deployment

### Dockerfile

```dockerfile
# Python agent
FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy agent code
COPY . .

# Run with gunicorn
CMD ["gunicorn", "main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8000"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  agent:
    build: .
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
    depends_on:
      - redis
      - otel-collector

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  otel-collector:
    image: otel/opentelemetry-collector:latest
    ports:
      - "4317:4317"
```

## Kubernetes Deployment

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: agent-service
  template:
    metadata:
      labels:
        app: agent-service
    spec:
      containers:
        - name: agent
          image: myregistry/agent-service:v1.0.0
          ports:
            - containerPort: 8000
          env:
            - name: OPENAI_API_KEY
              valueFrom:
                secretKeyRef:
                  name: agent-secrets
                  key: openai-api-key
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: agent-service
spec:
  selector:
    app: agent-service
  ports:
    - port: 80
      targetPort: 8000
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

## Azure Deployment

### Azure Container Apps

```yaml
# azure-container-app.yaml
name: agent-service
properties:
  configuration:
    ingress:
      external: true
      targetPort: 8000
    secrets:
      - name: openai-key
        value: ${OPENAI_API_KEY}
  template:
    containers:
      - image: myregistry.azurecr.io/agent-service:v1.0.0
        name: agent
        env:
          - name: OPENAI_API_KEY
            secretRef: openai-key
        resources:
          cpu: 0.5
          memory: 1Gi
    scale:
      minReplicas: 1
      maxReplicas: 10
      rules:
        - name: http-rule
          http:
            metadata:
              concurrentRequests: 100
```

### Azure Functions

```python
# function_app.py
import azure.functions as func
from agent_framework import ChatAgent
from agent_framework.hosting.azure import create_function_handler

app = func.FunctionApp()

class MyAgent(ChatAgent):
    system_prompt = "You are a helpful assistant."

handler = create_function_handler(MyAgent())

@app.route(route="chat", methods=["POST"])
async def chat(req: func.HttpRequest) -> func.HttpResponse:
    return await handler(req)
```

## Production Configuration

### Environment Variables

```python
from agent_framework.hosting import HostingConfig
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # API Keys
    openai_api_key: str
    azure_openai_endpoint: str = ""

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 4

    # Rate Limiting
    rate_limit_requests: int = 100
    rate_limit_window: int = 60

    # Telemetry
    otel_endpoint: str = ""
    otel_service_name: str = "agent-service"

    # Security
    api_key_header: str = "X-API-Key"
    allowed_origins: list[str] = ["*"]

    class Config:
        env_file = ".env"

settings = Settings()
```

### Rate Limiting

```python
from fastapi import FastAPI, Request
from agent_framework.hosting.middleware import RateLimiter

app = FastAPI()

# Add rate limiting
app.add_middleware(
    RateLimiter,
    requests_per_minute=100,
    burst_size=20,
    key_func=lambda r: r.headers.get("X-API-Key", r.client.host)
)
```

### Authentication

```python
from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import APIKeyHeader

app = FastAPI()
api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Depends(api_key_header)):
    if api_key not in VALID_API_KEYS:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return api_key

@app.post("/chat")
async def chat(request: ChatRequest, api_key: str = Depends(verify_api_key)):
    return await agent.chat(request.message)
```

### Health Checks

```python
from fastapi import FastAPI
from agent_framework.hosting.health import HealthChecker

app = FastAPI()

health = HealthChecker()
health.add_check("database", check_database)
health.add_check("redis", check_redis)
health.add_check("openai", check_openai_api)

@app.get("/health")
async def health_check():
    return await health.check()

@app.get("/health/live")
async def liveness():
    return {"status": "alive"}

@app.get("/health/ready")
async def readiness():
    result = await health.check()
    if not result["healthy"]:
        raise HTTPException(status_code=503)
    return result
```

## Best Practices

### 1. Graceful Shutdown

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await agent.initialize()
    yield
    # Shutdown
    await agent.cleanup()

app = FastAPI(lifespan=lifespan)
```

### 2. Request Timeouts

```python
from agent_framework.hosting.middleware import TimeoutMiddleware

app.add_middleware(
    TimeoutMiddleware,
    timeout=30  # seconds
)
```

### 3. Circuit Breaker

```python
from agent_framework.hosting import CircuitBreaker

circuit = CircuitBreaker(
    failure_threshold=5,
    recovery_timeout=60
)

@app.post("/chat")
@circuit.protected
async def chat(request: ChatRequest):
    return await agent.chat(request.message)
```

## Related

- `ms-agent-types` skill - Agent implementation
- `ms-observability` skill - Production monitoring
- `ms-ag-ui` skill - Web interface integration
- [Hosting Docs](https://learn.microsoft.com/en-us/agent-framework/guides/hosting)
