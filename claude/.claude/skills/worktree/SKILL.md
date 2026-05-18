---
name: worktree
description: >
  Manage git worktrees and correlate them with JIRA tickets assigned to the current user.
  Trigger phrases: "worktree", "list worktrees", "worktree status", "worktree done",
  "finish worktree", "merge worktree", "close worktree", "worktree and jira", "worktree tickets",
  "start worktree", "new worktree", "create worktree", "add worktree",
  "PR #", "pull request", "github.com/pull", "/pull/", "fix comments on", "address comments on",
  "review comments on", "update PR", "push to PR", "changes on PR".
  Subcommands: list (default), add, done.
arguments: [subcommand, target]
version: 1.3.0
---

# Worktree + JIRA Skill

Manages git worktrees and correlates their branches with JIRA tickets assigned to the current
user. When a worktree is created the corresponding JIRA ticket is transitioned to In Progress
and implementation begins immediately. When complete, changes are committed, pushed, and a PR
is created. When the PR merges, the ticket transitions to Done and the worktree is removed.

## Subcommands

- **`/worktree`** or **`/worktree list`** — Show all worktrees with their JIRA ticket status.
- **`/worktree add <branch> [path]`** — Create a worktree, move its JIRA ticket to In Progress, and begin implementation.
- **`/worktree done [branch-or-path]`** — Merge the worktree branch and mark its JIRA ticket Done.

---

## PR Resolution Protocol

Use this protocol whenever a PR URL or number is mentioned (e.g. "fix comments on PR #854",
"github.com/.../pull/854", "update PR 854"). Run all steps before doing any work on the PR.

### Step R1 — Resolve PR to branch

```bash
gh pr view <number-or-url> --json number,headRefName,baseRefName,title,url
```

Extract: `headRefName` (the branch), `baseRefName` (must be verified — see mandatory tracking
branch check), `number`, `title`.

### Step R2 — Find the matching local worktree

```bash
git worktree list --porcelain
```

Scan for a block whose `branch` field matches `refs/heads/<headRefName>`. Extract the `worktree`
path from that block.

- **Match found** → set working directory to that path for all subsequent file reads, edits,
  and git commands. Report: `Working in worktree: <path> (branch: <branch>)`.
- **No match** → note it and continue from the repo root. Do not block. Do not ask.

### Step R3 — Load JIRA context (if worktree found)

Apply the regex `[A-Z][A-Z0-9]+-\d+` to `headRefName`. If a ticket ID is found:

```bash
acli jira workitem view <TICKET-ID> --json
```

Read `fields.summary`, `fields.status.name`, `fields.description`, and
`fields.comment.comments`. Use this as background context for understanding what the PR is
meant to accomplish. Do not transition the ticket status during PR comment work.

### Step R4 — Verify tracking branch (MANDATORY)

Confirm `baseRefName` from Step R1 is the expected target (typically `develop`, or the stacked
base branch). If it does not match expectations, **stop and report** before touching anything.

---

## `/worktree list`

### Step 1 — Find the git repo root

`git worktree list` must be run from within a git repository. Determine the right repo:
- If the user provided a path, use that.
- Otherwise, use `git rev-parse --show-toplevel` from the current working directory.
- If cwd is not a git repo, ask the user which repo to inspect.

### Step 2 — List all worktrees

```bash
git worktree list --porcelain
```

This outputs blocks like:
```
worktree /path/to/worktree
HEAD abc123
branch refs/heads/SDK-123-my-feature
```

Parse each block: extract the `worktree` path and the short branch name (strip `refs/heads/`).
For bare worktrees or detached HEADs, note them as "detached" and skip JIRA correlation.

### Step 3 — Extract JIRA ticket IDs from branch names

For each branch name, scan for the first match of `[A-Z][A-Z0-9]+-\d+` (e.g. `SDK-123`).
- Match anywhere in the branch name (handles `feature/SDK-123-desc`, `adam/SDK-123`, `SDK-123-desc`).
- If no match, the worktree has no associated ticket — list it without JIRA data.
- First match wins; ignore any subsequent matches.

### Step 4 — Fetch JIRA ticket data

For each unique ticket ID found, fetch in parallel:

```bash
acli jira workitem view <TICKET-ID> --json
```

Extract from the JSON: `fields.summary` (title), `fields.status.name` (current status),
`fields.assignee.displayName` (to confirm it belongs to the current user).

If a ticket is **not assigned to the current user**, still show it — but flag it:
`(not assigned to you)`.

Also fetch all open tickets assigned to the current user to cross-check — any assigned ticket
whose ID appears in a worktree branch is worth highlighting even if the branch naming is unusual.
Only include the `SDK` project; other projects (e.g. `SGI`) are treated as dead/out-of-scope.

```bash
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done AND project = SDK" --json --paginate
```

### Step 5 — Auto-sync and display

