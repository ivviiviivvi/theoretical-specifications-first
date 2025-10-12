---
description: Facilitate project handoff between Spec-Driven Development format and traditional development formats, enabling bidirectional migration.
scripts:
  sh: scripts/bash/handoff-project.sh --json
  ps: scripts/powershell/handoff-project.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Enable seamless project handoff between Spec-Driven Development (SDD) repositories and traditional development projects. This supports two critical scenarios:
- **Import** (non-SDD → SDD): Bring existing projects into the Spec-Driven Development workflow
- **Export** (SDD → non-SDD): Package SDD projects for teams/platforms that don't use this methodology

Execution steps:

1. **Determine handoff direction and context**:

   Parse user input to identify:
   - Direction: `import` (non-SDD → SDD) or `export` (SDD → non-SDD)
   - If direction unclear, present options:
     ```
     Please specify handoff direction:
     
     A. IMPORT - Bring an existing project into Spec-Driven Development format
        Example: "import from /path/to/existing/project"
     
     B. EXPORT - Package this SDD project for teams not using this methodology
        Example: "export current project"
        Example: "export feature 001-photo-albums"
     
     Reply with 'A' or 'import', or 'B' or 'export'
     ```

2. **Run initialization script**:
   - Execute `{SCRIPT}` from repo root once
   - Parse JSON output for context paths and validation status
   - **CRITICAL**: Validate JSON structure before proceeding:
     * Check JSON is well-formed (try-catch parse)
     * Verify required fields exist: REPO_ROOT, IS_SDD_REPO, CONSTITUTION_STATUS
     * If validation fails: ERROR "Script output invalid. Please report this issue."
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

---

## IMPORT Workflow (non-SDD → SDD)

**Prerequisites**: User has provided path to source project or has described the project context

### Import Steps:

**Progress Tracking**: Report progress at each major step:
- "[1/8] Creating import branch..."
- "[2/8] Analyzing source project..."
- "[3/8] Generating constitution..."
- etc.

1. **Create import branch** (if in a git repository):
   - Check if repository has git: Run `git rev-parse --show-toplevel 2>/dev/null`
   - **CRITICAL Validations**:
     * Check if `001-initial-import` branch already exists: `git rev-parse --verify 001-initial-import 2>/dev/null`
     * If exists: ERROR "Import branch '001-initial-import' already exists. Delete it first or use a different approach."
     * Check working directory is clean: `git status --porcelain`
     * If not clean: ERROR "Working directory has uncommitted changes. Commit or stash them before importing."
   - If git available: Create and checkout branch `001-initial-import`
   - If git not available: Proceed with import in current context (warn user)
   - Set environment variable: `export SPECIFY_FEATURE=001-initial-import`

2. **Source analysis**:
   - **PREREQUISITE CHECK**: Verify required templates exist:
     * Check `.specify/templates/spec-template.md` exists
     * Check `.specify/templates/plan-template.md` exists  
     * Check `/memory/constitution.md` exists (as template)
     * If any missing: ERROR "Required templates missing. Run 'specify init .' in this repository first."
   - Identify source project structure:
     * README/documentation files
     * Source code organization
     * Existing requirements/specs (if any)
     * Build/deployment configuration
     * Test structure
   - Detect technology stack from package files (package.json, requirements.txt, pom.xml, etc.)
   - Identify primary programming languages

3. **Generate constitution**:
   - **CRITICAL**: Check if constitution already exists with content:
     * If `/memory/constitution.md` exists and is NOT a template (contains filled principles):
       - ERROR "Constitution already exists with project principles. Import would overwrite existing constitution."
       - Suggest: "To proceed: (1) Back up existing constitution, (2) Delete it, (3) Re-run import"
       - Or: "Consider importing into a separate project and merging constitutions manually."
   - If source has documented principles (CONTRIBUTING.md, CODE_STYLE.md, etc.), extract them
   - Otherwise, infer from code patterns:
     * Test coverage patterns → testing principles
     * Code organization → architecture principles
     * Dependency choices → technology preferences
   - Load the constitution template from `/memory/constitution.md` as a starting point
   - Fill in the template placeholders with extracted/inferred principles
   - **INTERACTIVE**: Present generated principles and ask for user review/refinement
   - Save the finalized constitution to `/memory/constitution.md`

