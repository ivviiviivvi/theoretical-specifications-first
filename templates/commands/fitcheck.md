---
description: Evaluate whether a feature idea aligns with project constitution, principles, and strategic direction before creating a full specification.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
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

Goal: Quickly validate whether a proposed feature idea fits within the project's established principles, constraints, and strategic direction. This command runs BEFORE `/speckit.specify` to prevent wasted effort on ideas that fundamentally conflict with project governance.

Execution steps:

1. Run `{SCRIPT}` from repo root **once** to establish context. Parse JSON output for:
   - `REPO_ROOT`
   - (Optional) `CURRENT_BRANCH` if in a feature branch
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. Load governing documents and context:
   - **REQUIRED**: Load `/memory/constitution.md` to understand core principles, constraints, and governance rules
     * If constitution.md is missing or empty: ERROR "Constitution required for fit check. Run /speckit.constitution first to establish project principles."
   - **IF EXISTS**: Load `README.md` for project purpose and scope
   - **IF EXISTS**: Load `docs/index.md` or similar documentation for strategic goals
   - **IF EXISTS**: Scan `specs/` directory to understand existing feature themes and patterns

3. Parse the feature idea from user input:
   - If empty or too vague (< 10 words): ERROR "Please provide a concrete feature idea description"
   - Extract: core purpose, affected actors, high-level functionality, implied constraints

4. Perform multi-dimensional fit analysis:

   **A. Constitutional Alignment**
   - Check if the idea violates any core principles from constitution.md
   - Identify which principles it most directly relates to
   - Flag any explicit prohibitions or requirements from governance rules
   - Status: ✓ ALIGNED | ⚠ CONCERNS | ✗ CONFLICTS

   **B. Scope Fit**
   - Compare against project's stated mission/purpose
   - Check if it's tangential vs. core to the project's goals
   - Assess if it fits the target user/persona (if defined)
   - Status: ✓ IN-SCOPE | ⚠ EDGE-CASE | ✗ OUT-OF-SCOPE

   **C. Complexity Assessment**
   - Estimate relative complexity (Simple / Moderate / Complex / Very Complex)
   - Identify if it requires new architectural patterns
   - Check if it introduces new external dependencies
   - Flag if it would require constitution amendments
   - Status: ✓ MANAGEABLE | ⚠ SIGNIFICANT | ✗ EXCESSIVE

   **D. Strategic Coherence**
   - Does it duplicate or conflict with existing features?
   - Does it create synergies with existing features?
   - Is it foundational (enabler) or leaf (end-user facing)?
   - Status: ✓ SYNERGISTIC | ⚠ INDEPENDENT | ✗ CONFLICTING

5. Generate recommendation with reasoning:

   **Format:**
   ```
   # Fit Check Result: [FEATURE IDEA SHORT TITLE]
   
   **Evaluated**: [DATE]
   **Recommendation**: [PROCEED | PROCEED WITH CAUTION | REVISE | REJECT]
   
   ## Summary
   [2-3 sentence executive summary of the fit assessment]
   
   ## Detailed Analysis
   
   ### Constitutional Alignment: [✓/⚠/✗]
   [Specific principles affected, violations or strong alignments]
   
   ### Scope Fit: [✓/⚠/✗]
   [How well it matches project purpose and boundaries]
   
   ### Complexity Assessment: [Simple/Moderate/Complex/Very Complex]
   [Key complexity drivers and architectural implications]
   
   ### Strategic Coherence: [✓/⚠/✗]
   [Relationship to existing features and strategic goals]
   
   ## Concerns & Recommendations
   [Numbered list of specific concerns with actionable recommendations]
   
   ## Suggested Modifications
   [If REVISE: specific changes to make the idea fit better]
   [If PROCEED WITH CAUTION: guardrails or scoping suggestions]
   [If PROCEED: any optional enhancements that could improve fit]
   
   ## Next Steps
   [If PROCEED or PROCEED WITH CAUTION:]
   - Run `/speckit.specify` with the following refined description: [IMPROVED_DESCRIPTION]
   
   [If REVISE:]
   - Address the concerns above and re-run `/speckit.fitcheck` with modified idea
   
   [If REJECT:]
   - Consider alternative approaches that better align with [SPECIFIC_PRINCIPLES]
   - Or propose a constitution amendment if this represents a strategic pivot
   ```

6. Interactive clarification (optional):
   - If the idea is borderline on multiple dimensions, ask 1-2 targeted questions to refine assessment
   - Questions should be yes/no or multiple choice
   - Example: "Is this feature intended for [audience A] or [audience B]?"
   - Maximum 2 clarification questions total

7. Save analysis report:
   - Create directory `REPO_ROOT/fitcheck-reports/` if it doesn't exist
   - Save to `REPO_ROOT/fitcheck-reports/fitcheck-[idea-slug]-[timestamp].md`
   - Generate slug from first 3-4 words of idea (lowercase, hyphenated)
   - Ensure `fitcheck-reports/` is in `.gitignore` (add if not present)
   - Report the saved location to user

8. Update agent context:
   - Run `{AGENT_SCRIPT}` to update the appropriate agent-specific context file
   - Log fitcheck activity and results
   - Add validated features to agent's memory if PROCEED recommendation

9. Final output:
   - Display the recommendation prominently
   - Show path to detailed analysis file
   - Provide clear next step command or action

Behavior rules:
- Be constructive: frame concerns as opportunities to refine the idea
- Be specific: cite exact principles, constraints, or conflicts
- Be actionable: provide concrete suggestions for improvement
- Be efficient: complete analysis in single pass unless clarification truly needed
- Default to PROCEED WITH CAUTION rather than REJECT for edge cases
- If project has no existing features (empty specs/), be more permissive on strategic coherence

Context for analysis: {ARGS}
