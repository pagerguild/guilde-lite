# AI Agent Sandboxing

Three levels of isolation for running AI coding agents safely.

## Level 1: Basic (File/Network Restrictions)

Uses Claude Code's built-in sandbox + macOS sandbox-exec.

```bash
task sandbox:basic -- claude
```

## Level 2: Container Isolation

Runs agents in OrbStack containers with limited mounts.

```bash
task sandbox:container -- claude
```

## Level 3: VM Isolation

Full VM separation using OrbStack Linux VM.

```bash
task sandbox:vm -- claude
```

## Quick Reference

| Level | Isolation | Performance | Use Case |
|-------|-----------|-------------|----------|
| Basic | Process | Native | Trusted projects, your own code |
| Container | Namespace | ~95% native | Untrusted dependencies, third-party code |
| VM | Full | ~90% native | Highly sensitive, security research |
