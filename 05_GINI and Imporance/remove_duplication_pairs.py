#!/usr/bin/env python3
import sys

seen = set()
with open(sys.argv[1], 'r') as f:
    for line in f:
        cols = line.strip().split('\t')
        if len(cols) < 3: 
            continue  # 跳过不完整的行
        
        # 创建无序代谢物对（小值在前）
        pair = tuple(sorted([cols[0], cols[1]]))
        
        # 只输出首次出现的无序对
        if pair not in seen:
            seen.add(pair)
            print(line.strip())
