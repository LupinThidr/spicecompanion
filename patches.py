#!/usr/bin/env python3

import json
import os
import re

patches = []
path = os.path.join(".", "assets", "patches")
path_filter = re.compile("^[A-Z0-9]{3}-[0-9]{10}")
for filename in os.listdir(path):
    if path_filter.match(filename):
        with open(os.path.join(path, filename), "r") as file:
            content = file.read()
        patch_list = json.loads(content)
        for patch in patch_list:
            patches.append(patch)
print(json.dumps(patches))
