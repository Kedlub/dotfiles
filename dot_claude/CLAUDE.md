# Claude Code User Settings

## Research First — Always Look Things Up

Internal model knowledge goes stale quickly. When working with any library,
framework, API, cloud service, or tool — even well-known ones — always look up
current docs and behavior before writing code or giving advice.

- **context7**: Use for library/framework documentation, API syntax, config
  options, version migration, and CLI usage. Prefer this over web search for
  anything that has published docs.
- **Exa**: Use for broader web research — blog posts, changelogs, GitHub
  issues, Stack Overflow, release announcements. Returns clean LLM-optimized
  content and uses less context than fetching pages manually. Prefer over
  WebSearch; only fall back to WebSearch if Exa doesn't have it.

When to look things up (non-exhaustive):
- Using a library/tool you haven't touched yet in this session
- Writing integration code against an external API or service
- Debugging behavior that might stem from a version change
- Answering a question about current best practices or defaults
- Any time you're about to say "I believe" or "IIRC" — look it up instead

## Agent-Portable Project Instructions — Prefer AGENTS.md

Keep project instructions accessible to every coding agent, not just Claude
Code. `AGENTS.md` is the open, cross-tool standard (read by Claude Code, Codex,
Cursor, Copilot, Gemini, Aider, and others); `CLAUDE.md` is Claude-specific.
Claude Code reads `CLAUDE.md`, **not** `AGENTS.md`, natively — so bridge the two
rather than duplicating content.

**Respect the repo's existing convention first.** Before creating or editing any
instruction file, check what's already there and which file is the source of
truth — don't impose the default below on a project that already has a working
setup. Tells to look for:
- A symlink (`CLAUDE.md → AGENTS.md` or the reverse) — edit the real target.
- An `@`-import chain — edit the file that holds the actual content.
- A manually duplicated copy (e.g. `CLAUDE.md` is the source and `AGENTS.md` is
  a hand-maintained copy git-ignored via `.git/info/exclude` or `.gitignore`).
  Here, edit the source and re-sync the copy; don't convert it to a symlink/
  import unless asked.
When the source is ambiguous, check `git log`/`.gitignore`/`.git/info/exclude`
and the symlink status (`ls -l`) before writing, and ask if still unclear.

The guidance below is the **default for greenfield projects** with no existing
convention. When creating a new project, or when asked to create/init a
project's `CLAUDE.md`:
- **Write the real instructions in `AGENTS.md` at the repo root**, never in a
  standalone `CLAUDE.md`.
- **Bridge `CLAUDE.md` to it** using one of:
  - **Symlink (preferred default on macOS/Fedora):** `ln -s AGENTS.md CLAUDE.md`
    — both platforms support symlinks, so the two files stay identical with zero
    maintenance.
  - **Import:** create `CLAUDE.md` containing `@AGENTS.md` on its own line. Use
    this when you want Claude-specific notes *in addition to* the shared content
    — put them below the import.
- In a monorepo, place a nested `AGENTS.md` in each package; agents read the
  nearest file in the tree (closest wins). Bridge each with its own symlink/
  import only if a tool there needs `CLAUDE.md`.

`@import` mechanics: `@path/to/file` resolves relative to the file containing
it; `~` and absolute paths work; max 4 hops deep. The first external import in a
project triggers a one-time approval dialog.

Keep `AGENTS.md` concise (aim under ~150 lines) and cover the high-value areas:
exact build/test/lint/run commands, testing conventions, project structure,
code style, git/PR/commit conventions, security gotchas, and a "do not touch"
boundaries list (generated files, secrets, vendored code, migrations). Use real
copy-pasteable commands, not placeholders — agents auto-run the test/lint
commands they find. Link out to deeper docs rather than inlining everything, and
update it in the same change that alters build/test/structure.

For Claude-only features that don't belong in the shared file (skills, hooks,
settings), use `.claude/` and `CLAUDE.local.md`, not `AGENTS.md`.

## Preferred CLI Tools

Builtin tools come first. For searching, finding, and reading files, the builtin
`Grep` (ripgrep under the hood), `Glob`, and `Read` tools beat shelling out —
they return structured results, avoid shell-quoting pitfalls, and don't spend
tokens on ANSI color. Reach for the CLI tools below when a builtin doesn't cover
the case (shell pipelines, type/time filters, exec-per-result) or for the user's
own interactive terminal.

### File Search and Navigation
- **Grep tool**: Prefer the builtin `Grep` tool for content search; it runs
  ripgrep under the hood. Drop to `rg` in Bash only for flags the tool doesn't
  expose.
- **fd**: Prefer the builtin `Glob` tool for finding files by name or path
  pattern. Reach for `fd` when you need more than name matching — type filters,
  modification time, or `-x` to run a command per result.
  - Respects .gitignore by default
  - Example: `fd -e py` or `fd pattern --changed-within 1d`

### System Analysis
- **dua (Disk Usage Analyzer)**: Faster `du` for analyzing disk space
  - Example: `dua /path` for non-interactive aggregate sizes

### File Listing
- **eza**: Enhanced `ls` (git status, tree view via `eza --tree`). Use the
  `Glob`/`Read` tools when inspecting files for myself.

### JSON, YAML, and HTTP
- **jq**: Use for JSON processing in shell pipelines
  - Example: `cat package.json | jq '.dependencies'`
- **yq**: Use for YAML/TOML processing in shell pipelines
  - Example: `yq '.services' docker-compose.yml`
- **xh**: Use instead of `curl` for HTTP requests
  - Simpler syntax, JSON by default
  - Example: `xh GET api.example.com/data`

