#!/usr/bin/env python3
import argparse
import os
import sys
import re
from collections import defaultdict

def extract_cluster_id(gene_id):
    """从基因ID中提取聚类编号(C后面的数字)"""
    # 使用正则表达式匹配聚类编号
    match = re.search(r'\.C(\d+)\.', gene_id)
    if match:
        return match.group(1)
    return None

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='提取同聚类(C编号相同)的调控对',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('input_file', help='调控文件（三列：基因1 基因2 相关性）')
    parser.add_argument('-o', '--output', default='same_cluster_pairs.txt', 
                        help='输出文件名（默认: "same_cluster_pairs.txt"）')
    parser.add_argument('--min-correlation', type=float, default=0.0,
                        help='最小相关性阈值（默认: 0.0）')
    parser.add_argument('--max-correlation', type=float, default=1.0,
                        help='最大相关性阈值（默认: 1.0）')
    parser.add_argument('--cluster-map', action='store_true',
                        help='额外输出聚类映射文件')
    
    args = parser.parse_args()
    
    # 存储聚类信息
    cluster_pairs = []
    cluster_stats = defaultdict(int)
    gene_clusters = defaultdict(set)
    cluster_genes = defaultdict(set)
    
    total_pairs = 0
    same_cluster_count = 0
    cluster_id_errors = 0
    
    try:
        with open(args.input_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                # 跳过空行和注释行
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                    
                parts = line.split()
                
                # 验证行格式
                if len(parts) < 3:
                    print(f"警告: 第 {line_num} 行格式错误 (跳过): {line}")
                    continue
                
                gene1, gene2, corr_str = parts[:3]
                
                # 解析相关性值
                try:
                    correlation = float(corr_str)
                except ValueError:
                    print(f"警告: 第 {line_num} 行相关性值无效 (跳过): {corr_str}")
                    continue
                
                # 检查相关性阈值
                if not (args.min_correlation <= abs(correlation) <= args.max_correlation):
                    continue
                
                total_pairs += 1
                
                # 提取聚类ID
                cluster1 = extract_cluster_id(gene1)
                cluster2 = extract_cluster_id(gene2)
                
                # 检查聚类ID是否有效
                if cluster1 is None or cluster2 is None:
                    cluster_id_errors += 1
                    continue
                
                # 记录基因聚类信息
                gene_clusters[gene1].add(cluster1)
                gene_clusters[gene2].add(cluster2)
                cluster_genes[cluster1].add(gene1)
                cluster_genes[cluster2].add(gene2)
                
                # 检查是否同聚类
                if cluster1 == cluster2:
                    same_cluster_count += 1
                    cluster_stats[cluster1] += 1
                    cluster_pairs.append((gene1, gene2, correlation, cluster1))
    
    except Exception as e:
        print(f"错误: 无法读取输入文件 {args.input_file}: {str(e)}")
        sys.exit(1)
    
    # 输出结果
    try:
        with open(args.output, 'w') as fout:
            # 写入标题行
            fout.write("Gene1\tGene2\tCorrelation\tCluster\n")
            
            # 写入同聚类调控对
            for pair in cluster_pairs:
                fout.write("\t".join(map(str, pair)) + "\n")
        
        # 控制台输出摘要
        print(f"分析完成! 结果已保存到: {args.output}")
        print(f"- 总调控对数: {total_pairs}")
        print(f"- 同聚类调控对数: {same_cluster_count} (占比: {same_cluster_count/total_pairs*100:.2f}%)")
        print(f"- 聚类ID提取错误数: {cluster_id_errors}")
        
        # 聚类统计信息
        if cluster_stats:
            print("\n聚类统计:")
            # 按调控对数量排序
            sorted_clusters = sorted(cluster_stats.items(), key=lambda x: x[1], reverse=True)
            
            # 输出前10大聚类
            print("\n调控对最多的聚类:")
            for cluster, count in sorted_clusters[:10]:
                print(f"- 聚类 C{cluster}: {count} 对调控对")
            
            # 输出基因最多的聚类
            cluster_gene_counts = [(c, len(genes)) for c, genes in cluster_genes.items()]
            sorted_by_genes = sorted(cluster_gene_counts, key=lambda x: x[1], reverse=True)
            
            print("\n基因最多的聚类:")
            for cluster, gene_count in sorted_by_genes[:5]:
                print(f"- 聚类 C{cluster}: {gene_count} 个基因")
            
            # 输出多聚类基因
            multi_cluster_genes = {gene: clusters for gene, clusters in gene_clusters.items() if len(clusters) > 1}
            if multi_cluster_genes:
                print(f"\n跨多个聚类的基因 ({len(multi_cluster_genes)} 个):")
                for gene, clusters in list(multi_cluster_genes.items())[:5]:
                    print(f"- {gene}: 聚类 {'、'.join(f'C{c}' for c in clusters)}")
        
        # 生成聚类映射文件
        if args.cluster_map:
            cluster_map_file = "cluster_gene_mapping.txt"
            with open(cluster_map_file, 'w') as fmap:
                fmap.write("Cluster\tGenes\n")
                for cluster, genes in sorted(cluster_genes.items()):
                    gene_list = ",".join(sorted(genes))
                    fmap.write(f"C{cluster}\t{gene_list}\n")
            print(f"\n聚类-基因映射文件已保存到: {cluster_map_file}")
    
    except Exception as e:
        print(f"错误: 无法写入输出文件 {args.output}: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
