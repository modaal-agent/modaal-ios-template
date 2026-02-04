# IOS_APP_NAME

An iOS app project created with Modaal AI.

---

## Project Structure

```
├── README.md           # This file
├── PRD.md              # Product Requirements Document (created during Refine)
├── PLAN.md             # Current working plan (maintained in Vibe mode)
├── specs/              # Feature specifications and artifacts (Specify mode)
│   └── xxx-feature/    # Feature xxx
└── src-ios/            # iOS application source code
    ├── App/            # Main app target
    ├── Libraries/      # App-specific libraries
    └── SharedLibraries/# Shared/reusable libraries
```

---

## Workflow Modes

### Vibe Mode 🎸

**Best for**: Quick prototyping, exploration, iterating on ideas

The agent acts as your thought partner and co-creator. Fast, flexible, conversational.

**How it works**:

- Maintains a lightweight `PLAN.md` with immediate next steps
- Executes your requests while keeping track of progress
- Suggests next steps as you build

**Example prompts**:

- "Let's build the home screen with a list of items"
- "Add a detail view when tapping an item"
- "Make the UI look better - add some polish"
- "What should we work on next?"

### Refine Mode 📝

**Best for**: Starting a new project, clarifying requirements

Transforms your idea into a structured Product Requirements Document (PRD).

**How it works**:

- Analyzes your input and any attached files (screenshots, designs)
- Creates `PRD.md` with structured requirements
- Recommends next workflow mode based on complexity

**Example prompts**:

- "I want to build a fitness tracking app"
- "Create an app like this [attach screenshot]"
- "Build a recipe book app with meal planning"

### Specify Mode 📋

**Best for**: Complex features, production-quality development

Follows a rigorous cycle: Specification → Planning → Tasks → Implementation.

**How it works**:

- Creates detailed feature specifications in `specs/`
- Breaks down work into concrete tasks
- Implements with full traceability

**Example prompts**:

- "Specify the user authentication feature"
- "Create a plan for the data sync system"
- "Break down the payment integration into tasks"
- "Implement the next task"

---

## Quick Start

1. **Already have a PRD?** → Switch to **Vibe** or **Specify** mode and start building
2. **Starting fresh?** → Use **Refine** mode to create your PRD first
3. **Want to explore?** → Jump into **Vibe** mode and iterate

---

## Tips

- **Be specific**: "Add a blue header with the app title" works better than "make it look nice"
- **Iterate**: Start simple, refine as you go
- **Use attachments**: Share screenshots, designs, or reference images
- **Check the plan**: In Vibe mode, the agent maintains `PLAN.md` with next steps
- **Switch modes**: Use Vibe for speed, Specify for structure

---

_Built with [Modaal.dev](https://modaal.dev)_
