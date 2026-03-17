# Claude Code User Settings

## Documentation and Research Preferences

When working with documentation or conducting research tasks:
- **Prefer context7** over basic search tools when applicable
- Use context7 for comprehensive codebase understanding and documentation lookup
- Leverage context7's semantic search capabilities for finding relevant code patterns

## Web Search
 
Prefer the Exa MCP server for web searches. It returns clean, LLM-optimized
content and uses less context than fetching and parsing pages yourself.
Only fall back to WebSearch if Exa doesn't have the information.

## Temporary Workspace Management

### Directory Structure
- Use `/tmp/claude/` as the base directory for all temporary work
- Create descriptive subdirectories based on the task context
  - Examples: `/tmp/claude/mc-falling-block-research`, `/tmp/claude/csv-analysis`
- **Always check existing `/tmp/claude/` subdirectories first** before creating new ones
  - Use `fd` or `eza --tree` to survey existing work
  - Reuse relevant directories if the research topic overlaps

### Documentation Requirements
After completing work in a temporary directory, create a `README.md` that includes:
- Brief description of what the directory contains
- Date/timestamp of the research session
- Key findings or purpose
- List of main files and their purposes

Example README.md:
```
# MC Falling Block Research
**Date:** 2025-01-18
**Purpose:** Investigate Minecraft falling block entity behavior and NBT structure

## Contents
- `falling_block_nbt.json` - Example NBT data structures
- `entity_behavior.md` - Notes on physics simulation
- `test_scenarios.txt` - Edge cases for testing

## Key Findings
- Falling blocks use FallingSand entity type (pre-1.11) or falling_block (1.11+)
- NBT tag `Time` tracks ticks since entity spawned
```

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

## Git Commit Preferences

Follow the 50/72 conventional commit format:
- Title: Maximum 50 characters
- Description: Maximum 72 characters per line
- No formatting (no markdown, no bullet points)
- Plain text only in commit messages

## General Approach
- Assume familiarity with technical concepts and command-line tools
- Provide detailed technical explanations without oversimplification
- Use efficient, modern tooling when available
