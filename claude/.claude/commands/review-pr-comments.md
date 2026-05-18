---
description: Review and resolve open PR comments
argument-hint: [pr-url]
---

Review and resolve all open comments on a GitHub pull request.

If a PR URL was provided use it: $ARGUMENTS

Otherwise fall back to the current branch's PR.

## Step 1 — Find the PR

If a URL was provided, extract the PR number from it (e.g. `.../pull/254` → `254`) and the owner/repo from the URL path.

Otherwise detect from the current branch:
```
gh pr view --json number,url,title,headRefName,baseRefName
```

Get OWNER/REPO from: `gh repo view --json nameWithOwner`

## Step 1b — Verify the tracking (base) branch — MANDATORY

**This check is required before any changes are made to the PR.**

```
gh pr view <NUMBER> --json baseRefName,headRefName,url
```

Confirm `baseRefName` matches what you expect (typically `develop`, or the stacked base branch
for stacked PRs). If it does not match, **stop immediately** and report the discrepancy to the
user. Do not push code, reply to comments, or resolve threads until the user confirms the base
is correct.

## Step 1c — Locate worktree and load context (non-blocking)

Find the local worktree for this PR's branch (from `headRefName` in Step 1):

```bash
git worktree list --porcelain
```

Scan for a block whose `branch` field is `refs/heads/<headRefName>`.

- **Match found** → set working directory to that worktree path for all file reads, edits, and
  git commands. Then check the branch name for a JIRA ticket ID (`[A-Z][A-Z0-9]+-\d+`). If
  found, fetch the ticket:
  ```bash
  acli jira workitem view <TICKET-ID> --json
  ```
  Read `fields.summary`, `fields.description`, and `fields.comment.comments` for background
  context. Do **not** transition the ticket status.
- **No match** → note "no local worktree found for this PR" and continue from the repo root.
  This is not an error. Do not block, do not ask.

## Step 2 — Fetch ALL comment sources in parallel

Run all three fetches at once:

**A. Inline review threads (GraphQL):**
```
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: NUMBER) {
      reviewThreads(first: 50) {
        nodes {
          id
          isResolved
          comments(first: 20) {
            nodes {
              databaseId
              author { login }
              body
              path
              line
            }
          }
        }
      }
    }
  }
}'
```

**B. PR-level reviews with bodies (REST):**
```
gh api repos/OWNER/REPO/pulls/NUMBER/reviews
```
These are top-level review summaries (not inline). Process any review whose `body` is non-empty.

**C. General issue comments (REST):**
```
gh api repos/OWNER/REPO/issues/NUMBER/comments
```

Never skip comments based on author — process comments from bots, reviewers, and the PR author equally.

## Step 3 — Process each item that needs attention

**Inline threads (from A):** Process if `isResolved: false`, OR if `isResolved: true` with only 1 comment (resolved but never replied to — reply, skip re-resolving).

**PR-level reviews (from B):** Process every review with a non-empty `body`. These do not have a "resolved" state — always reply.

**Issue comments (from C):** Process every comment. These do not have a "resolved" state — always reply.

For each item, read all comments/body to understand the full context.

**Decision logic:**
- If the fix is clear → make the code change, then proceed to Step 4
- If the fix is unclear or has multiple valid options → stop and ask the user before proceeding
- If no code change is needed (already correct, out of scope, acknowledged, etc.) → skip to Step 4

## Step 4 — Commit and push (only if code was changed)

**NOTE: ONLY COMMIT AND PUSH FOR THIS COMMAND. THIS IS NOT DEFAULT BEHAVIOR AND SHOULD NOT BE A DEFAULT ACTION**

Stage only the files that were modified:
```
git add <specific files>
git commit -m "<concise description of fix>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push
```

## Step 5 — Reply

**For inline thread comments** — reply to the root comment's `databaseId`:
```
gh api repos/OWNER/REPO/pulls/comments/COMMENT_ID/replies \
  --method POST \
  --field body='<explanation>'
```
If that returns 404, fall back to a general issue comment quoting the path and line:
```
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --method POST \
  --field body='Re `PATH` line LINE: <explanation>'
```

**For PR-level reviews and issue comments** — post a general issue comment:
```
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --method POST \
  --field body='<explanation>'
```

## Step 6 — Resolve inline threads

For each inline thread that was `isResolved: false`, resolve it using the GraphQL node ID from Step 2A:
```
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
    thread { isResolved }
  }
}'
```

PR-level reviews and issue comments have no resolve state — skip this step for them.

## Notes

- Bot comments (nitpickybot, gemini, wiz, etc.) are treated the same as human comments
- PR author comments are treated the same as reviewer comments — never skip based on author
- Never use `git add -A` or `git add .` — stage specific files only
