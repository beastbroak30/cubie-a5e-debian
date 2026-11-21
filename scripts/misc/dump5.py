import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
fp = d['footprints']
for k, v in fp.items():
    print("###", k)
    print(json.dumps(v, ensure_ascii=False, indent=1)[:6000])
    print()
print("### EXTRA PARTS")
for e in d['extra_parts']:
    print(json.dumps(e, ensure_ascii=False))
print("### MISSING PARTS")
for e in d['missing_parts']:
    print(json.dumps(e, ensure_ascii=False))
