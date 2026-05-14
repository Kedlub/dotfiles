# Codex CLI User Settings

## Documentation and Research Preferences

When working with documentation or conducting research tasks:
- Prefer local repository inspection with `rg`, file reads, and project tooling for codebase understanding.
- Prefer Context7 for library, framework, SDK, and API documentation when applicable.
- Use Context7 to find current external code patterns and reference docs.

## Web Search

Prefer the Exa MCP server for web searches. It returns clean, LLM-optimized
content and uses less context than fetching and parsing pages manually. Fall
back to Codex web search when Exa is unavailable or lacks the information.

## Preferred CLI Tools

Use these modern CLI tools instead of their traditional alternatives:

### File Search and Navigation

- Use `rg` instead of `grep` for faster, more intelligent searching.
- Use `fd` instead of `find` for simpler, faster file discovery.

### System Analysis

- Use `dua` for analyzing disk space.

### File Listing

- Use `eza` instead of `ls` for enhanced directory listings.

### JSON, YAML, and HTTP

- Use `jq` for JSON processing in shell pipelines.
- Use `yq` for YAML/TOML processing in shell pipelines.
- Use `xh` instead of `curl` for HTTP requests.

### Code Analysis

- Use `tokei` for quick codebase statistics.

### Diff and Output

- Use `bat` for syntax-highlighted output in shell pipelines.
- Assume `delta` is configured as the git pager for better diffs.
- Use `difftastic` when semantic diff matters more than line-level diff.

### Benchmarking

- Use `hyperfine` for benchmarking and comparing command performance.

### Python

- Prefer `uv` for Python workflows unless the project clearly uses another
  tool or package manager.
- Use `uv run` for one-off inline scripts, adding temporary dependencies with
  `--with` as needed.
- Use `uv run` for standalone Python script files, and declare script
  dependencies with PEP 723 metadata headers when dependencies are required.
- Use `uv` for `pyproject.toml`, dependency, virtual environment, and Python
  version management tasks when there is no conflicting project convention.

### JS/TS Linting and Formatting

- Prefer `biome` over eslint/prettier when a project has no existing eslint config.
- Use `biome` for standalone JS/TS files.
- If a project already has eslint configured, use eslint instead.

## Git Commit Preferences

Follow the 50/72 conventional commit format:
- Title: maximum 50 characters.
- Description: maximum 72 characters per line.
- No markdown or bullet formatting in commit messages.
- Plain text only in commit messages.

## Planning and Brainstorming

When planning or brainstorming, use an interview-style approach. Ask concise
questions to collaboratively shape requirements, constraints, and design
decisions instead of presenting a finished plan upfront.

## General Approach

- Assume familiarity with technical concepts and command-line tools.
- Provide detailed technical explanations without oversimplification.
- Use efficient, modern tooling when available.
- Use the project's existing package manager, scripts, formatter, and test commands before falling back to global preferences.
