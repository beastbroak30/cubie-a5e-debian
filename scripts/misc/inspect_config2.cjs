// Inspect the real shape of opencode.jsonc: where the mcp servers and the
// kicad agents actually live, and whether my edits landed correctly.
const fs = require("fs");

const p = "C:/Users/akant/.config/opencode/opencode.jsonc";
const raw = fs.readFileSync(p, "utf8").replace(/^\uFEFF/, "");
const stripped = raw
  .replace(/\/\*[\s\S]*?\*\//g, "")
  .split("\n")
  .map((l) => l.replace(/^\s*\/\/.*$/, ""))
  .join("\n");
const j = JSON.parse(stripped);

function walk(o, path, depth) {
  if (depth > 2 || o === null || typeof o !== "object") return;
  for (const k of Object.keys(o)) {
    const v = o[k];
    const kind = Array.isArray(v) ? "array" : typeof v;
    if (kind === "object") {
      console.log(`${"  ".repeat(depth)}${path}${k} {}`);
      walk(v, "", depth + 1);
    } else {
      console.log(`${"  ".repeat(depth)}${path}${k}: ${kind}`);
    }
  }
}

console.log("top level keys:", Object.keys(j).join(", "));
console.log("");
walk(j, "", 0);

const mcp = j.mcp || {};
const container = mcp.servers ? mcp.servers : mcp;
const k = container.kicad;
console.log("\n--- kicad entry ---");
console.log(JSON.stringify(k, null, 1).slice(0, 1200));

const entry = k && k.command && k.command[1];
console.log("entrypoint exists:", entry ? fs.existsSync(entry) : "n/a");

const agents = j.agents || {};
const kk = Object.keys(agents).filter((a) => a.includes("kicad"));
console.log("\nkicad agents:", kk.join(", ") || "NONE FOUND");
for (const a of kk) {
  const sys = agents[a].system || ""; const stale=["get_schematic_summary","wire_pins_to_net","connect_pins","get_symbol_pins","add_power_symbol","auto_place_decoupling_cap","list_unconnected_pins","update_pcb_from_schematic","place_footprint","add_copper_zone","add_pcb_line"]; const hits=stale.filter(t=>sys.includes(t)&&!/FORBIDDEN|no longer exist|do not exist/.test(sys)); const hasNew=["batch_connect","add_schematic_wire","find_overlapping_elements","list_schematic_components"].filter(t=>sys.includes(t)); console.log(`  ${a}: ${sys.length} chars | new-tools:${hasNew.join(",")||"none"} | stale:${hits.join(",")||"none"}`);
}

