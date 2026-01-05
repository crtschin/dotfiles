---
name: skill-authoring
description: Comprehensive guide and templates for creating effective Agent Skills (open standard SKILL.md format). Use this when the user asks to create a new skill, debug an existing one, or understand the agent skills architecture.
---

# Skill Authoring Guide

## Overview
Agent Skills are a simple, open format for giving agents new capabilities and expertise. They are folders of instructions, scripts, and resources that agents can discover and use to do things more accurately and efficiently. This standard is supported by tools like OpenCode, Cursor, and Claude.

## Core Principles

1.  **Progressive Disclosure**: Do not dump all information in `SKILL.md`.
    *   **Level 1 (Metadata)**: The YAML frontmatter is always loaded. Keep descriptions distinct to prevent false triggering.
    *   **Level 2 (Instructions)**: `SKILL.md` is loaded when triggered. Keep it under 5k tokens.
    *   **Level 3 (Resources)**: Specific scripts or reference files (e.g., `api-docs.md`, `run_tests.py`) are only read by the agent if explicitly referenced in the instructions.

2.  **Distinct Descriptions**: The `description` field in YAML is the *only* thing the agent sees initially. It must clearly define:
    *   **What** the skill does.
    *   **When** to use it (trigger conditions).
    *   **Keywords** relevant to the task.

## File Structure

A skill is a directory containing at minimum a `SKILL.md`.

```text
my-skill/
├── SKILL.md          # Entry point with YAML frontmatter
├── reference/        # (Optional) Large documentation files
│   └── api.md
└── scripts/          # (Optional) Executable utility scripts
    └── validate.py
```

## Template: SKILL.md

Use this template for new skills:

```markdown
---
name: unique-skill-name-kebab-case
description: <ACTION VERB> <OBJECT>. Use when <CONDITION>.
---

# <Skill Title>

## Quick Start
Provide the most common command or workflow immediately.

## Instructions
1. Step-by-step logic for the agent.
2. If complex, reference external files: "Read `reference/details.md` for strict validation rules."

## Constraints
- Explicitly list what the agent should NOT do.
- List security warnings if relevant.

## Examples
### <Example Scenario>
Explain how to handle a specific edge case.
```

## Best Practices

*   **Actionable Names**: Use `kebab-case` (e.g., `git-commit-helper`, not `GitCommitHelper`).
*   **Deterministic Scripts**: Prefer bundling Python/Bash scripts for complex logic (e.g., data validation, formatting) rather than asking the LLM to hallucinate the steps.
*   **Context Efficiency**: Move long lists, schemas, or logs into separate files and only tell the agent to read them if absolutely necessary.
*   **Security**: Exercise extreme caution with skills that fetch data from external URLs or execute code. Treat installing a skill like installing software.

## Adoption & Compatibility
The Agent Skills format is an open standard.
*   **Enables**: Domain expertise packaging, new capabilities, repeatable workflows, and interoperability.
*   **Supported By**: OpenCode, Cursor, Amp, Letta, Goose, Claude Code, and more.
