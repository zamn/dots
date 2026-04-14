---
name: acli
description: This skill should be used when the user asks to interact with any atlassian product- jira, confluence, etc.
version: 1.0.0
---

# ACLI Skill

## Overview

Uses the `acli` command line to create, list, delete, update information from atlassian products.

## Process

Analyse the request and decide which atlassian product to use. If the request satisfies multiple then use multiple products.

#### JIRA

If creating a JIRA ticket always assign it to the authenticated user. Give the ticket a well thought out description but be succint and err on the side of caution when attempting to infer additional details.
- If the ticket is talking about a certain part of the codebase, use the `gh` (github) CLI to link to the file or directory that is relevant.
  - This is useful if linking to parts of the codebase as reference points rather than what files to directly modify (you can try to figure this out but again err on side of caution).

If the request can be done in a better way, ask the user if they would like to do things that way.
