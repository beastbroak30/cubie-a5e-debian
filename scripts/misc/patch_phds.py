import json, re, shutil, pathlib

cfg = pathlib.Path(r"C:\Users\akant\.config\opencode\opencode.jsonc")
prompt = pathlib.Path(r"C:\Users\akant\AppData\Local\Temp\opencode\phds_prompt.md").read_text(encoding="utf-8").strip()
text = cfg.read_text(encoding="utf-8")

shutil.copy2(cfg, str(cfg) + ".bak-phds")

old_desc = '"description": "PhD-level advisor for hard small problems: analysis, design trade-offs, math checks, debugging hypotheses. Advice only, never edits or runs commands.",'
new_desc = json.dumps(
    "Principal PhD Hardware, Embedded Systems, RF/Mixed-Signal, Edge AI & Applied Physics Advisor. "
    "Invoked before designing architectures, schematics/PCB layouts, bare-metal/RTOS firmware, "
    "or physics/metrology problems. Verifies official datasheets, cites exact sources, "
    "requests missing specifications.",
    ensure_ascii=False) + ","
assert text.count(old_desc) == 1
text = text.replace(old_desc, "      " + new_desc, 1)

system_line = re.compile(r'^      "system": "You are a PhD advisor in electronics.*$', re.M)
m = list(system_line.finditer(text))
assert len(m) == 1, len(m)
repl = '      "system": ' + json.dumps(prompt, ensure_ascii=False) + ','
text = text[:m[0].start()] + repl + text[m[0].end():]

cfg.write_text(text, encoding="utf-8")
print("ok", len(prompt), "chars")
