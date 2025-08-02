#!/usr/bin/env python3
import argparse
import os
import sys

def load_cluster_mapping(cluster_file):
    cluster_map = {}
    with open(cluster_file, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 2:
                original_id = parts[0].strip()
                clustered_id = parts[1].strip()
                cluster_map[original_id] = clustered_id
    return cluster_map

def process_union_file(union_file, cluster_map, output_file):
    with open(union_file, 'r') as fin, open(output_file, 'w') as fout:
        header = fin.readline().strip()
        if header.startswith("Gene") or header.startswith("Source"):
            fout.write(header.replace("Gene", "Clustered_Gene").replace("Metabolite", "Clustered_Metabolite") + "\n")
        else:
            fin.seek(0)
        
        for line in fin:
            parts = line.strip().split('\t')
            if len(parts) < 4:
                continue
                
            gene_id = parts[0]
            metab_id = parts[1]
            source = parts[2]
            corr = parts[3]
            
            clustered_gene = cluster_map.get(gene_id, gene_id)
            
            clustered_metab = cluster_map.get(metab_id, metab_id)
            
            fout.write(f"{clustered_gene}\t{clustered_metab}\t{source}\t{corr}\n")

def main():
    parser = argparse.ArgumentParser(
        description='将聚类信息添加回union文件',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('cluster_file', help='聚类信息文件 (格式: original_id\\tclustered_id)')
    parser.add_argument('union_file', help='最终union文件 (格式: Gene\\tMetabolite\\tSource\\tCorr)')
    parser.add_argument('-o', '--output', default='union_with_clusters.txt', 
                        help='输出文件名 (默认: "union_with_clusters.txt")')
    args = parser.parse_args()
    
    cluster_map = load_cluster_mapping(args.cluster_file)
    print(f"已加载 {len(cluster_map)} 个聚类映射")
    
    process_union_file(args.union_file, cluster_map, args.output)
    print(f"处理完成! 结果已保存到 {args.output}")

if __name__ == "__main__":
    main()