4. **Extract and structure specifications**:
   - Look for existing specifications in:
     * README.md feature descriptions
     * Issue tracker references (if provided)
     * Documentation files (docs/, wiki/, etc.)
     * Code comments with user stories or requirements
   - If found: consolidate into feature specs in `specs/001-initial-import/spec.md`
   - If not found: generate spec from codebase analysis:
     * Identify major functional areas from code structure
     * Infer user flows from API/UI entry points
     * Document existing features as "As-Is" spec
   - Use the spec template structure from `.specify/templates/spec-template.md`

5. **Create implementation plan**:
   - Generate `specs/001-initial-import/plan.md` documenting:
     * Current architecture (as-is)
     * Technology stack inventory
     * Existing project structure
     * Dependencies and external integrations
   - Use the plan template structure from `.specify/templates/plan-template.md`
   - Mark this as a "BASELINE" plan representing current state

6. **Update agent context**:
   - Run `{AGENT_SCRIPT}` to update the appropriate agent-specific context file
   - Add imported project's tech stack and architecture notes
   - Preserve any manual additions between markers

7. **Migration report**:
   Generate `specs/001-initial-import/import-report.md`:
   ```markdown
   # Project Import Report
   
   **Source**: [PATH_OR_DESCRIPTION]
   **Import Date**: [DATE]
   **Imported By**: Spec Kit Handoff Command
   
   ## Source Project Summary
   - **Tech Stack**: [LANGUAGES, FRAMEWORKS]
   - **Project Type**: [WEB_APP, CLI_TOOL, LIBRARY, etc.]
   - **Size**: [LOC, FILE_COUNT, COMPLEXITY_ESTIMATE]
   
   ## Imported Artifacts
   - ✓ Constitution: /memory/constitution.md
   - ✓ Baseline Spec: specs/001-initial-import/spec.md
   - ✓ Baseline Plan: specs/001-initial-import/plan.md
   
   ## What Was Preserved
   - [LIST OF KEY ELEMENTS CAPTURED]
   
   ## What Needs Attention
   - [LIST OF GAPS OR UNCLEAR AREAS]
   
   ## Next Steps
   1. Review and refine `/memory/constitution.md`
   2. Review baseline spec in `specs/001-initial-import/spec.md`
   3. Create first new feature: `/speckit.specify [your next feature]`
   4. Continue normal SDD workflow from here
   ```

8. **Completion**:
   - Save all generated files
   - Print import summary with next steps
   - Suggest: "Run `/speckit.specify` to start adding new features"
   
   **Error Recovery**: If import fails at any step:
   - Print clear error message with step number where failure occurred
   - List files that were successfully created (partial state)
   - Provide cleanup commands:
     ```bash
     # To clean up partial import:
     git checkout main  # or your original branch
     git branch -D 001-initial-import
     rm -rf specs/001-initial-import/
     # Restore constitution if it was overwritten (from backup)
     ```
   - Suggest: "Fix the underlying issue and re-run import"

---

## EXPORT Workflow (SDD → non-SDD)

**Goal**: Create a standalone package that traditional development teams can understand without SDD tooling

### Export Steps:

1. **Scope determination**:
   - If user specified a feature (e.g., "export feature 001-photo-albums"):
     * **VALIDATE**: Check if feature exists before proceeding
     * Verify `specs/001-photo-albums/` directory exists
     * If not found: ERROR "Feature '001-photo-albums' not found in specs/ directory"
     * List available features to help user
     * Export only that feature's artifacts
   - If user said "export current project" or "export all":
     * Export all features in specs/
     * **VALIDATE**: Check if specs/ directory has any features
     * If empty: ERROR "No features found to export. Create features first with /speckit.specify"
   - If ambiguous, ask:
     ```
     What would you like to export?
     
     A. Current feature only (if in feature branch)
     B. Specific feature by number (e.g., 001, 002)
     C. All features (complete project documentation)
     
     Reply with option letter or specify feature number.
     ```

