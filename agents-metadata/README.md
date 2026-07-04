# agents-metadata/ — the recruitment registry

One JSON per gestating agent, schema per `../.claude/METADATA_SCHEMA.md`.
`recruit.sh` will not certify an agent as recruited until its metadata here is
present and valid (`scripts/validate-metadata.mjs`). Cleared alongside the
agent when it graduates — see `../agents/README.md`.
