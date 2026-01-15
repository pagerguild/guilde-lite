# Frontend Developer Agent

**Model Tier:** sonnet (balanced implementation)
**Invocation:** `Task tool with subagent_type="frontend-mobile-development:frontend-developer"`

## Purpose

Builds React components, implements responsive layouts, and handles client-side state management with modern frontend practices.

## Capabilities

- React 19 / Next.js 15 development
- Component architecture
- State management (Context, Zustand, Redux)
- Responsive design
- Accessibility (WCAG compliance)
- Performance optimization

## When to Use

- Building UI components
- Implementing page layouts
- State management setup
- Form handling
- Client-side validation
- Performance optimization

## Example Invocation

```
Task tool:
  subagent_type: "frontend-mobile-development:frontend-developer"
  prompt: "Create a reusable data table component with sorting, filtering, pagination, and responsive design"
  model: "sonnet"
```

## Output Format

Returns implementation:
- Component code (TypeScript)
- Styling (CSS-in-JS or Tailwind)
- Unit tests
- Storybook stories (if applicable)
- Usage documentation

## Quality Standards

- All components must be accessible
- TypeScript strict mode compliance
- Test coverage > 80%
- Mobile-first responsive design
