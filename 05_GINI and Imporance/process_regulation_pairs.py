#!/usr/bin/env python3
import sys
import os
import re
import argparse
from collections import defaultdict

def extract_cluster_info(original_id):
    """从原始ID中提取聚类信息和基本ID"""
    # 匹配结构基因和转录因子ID格式：SG.C1.LG04.2303 或 TF.C5.LG11.3931
    if original_id.startswith("SG.") or original_id.startswith("TF."):
        parts = original_id.split('.')
        if len(parts) >= 3 and parts[1].startswith('C'):
            cluster = parts[1]
            base_id = f"{parts[0]}.model.{'.'.join(parts[2:])}"
            return base_id, cluster
    # 匹配代谢物ID格式：TMC1.467
    elif original_id.startswith("TM"):
        match = re.match(r'TM(C\d+)\.(\d+)', original_id)
        if match:
            cluster = match.group(1)
            base_id = f"TM{match.group(2)}"
            return base_id, cluster
    
    # 如果不符合上述模式，返回原始ID和空聚类
    return original_id, "NA"

def process_files(file_list):
    """处理文件列表，返回代谢物对信息"""
    pair_first_value = {}
    pair_file_count = defaultdict(int)
    id_cluster_mapping = defaultdict(lambda: defaultdict(str))
    
    for file_idx, filename in enumerate(file_list, 1):
        seen_in_file = set()
        
        with open(filename, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) < 3:
                    continue
                
                # 处理第一列ID
                base_id1, cluster1 = extract_cluster_info(parts[0])
                id_cluster_mapping[base_id1][file_idx] = cluster1
                
                # 处理第二列ID
                base_id2, cluster2 = extract_cluster_info(parts[1])
                id_cluster_mapping[base_id2][file_idx] = cluster2
                
                # 标准化代谢物对
                sorted_pair = tuple(sorted([base_id1, base_id2]))
                
                if sorted_pair not in seen_in_file:
                    seen_in_file.add(sorted_pair)
                    
                    if sorted_pair not in pair_first_value:
                        pair_first_value[sorted_pair] = parts[2]  # 相关性值
                    
                    pair_file_count[sorted_pair] += 1
    
    return pair_first_value, pair_file_count, id_cluster_mapping

def write_cluster_mapping(mapping, file_list, output_file):
    """将聚类映射信息写入文件"""
    with open(output_file, 'w') as f:
        # 表头
        headers = ["Base_ID"] + [f"File_{i}_Cluster" for i in range(1, len(file_list)+1)]
        f.write("\t".join(headers) + "\n")
        
        # 写入每个ID的聚类信息
        for base_id, cluster_info in mapping.items():
            row = [base_id]
            for i in range(1, len(file_list)+1):
                row.append(cluster_info.get(i, "NA"))
            f.write("\t".join(row) + "\n")

def main():
    parser = argparse.ArgumentParser(description='处理基因-代谢物相关性文件的交集和并集')
    parser.add_argument('files', nargs='+', help='输入文件列表')
    parser.add_argument('-o', '--output', default='output', 
                        help='输出文件前缀 (默认: "output")')
    parser.add_argument('-m', '--min-files', type=int, default=2,
                        help='最小文件数要求 (默认: 2)')
    args = parser.parse_args()
    
    input_files = args.files
    num_files = len(input_files)
    output_prefix = args.output
    min_files = args.min_files
    
    if min_files < 1:
        print("错误: 最小文件数必须至少为1")
        sys.exit(1)
    
    if num_files < min_files:
        print(f"错误: 需要至少 {min_files} 个输入文件")
        sys.exit(1)
    
    # 处理文件
    first_value, file_count, cluster_mapping = process_files(input_files)
    
    # 创建输出文件
    union_file = f"{output_prefix}_union.txt"
    intersection_file = f"{output_prefix}_intersection.txt"
    filtered_file = f"{output_prefix}_min{min_files}.txt"
    mapping_file = f"{output_prefix}_cluster_mapping.txt"
    
    # 写入并集文件 (所有唯一代谢物对)
    with open(union_file, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorrelation\n")
        for pair, corr in first_value.items():
            f.write(f"{pair[0]}\t{pair[1]}\t{corr}\n")
    
    # 写入交集文件 (存在于所有文件中的代谢物对)
    with open(intersection_file, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorrelation\n")
        for pair, count in file_count.items():
            if count == num_files:
                corr = first_value[pair]
                f.write(f"{pair[0]}\t{pair[1]}\t{corr}\n")
    
    # 写入过滤文件 (存在于至少min_files个文件中的代谢物对)
    with open(filtered_file, 'w') as f:
        f.write("Metabolite1\tMetabolite2\tCorrelation\tFileCount\n")
        for pair, count in file_count.items():
            if count >= min_files:
                corr = first_value[pair]
                f.write(f"{pair[0]}\t{pair[1]}\t{corr}\t{count}\n")
    
    # 写入聚类映射文件
    write_cluster_mapping(cluster_mapping, input_files, mapping_file)
    
    print(f"处理完成! 结果已保存:")
    print(f"- 并集文件: {union_file}")
    print(f"- 交集文件: {intersection_file}")
    print(f"- 过滤文件 (≥{min_files}个文件): {filtered_file}")
    print(f"- 聚类映射文件: {mapping_file}")

if __name__ == "__main__":
    main()
