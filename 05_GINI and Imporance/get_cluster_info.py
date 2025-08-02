#!/usr/bin/env python3
import argparse
import os
import sys

def extract_clusters(id_file, cluster_file, output_file):
    """根据基础ID提取聚类信息，不存在时标记为C0"""
    # 读取基础ID文件
    base_ids = []
    seen_ids = set()
    with open(id_file, 'r') as f:
        for line in f:
            base_id = line.strip()
            if base_id and base_id not in seen_ids:  # 忽略空行和重复ID
                base_ids.append(base_id)
                seen_ids.add(base_id)
    
    print(f"已加载 {len(base_ids)} 个唯一基础ID")
    
    # 读取聚类信息文件并构建映射字典
    cluster_map = {}
    with open(cluster_file, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) < 3:
                continue  # 跳过格式不正确的行
                
            original_id = parts[0].strip()
            clustered_id = parts[1].strip()
            cluster = parts[2].strip()
            
            # 添加到映射字典
            cluster_map[original_id] = (clustered_id, cluster)
    
    print(f"已加载 {len(cluster_map)} 个聚类映射")
    
    # 提取匹配的聚类信息并处理未匹配项
    matched_count = 0
    unmatched_count = 0
    
    with open(output_file, 'w') as fout:
        # 写入标题行
        fout.write("Original_ID\tClustered_ID\tCluster\n")
        
        # 处理每个基础ID
        for base_id in base_ids:
            if base_id in cluster_map:
                # 存在聚类信息
                clustered_id, cluster = cluster_map[base_id]
                fout.write(f"{base_id}\t{clustered_id}\t{cluster}\n")
                matched_count += 1
            else:
                # 不存在聚类信息，标记为C0
                fout.write(f"{base_id}\t{base_id}\tC0\n")
                unmatched_count += 1
    
    # 统计信息
    print(f"处理完成! 结果已保存到 {output_file}")
    print(f"- 匹配的聚类信息: {matched_count} ({matched_count/len(base_ids)*100:.1f}%)")
    print(f"- 未匹配的ID(标记为C0): {unmatched_count} ({unmatched_count/len(base_ids)*100:.1f}%)")
    
    # 可选：保存未匹配ID列表
    if unmatched_count > 0:
        unmatched_file = os.path.splitext(output_file)[0] + "_unmatched_ids.txt"
        with open(unmatched_file, 'w') as f:
            for base_id in base_ids:
                if base_id not in cluster_map:
                    f.write(f"{base_id}\n")
        print(f"- 未匹配ID列表已保存到: {unmatched_file}")

def main():
    parser = argparse.ArgumentParser(
        description='根据基础ID提取聚类信息（不存在时标记为C0）',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('id_file', help='基础ID文件（单列文件）')
    parser.add_argument('cluster_file', help='聚类信息文件（格式: original_id\\tclustered_id\\tcluster）')
    parser.add_argument('-o', '--output', default='extracted_clusters.txt', 
                        help='输出文件名 (默认: "extracted_clusters.txt")')
    args = parser.parse_args()
    
    extract_clusters(args.id_file, args.cluster_file, args.output)

if __name__ == "__main__":
    main()
