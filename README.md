# llm-agent-maker

An **agent nursery** for [Claude Code](https://claude.com/claude-code): specialized LLM agent templates are *born, iterated, and graduated* here, then promoted to where they actually run (`~/.claude/agents/`).

## The nursery model

This repo is a birthplace, not a permanent home.

- **Gestation is git-tracked.** Every iteration of an agent-in-progress lands in git history. Git — not the working tree — is the durable archive; an empty `agents/` floor is the healthy steady state. (This public repo is a fresh-history snapshot: development history predating the initial public release lives in a private archive repository.)
- **The grown self lives at user level.** A finished agent is promoted to `~/.claude/agents/agent-[name].md`, and its bundled skills are flattened to `~/.claude/skills/`. On any conflict, the promoted copy wins.
- **Recruitment is gated.** `./recruit.sh` refuses to promote an agent until its registry metadata (`agents-metadata/agent-[name].json`) validates against [`.claude/METADATA_SCHEMA.md`](.claude/METADATA_SCHEMA.md) via `scripts/validate-metadata.mjs`.
- **Graduates are discarded from the tree.** After promotion, the nursery copies are `git rm`'d; the lineage lives in history.

## How agents are born

The `/birth` command (installed at user level) runs a tiered generation pipeline — spec refinement, tier triage, domain research with primary-source claim verification, facet-mode generation, static critique, and dynamic validation where test subagents actually run the template. Architecture and rationale: [`.claude/BIRTH_ARCHITECTURE.md`](.claude/BIRTH_ARCHITECTURE.md).

Templates follow one of two archetype schemas — a recruiting brief for consultative agents, a Viticci-pattern operating manual for operational agents — dispatched by what "done" means. See [`CLAUDE.md`](CLAUDE.md) for the full contract.

## Layout

- `agents/` — templates currently in gestation (usually empty)
- `agents-metadata/` — the recruitment registry
- `.claude/` — framework docs and the pipeline agents (`agent-llm-recruiter`, `agent-llm-critic`, `agent-llm-validator`, …)
- `.birth-working/` — transient per-birth working data (cleared on graduation)
- `recruit.sh` + `scripts/validate-metadata.mjs` — the gated promotion path

## License

[MIT](LICENSE)
