---
name: test-open-prs
description: >
  Pull every open PR authored by the current user in the current repo, merge them all into a
  throwaway local branch on top of the latest default branch, then (re)create docker containers
  from the repo's compose files. The temp branch is never pushed.
  Trigger phrases: "test my open prs", "test open prs", "merge my prs", "combine my prs",
  "pull all my prs", "integration test my prs", "spin up containers with my prs",
  "test all my prs together", "stack my open prs locally".
version: 1.0.0
---

# Test Open PRs Skill

Combines every open PR authored by the current user into a single throwaway local branch on top
of the latest default branch and brings up the project's docker containers against it. Useful for
locally validating that a stack of in-flight PRs work together end-to-end. The temp branch is
**never pushed**.

## Configured policy (do not re-ask)

- **Conflict handling:** attempt automatic resolution first, fall back to the user when stuck.
- **Compose files:** prefer the project's canonical dev set when one is discoverable
  (an `npm`/`pnpm`/`make` target that already chains `-f` flags, or an obvious `*.override.yml`
  partner to `docker-compose.yml`). Otherwise auto-detect all `docker-compose*.y{a,}ml` in the
  repo root. Either way, **report the chosen set** in the final summary so the deviation is
  visible.
- **Temp branch:** leave it around after exit; switch the user back to their original branch.
- **Base branch:** the repo's default branch (`gh repo view --json defaultBranchRef`).
- **Docker action:** `up -d --build --force-recreate` (no `down` first).
- **Dirty working tree:** stop and report. Do not stash without asking.

---

## Step 1 — Preflight

Verify the environment before touching anything. If any check fails, stop and report.

```bash
# In a git repo?
git rev-parse --show-toplevel

# Clean working tree? (must produce zero output)
git status --porcelain

# Tools available?
gh auth status
docker compose version
```

Single-line preflight summary check:
`git rev-parse --show-toplevel >/dev/null && [ -z "$(git status --porcelain)" ] && gh auth status >/dev/null && docker compose version >/dev/null`

If `git status --porcelain` is non-empty, **stop**. Report the dirty files and tell the user to
commit or stash before re-running. Do not stash for them.

Remember the original branch:

```bash
git rev-parse --abbrev-ref HEAD
```

Save this — you'll restore it at the end.

---

## Step 2 — Discover PRs and base branch

```bash
# Repo default branch
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name

# Current user's open PRs in this repo
gh pr list --author @me --state open \
  --json number,title,url,mergeable,mergeStateStatus
```

`gh pr list` is already scoped to the cwd's repo, so no fork filtering is needed — and PRs from
forks merge fine via the `pull/<n>/head` ref used in Step 5.

If the list is empty, stop and report: `No open PRs authored by @me in <owner>/<repo>. Nothing to do.`

Show the user the discovered set before proceeding:

```
Default branch: develop
Found 3 open PRs (all merged onto develop):
  #1277  "Support TS SDK generation from GraphQL"
  #1281  "Tighten TS schema mapper nullability"
  #1284  "Fix Ruby auth header passthrough"
```

Order the PRs by number ascending (oldest first) — older PRs are more likely to be ancestors of
newer ones in stacked workflows, which reduces merge conflict surface area.

---

## Step 3 — Sync the base branch

```bash
git fetch origin <base>
```

The temp branch will be created from `origin/<base>` directly, so you do **not** need to fast-forward
the local copy of the base branch. Leaving it untouched avoids accidentally clobbering local state
on the user's checkout of `develop`/`main`.

---

## Step 4 — Create the temp branch

Generate a timestamped branch name. Use `date +%s` (epoch seconds) so the name is unique and
contains no characters that need escaping:

```bash
TEMP_BRANCH="temp/test-prs-$(date +%s)"
git checkout -b "$TEMP_BRANCH" "origin/<base>"
```

Single-line: `TEMP_BRANCH="temp/test-prs-$(date +%s)" && git checkout -b "$TEMP_BRANCH" "origin/<base>"`

Report the temp branch name to the user — they'll need it later to re-inspect the merged state.

---

## Step 5 — Merge each PR

For each PR in the ordered list, fetch the PR head via GitHub's universal `pull/<n>/head` ref —
this works for both same-repo and fork PRs without needing the head branch name:

```bash
git fetch origin "pull/<number>/head"
git merge --no-ff -m "Merge PR #<number>: <title>" FETCH_HEAD
```

Single-line per PR:
`git fetch origin "pull/<n>/head" && git merge --no-ff -m "Merge PR #<n>: <title>" FETCH_HEAD`

### Conflict handling

If `git merge` exits non-zero with conflicts:

1. **Inspect the conflicts:**
   ```bash
   git status --short | grep '^UU\|^AA\|^DD\|^AU\|^UA\|^UD\|^DU'
   git diff --name-only --diff-filter=U
   ```

