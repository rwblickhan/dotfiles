#!/usr/bin/env python3
import json
import os

HERE = os.path.dirname(os.path.realpath(__file__))

with open(os.path.join(HERE, "emoji_data.json"), encoding="utf-8") as f:
    entries = json.load(f)

items = []
for entry in entries:
    emoji = entry["e"]
    items.append({
        "title": f"{emoji}  {entry['d']}",
        "subtitle": entry["k"],
        "arg": emoji,
        "uid": emoji,
        "match": (entry["d"] + " " + entry["k"]).lower(),
    })

print(json.dumps({"items": items}))
