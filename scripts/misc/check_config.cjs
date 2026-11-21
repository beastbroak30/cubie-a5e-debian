// Validate opencode.jsonc after hand edits: strip comments, JSON.parse, then
// check the kicad MCP entry and every kicad agent prompt for stale tool names.
const fs = require("fs");

const p = "C:/Users/akant/.config/opencode/opencode.jsonc";
const raw = fs.readFileSync(p, "utf8").replace(/^\uFEFF/, "");

const noBlock = raw.replace(/\/\*[\s\S]*?\*\//g, "");
const stripped = noBlock
  .split("\n")
  .map((line) => line.replace(/^\s*\/\/.*$/, ""))
  .join("\n");

let j;
try {
  j = JSON.parse(stripped);
} catch (e) {
  console.log("PARSE FAIL:", e.message);
  const m = /position\s+(\d+)/.exec(e.message);
  if (m) {
    const i = Number(m[1]);
    console.log("context:", JSON.stringify(stripped.slice(Math.max(0, i - 120), i + 120)));
  }
  process.exit(1);
}

console.log("PARSE OK");
console.log("mcp servers:", Object.keys(j.mcp || {}).join(", "));

const k = j.mcp && j.mcp.kicad;
console.log("kicad.command:", JSON.stringify(k && k.command));
console.log("kicad.env keys:", Object.keys((k && k.environment) || {}).join(", "));
console.log("kicad.disabled:", k && k.disabled);
console.log("kicad.timeout:", JSON.stringify(k && k.timeout));

const entry = (k && k.command && k.command[1]) || "";
console.log("entrypoint exists:", entry ? fs.existsSync(entry) : "n/a");

const agents = j.agent || {};
const kk = Object.keys(agents).filter((a) => a.startsWith("kicad-"));
console.log("kicad agents:", kk.join(", "));

const stale = [
  "get_schematic_summary",
  "wire_pins_to_net",
  "connect_pins",
  "get_symbol_pins",
  "add_power_symbol",
  "auto_place_decoupling_cap",
  "list_unconnected_pins",
  "update_pcb_from_schematic",
  "place_footprint",
  "add_copper_zone",
  "add_pcb_line",
  "add_text",
];

let problems = 0;
for (const a of kk) {
  const sys = agents[a].system || "";
  const hits = stale.filter((t) => sys.includes(t));
  if (hits.length) {
    problems++;
    console.log(`  ${a}: mentions ${hits.join(", ")}`);
  }
  console.log(`  ${a}: system prompt ${sys.length} chars, model ${agents[a].model || "inherit"}`);
}
if (!problems) console.log("no stale tool names in any kicad agent prompt");
