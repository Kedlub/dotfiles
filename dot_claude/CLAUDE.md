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