For each ticket with an active worktree, check PR state using `--state all` so merged PRs are
detected (omitting this flag silently hides merged PRs and is the root cause of stale worktrees
going undetected):

```bash
gh pr list --repo <owner>/<repo> --head <branch-name> --state all --json number,state,mergedAt,url
```

Then apply these transitions without asking, reporting each one:
- PR state is `MERGED` → transition ticket to Done, flag worktree as **stale** (auto-clean: transition + remove)
- Status is `Todo` or `Open` (no PR or open PR) → transition to `In Progress`
- Status is `Todo`, `Open`, or `In Progress` and an **open PR exists** → transition to `In Review`
- Status is already `In Review` or `Done` with no merged PR → leave as-is

For any worktree flagged as stale (merged PR found), immediately run the `/worktree done` cleanup
flow: transition ticket to Done and remove the worktree (using `--force` if only artifacts remain).

Print a table with columns:

| Worktree Path | Branch | Ticket | Status | Summary |
|---|---|---|---|---|
| /path/to/wt | SDK-123-feature | SDK-123 | In Progress | Add new endpoint |
| /path/to/main | main | — | — | (no ticket) |

- Highlight tickets whose status is `Done` but the worktree still exists (stale worktrees).
- If a ticket from the JIRA search has **no** worktree, note it at the bottom:
  `Tickets with no worktree: SDK-456 (In Progress) — "Fix pagination bug"`

---

## `/worktree add <branch> [path]`

Creates a new worktree and transitions the associated JIRA ticket to In Progress.

### Step 1 — Parse arguments

- `$target` is the branch name (required). If not provided, ask the user.
- An optional second argument is the worktree path. If omitted, default to
  `<repo-root>-worktrees/<branch-name>` (a `<repo-name>-worktrees` directory
  sibling to the repo root, grouping all worktrees for that repo together).

### Step 2 — Extract the JIRA ticket ID

Apply the regex `[A-Z][A-Z0-9]+-\d+` to the branch name.
If no ticket ID is found, skip all JIRA steps and proceed to create the worktree only.

### Step 3 — Fetch the ticket

```bash
acli jira workitem view <TICKET-ID> --json
```

Extract `fields.summary` and `fields.status.name`. Report what will happen:
```
Creating worktree for SDK-123 — "Add new endpoint" (Todo → In Progress)
```

