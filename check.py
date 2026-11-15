"""The gallery checked as the studio reads it: every entry whole (an id of
the right form, said once; the graph file there, its sha256 the entry's, a
graph bundle within 2 MB; a preview GIF within 6 MB), and no file in
effects/ or previews/ that no entry names; and the add-on packs the same way
(packs.json: each look of an allowed name and kind in looks/<pack id>/, its
sha256 the list's, within 512 KB; a picture in previews/packs/; no stray
files). Run by the pull-request check; exits 1 with what is wrong."""
import hashlib
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ID = re.compile(r"^[a-z0-9][a-z0-9-]{0,62}$")
BUNDLE_MAX, PREVIEW_MAX = 2 << 20, 6 << 20
# the studio's own limits (native/addons.py): what it would refuse is refused here first
LOOK = re.compile(r"^[A-Za-z0-9][A-Za-z0-9 ._()+&,'-]{0,90}\.(milk|glsl)$")
LOOK_MAX, PACK_PREVIEW_MAX = 512 << 10, 4 << 20
KINDS = ("milkdrop", "shadertoy")
PNG = bytes.fromhex("89504e470d0a1a0a")


def check_packs(bad):
    """The packs in packs.json against looks/ and previews/packs/; their count."""
    path = os.path.join(HERE, "packs.json")
    if not os.path.exists(path):
        return 0
    d = json.load(open(path, encoding="utf-8"))
    if d.get("packs") != 1 or not isinstance(d.get("list"), list):
        bad.append("packs.json: {\"packs\": 1, \"list\": [...]} expected"); return 0
    pids = set()
    names = {}                                # (kind, a look's name in lower case) -> the pack that has it
    for p in d["list"]:
        for it in (p.get("items") or []) if isinstance(p, dict) else []:
            if isinstance(it, dict) and isinstance(it.get("file"), str):
                # the studio lists a look by its name (the item's, else its file's): two of one name and kind
                # cannot both be shown - the second is refused there ("give one a NAME of its own")
                key = (p.get("kind"), str(it.get("name") or it["file"].rsplit(".", 1)[0]).strip().lower())
                if key in names and names[key] != p.get("id"):
                    bad.append(f"pack {p.get('id')}: {it['file']} has the name of a look in {names[key]} ({key[1]!r})")
                names.setdefault(key, p.get("id"))
        pid = p.get("id") if isinstance(p, dict) else None
        if not isinstance(pid, str) or not ID.match(pid):
            bad.append(f"packs.json: a pack with an id that is not lower case letters, digits and dashes: {pid!r}")
            continue
        if pid in pids:
            bad.append(f"pack {pid}: listed twice"); continue
        pids.add(pid)
        for key in ("name", "description", "licence"):
            if not isinstance(p.get(key), str) or not p[key].strip():
                bad.append(f"pack {pid}: no {key}")
        if p.get("kind") not in KINDS:
            bad.append(f"pack {pid}: kind is not one of {', '.join(KINDS)}")
        if "NC" in str(p.get("licence", "")).upper().replace(" ", "-").split("-") and not p.get("noncommercial"):
            bad.append(f"pack {pid}: a non-commercial licence, but not marked noncommercial")
        files = set()
        for it in p.get("items") or []:
            f = it.get("file") if isinstance(it, dict) else None
            if not isinstance(f, str) or not LOOK.match(f):
                bad.append(f"pack {pid}: a look named {f!r} (letters, digits, spaces and . _ ( ) + & , ' - only; "
                           ".milk or .glsl)"); continue
            if f in files:
                bad.append(f"pack {pid}: {f} listed twice"); continue
            files.add(f)
            if not str(it.get("author", "")).strip() or not str(it.get("licence", "")).strip():
                bad.append(f"pack {pid}: {f} has no author or licence")
            fp = os.path.join(HERE, "looks", pid, f)
            if not os.path.isfile(fp):
                bad.append(f"pack {pid}: looks/{pid}/{f} is missing"); continue
            data = open(fp, "rb").read()
            if len(data) > LOOK_MAX:
                bad.append(f"pack {pid}: {f} is over 512 KB")
            if hashlib.sha256(data).hexdigest() != str(it.get("sha256", "")).lower():
                bad.append(f"pack {pid}: {f}'s sha256 is not the file's ({hashlib.sha256(data).hexdigest()})")
        if not files:
            bad.append(f"pack {pid}: no looks")
        folder = os.path.join(HERE, "looks", pid)
        for f in sorted(os.listdir(folder)) if os.path.isdir(folder) else []:
            if f not in files:
                bad.append(f"looks/{pid}/{f}: the pack does not list it")
        png = os.path.join(HERE, "previews", "packs", pid + ".png")
        if not os.path.exists(png):
            bad.append(f"pack {pid}: previews/packs/{pid}.png is missing")
        elif os.path.getsize(png) > PACK_PREVIEW_MAX:
            bad.append(f"pack {pid}: the picture is over 4 MB")
        elif open(png, "rb").read(8) != PNG:
            bad.append(f"pack {pid}: the picture is not a PNG")
    looks = os.path.join(HERE, "looks")
    for f in sorted(os.listdir(looks)) if os.path.isdir(looks) else []:
        if f not in pids:
            bad.append(f"looks/{f}: no pack names it")
    pics = os.path.join(HERE, "previews", "packs")
    for f in sorted(os.listdir(pics)) if os.path.isdir(pics) else []:
        if not f.endswith(".png") or f[:-4] not in pids:
            bad.append(f"previews/packs/{f}: no pack names it")
    return len(pids)


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
            if folder == "previews" and f == "packs":
                continue
            if not f.endswith(ext) or f[:-len(ext)] not in ids:
                bad.append(f"{folder}/{f}: no entry names it")
    packs = check_packs(bad)
    for b in bad:
        print(b)
    print(f"{len(ids)} entries, {packs} packs" + (f", {len(bad)} problem(s)" if bad else ", all whole"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
