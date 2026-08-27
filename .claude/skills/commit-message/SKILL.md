---
name: commit-message
description: >
  Ultra-compressed commit message generator. Cuts noise from commit messages
  while preserving intent and reasoning. Subject ≤50 chars, body only when "why"
  isn't obvious. Use when user says "write a commit", "commit message",
  "generate commit", "/commit", or invokes /commit-message. Auto-triggers when
  staging changes
  ---

Write commit messages terse and exact. No fluff.  Why over what. Add body only
if requested by operator/user.


## Rules

**Subject line (technical requirements):**

- pattern: `<subject>: <action> <description>`
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
- ≤50 chars when possible, hard cap 72
- No trailing period
- No capitalization after the colon

**Determining `<subject>`:** the subject is the distilled **ONE WORD** thing
that was mostly changed — Component, Service, Feature, File, Module, Page, etc. Infer it
from the files changed and the scope of the modification. Examples of good
names: `Button`, `UserStore`, `BiblioPage`, `AllocationService`, `Instructions`,
`API`.  PascalCase.

**ONLY** when the subject cannot be identified form the the change context, use
the types as fallback: Feat: Bugfix: Refactor: Perf: Docs: Test: Chore: Build:
CI: Style: Revert:

**Body (technical requirements):**

- The body explains **what** and **why**, not **how** (the diff already shows how)
- Wrap at 72 chars
- Bullets `-` not `*`

**What NEVER goes in:**

- "This commit does X", "I", "we", "now", "currently" — the diff says what
- "As requested by..." — use Co-authored-by trailer
- "Generated with Claude Code" or any AI attribution — unless the user's own
  rule requires an `Assisted-by`/AI-attribution trailer, then add it as a trailer
- Emoji (unless project convention requires)
- Restating the file name when scope already says it

## Examples

### Subject lines

```console
Button: add color property
```

```console
UserStore: fix role fetching algorithm
```

```console
AllocationService: fix Config import
```

```console
BiblioPage: fix test id position
```

```console
API: add caching to user profile
```

### Component change with warranted body

```console
AuthService: add JWT authentication

Implements JWT-based authentication for the application. Users can now
log in with email/password and receive a token that expires after 24h.

- Login/logout endpoints
- Token validation middleware
- Session management in Redux store
- Protected route wrapper component
```

### Bugfix with context

```console
ApiDossiersContent: align types with API schema

The API response schema was updated but the frontend types were not
synchronized, causing runtime type errors when processing dossier data.
This commit updates the TypeScript interfaces to match the current API
contract.

- Updated DossierContent interface
- Fixed property names to match snake_case API response
- Added missing optional fields
```

### Bugfix with no single component (type prefix)

```console
Bugfix: fix race condition in reducer state synchronization

Multiple unrelated reducers read and wrote overlapping state during
the same dispatch cycle, causing intermittent stale-state bugs with
no single component responsible.

- Serialized state updates within a single dispatch
- Removed direct cross-reducer state reads
```

### Refactor with reasoning

```console
Refactor: replace StatefulPopover with StatefulTooltip

Replaces StatefulPopover with StatefulTooltip in CollapsedTags and
LimitDate components for better UX and consistency with design system.

StatefulTooltip provides better positioning logic, more consistent
styling, a simpler API, and better accessibility. This change reduces
complexity and aligns with the design system's component guidelines.
```

## Boundaries

Only generates the commit message. Does not run `git commit`, does not stage
files, does not amend. Output the message as plain text, no code fences. "stop
caveman-commit" or "normal mode": revert to verbose commit style.
