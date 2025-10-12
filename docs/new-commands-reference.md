# New Commands Quick Reference

This document provides examples and use cases for the newly added `/speckit.fitcheck` and `/speckit.handoff` commands.

## Important Notes

### Prerequisites
- **fitcheck** requires `/memory/constitution.md` to exist. Run `/speckit.constitution` first if starting a new project.
- **handoff import** works best in git repositories for proper branch management
- **handoff export** creates files in `exports/` directory within your repository

### Agent Context Updates
Both commands now update agent-specific context files (like `.claude/commands/`, `.github/prompts/`, etc.) to maintain consistency across your development workflow.

## `/speckit.fitcheck` - Idea Validation

### Purpose
Validates whether a feature idea aligns with your project's constitution, scope, and strategic direction **before** you invest time in creating a full specification.

### When to Use
- **Before `/speckit.specify`**: Use this as a gate-check to prevent wasted effort
- When you're unsure if an idea fits your project's principles
- To get quick feedback on scope and complexity

### Example Usage

```bash
# Check if a new feature idea fits the project
/speckit.fitcheck Add a real-time collaboration feature with WebSocket support and presence indicators

# Validate a complex architectural change
/speckit.fitcheck Migrate from REST API to GraphQL with subscriptions for real-time updates

# Test if a feature is within scope
/speckit.fitcheck Add PDF export functionality for reports with custom templates
```

### What It Analyzes
1. **Constitutional Alignment**: Checks against your project principles
2. **Scope Fit**: Evaluates if it matches project mission
3. **Complexity Assessment**: Estimates implementation complexity
4. **Strategic Coherence**: Checks relationships with existing features

### Output
- Recommendation: PROCEED | PROCEED WITH CAUTION | REVISE | REJECT
- Detailed analysis with specific concerns
- Actionable suggestions for improvement
- Next steps with refined description (if needed)

---

## `/speckit.handoff` - Project Migration

### Purpose
Facilitates bidirectional project migration between Spec-Driven Development (SDD) and traditional development formats.

### When to Use

#### IMPORT (non-SDD → SDD)
- Bringing an existing project into the SDD workflow
- Onboarding a legacy codebase
- Starting SDD with existing code

#### EXPORT (SDD → non-SDD)
- Sharing documentation with teams not using SDD
- Creating handoff packages for contractors
- Archiving project documentation

### Example Usage

#### Import Examples

```bash
# Import an existing Node.js project
/speckit.handoff import from /home/user/projects/my-app

# Import with project description
/speckit.handoff import This is a React-based task management application with REST API backend

# Import from current directory
/speckit.handoff import from .
```

#### Export Examples

```bash
# Export current project completely
/speckit.handoff export current project

# Export a specific feature
/speckit.handoff export feature 001-user-authentication

# Export all features
/speckit.handoff export all features
```

### Import Process
1. Creates import branch `001-initial-import` (if using git)
2. Analyzes source code structure and technology stack
3. Extracts or infers project principles → creates `constitution.md`
4. Generates baseline specification from codebase
5. Creates implementation plan documenting as-is state
6. Updates agent context files
7. Provides import report with next steps

### Export Process
1. Consolidates all specifications and plans
2. Removes SDD-specific terminology and markers
3. Creates standalone documentation package
4. Generates handoff instructions for recipients
5. Updates agent context files
6. Packages as ZIP file in `exports/` directory

### Output Locations
- **Imports**: Write to current repository structure
  - `/memory/constitution.md`
  - `/specs/001-initial-import/`
- **Exports**: Write to `exports/export-[project]-[timestamp]/`
  - `PROJECT_OVERVIEW.md`
  - `FEATURE_[NUM]_[NAME].md` files
  - `README_HANDOFF.md`
  - `TECH_STACK.md`
  - ZIP package in `exports/` directory

---

## Workflow Integration

### Recommended Workflow with New Commands

```
1. [Optional] /speckit.fitcheck <idea>
   ↓ (if PROCEED or PROCEED WITH CAUTION)
   
2. /speckit.constitution
   ↓
   
3. /speckit.specify
   ↓
   
4. [Optional] /speckit.clarify
   ↓
   
5. /speckit.plan
   ↓
   
6. /speckit.tasks
   ↓
   
7. [Optional] /speckit.analyze
   ↓
   
8. /speckit.implement
   ↓
   
9. [Optional] /speckit.handoff export
```

### Special Scenarios

#### Starting with Existing Code
```
1. /speckit.handoff import from <path>
2. Review generated constitution and baseline spec
3. Continue with normal workflow for new features
```

#### Sharing with Non-SDD Team
```
1. Complete feature implementation
2. /speckit.handoff export feature <number>
3. Share generated ZIP package
```

---