2. **Attempt automatic resolution** in this priority order:
   - **Lockfiles** (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Gemfile.lock`, `poetry.lock`,
     `go.sum`, `Cargo.lock`): accept theirs, then regenerate.
     ```bash
     git checkout --theirs <lockfile>
     git add <lockfile>
     # Then regenerate after the merge commits, in Step 6 prep:
     # npm install / yarn / bundle install / etc. as appropriate for the repo
     ```
   - **Both-sides-added imports / both-sides-added enum entries / both-sides-added test cases:**
     read the conflict markers, produce the union of both sides, and write the resolved file.
   - **Generated snapshot files** (under `tests/__snapshots__/`, `tests/snapshot/`, files ending in
     `.snap`): accept theirs and plan to regenerate after.
   - **Whitespace-only conflicts**: accept either side and add.

3. **For anything else** — overlapping logic edits, schema/contract changes, anything where the
   intent isn't mechanically obvious — **stop and ask the user**. Show:
   - The PR number/title being merged
   - The conflicted files
   - The conflict hunks (`git diff` of the conflicted region)
   - Three options: resolve manually now, skip this PR (`git merge --abort` and continue), or
     abort the whole skill (`git merge --abort && git checkout <original-branch> && git branch -D $TEMP_BRANCH`).

4. **After resolving:**
   ```bash
   git add <resolved files>
   git -c core.editor=true merge --continue
   ```

5. **If the user chose "skip this PR":** record the skipped PR number/title for the final report
   and continue with the next PR in the list. Do **not** silently skip without telling the user.

### Snapshot/lockfile regeneration

If any lockfiles or snapshot files were resolved with `--theirs`, regenerate them after **all**
PRs are merged but before docker comes up:

```bash
# Only if the repo has these — check first
[ -f package.json ] && npm install
[ -f Gemfile ] && bundle install
# Snapshots: only if explicitly invalidated. Defer to user — don't auto-run the full test suite.
```

If regeneration changes files, amend them into a single follow-up commit on the temp branch:

```bash
git add -A && git commit -m "regen lockfiles/snapshots after PR merges"
```

---

## Step 6 — (Re)create docker containers

### 6a. Pick the compose set

Start by listing every compose file in the repo root:

```bash
ls docker-compose*.yml docker-compose*.yaml 2>/dev/null
```

Single-line: `ls docker-compose*.yml docker-compose*.yaml 2>/dev/null`

If there are **two or fewer** files (e.g. `docker-compose.yml` + an obvious `*.override.yml`),
use them all — that's the trivial case.

If there are **three or more** files, treat the list as a menu, not a checklist. Many projects
ship alternate compose overrides for non-default scenarios (e.g. `docker-compose.headroom.yml`,
`docker-compose.<feature>-test.yml`) that **don't belong in a normal dev bring-up**. Composing
them together can shadow services, mount volumes the dev path doesn't expect, or simply fail to
start. Pick the canonical dev set instead:

1. **Look for the project's existing convention** before guessing. In priority order:
   - An `npm`/`pnpm` script whose body invokes `docker compose -f <a>.yml -f <b>.yml …`. Common
     names: `dev:local`, `dev`, `up`, `start:local`. `jq '.scripts' package.json | grep "docker compose"`.
     If you find one, **use the exact `-f` set it uses**.
   - A `Makefile` target with the same chain (`grep -E "docker compose -f" Makefile`).
   - A `docker-compose.override.yml` partner to `docker-compose.yml` — compose treats it
     specially (auto-merged when no `-f` is given), so the canonical set is just those two.
2. **Fall back to "all files"** only when none of the above turn up a convention. At that point
   it's the user's problem if alternate overrides collide.
3. **Always report the chosen set** in the final summary, including which files were available
   and which you skipped, so the user can correct you on the next invocation.

### 6b. Bring it up

Build the `docker compose` invocation with one `-f` flag per file in the chosen set:

```bash
docker compose -f docker-compose.yml [-f docker-compose.override.yml ...] up -d --build --force-recreate
```

Single-line example: `docker compose -f docker-compose.yml up -d --build --force-recreate`

If no compose files are found at all, report that and skip the docker step — do not error.

After `up` returns, surface the running containers so the user can confirm:

```bash
docker compose ps
```

---

## Step 7 — Return to original branch

```bash
git checkout <original-branch>
```

The temp branch (`$TEMP_BRANCH`) is **left in place** — do not delete it. The user can re-checkout
it later to inspect the merged state, run tests, etc.

---

## Step 8 — Report

Print a summary:

```
Temp branch: temp/test-prs-1751234567 (kept locally, not pushed)
Base:        develop @ origin/develop (latest)
Merged PRs:
  - #1281  "Tighten TS schema mapper nullability"     (clean)
  - #1284  "Fix Ruby auth header passthrough"         (auto-resolved package-lock.json)
Skipped PRs:
  - #1277  "Support TS SDK generation from GraphQL"   (user chose skip on conflict in src/foo.ts)
Compose set chosen: docker-compose.yml + docker-compose.localstack.yml
  Available but skipped: docker-compose.headroom.yml, docker-compose.incremental-test.yml
  Reason: matched npm "dev:local" script's -f chain — the others are alternate-scenario overrides
Containers: 4 services up (api, redis, localstack, postgres)
Current branch: <original-branch>

To re-inspect the merged state:  git checkout temp/test-prs-1751234567
To clean up:                     git branch -D temp/test-prs-1751234567
```

---

## Notes

- The temp branch is **never pushed**. Do not `git push` it under any circumstances.
- The skill operates on the repo at the cwd. If the user invokes it from outside a git repo,
  stop in Step 1 and ask which repo.
- "Open PRs by me" uses `gh pr list --author @me --state open`. Drafts are included — they're
  still authored by the user and presumably still worth testing.
- Per-PR base branches are not honored; everything stacks on the repo default branch. If the user
  has stacked PRs whose bases are each other, merging the older one first produces the same result
  as honoring the stack.
- Do not run the test suite automatically. The user invokes this skill to **bring up containers**;
  running tests is a separate decision they can make once the stack is up.
