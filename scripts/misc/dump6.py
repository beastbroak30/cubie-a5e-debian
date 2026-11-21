import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
watch = {'U1','U3','U5','Q1','U4','U11','D1A','D1B','D1C','D1D','R37','R38','R39','R40'}
for n in d['nets']:
    if any(p.split('.')[0] in watch for p in n['pins']):
        print(n['name'], "::", ", ".join(n['pins']))
print()
print("NETS TOTAL", len(d['nets']))
print("BLOCK ORDER", json.dumps(d.get('block_order'), ensure_ascii=False))
print("BLOCKS_NOTE", json.dumps(d.get('blocks_note'), ensure_ascii=False))
for i in (5,6,7,8,9):
    print(json.dumps(d['blocks'][i], ensure_ascii=False, indent=1))
