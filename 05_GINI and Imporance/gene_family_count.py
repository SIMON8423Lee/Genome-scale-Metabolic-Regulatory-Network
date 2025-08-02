#!/usr/bin/env python3
import argparse
import sys
from collections import defaultdict

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='统计基因ID文件中每个基因家族的基因数量并排序',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('family_file', help='基因家族文件（两列：基因ID 家族名称）')
    parser.add_argument('gene_file', help='基因ID文件（单列）')
    parser.add_argument('-o', '--output', default='family_counts.txt', 
                        help='输出文件名（默认: "family_counts.txt"）')
    
    args = parser.parse_args()
    
    # 步骤1: 读取基因家族文件
    gene_family = {}
    family_genes = defaultdict(set)
    
    try:
        with open(args.family_file, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    gene_id = parts[0]
                    family = parts[1]
                    gene_family[gene_id] = family
                    family_genes[family].add(gene_id)
    except Exception as e:
        print(f"错误: 无法读取家族文件 {args.family_file}: {str(e)}")
        sys.exit(1)
    
    # 步骤2: 读取基因ID文件
    gene_ids = set()
    try:
        with open(args.gene_file, 'r') as f:
            for line in f:
                gene_id = line.strip()
                if gene_id:
                    gene_ids.add(gene_id)
    except Exception as e:
        print(f"错误: 无法读取基因文件 {args.gene_file}: {str(e)}")
        sys.exit(1)
    
    # 步骤3: 统计每个家族的基因数量
    family_counts = defaultdict(int)
    unclassified = 0
    
    for gene_id in gene_ids:
        if gene_id in gene_family:
            family = gene_family[gene_id]
            family_counts[family] += 1
        else:
            unclassified += 1
    
    # 步骤4: 按基因数量排序（降序）
    sorted_families = sorted(
        family_counts.items(), 
        key=lambda x: (-x[1], x[0])  # 先按数量降序，再按家族名升序
    )
    
    # 步骤5: 输出结果
    try:
        with open(args.output, 'w') as fout:
            # 写入标题行
            fout.write("Family\tGene_Count\n")
            
            # 写入各家族统计
            for family, count in sorted_families:
                fout.write(f"{family}\t{count}\n")
            
            # 写入未分类基因统计
            if unclassified > 0:
                fout.write(f"\n# Unclassified genes: {unclassified}\n")
                fout.write(f"# Total genes in input: {len(gene_ids)}\n")
                fout.write(f"# Percentage classified: {100 * (len(gene_ids) - unclassified) / len(gene_ids):.2f}%\n")
        
        # 控制台输出摘要
        print(f"分析完成! 结果已保存到 {args.output}")
        print(f"- 总基因数: {len(gene_ids)}")
        print(f"- 分类基因数: {len(gene_ids) - unclassified}")
        print(f"- 未分类基因数: {unclassified}")
        print(f"- 发现家族数: {len(sorted_families)}")
        
        if sorted_families:
            print("\nTop 5 基因家族:")
            for i, (family, count) in enumerate(sorted_families[:5], 1):
                print(f"{i}. {family}: {count} 个基因")
        
    except Exception as e:
        print(f"错误: 无法写入输出文件 {args.output}: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
