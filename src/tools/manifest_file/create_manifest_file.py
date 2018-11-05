import os
import re

files = os.listdir("../../../data/raw/")
mock_files = []
sample_files = []
verdi_files = []

for file in files:
    if re.search("Mock", file):
        mock_files.append(file)
    elif re.search(".gitkeep", file):
        pass
    elif re.search("Undetermined", file):
        pass
    elif re.search("verdi", file):
        verdi_files.append(file)
    else:
        sample_files.append(file)



print("sample-id,absolute-filepath,direction")
for file in sample_files:
    if re.search("_R1_", file):
        direction = "forward"
    else:
        direction = "reverse"
    print(file[4:12] + "," + "$PWD/../../../data/raw/" + file + "," + direction)

for file in mock_files:
    if re.search("_R1_", file):
        direction = "forward"
    else:
        direction = "reverse"
    print(file[0:4] + "," + "$PWD/../../../data/raw/" + file + "," + direction)

for file in verdi_files:
    if re.search("_R1_", file):
        direction = "forward"
    else:
        direction = "reverse"
    print(file[0:8] + "," + "$PWD/../../../data/raw/" + file + "," + direction)