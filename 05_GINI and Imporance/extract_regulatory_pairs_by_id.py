#!/usr/bin/env python3
import argparse
import os
import sys
from collections import defaultdict

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='从基因调控网络中提取包含指定基因的调控对',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('network_file', help='基因调控网络文件（四列：node1 node2 Source Corr）')
    parser.add_argument('gene_file', help='基因ID文件（单列）')
    parser.add_argument('-o', '--output', default='gene_regulatory_pairs.txt', 
                        help='输出文件名（默认: "gene_regulatory_pairs.txt"）')
    parser.add_argument('--include-self', action='store_true',
                        help='包含自身调控对（当node1和node2相同时）')
    parser.add_argument('--min-corr', type=float, default=0.0,
                        help='最小相关性阈值（默认: 0.0）')
    parser.add_argument('--max-corr', type=float, default=1.0,
                        help='最大相关性阈值（默认: 1.0）')
    parser.add_argument('--sources', nargs='+', default=[],
                        help='只提取特定来源的调控对（例如: coexpression TFbinding）')
    
    args = parser.parse_args()
    
    # 步骤1: 读取基因ID文件
    target_genes = set()
    try:
        with open(args.gene_file, 'r') as f:
            for line in f:
                gene_id = line.strip()
                if gene_id:
                    target_genes.add(gene_id)
        print(f"已读取 {len(target_genes)} 个目标基因")
    except Exception as e:
        print(f"错误: 无法读取基因文件 {args.gene_file}: {str(e)}")
        sys.exit(1)
    
    # 步骤2: 处理网络文件
    regulatory_pairs = []
    total_pairs = 0
    sources_count = defaultdict(int)
    
    try:
        with open(args.network_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                # 跳过空行
                if not line.strip():
                    continue
                    
                parts = line.strip().split()
                
                # 验证行格式
                if len(parts) < 4:
                    print(f"警告: 第 {line_num} 行格式错误 (跳过): {line.strip()}")
                    continue
                
                node1, node2, source, corr_str = parts[:4]
                
                # 解析相关性值
                try:
                    corr = float(corr_str)
                except ValueError:
                    print(f"警告: 第 {line_num} 行相关性值无效 (跳过): {corr_str}")
                    continue
                
                # 跳过自身调控对（如果未指定包含）
                if not args.include_self and node1 == node2:
                    continue
                
                # 检查相关性阈值
                if not (args.min_corr <= abs(corr) <= args.max_corr):
                    continue
                
                # 检查来源过滤
                if args.sources and source not in args.sources:
                    continue
                
                total_pairs += 1
                sources_count[source] += 1
                
                # 检查是否包含目标基因
                if node1 in target_genes or node2 in target_genes:
                    regulatory_pairs.append((node1, node2, source, corr))
    
    except Exception as e:
        print(f"错误: 无法读取网络文件 {args.network_file}: {str(e)}")
        sys.exit(1)
    
    # 步骤3: 输出结果
    try:
        with open(args.output, 'w') as fout:
            # 写入标题行
            fout.write("Node1\tNode2\tSource\tCorrelation\n")
            
            # 写入调控对
            for pair in regulatory_pairs:
                fout.write("\t".join(map(str, pair)) + "\n")
        
        # 控制台输出摘要
        print(f"\n分析完成! 结果已保存到 {args.output}")
        print(f"- 网络文件总调控对数: {total_pairs}")
        print(f"- 提取到的相关调控对数: {len(regulatory_pairs)}")
        print(f"- 包含目标基因的调控对占比: {len(regulatory_pairs)/total_pairs*100:.2f}%")
        
        if sources_count:
            print("\n调控来源统计:")
            for source, count in sorted(sources_count.items()):
                print(f"- {source}: {count} 对")
        
        # 统计每个基因的调控关系
        gene_regulation = defaultdict(lambda: {"regulates": 0, "regulated_by": 0})
        for node1, node2, _, _ in regulatory_pairs:
            if node1 in target_genes:
                gene_regulation[node1]["regulates"] += 1
            if node2 in target_genes:
                gene_regulation[node2]["regulated_by"] += 1
        
        if gene_regulation:
            print("\n目标基因调控关系统计:")
            print("Gene\tRegulates\tRegulatedBy\tTotal")
            for gene, counts in sorted(gene_regulation.items()):
                total = counts["regulates"] + counts["regulated_by"]
                print(f"{gene}\t{counts['regulates']}\t{counts['regulated_by']}\t{total}")
            
            # 找出调控关系最多的基因
            most_active = max(gene_regulation.items(), key=lambda x: x[1]["regulates"])
            most_targeted = max(gene_regulation.items(), key=lambda x: x[1]["regulated_by"])
            
            print(f"\n- 最活跃调控基因: {most_active[0]} (调控 {most_active[1]['regulates']} 个基因)")
            print(f"- 最受调控基因: {most_targeted[0]} (被 {most_targeted[1]['regulated_by']} 个基因调控)")
    
    except Exception as e:
        print(f"错误: 无法写入输出文件 {args.output}: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
