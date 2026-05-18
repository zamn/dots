---
name: acli
description: This skill should be used when the user asks to interact with any atlassian product- jira, confluence, etc. Trigger phrases include: "create a ticket", "jira ticket", "create subtasks", "break this ticket down", "view issue", "update ticket", "link to ticket", any mention of a Jira issue key (e.g. SDK-1234), "confluence page", or any request to read/write Jira or Confluence. Use `acli jira workitem view <KEY>` to fetch ticket details.
version: 1.0.0
---

# ACLI Skill

## Overview

Uses the `acli` command line to create, list, delete, update information from atlassian products.

## CLI Reference

```bash
acli jira workitem view <KEY>          # View a ticket
acli jira workitem create [flags]      # Create a ticket
acli jira workitem edit <KEY> [flags]  # Edit a ticket
acli jira workitem search [flags]      # Search tickets
acli jira workitem link [flags]        # Link tickets
```

Key `create` flags: `--project`, `--type`, `--summary`, `--description`, `--assignee`, `--parent`, `--label`

**Important**: Use `--type "Sub-task"` (not "Task") when creating child tickets under a parent. Task-under-Task hierarchy is rejected by the API.

## Process

Analyse the request and decide which atlassian product to use. If the request satisfies multiple then use multiple products.

#### JIRA

If creating a JIRA ticket always assign it to the authenticated user. Give the ticket a well thought out description but be succint and err on the side of caution when attempting to infer additional details.
- If the ticket is talking about a certain part of the codebase, use the `gh` (github) CLI to link to the file or directory that is relevant.
  - This is useful if linking to parts of the codebase as reference points rather than what files to directly modify (you can try to figure this out but again err on side of caution).

If the request can be done in a better way, ask the user if they would like to do things that way.
