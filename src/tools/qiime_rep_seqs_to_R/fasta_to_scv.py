
with open("../../../data/processed/reference_sequenceces/sequences.fasta") as f:
    lines = f.readlines()

md5sum = []
sequence = []
#[md5sum.append(line) for line in lines if line.startswith(">") ]

[md5sum.append(line[1:]) if line.startswith(">") else sequence.append(line) for line in lines]

strip_md5sum = []
[strip_md5sum.append(sum.rstrip()) for sum in md5sum]

print("md5sum, sequence")
for (i, sum) in enumerate(md5sum):
    print(sum.rstrip() + "," + sequence[i].rstrip())
