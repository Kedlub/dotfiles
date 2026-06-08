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

Use these modern CLI tools instead of their traditional alternatives:

### File Search and Navigation
- **ripgrep (rg)**: Use instead of `grep` for faster, more intelligent searching
  - Respects .gitignore by default
  - Supports regex patterns natively
  - Example: `rg "pattern" --type python`

- **fd**: Use instead of `find` for simpler, faster file discovery
  - More intuitive syntax
  - Respects .gitignore by default
  - Example: `fd "*.py"` instead of `find . -name "*.py"`

### System Analysis
- **dua (Disk Usage Analyzer)**: Use for analyzing disk space
  - Interactive TUI available with `dua interactive` or `dua i`
  - Faster than `du` with better visualization

### File Listing
- **eza**: Use instead of `ls` for enhanced directory listings
  - Git integration shows file status
  - Tree view with `eza --tree`
  - Better formatting and icons

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

### Diff and Output
- **bat**: Use for syntax-highlighted output in shell pipelines
  - Example: `some_command | bat -l json`
- **delta**: Assumed configured as git pager for better diffs
- **difftastic**: AST-aware structural diffs that understand language syntax
  - Use when semantic diff matters more than line-level diff
  - Example: `difft old.py new.py` or `GIT_EXTERNAL_DIFF=difft git diff`

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

## Git Commit Preferences

Follow the 50/72 conventional commit format:
- Title: Maximum 50 characters
- Description: Maximum 72 characters per line
- No formatting (no markdown, no bullet points)
- Plain text only in commit messages

## Planning and Brainstorming

When in plan mode or generally planning/brainstorming, use an interview-style
approach: ask questions using the AskUserQuestion tool to collaboratively shape
the plan rather than presenting a finished plan upfront. Iterate through
questions to refine requirements, constraints, and design decisions together.

## General Approach
- Assume familiarity with technical concepts and command-line tools
- Provide detailed technical explanations without oversimplification
- Use efficient, modern tooling when available
- Use the project's existing package manager, scripts, formatter, and test
  commands before falling back to global preferences
