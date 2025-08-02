#!/usr/bin/env python3
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
        match = re.match(r'TM(C?\d+)\.?(\d+)', original_id)
        if match:
            cluster = match.group(1)
            # 确保聚类格式正确
            if not cluster.startswith('C'):
                cluster = f"C{cluster}"
            base_id = f"TM{match.group(2)}"
            return base_id, cluster
    
    # 如果不符合上述模式，返回原始ID和空聚类
    return original_id, "NA"

def process_file(input_file, output_file, mapping_file):
    """处理文件，提取聚类信息"""
    cluster_mapping = defaultdict(lambda: {"cluster": "NA", "original_id": ""})
    
    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        for line in fin:
            parts = line.strip().split()
            if len(parts) < 3:
                continue
            
            # 处理第一列ID
            orig_id1 = parts[0]
            base_id1, cluster1 = extract_cluster_info(orig_id1)
            cluster_mapping[base_id1] = {"cluster": cluster1, "original_id": orig_id1}
            
            # 处理第二列ID
            orig_id2 = parts[1]
            base_id2, cluster2 = extract_cluster_info(orig_id2)
            cluster_mapping[base_id2] = {"cluster": cluster2, "original_id": orig_id2}
            
            # 写入基本ID文件
            fout.write(f"{base_id1}\t{base_id2}\t{parts[2]}\n")
    
    # 写入聚类映射文件
    with open(mapping_file, 'w') as fmap:
        fmap.write("Base_ID\tOriginal_ID\tCluster\n")
        for base_id, info in cluster_mapping.items():
            fmap.write(f"{base_id}\t{info['original_id']}\t{info['cluster']}\n")
    
    print(f"处理完成! 结果已保存:")
    print(f"- 基本ID文件: {output_file}")
    print(f"- 聚类映射文件: {mapping_file}")

def main():
    parser = argparse.ArgumentParser(description='从基因-代谢物文件中提取聚类信息')
    parser.add_argument('input_file', help='输入文件（包含聚类属性）')
    parser.add_argument('-o', '--output', help='基本ID输出文件（默认：输入文件名_base.txt）')
    parser.add_argument('-m', '--mapping', help='聚类映射文件（默认：输入文件名_clusters.txt）')
    args = parser.parse_args()
    
    # 设置默认输出文件名
    base_name = os.path.splitext(os.path.basename(args.input_file))[0]
    output_file = args.output or f"{base_name}_base.txt"
    mapping_file = args.mapping or f"{base_name}_clusters.txt"
    
    process_file(args.input_file, output_file, mapping_file)

if __name__ == "__main__":
    main()
