---
name: skill-authoring
description: Comprehensive guide and templates for creating effective Agent Skills following the official SKILL.md specification. Use when creating new skills, debugging existing ones, or understanding agent skills architecture and validation.
---

# Skill Authoring Guide

## Overview
Agent Skills are a simple, open format for giving agents new capabilities and expertise. They are directories containing instructions, scripts, and resources that agents can discover and use. This is an open standard supported by OpenCode, Cursor, Claude Code, and other agent platforms.

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```text
skill-name/
├── SKILL.md          # Required
├── scripts/          # Optional - executable code
├── references/       # Optional - additional documentation
└── assets/          # Optional - static resources
```

## SKILL.md Format

### Required Frontmatter

```yaml
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

### Optional Frontmatter Fields

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents.
license: Apache-2.0
compatibility: Requires git, docker, jq, and internet access
metadata:
  author: example-org
  version: "1.0"
allowed-tools: Bash(git:*) Read WebFetch
---
```

## Field Specifications

### `name` Field (Required)
- **Constraints**: 1-64 characters, lowercase letters, numbers, hyphens only
- **Rules**: Cannot start/end with hyphen, no consecutive hyphens, must match directory name
- **Valid**: `pdf-processing`, `data-analysis`, `code-review`
- **Invalid**: `PDF-Processing`, `-pdf`, `pdf--processing`

### `description` Field (Required)
- **Constraints**: 1-1024 characters, non-empty
- **Best practice**: Describe what the skill does AND when to use it
- **Good**: "Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction."
- **Poor**: "Helps with PDFs."

### `license` Field (Optional)
- Specifies the license applied to the skill
- Keep short: license name or reference to bundled license file

### `compatibility` Field (Optional)
- **Constraints**: 1-500 characters if provided
- Use only for specific environment requirements
- Examples: "Designed for Claude Code", "Requires git, docker, jq, and internet access"

### `metadata` Field (Optional)
- Arbitrary key-value mapping for additional metadata
- Use unique key names to avoid conflicts

### `allowed-tools` Field (Optional, Experimental)
- Space-delimited list of pre-approved tools
- Example: `allowed-tools: Bash(git:*) Bash(jq:*) Read`

## Body Content Guidelines

### Recommended Structure
```markdown
# <Skill Title>

## Quick Start
Provide the most common command or workflow immediately.

## Instructions
1. Step-by-step logic for the agent
2. Reference external files when complex: "Read `reference/details.md` for validation rules"

## Constraints
- Explicitly list what the agent should NOT do
- Security warnings if relevant

## Examples
### <Example Scenario>
Explain how to handle specific edge cases
```

## Progressive Disclosure Strategy

Skills should be structured for efficient context use:

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup
2. **Instructions** (< 5000 tokens): Full `SKILL.md` body loaded when activated
3. **Resources** (as needed): Files loaded only when referenced

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

## Optional Directories

### `scripts/` Directory
- Contains executable code (Python, Bash, JavaScript, etc.)
- Scripts should be self-contained and handle edge cases gracefully
- Include helpful error messages

### `references/` Directory
- Additional documentation loaded on demand
- Common files: `REFERENCE.md`, `FORMS.md`, domain-specific files
- Keep files focused to minimize context usage

### `assets/` Directory
- Static resources: templates, images, data files, schemas
- Document templates, configuration templates, diagrams, examples

## File References

Use relative paths from skill root:
```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

Keep references one level deep. Avoid nested reference chains.

## Best Practices

### Naming
- Use `kebab-case` (e.g., `git-commit-helper`)
- Keep names descriptive and actionable

### Content Management
- Move long lists, schemas, or logs to separate files
- Only reference external files when absolutely necessary
- Keep main instructions concise and focused

### Security
- Exercise extreme caution with skills that fetch external URLs or execute code
- Treat installing a skill like installing software
- Validate all external inputs

### Scripts vs Instructions
- Prefer bundling deterministic scripts for complex logic
- Use scripts for data validation, formatting, repetitive tasks
- Keep instructions focused on decision-making and workflow guidance

## Validation

Use the skills-ref library to validate skills:
```bash
skills-ref validate ./my-skill
```

This checks:
- Valid YAML frontmatter
- Correct naming conventions
- Required field presence
- Field constraint compliance

## Compatibility & Adoption

The Agent Skills format is an open standard that enables:
- Domain expertise packaging
- New agent capabilities
- Repeatable workflows
- Cross-platform interoperability
