# agents/ — the gestation floor

This directory holds **only agents currently being born or iterated**. An empty
floor is the healthy steady state.

## Lifecycle

1. `/birth` writes a new agent template here as `agent-[name].md`, plus its
   metadata at `../agents-metadata/agent-[name].json`.
2. Iterate. Every revision is captured in git history — git is the archive.
3. `./recruit.sh` promotes the agent to `~/.claude/agents/` — **only after**
   `scripts/validate-metadata.mjs` certifies its registry metadata.
4. Once promoted, `git rm` the agent's `.md` here and its `.json` in
   `../agents-metadata/`. The grown self at user level is now authoritative;
   the lineage lives in git history.

To recover any previously-born agent:
`git log --all --oneline -- agents/` then `git checkout <sha> -- <path>`.

See the root `CLAUDE.md` "nursery model" section for the full contract.
