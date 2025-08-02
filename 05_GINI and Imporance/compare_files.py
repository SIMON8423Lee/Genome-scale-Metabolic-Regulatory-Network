#!/usr/bin/env python3
import os
import argparse
from collections import defaultdict

def get_base_filename(path):
    """从文件路径中提取基本文件名（不带扩展名）"""
    return os.path.splitext(os.path.basename(path))[0]

def read_pairs(filename):
    """读取文件中的调控对"""
    pairs = set()
    pair_values = {}
    
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 3:
                continue
            
            id1, id2 = parts[0], parts[1]
            corr = parts[2]
            
            # 标准化代谢物对
            sorted_pair = tuple(sorted([id1, id2]))
            
            pairs.add(sorted_pair)
            pair_values[sorted_pair] = corr
    
    return pairs, pair_values

def compare_files(file1, file2, output_prefix):
    """比较两个基本ID文件"""
    # 获取文件基本名
    file1_base = get_base_filename(file1)
    file2_base = get_base_filename(file2)
    
    # 读取文件内容
    file1_pairs, file1_values = read_pairs(file1)
    file2_pairs, file2_values = read_pairs(file2)
    
    # 计算各种关系
    all_pairs = file1_pairs | file2_pairs
    intersection = file1_pairs & file2_pairs
    exclusive_file1 = file1_pairs - file2_pairs
    exclusive_file2 = file2_pairs - file1_pairs
    
    # 创建输出目录
    os.makedirs(output_prefix, exist_ok=True)
    
    # 1. 输出交集
    intersection_file = f"{output_prefix}/intersection_{file1_base}_vs_{file2_base}.txt"
    with open(intersection_file, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorr_File1\tCorr_File2\n")
        for pair in sorted(intersection):
            id1, id2 = pair
            f.write(f"{id1}\t{id2}\t{file1_values[pair]}\t{file2_values[pair]}\n")
    
    # 2. 输出并集
    union_file = f"{output_prefix}/union_{file1_base}_vs_{file2_base}.txt"
    with open(union_file, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tSource\tCorr\n")
        for pair in sorted(all_pairs):
            id1, id2 = pair
            if pair in intersection:
                # 取第一个文件的值作为代表
                f.write(f"{id1}\t{id2}\tBoth\t{file1_values[pair]}\n")
            elif pair in exclusive_file1:
                f.write(f"{id1}\t{id2}\t{file1_base}\t{file1_values[pair]}\n")
            else:
                f.write(f"{id1}\t{id2}\t{file2_base}\t{file2_values[pair]}\n")
    
    # 3. 输出文件1独占
    exclusive_file1_out = f"{output_prefix}/exclusive_{file1_base}.txt"
    with open(exclusive_file1_out, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorr\n")
        for pair in sorted(exclusive_file1):
            id1, id2 = pair
            f.write(f"{id1}\t{id2}\t{file1_values[pair]}\n")
    
    # 4. 输出文件2独占
    exclusive_file2_out = f"{output_prefix}/exclusive_{file2_base}.txt"
    with open(exclusive_file2_out, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorr\n")
        for pair in sorted(exclusive_file2):
            id1, id2 = pair
            f.write(f"{id1}\t{id2}\t{file2_values[pair]}\n")
    
    print(f"比较完成! 结果已保存到 {output_prefix}/ 目录:")
    print(f"- 交集: {os.path.basename(intersection_file)}")
    print(f"- 并集: {os.path.basename(union_file)}")
    print(f"- {file1_base}独占: {os.path.basename(exclusive_file1_out)}")
    print(f"- {file2_base}独占: {os.path.basename(exclusive_file2_out)}")

def main():
    parser = argparse.ArgumentParser(description='比较两个基本ID文件')
    parser.add_argument('file1', help='第一个基本ID文件')
    parser.add_argument('file2', help='第二个基本ID文件')
    parser.add_argument('-o', '--output', default='comparison_results', 
                        help='输出目录前缀 (默认: "comparison_results")')
    args = parser.parse_args()
    
    compare_files(args.file1, args.file2, args.output)

if __name__ == "__main__":
    main()
