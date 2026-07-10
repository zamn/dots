---
description: Read, address, reply to, and resolve review comments on a GitHub PR
argument-hint: [pr-url-or-number]
---

Review and address comments on the current branch's GitHub pull request.

If a PR URL or number was provided, use it: $ARGUMENTS

## Scope

- Use GitHub via the `gh` CLI.
- If no PR argument is provided, detect the PR for the current branch.
- If the PR branch has a matching local worktree, use that worktree.
- If no matching worktree exists, continue from the current repo root. Missing worktree is not a blocker.
- Address unresolved review threads and actionable issue comments.
- If the PR has merge conflicts, fix them as part of this command before finalizing.

## Step 1 - Resolve the PR

If an argument was provided, resolve it:

```bash
gh pr view <pr-url-or-number> --json number,url,title,headRefName,baseRefName,author,mergeStateStatus,mergeable
```

Otherwise resolve the current branch's PR:

```bash
gh pr view --json number,url,title,headRefName,baseRefName,author,mergeStateStatus,mergeable
```

Also get the repo:

```bash
gh repo view --json nameWithOwner
```

## Step 2 - Prefer the PR worktree when available

Find a matching local worktree for `headRefName`:

```bash
git worktree list --porcelain
```

If a block has `branch refs/heads/<headRefName>`, run all subsequent file edits and git commands from that `worktree` path.

If no match exists, continue in the current repo root. Report that no worktree was found, but do not stop.

## Step 3 - Sync and check conflicts

Fetch the base branch and PR head:

```bash
git fetch origin <baseRefName>
git fetch origin <headRefName>
```

Check whether the PR is conflicted or dirty:

```bash
gh pr view <number> --json mergeStateStatus,mergeable
git status --short
```

If the PR has merge conflicts, fix them before resolving comments. Merge or rebase onto the latest base branch according to the repo's normal workflow. If the conflict cannot be resolved mechanically, ask the user with the conflicted files and the choices.

## Step 4 - Fetch review threads and comments

Fetch unresolved review threads with GraphQL:

```bash
gh api graphql -f owner='<owner>' -f name='<repo>' -F number=<number> -f query='
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          originalLine
          comments(first: 50) {
            nodes {
              id
              databaseId
              author { login }
              body
              url
              createdAt
            }
          }
        }
      }
    }
  }
}'
```

Also fetch issue comments for non-inline actionable feedback:

```bash
gh api repos/<owner>/<repo>/issues/<number>/comments
```

Ignore resolved review threads unless the user explicitly asks to revisit them.

## Step 5 - Decide and act

For each unresolved thread or actionable comment:

- If it asks for a valid code change, make the smallest correct change.
- If it is already addressed by current code, prepare a reply explaining why.
- If it is wrong, prepare a reply explaining the evidence.
- If the right resolution is unclear, stop and ask the user. If multiple valid fixes exist, ask which one to take.
- Do not invent intent from ambiguous feedback.

If code changed, run the relevant focused checks for the touched area. Then commit and push:

```bash
git status --short
git add <changed-files>
git commit -m "Address PR review comments"
git push origin <headRefName>
```

Use a more specific commit message when the change has a clear scope.

## Step 6 - Reply and resolve

For every handled review thread, reply with the resolution, then resolve the thread.

Reply to a review comment:

```bash
gh api repos/<owner>/<repo>/pulls/comments/<comment-database-id>/replies -f body='<reply>'
```

Resolve the thread:

```bash
gh api graphql -f threadId='<thread-id>' -f query='mutation($threadId: ID!) { resolveReviewThread(input: {threadId: $threadId}) { thread { id isResolved } } }'
```

For issue comments, reply with a normal PR comment when needed:

```bash
gh pr comment <number> --body '<reply>'
```

When commenting through Adam's GitHub account, include this footer:

```text
Sent by Claude on behalf of Adam
```

## Step 7 - Verify and report

After pushing and resolving comments, verify PR state:

```bash
gh pr view <number> --json url,mergeStateStatus,mergeable,reviewDecision,statusCheckRollup
```

Report:

- PR URL
- Comments handled
- Code changes made
- Commit pushed, if any
- Checks run
- Remaining unresolved or unclear comments
