import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
refs = set()
for i in range(5, 10):
    refs |= set(d['blocks'][i]['components'])

in_net = {}
for n in d['nets']:
    for p in n['pins']:
        r, pn = p.rsplit('.', 1)
        in_net.setdefault(r, set()).add(pn)

in_nc = {}
for nc in d['no_connect']:
    r, pn = nc['pin'].rsplit('.', 1)
    in_nc.setdefault(r, set()).add(pn)

print("### PIN COVERAGE (block 5-9 refs)")
for r in sorted(refs, key=lambda s: (s.rstrip('0123456789'), int(''.join(c for c in s if c.isdigit()) or 0))):
    nets = in_net.get(r, set())
    ncs = in_nc.get(r, set())
    both = nets & ncs
    print(f"{r}: nets={sorted(nets, key=lambda x:(len(x),x))} nc={sorted(ncs, key=lambda x:(len(x),x))}" + (f"  BOTH={both}" if both else ""))

print()
print("### FOOTPRINTS (scope refs)")
for f in d['footprints']:
    if isinstance(f, dict):
        ref = f.get('ref') or f.get('reference') or f.get('designator')
        if ref in refs:
            print(json.dumps(f, ensure_ascii=False))
    else:
        print("NONDICT", f)
