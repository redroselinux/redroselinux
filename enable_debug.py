with open("src/installer/common.h") as f:
    lines = [l if not l.startswith("#define DEBUG") else "#define DEBUG 1\n" for l in f]
open("src/installer/common.h", "w").writelines(lines)