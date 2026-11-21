import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
print("### SINGLE-PIN NETS")
for n in d['nets']:
    if len(n['pins']) < 2:
        print(" ", n['name'], n['pins'])
print()
refs = set()
for i in range(5, 10):
    refs |= set(d['blocks'][i]['components'])
print("### NET SUMMARY")
for n in d['nets']:
    hit = [p for p in n['pins'] if p.split('.')[0] in refs]
    print("%-22s total=%3d inscope=%d" % (n['name'], len(n['pins']), len(hit)))
