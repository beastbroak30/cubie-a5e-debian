import json, io
d = json.load(io.open(r'D:\KANRE\kicad\artifacts\netlist-bare.json', encoding='utf-8-sig'))
for i in range(5, 10):
    b = d['blocks'][i]
    print("=" * 70)
    print(i, b['name'], "|", b.get('purpose'))
    print("COMPONENTS:", ", ".join(b['components']))
