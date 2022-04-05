#!/usr/bin/env python3
#
# Darren Spruell <dspruell@sancho2k.net>
#
# Extract Sumo Logic content export JSON data to files.

from argparse import ArgumentParser
import json
import logging
from pathlib import Path
from typing import List, Tuple


TYPE_FOLDER: str = "FolderSyncDefinition"
TYPE_SEARCH: str = "SavedSearchWithScheduleSyncDefinition"

node_list: List[Tuple] = []
folder_list: List[Tuple] = []
search_list: List[Tuple] = []

logging.basicConfig(level=logging.DEBUG, format="%(message)s")


def main():
    parser = ArgumentParser()
    parser.add_argument("infile", help="JSON input file")
    args = parser.parse_args()

    with open(args.infile, "r") as content:
        data: dict = json.load(content)

    #
    # Traverse structure and build list of folders (directories) to create
    # and list of searches to write to their respective parent directory.
    #

    # The first node is the top of the structure and is a folder.
    parent_folder = "."
    node_list.append((parent_folder, data))

    while node_list:
        parent_folder, node = node_list.pop(0)

        # Build list of directories to create
        if node["type"] == TYPE_FOLDER:
            nname = node["name"].replace("/", "_").replace(" ", "_")
            folder_path = Path(parent_folder) / Path(nname)
            folder_desc = node["description"]
            folder_list.append((folder_path, folder_desc))
            for child in node.get("children", []):
                parent_folder = folder_path
                node_list.append((parent_folder, child))

        # Build list of searches to store. Store only the file name without any
        # extension.
        elif node["type"] == TYPE_SEARCH:
            nname = node["name"].replace("/", "_").replace(" ", "_")
            search_path = Path(parent_folder) / Path(nname)
            search_list.append((search_path, node))

    for path, desc in folder_list:
        Path(path).mkdir(exist_ok=True)

    for path, node in search_list:
        with Path(path.with_suffix(".json")).open("w") as f:
            f.write(json.dumps(node, indent=4))
        with Path(path.with_suffix(".search.txt")).open("w") as f:
            f.write(node["search"]["queryText"])
        with Path(path.with_suffix(".name.txt")).open("w") as f:
            f.write(node["name"])
        # Ignore blank descriptions.
        if node["description"]:
            with Path(path.with_suffix(".description.txt")).open("w") as f:
                f.write(node["description"])


if __name__ == "__main__":
    main()