## Tips & Best Practices

### For `/speckit.fitcheck`
- Be specific in your idea description (more detail = better analysis)
- Use it early to save time on misaligned features
- Pay attention to the "Suggested Modifications" section
- Don't skip it for complex or boundary-case features

### For `/speckit.handoff` Import
- Provide context about the project when importing
- Review and refine the generated constitution
- The baseline spec documents "what exists" not "what should be"
- Use it to establish a starting point, not as final documentation

### For `/speckit.handoff` Export
- Export early and often for documentation continuity
- Include relevant context in exported packages
- Test the exported package with someone unfamiliar with SDD
- Use specific feature exports for incremental handoffs
- **Check exports/ directory** - packages are saved locally, not to /tmp

## Known Limitations

### fitcheck Command
- **Requires constitution**: Cannot run without `/memory/constitution.md`
- **AI-dependent analysis**: Quality depends on AI agent's capability to interpret principles
- **No automated testing**: Results saved for manual review only
- Analysis reports saved to `fitcheck-reports/` directory (excluded from git)

### handoff Command
- **Import complexity**: Large codebases may take several minutes to analyze
- **No checkpoint/resume**: If import fails mid-process, must restart
- **Limited code parsing**: Complex build systems or monorepos may not parse fully
- **Interactive prompts**: May not work in batch/CI contexts
- **Git recommended**: Import without git creates artifacts without branch isolation
- Export packages saved locally in `exports/` directory (excluded from git)

---

## Troubleshooting

### `/speckit.fitcheck` Issues
- **"No constitution found"**: Create one with `/speckit.constitution` first
- **Analysis seems generic**: Provide more detail in your idea description
- **Recommendation unclear**: Run `/speckit.clarify` after `/speckit.specify` for deeper exploration

### `/speckit.handoff` Import Issues
- **Source path not found**: Verify the absolute path is correct
- **Generated constitution empty**: Source lacks documented principles; you'll need to define them
- **Import fails**: Ensure source directory is readable and contains recognizable project structure

### `/speckit.handoff` Export Issues
- **No features to export**: Create at least one feature with `/speckit.specify` first
- **Export package too large**: Export specific features instead of entire project
- **SDD markers remain**: Report as bug; should be automatically cleaned

---

## Command Reference Card

| Command | Phase | Input Required | Output |
|---------|-------|----------------|--------|
| `/speckit.fitcheck` | Pre-spec | Feature idea description | Analysis report with recommendation |
| `/speckit.handoff import` | Initial | Source project path | Constitution, baseline spec, plan |
| `/speckit.handoff export` | Any | Feature number or "all" | Documentation package (ZIP) |

---

## Examples Gallery

### Example 1: Checking a Feature Idea

```bash
/speckit.fitcheck Add a plugin system that allows third-party developers to extend functionality with custom JavaScript code
```

**Output** (abbreviated):
```
# Fit Check Result: Plugin System

**Recommendation**: PROCEED WITH CAUTION

## Concerns & Recommendations
1. Security: Plugin system introduces code execution risks
   → Recommendation: Implement sandboxing and code review process
2. Complexity: Moderate to Complex (new architectural pattern)
   → Recommendation: Start with limited plugin API surface area

## Next Steps
Run /speckit.specify with this refined description:
"Add a sandboxed plugin system with limited API access that allows 
third-party developers to extend functionality..."
```

### Example 2: Importing a Project

```bash
/speckit.handoff import from /home/user/projects/todo-app
```

**Output** (abbreviated):
```
# Project Import Report

**Source**: /home/user/projects/todo-app
**Tech Stack**: React, Node.js, MongoDB

## Imported Artifacts
✓ Constitution: /memory/constitution.md (3 principles extracted)
✓ Baseline Spec: specs/001-initial-import/spec.md
✓ Baseline Plan: specs/001-initial-import/plan.md

## What Needs Attention
- No testing documentation found; recommend adding test principles
- API authentication unclear; needs specification

## Next Steps
1. Review /memory/constitution.md
2. Add missing principles for testing and security
3. Create first new feature: /speckit.specify [your next feature]
```

### Example 3: Exporting Documentation

```bash
/speckit.handoff export feature 002-user-dashboard
```

**Output**:
```
Export Complete!

Package Location: /tmp/export-myproject-20251011-234500/
Package Size: 1.2 MB
Files Included:
  - PROJECT_OVERVIEW.md
  - FEATURE_002_USER_DASHBOARD.md
  - TECH_STACK.md
  - README_HANDOFF.md

Compressed: /tmp/export-myproject-20251011-234500.zip

Share this package with your team for handoff.
```

---

*For more information, see the main [README.md](../README.md) or visit [Spec Kit Documentation](https://github.github.io/spec-kit/)*
