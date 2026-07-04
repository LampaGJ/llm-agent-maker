#!/usr/bin/env node
// Recruitment gate: an agent is not "certified as recruited" until its metadata
// JSON is present in agents-metadata/ AND validates against .claude/METADATA_SCHEMA.md.
//
// Usage:  node scripts/validate-metadata.mjs <agent-name> [<agent-name> ...]
//         node scripts/validate-metadata.mjs --file agents-metadata/agent-foo.json
// Exit 0 => all valid (gate passes). Exit 1 => at least one failure (gate blocks recruitment).
//
// Dependency-free by design: this nursery has no package.json. If it ever gains one,
// migrate this to Zod (the house validation framework) — see ~/.claude/CLAUDE.md.

import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname, basename } from "node:path";
import { fileURLToPath } from "node:url";

// Metadata dir resolution (portable — one copy works from any project):
//   1. --dir <path> flag   2. $AGENT_METADATA_DIR   3. <cwd>/agents-metadata
//   4. fallback: <script>/../agents-metadata (in-repo layout)
function resolveMetadataDir(argv) {
  const i = argv.indexOf("--dir");
  if (i !== -1 && argv[i + 1]) return resolve(argv[i + 1]);
  if (process.env.AGENT_METADATA_DIR) return resolve(process.env.AGENT_METADATA_DIR);
  const cwdDir = resolve(process.cwd(), "agents-metadata");
  if (existsSync(cwdDir)) return cwdDir;
  return resolve(dirname(fileURLToPath(import.meta.url)), "..", "agents-metadata");
}
const METADATA_DIR = resolveMetadataDir(process.argv);

/** Validate one parsed metadata object. Returns array of human-readable problems (empty = valid). */
function validate(meta, expectedName) {
  const problems = [];
  const isStr = (v) => typeof v === "string" && v.trim().length > 0;
  const arr = (v, lo, hi, label) => {
    if (!Array.isArray(v)) return problems.push(`${label}: must be an array`);
    if (v.length < lo || v.length > hi) problems.push(`${label}: expected ${lo}-${hi} entries, got ${v.length}`);
  };

  if (!isStr(meta.agent_name)) problems.push("agent_name: missing/empty");
  else if (expectedName && meta.agent_name !== expectedName)
    problems.push(`agent_name "${meta.agent_name}" != filename "${expectedName}"`);

  if (!/^\d{4}-\d{2}-\d{2}$/.test(meta.created ?? "")) problems.push("created: must be ISO date YYYY-MM-DD");

  const spec = meta.specification ?? {};
  for (const k of ["scope", "depth", "function", "risk_profile", "context"])
    if (!isStr(spec[k])) problems.push(`specification.${k}: missing/empty`);

  const wf = meta.workflow ?? {};
  if (!isStr(wf.method)) problems.push("workflow.method: missing/empty");
  if (typeof wf.iterations !== "number" || wf.iterations < 1 || wf.iterations > 5)
    problems.push("workflow.iterations: must be a number 1-5");
  if (!isStr(wf.final_verdict)) problems.push("workflow.final_verdict: missing/empty");

  arr(meta.core_capabilities, 3, 5, "core_capabilities");
  arr(meta.key_expertise, 4, 8, "key_expertise");

  // Archetype dispatch (METADATA_SCHEMA.md): consultative agents register
  // success_metrics; operational agents register validation_gates instead.
  if (meta.archetype !== undefined && !["consultative", "operational"].includes(meta.archetype))
    problems.push(`archetype: must be "consultative" or "operational", got "${meta.archetype}"`);
  if (meta.archetype === "operational") {
    arr(meta.validation_gates, 3, 5, "validation_gates");
  } else {
    arr(meta.success_metrics, 3, 5, "success_metrics");
    if (Array.isArray(meta.success_metrics) && !meta.success_metrics.some((m) => /\d/.test(String(m))))
      problems.push("success_metrics: at least one metric should include a specific number");
  }

  if (!isStr(meta.final_template)) problems.push("final_template: missing/empty");

  return problems;
}

const args = process.argv.slice(2);
const targets = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--dir") { i++; continue; } // consumed by resolveMetadataDir
  else if (args[i] === "--file") targets.push({ path: resolve(args[++i]) });
  else {
    const name = basename(args[i]).replace(/\.(md|json)$/, "");
    targets.push({ name, path: resolve(METADATA_DIR, `${name}.json`) });
  }
}

if (targets.length === 0) {
  console.error("usage: validate-metadata.mjs <agent-name>... | --file <path>");
  process.exit(2);
}

let failed = 0;
for (const t of targets) {
  const label = t.name ?? basename(t.path);
  if (!existsSync(t.path)) {
    console.error(`✗ ${label}: NO METADATA in registry (${t.path}) — recruitment blocked`);
    failed++;
    continue;
  }
  let meta;
  try {
    meta = JSON.parse(readFileSync(t.path, "utf8"));
  } catch (e) {
    console.error(`✗ ${label}: metadata is not valid JSON — ${e.message}`);
    failed++;
    continue;
  }
  const problems = validate(meta, t.name ?? meta.agent_name);
  if (problems.length) {
    console.error(`✗ ${label}: metadata incomplete —`);
    for (const p of problems) console.error(`    • ${p}`);
    failed++;
  } else {
    console.log(`✓ ${label}: metadata certified`);
  }
}

process.exit(failed > 0 ? 1 : 0);
