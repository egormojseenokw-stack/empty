#!/usr/bin/env python3
"""
Split RecordType__c.object-meta.xml: extract inline <recordTypes> blocks
into separate recordTypes/*.recordType-meta.xml files and create a reduced
object-meta.xml without inline record types (so SF CLI can deploy without
hitting Node.js string size limit).
"""
import os
import re
import sys

# Run from repo root
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
OBJ_PATH = "force-app/main/default/objects/RecordType__c/RecordType__c.object-meta.xml"
RECORD_TYPES_DIR = "force-app/main/default/objects/RecordType__c/recordTypes"
NAMESPACE = "http://soap.sforce.com/2006/04/metadata"
RECORDTYPES_OPEN = "    <recordTypes>"
RECORDTYPES_CLOSE = "    </recordTypes>"


def extract_fullname(block_lines):
    for line in block_lines:
        m = re.match(r"\s*<fullName>([^<]+)</fullName>", line)
        if m:
            return m.group(1).strip()
    return None


def write_record_type_file(base_dir, full_name, inner_lines):
    rec_dir = os.path.join(base_dir, RECORD_TYPES_DIR)
    os.makedirs(rec_dir, exist_ok=True)
    path = os.path.join(rec_dir, f"{full_name}.recordType-meta.xml")
    with open(path, "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f.write(f'<RecordType xmlns="{NAMESPACE}">\n')
        for line in inner_lines:
            f.write(line)
        f.write("</RecordType>\n")
    return path


def main():
    base_dir = REPO_ROOT
    os.chdir(base_dir)
    obj_full = os.path.join(base_dir, OBJ_PATH)
    if not os.path.isfile(obj_full):
        print(f"File not found: {obj_full}", file=sys.stderr)
        sys.exit(1)

    head_lines = []
    tail_lines = []
    current_block = None
    count = 0

    with open(obj_full, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            if current_block is not None:
                if line.rstrip() == RECORDTYPES_CLOSE:
                    full_name = extract_fullname(current_block)
                    if full_name:
                        write_record_type_file(base_dir, full_name, current_block)
                        count += 1
                        if count % 20 == 0:
                            print(f"  Extracted {count} record types...")
                    current_block = None
                    tail_lines = [line]
                else:
                    current_block.append(line)
                continue

            if line.rstrip() == RECORDTYPES_OPEN:
                current_block = []
                continue

            if current_block is None and not tail_lines:
                head_lines.append(line)
            elif current_block is None and tail_lines:
                tail_lines.append(line)

        if current_block is not None:
            full_name = extract_fullname(current_block)
            if full_name:
                write_record_type_file(base_dir, full_name, current_block)
                count += 1
            current_block = None

    if tail_lines and RECORDTYPES_CLOSE in tail_lines[0]:
        reduced_tail = tail_lines[1:]
    else:
        reduced_tail = tail_lines

    backup = obj_full + ".backup"
    reduced_path = obj_full + ".reduced"
    with open(reduced_path, "w", encoding="utf-8") as out:
        for line in head_lines:
            out.write(line)
        for line in reduced_tail:
            out.write(line)

    os.rename(obj_full, backup)
    os.rename(reduced_path, obj_full)

    print(f"Done. Extracted {count} record types to {RECORD_TYPES_DIR}/")
    print(f"Original backed up to RecordType__c.object-meta.xml.backup")
    print("RecordType__c.object-meta.xml is now reduced (no inline record types).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