2. **Generate consolidated documentation**:
   
   Create export package in repository at `exports/export-[PROJECT_NAME]-[TIMESTAMP]/`:
   
   **A. PROJECT_OVERVIEW.md**:
   ```markdown
   # [PROJECT_NAME] - Exported Documentation
   
   **Exported**: [DATE]
   **Source**: Spec-Driven Development Repository
   
   ## About This Export
   This documentation was generated from a Spec-Driven Development project.
   It consolidates specifications, implementation plans, and design decisions
   into a format readable by teams not using the SDD methodology.
   
   ## Project Principles
   [Content from /memory/constitution.md, reformatted for general audience]
   
   ## Project Structure
   [Overview of included features and their relationships]
   ```
   
   **B. For each exported feature, create FEATURE_[NUM]_[NAME].md**:
   ```markdown
   # Feature: [FEATURE_NAME]
   
   ## Specification
   [Contents of spec.md with SDD-specific markers removed]
   
   ## Implementation Plan
   [Contents of plan.md]
   
   ## Task Breakdown
   [Contents of tasks.md if exists]
   
   ## Design Artifacts
   [Contents of data-model.md, contracts/, quickstart.md if they exist]
   ```
   
   **C. GLOSSARY.md** (if terminology is complex):
   Extract and consolidate domain terms from all specs
   
   **D. TECH_STACK.md**:
   Consolidate all technology choices from plan files:
   - Languages and frameworks
   - Build tools
   - Test frameworks
   - Deployment targets
   - External dependencies

3. **Clean up SDD-specific references**:
   - Remove `/speckit.*` command references
   - Replace SDD workflow terms with generic equivalents:
     * "Constitution" → "Project Principles"
     * "Feature branch" → "Feature documentation"
     * "[NEEDS CLARIFICATION]" → "TBD" or resolve to default
   - Remove JSON/script metadata blocks
   - Convert internal cross-references to relative file links

4. **Generate handoff README**:
   Create `README_HANDOFF.md` in export package:
   ```markdown
   # Handoff Instructions
   
   This package contains comprehensive documentation exported from a
   Spec-Driven Development project. Here's how to use it:
   
   ## For Product Managers
   - Start with PROJECT_OVERVIEW.md for project principles
   - Review individual FEATURE_*.md files for detailed requirements
   
   ## For Developers
   - Review TECH_STACK.md for technology decisions
   - Each FEATURE file includes implementation plans and task breakdowns
   - Data models and API contracts are embedded in feature documentation
   
   ## For Project Managers
   - Task breakdowns in FEATURE files can be imported into your project management tool
   - Acceptance criteria are clearly marked in each feature specification
   
   ## Need to Modify Features?
   Since this is a documentation export, changes should be made to your
   own project management tools. If you want to adopt the full SDD workflow:
   
   1. Install Spec Kit: [INSTALLATION_LINK]
   2. Run: specify init [project-name]
   3. Import these docs using: /speckit.handoff import
   ```

5. **Package and compress**:
   - Create ZIP file: `[PROJECT_NAME]-export-[TIMESTAMP].zip`
   - Include all generated markdown files
   - Add a LICENSE file from source if present
   - Save ZIP in repository `exports/` directory
   - Also offer to copy to user-specified location if requested

6. **Update agent context**:
   - Run `{AGENT_SCRIPT}` to update the appropriate agent-specific context file
   - Log export activity and package location

7. **Completion**:
   - Print export summary with package location
   - List included features
   - Show package size and file count
   - Provide next steps for recipient

---

## Behavior Rules

### For IMPORT:
- Be conservative: preserve more rather than less from source
- Flag uncertainties clearly in generated docs
- Make constitution extractive, not prescriptive (capture what exists, don't invent rules)
- Interactive: always confirm generated principles before finalizing
- Non-destructive: never modify source project

### For EXPORT:
- Be comprehensive: include all context needed for understanding
- Remove jargon: translate SDD terminology to universal terms
- Be self-contained: export should be understandable without SDD knowledge
- Respect privacy: don't include TODO items or internal notes unless user explicitly requests
- Format for reading: optimize for clarity over tooling compatibility

### Error Handling:
- If import source path doesn't exist or is inaccessible: ERROR with clear message
- If export requested but no specs exist: ERROR "No features to export. Run /speckit.specify first"
- If export requested for non-existent feature number: list available features
- If constitution.md missing on export: warn but proceed with skeleton constitution

### Output Locations:
- Imports write to current SDD repository structure
- Exports write to `REPO_ROOT/exports/export-[name]-[timestamp]/` directory
- Export ZIP files saved in `REPO_ROOT/exports/`
- Always print full absolute paths to generated artifacts
- Ensure `exports/` directory is in `.gitignore` (add if not present)

Context for handoff: {ARGS}
