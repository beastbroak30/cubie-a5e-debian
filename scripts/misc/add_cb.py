import json, io, sys, shutil

P = r"D:\KANRE\kicad\artifacts\netlist-bare.json"
BAK = r"D:\KANRE\kicad\artifacts\netlist-bare.json.bak-cb"

raw = io.open(P, encoding="utf-8-sig").read()
d = json.loads(raw)

nets_before = len(d["nets"])
rows_before = len(d["footprints"]["table"])
extra_before = len(d["extra_parts"])
log_before = len(d["change_log"])

# --- 1. component entry -------------------------------------------------
if any(r.get("ref") == "C47" for r in d["footprints"]["table"]):
    sys.exit("FAIL: C47 already exists in footprints.table")
if any(r.get("ref") == "C47" for r in d["extra_parts"]):
    sys.exit("FAIL: C47 already exists in extra_parts")

entry = {
    "ref": "C47",
    "part": "100 nF 50 V X7R, 10 percent",
    "pkg": "0805",
    "tol": "10% X7R 50 V",
    "mount": "SMD",
    "pins": 2,
    "pin_order": "1/2 non-polar",
    "note": (
        "C_B: DAC servo base decoupling, 100 nF MLCC on the Q1 base node behind the R2 10k "
        "stopper, returned to Star AGND. NOT on the DAC_OUT pin: STM32G491RE Table 68 limits "
        "CL at the pin to 50 pF, so the capacitor sits behind R2 (Gate 0, "
        "artifacts/gate0-stm32-dac-adc.md). Dielectric and voltage class copied from the other "
        "100 nF 0805 lines in this file: 10 percent X7R 50 V."
    ),
}
d["footprints"]["table"].append(entry)

# --- 2. NET_Q1_BASE -----------------------------------------------------
q1 = [n for n in d["nets"] if n.get("name") == "NET_Q1_BASE"]
if len(q1) != 1:
    sys.exit("FAIL: NET_Q1_BASE count %d" % len(q1))
q1 = q1[0]
if "R2.2" not in q1["pins"] or "Q1.2" not in q1["pins"]:
    sys.exit("FAIL: NET_Q1_BASE pins unexpected: %r" % q1["pins"])
if "C47.1" in q1["pins"]:
    sys.exit("FAIL: C47.1 already on NET_Q1_BASE")
q1["pins"].append("C47.1")

# --- 3. Star AGND -------------------------------------------------------
ag = [n for n in d["nets"] if n.get("name") == "Star AGND"]
if len(ag) != 1:
    sys.exit("FAIL: Star AGND count %d" % len(ag))
ag = ag[0]
if ag["pins"][0] != "U2.3" or ag["pins"][1] != "C1.2":
    sys.exit("FAIL: Star AGND head unexpected: %r" % ag["pins"][:4])
if "C47.2" in ag["pins"]:
    sys.exit("FAIL: C47.2 already on Star AGND")
ag["pins"].append("C47.2")

# --- 4. change_log ------------------------------------------------------
d["change_log"].append({
    "date": "2026-11-13",
    "change": (
        "C_B 100 nF 0805 added, base of Q1: C47.1 on NET_Q1_BASE behind R2, C47.2 on Star AGND. "
        "Gate 0 (artifacts/gate0-stm32-dac-adc.md)."
    ),
})

# --- 5. write -----------------------------------------------------------
out = json.dumps(d, indent=2, ensure_ascii=False)
if raw.endswith("\n"):
    out += "\n"
with io.open(P, "w", encoding="utf-8-sig", newline="") as f:
    f.write(out)

# --- 6. verify ----------------------------------------------------------
chk = json.load(io.open(P, encoding="utf-8-sig"))
ok = True
def need(cond, msg):
    global ok
    if not cond:
        ok = False
        print("FAIL:", msg)

q = [n for n in chk["nets"] if n.get("name") == "NET_Q1_BASE"][0]
a = [n for n in chk["nets"] if n.get("name") == "Star AGND"][0]
need(q["pins"] == ["R2.2", "Q1.2", "C47.1"], "NET_Q1_BASE pins %r" % q["pins"])
need(a["pins"][-1] == "C47.2" and "C47.2" in a["pins"], "Star AGND missing C47.2")
need(len(chk["nets"]) == nets_before, "net count %d -> %d" % (nets_before, len(chk["nets"])))
need(len(chk["footprints"]["table"]) == rows_before + 1,
     "footprint rows %d -> %d" % (rows_before, len(chk["footprints"]["table"])))
need(len(chk["extra_parts"]) == extra_before, "extra_parts count changed")
need(len(chk["change_log"]) == log_before + 1, "change_log count changed")
need([r for r in chk["footprints"]["table"] if r.get("ref") == "C47"][0]["pkg"] == "0805", "C47 pkg")
need(len([r for r in chk["footprints"]["table"] if r.get("ref") == "C47"]) == 1, "C47 row count")

# no other net changed: compare every net except the two touched
old = json.loads(io.open(BAK, encoding="utf-8-sig").read())
oldmap = {n["name"]: n for n in old["nets"]}
newmap = {n["name"]: n for n in chk["nets"]}
need(set(oldmap) == set(newmap), "net name set changed")
for name in oldmap:
    if name in ("NET_Q1_BASE", "Star AGND"):
        continue
    need(oldmap[name] == newmap[name], "net %s modified" % name)

# no other component row changed
oldrows = {r.get("ref"): r for r in old["footprints"]["table"]}
for ref, row in oldrows.items():
    need(newmap is not None, "")
    need(chk["footprints"]["table"][0] is not None, "")
newrows = chk["footprints"]["table"]
need(len(newrows) == len(old["footprints"]["table"]) + 1, "row delta")
need(all(o == n for o, n in zip(old["footprints"]["table"], newrows)), "existing rows modified")

# other top-level keys untouched
for k in old:
    if k in ("nets", "footprints", "change_log"):
        continue
    need(old[k] == chk[k], "top-level key %s modified" % k)

if not ok:
    shutil.copyfile(BAK, P)
    print("ROLLED BACK")
    sys.exit(1)
print("VERIFIED: nets=%d footprint_rows=%d extra_parts=%d change_log=%d"
      % (len(chk["nets"]), len(newrows), len(chk["extra_parts"]), len(chk["change_log"])))