If the ticket is already In Progress, note it and skip the transition (don't double-transition).
If the ticket is Done, note that it's unusual but proceed without asking.

### Step 4 — Create the worktree

```bash
git worktree add <path> -b <branch>
```

If the branch already exists remotely, use:
```bash
git worktree add <path> <branch>
```

If creation fails, show the error and stop — do not transition the ticket.

### Step 5 — Transition the JIRA ticket to In Progress

Only runs if the worktree was created successfully.

```bash
acli jira workitem transition --key <TICKET-ID> --status "In Progress"
```

If the transition fails (status name not found in this project):
- Show the error and list available statuses from `acli jira workitem view <ID> --json`.
- Ask the user which status to use, then retry.

Do **not** silently swallow transition failures.

### Step 6 — Gather clarifying information before implementing

Fetch the full ticket description and any linked tickets:

```bash
acli jira workitem view <TICKET-ID> --json
```

Read `fields.description`, `fields.comment.comments`, and `fields.issuelinks` from the JSON.

Then read the relevant parts of the codebase to understand what already exists (e.g. how other
languages implement the same feature, what patterns are used, what files are likely to change).

Based on the ticket description and codebase context, identify any ambiguities that would
materially affect the implementation — scope, behaviour edge cases, which files to touch,
whether to follow an existing pattern or introduce something new. Ask all of these as a
**single grouped message** before writing any code. Do not ask about things that are clearly
answered by the ticket or codebase.

Wait for the user's answers before proceeding to Step 7.

### Step 7 — Implement the ticket

Work inside the new worktree directory. Follow all code standards from CLAUDE.md.
Implement the ticket based on the description, user answers from Step 6, and codebase patterns.

When complete:

```bash
# Stage and commit
git add <relevant files>
git commit -m "<conventional commit message referencing ticket ID>"

# Push
git push origin <branch>

# Create PR
gh pr create \
  --title "<short title> (<TICKET-ID>)" \
  --body "..." \
  --base develop
```

After creating the PR, immediately verify its tracking branch (MANDATORY):

```bash
gh pr view --json baseRefName,headRefName,url
```

If `baseRefName` is not `develop` (or your intended base), stop and report to the user before proceeding.

The PR body should follow the repo's existing PR template (check for `.github/pull_request_template.md`).
Include a link to the JIRA ticket in the PR body.

Once the PR is created, transition the JIRA ticket to In Review:

```bash
acli jira workitem transition --key <TICKET-ID> --status "In Review"
```

If the transition fails, surface available statuses and ask the user which to use.

### Step 8 — Confirm and show updated list

Report what was done:
- Worktree created at `<path>` on branch `<branch>`
- JIRA ticket transitioned to In Progress
- Implementation complete
- PR created: `<url>`

Then automatically run the `/worktree list` sweep so the user sees the updated state.

---

## `/worktree done [branch-or-path]`

Marks a worktree as finished: checks/merges the PR, transitions the JIRA ticket to Done,
and removes the worktree.

### Step 1 — Identify the target worktree

- If `$target` is provided, match it against worktree paths or branch names from `git worktree list --porcelain`.
- If no target is given and the user is inside a worktree, use the current worktree.
- If ambiguous, ask the user to clarify.

### Step 2 — Extract the JIRA ticket ID

Apply the same regex from the list command: `[A-Z][A-Z0-9]+-\d+`.
If no ticket ID is found in the branch name, skip all JIRA steps — proceed to PR/worktree removal only.

### Step 3 — Check the PR status

**Before anything else: verify the tracking branch (MANDATORY).**

```bash
gh pr list --head <branch-name> --json number,baseRefName,headRefName,state,url
```

Confirm `baseRefName` is the expected target branch. If it is not, stop and report to the user.

Determine the PR state:
- **Merged** → proceed directly to JIRA transition and worktree removal.
- **No PR found** → check if the branch was merged directly into develop:
  ```bash
  git log --oneline origin/develop | grep -i "<branch-name or ticket-id>"
  ```
  If found in develop history → treat as merged and proceed.
  If not found → inform the user the branch does not appear to be merged, and stop. Do not remove the worktree or transition the ticket.
- **Open** → show the PR title and URL. Ask the user: merge now, or skip merging and just clean up?
  - If merging: `gh pr merge <number> --merge` (or `--squash` / `--rebase` if the user prefers).
  - Wait for the merge to complete before continuing.
- **Closed (not merged)** → note that the PR was closed without merging. Ask the user whether to proceed anyway before removing the worktree or transitioning the ticket.

### Step 4 — Transition the JIRA ticket to Done

Only runs once the branch is confirmed merged into develop.

```bash
acli jira workitem transition --key SDK-123 --status "Done"
```

If the ticket is already `Done`, skip the transition silently.

If the transition fails (e.g. status name doesn't exist in this project):
- Show the error message.
- Run `acli jira workitem view SDK-123 --json` and list the available transition names from
  `transitions[]`.
- Ask the user which status to use, then retry.

Do **not** silently swallow transition failures.

### Step 5 — Remove the worktree

Only runs once the branch is confirmed merged into develop (same gate as Step 4).

```bash
git worktree remove <worktree-path>
```

If the worktree has uncommitted changes, `git worktree remove` will refuse. In that case:
- Run `git -C <worktree-path> status --short` to list the modified/untracked files.
- If **every** listed file is an auto-generated artifact (e.g. `node_modules/`, `package-lock.json`,
  `*.lock`, `dist/`, `build/`, `__pycache__/`, `.venv/`, `target/`, `vendor/`), use `--force`
  without asking — these files carry no work and can be regenerated.
- Otherwise, show the non-artifact files and ask the user: stash, discard, or abort.
- Do **not** use `--force` for worktrees with real uncommitted work without explicit user confirmation.

### Step 6 — Confirm completion

Report what was done:
- Branch merged (or already merged)
- JIRA ticket transitioned to Done (or already Done / skipped)
- Worktree removed

---

## Notes

- JIRA ticket IDs are extracted from branch names only — not from commit messages or PR titles.
- A worktree without a JIRA ticket in its branch name is valid; JIRA steps are silently skipped.
- **Never ask for confirmation before transitioning ticket statuses** — just do it and report what was done.
- If a transition status name fails, surface available statuses and ask — never silently swallow errors.
- `git worktree list` must be run from inside a git repository. If the cwd is not a git repo,
  ask the user for the repo path before proceeding.
- A `WorktreeCreate` hook in `~/.claude/settings.json` automatically triggers the list sweep
  whenever a worktree is created outside of `/worktree add` (e.g. raw `git worktree add` via Bash).

---

## MANDATORY: Check Tracking Branch Before Any PR Change

**This rule is absolute and has no exceptions.**

Before making ANY change to a PR — pushing commits, merging, updating the base, closing — you
MUST verify the PR's tracking (base) branch:

```bash
gh pr view <number> --json baseRefName,headRefName,url
```

Confirm `baseRefName` is the branch you expect (typically `develop`, or the stacked base branch
for stacked PRs). If it does not match what you expect, **stop immediately** and report the
discrepancy to the user before touching anything. Do not assume; do not proceed.

This check applies to every subcommand (`add`, `done`, `list` auto-sync merges) and to any ad-hoc
PR interaction triggered during the skill's execution. No PR interaction bypasses this gate.
