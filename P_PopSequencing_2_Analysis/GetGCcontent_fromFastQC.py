import numpy as np

path = "/home/david/Downloads/fastqc_data.txt"
started = False
contents, counts = [], []
with open(path, "r") as f:
    for line in f.readlines():
        if not started:
            spl = [s.strip() for s in line.split()]
            # print(spl)
            if spl == ["#GC", "Content", "Count"]:
                started = True
        else:
            spl = line.split()
            if spl == [">>END_MODULE"]:
                break
            assert len(spl) == 2
            content, count = spl
            contents.append(int(content.strip()))
            counts.append(float(count.strip()))

contents_counts = np.stack([contents, counts])

print(f"contents is a {type(contents)} with entries of type {type(contents[0])}.")
print(f"counts is a {type(counts)} with entries of type {type(counts[0])}.")
print(f"contents_counts is a {type(contents_counts)} with shape {contents_counts.shape} and entries of type {contents_counts.dtype}.")