### Code Analysis
- **tokei**: Use for quick codebase statistics (lines of code by language)
  - Example: `tokei src/`

### Benchmarking
- **hyperfine**: Use for benchmarking and comparing command performance
  - Example: `hyperfine 'command_a' 'command_b'`

### JS/TS Linting and Formatting
- **biome**: Prefer over eslint/prettier when a project has no existing eslint config
  - Also use for standalone / solo JS/TS files
  - If a project already has eslint configured, use eslint instead
  - Example: `biome check --write file.ts`

### Python
- **uv**: Prefer for Python workflows unless the project clearly uses another
  tool or package manager
  - Use `uv run` for one-off inline scripts, adding temporary dependencies
    with `--with` as needed
  - Use `uv run` for standalone script files, declaring dependencies with
    PEP 723 metadata headers when required
  - Use `uv` for `pyproject.toml`, dependency, virtual environment, and Python
    version management when there is no conflicting project convention

### Node Version Management
- **fnm**: Node version manager in use (not nvm/asdf). It reads `.nvmrc` /
  `.node-version`.
  - Auto-switching is `--use-on-cd`, a shell `chpwd` hook that only fires on an
    *interactive* `cd`. A `cd <dir> && ...` baked into a non-interactive command
    (the kind agents run) does NOT trigger it — the shell stays on fnm's default
    Node, which can be a newer major than the project pins.
  - Symptom of the wrong version: tests/builds fail in ways the project doesn't
    expect (e.g. experimental-API differences like `localStorage.getItem is not
    a function` under a too-new Node).
  - Fix: prefix project commands with `fnm use` so it resolves the nearest
    version file, e.g. `cd path/to/pkg && fnm use && npm run test`. Persisted-cwd
    shells started inside the pinned dir resolve correctly on their own, but
    `fnm use` is the bulletproof guard.

## Code Comments

Write comments sparingly and keep them compact. Default to letting clear
names and straightforward code speak for themselves — don't narrate what the
code already says.

Add a comment only where it earns its place:
- Non-obvious or complex logic that isn't clear from reading it
- A fix or workaround for an edge case, bug, or platform quirk — note the *why*
- A deliberate non-obvious choice, tradeoff, or constraint
- A warning about a gotcha or non-obvious side effect

Avoid:
- Restating the code ("increment i", "loop over items")
- Section banners and decorative dividers
- Commentary on the change/diff itself ("renamed from foo", "now also handles")
  — that belongs in the commit message, not the code
- Redundant docstrings on self-explanatory functions

Keep them short — prefer a single concise line over a paragraph. Match the
surrounding file's existing comment style and density.

## Git Commit Preferences

Follow the 50/72 conventional commit format:
- Title: Maximum 50 characters
- Description: Maximum 72 characters per line
- No formatting (no markdown, no bullet points)
- Plain text only in commit messages

## Pull Requests — Be Careful with Issue-Closing Keywords

GitHub auto-closes a linked issue when a PR merges if the description (or any
commit) contains a closing keyword: `close`/`closes`/`closed`, `fix`/`fixes`/
`fixed`, `resolve`/`resolves`/`resolved` followed by an issue reference (`#123`,
`owner/repo#123`, or a full issue URL). Treat these as side-effectful — don't
emit them by default.

- **Do not** use closing keywords to link an issue unless the user has
  explicitly approved or requested it for that specific PR. An issue is often
  broader than a single PR; closing it on merge is frequently wrong.
- When you want to reference an issue for context, use a **non-closing** form
  instead: plain `#123`, `Ref #123`, `Related to #123`, `Part of #123`, or
  `See #123`. These link without triggering auto-close.
- This applies to the PR **description/body**, and also to commit messages,
  since GitHub honors closing keywords in commits too.

**Pre-process plans before attaching them to a PR.** When a plan, task list, or
notes get embedded into a PR description, scan the text first and neutralize any
incidental closing keyword + issue reference (e.g. a checklist line like
"Fixes #42") so it doesn't silently close an issue on merge. Rewrite to a
non-closing form or drop the reference. If a plan legitimately should close an
issue, confirm with the user before keeping the keyword.

## Planning and Brainstorming

When in plan mode or generally planning/brainstorming, use an interview-style
approach: ask questions using the AskUserQuestion tool to collaboratively shape
the plan rather than presenting a finished plan upfront. Iterate through
questions to refine requirements, constraints, and design decisions together.

## Getting My Attention

When you finish responding and are genuinely handing control back to me, call
the `PushNotification` tool with a short, specific message saying what's done or
what you need (I'm often looking elsewhere). That one call covers everything: a
`PreToolUse` hook turns it into a local sound + desktop banner here, and the tool
also pushes to my phone when Remote Control is connected — so it works whether or
not Remote Control happens to be on. There is no Stop-hook sound, because that
fires on every turn-end and can't tell a real handoff from a background resume.

- **Do** ping when: a task is complete, you need my input or a decision, or you
  hit something that blocks further progress.
- **Do NOT** ping when you are about to be auto-resumed — i.e. you launched a
  background subagent or shell (`run_in_background`) and are only ending the
  turn to wait for it. You'll wake yourself; my attention isn't needed yet.
- Permission prompts already ping deterministically via a hook, so you don't
  need to notify for those.

## General Approach
- Assume familiarity with technical concepts and command-line tools
- Provide detailed technical explanations without oversimplification
- Use efficient, modern tooling when available
- Use the project's existing package manager, scripts, formatter, and test
  commands before falling back to global preferences
