"""The gallery checked as the studio reads it: every entry whole (an id of
the right form, said once; the graph file there, its sha256 the entry's, a
graph bundle within 2 MB; a preview GIF within 6 MB), and no file in
effects/ or previews/ that no entry names. Run by the pull-request check;
exits 1 with what is wrong."""
import hashlib
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ID = re.compile(r"^[a-z0-9][a-z0-9-]{0,62}$")
BUNDLE_MAX, PREVIEW_MAX = 2 << 20, 6 << 20


def main():
    bad = []
    idx = json.load(open(os.path.join(HERE, "index.json"), encoding="utf-8"))
    entries = idx.get("entries")
    if idx.get("gallery") != 1 or not isinstance(entries, list):
        print("index.json: {\"gallery\": 1, \"entries\": [...]} expected"); return 1
    ids = set()
    for e in entries:
        eid = e.get("id") if isinstance(e, dict) else None
        if not isinstance(eid, str) or not ID.match(eid):
            bad.append(f"an entry with an id that is not lower case letters, digits and dashes: {eid!r}"); continue
        if eid in ids:
            bad.append(f"{eid}: listed twice"); continue
        ids.add(eid)
        for key in ("name", "description"):
            if not isinstance(e.get(key), str) or not e[key].strip():
                bad.append(f"{eid}: no {key}")
        path = os.path.join(HERE, "effects", eid + ".graph.json")
        if not os.path.exists(path):
            bad.append(f"{eid}: effects/{eid}.graph.json is missing"); continue
        data = open(path, "rb").read()
        if len(data) > BUNDLE_MAX:
            bad.append(f"{eid}: the graph file is over 2 MB")
        if hashlib.sha256(data).hexdigest() != str(e.get("sha256", "")).lower():
            bad.append(f"{eid}: sha256 is not the graph file's ({hashlib.sha256(data).hexdigest()})")
        try:
            b = json.loads(data.decode("utf-8"))
            if not isinstance(b, dict) or not isinstance(b.get("graph"), dict):
                bad.append(f"{eid}: the graph file is not a graph bundle")
        except (ValueError, UnicodeError):
            bad.append(f"{eid}: the graph file does not read as JSON")
        gif = os.path.join(HERE, "previews", eid + ".gif")
        if not os.path.exists(gif):
            bad.append(f"{eid}: previews/{eid}.gif is missing")
        elif os.path.getsize(gif) > PREVIEW_MAX:
            bad.append(f"{eid}: the preview is over 6 MB")
        elif open(gif, "rb").read(6) not in (b"GIF87a", b"GIF89a"):
            bad.append(f"{eid}: the preview is not a GIF")
    for folder, ext in (("effects", ".graph.json"), ("previews", ".gif")):
        for f in os.listdir(os.path.join(HERE, folder)):
            if not f.endswith(ext) or f[:-len(ext)] not in ids:
                bad.append(f"{folder}/{f}: no entry names it")
    for b in bad:
        print(b)
    print(f"{len(ids)} entries" + (f", {len(bad)} problem(s)" if bad else ", all whole"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
