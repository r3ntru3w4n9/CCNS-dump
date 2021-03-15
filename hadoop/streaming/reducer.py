import sys
from collections import defaultdict

groups = defaultdict(int)

for line in sys.stdin:
    (key, val) = line.strip().split("\t", maxsplit=1)
    groups[key] += 1

for (key, val) in groups.items():
    print("{}\t{}".format(key, val), file=sys.stdout)
