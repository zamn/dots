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
gh pr view --json number,url,title,headRefName
```

## Step 2 — Fetch all review thread data via GraphQL

Use GraphQL to get threads with their node IDs (needed for resolving), resolved status, file/line context, and all comments in each thread:

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

Get OWNER/REPO from: `gh repo view --json nameWithOwner`

## Step 3 — Process each unresolved thread

For each thread where `isResolved: false`, read all comments in it to understand the full context and what's being asked.

**Decision logic:**

- If the fix is clear → make the code change, then proceed to Step 4
- If the fix is unclear or has multiple valid options → stop and ask the user before proceeding
- If no code change is needed (already correct, out of scope, acknowledged, etc.) → skip to Step 4

## Step 4 — Commit and push (only if code was changed)

Stage only the files that were modified:
```
git add <specific files>
git commit -m "<concise description of fix>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push
```

## Step 5 — Reply to the thread

Reply to the root comment of each thread (first comment's `databaseId`):

```
gh api repos/OWNER/REPO/pulls/comments/COMMENT_ID/replies \
  --method POST \
  --field body='<explanation of what was done or why no change was needed>'
```

## Step 6 — Resolve the thread

Use the thread's GraphQL node ID from Step 2:

```
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
    thread { isResolved }
  }
}'
```

## Notes

- Process threads that were already resolved but have no reply — reply but skip re-resolving
- Bot comments (nitpickybot, gemini, etc.) are treated the same as human comments
- General PR issue comments (`/issues/NUMBER/comments`) do not have threads to resolve — reply only
- Never use `git add -A` or `git add .` — stage specific files only
