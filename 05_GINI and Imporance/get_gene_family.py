#!/usr/bin/env python3
import argparse
import sys
import os
from collections import defaultdict

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='统计基因家族分布并输出具体基因列表',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('family_file', help='基因家族文件（两列：基因ID 家族名称）')
    parser.add_argument('gene_file', help='基因ID文件（单列）')
    parser.add_argument('-o', '--output', default='family_counts.txt', 
                        help='输出文件名（默认: "family_counts.txt"）')
    parser.add_argument('-l', '--list-genes', action='store_true',
                        help='输出每个家族的具体基因列表')
    parser.add_argument('-d', '--gene-list-dir', default='gene_lists',
                        help='基因列表输出目录（默认: "gene_lists"）')
    parser.add_argument('-e', '--extract-family', 
                        help='提取特定家族的基因列表（输出到单独文件）')
    
    args = parser.parse_args()
    
    # 步骤1: 读取基因家族文件
    gene_family = {}
    
    try:
        with open(args.family_file, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    gene_id = parts[0]
                    family = parts[1]
                    gene_family[gene_id] = family
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
    
    # 步骤3: 统计每个家族的基因
    family_genes = defaultdict(list)
    unclassified = []
    
    for gene_id in gene_ids:
        if gene_id in gene_family:
            family = gene_family[gene_id]
            family_genes[family].append(gene_id)
        else:
            unclassified.append(gene_id)
    
    # 步骤4: 按基因数量排序（降序）
    sorted_families = sorted(
        family_genes.items(), 
        key=lambda x: (-len(x[1]), x[0])  # 先按数量降序，再按家族名升序
    )
    
    # 步骤5: 输出结果
    try:
        # 创建基因列表输出目录
        if args.list_genes or args.extract_family:
            os.makedirs(args.gene_list_dir, exist_ok=True)
        
        with open(args.output, 'w') as fout:
            # 写入标题行
            fout.write("Family\tGene_Count\n")
            
            # 写入各家族统计
            for family, genes in sorted_families:
                count = len(genes)
                fout.write(f"{family}\t{count}\n")
                
                # 如果需要输出基因列表
                if args.list_genes:
                    gene_list_file = os.path.join(args.gene_list_dir, f"{family}.txt")
                    with open(gene_list_file, 'w') as fgene:
                        fgene.write("\n".join(sorted(genes)))
            
            # 写入未分类基因统计
            if unclassified:
                fout.write(f"\n# Unclassified genes: {len(unclassified)}\n")
                fout.write(f"# Total genes in input: {len(gene_ids)}\n")
                fout.write(f"# Percentage classified: {100 * (len(gene_ids) - len(unclassified)) / len(gene_ids):.2f}%\n")
                
                # 输出未分类基因列表
                if args.list_genes:
                    unclassified_file = os.path.join(args.gene_list_dir, "unclassified_genes.txt")
                    with open(unclassified_file, 'w') as fun:
                        fun.write("\n".join(sorted(unclassified)))
        
        # 如果指定提取特定家族
        if args.extract_family:
            extracted_family = args.extract_family
            extracted_genes = []
            
            # 查找指定家族
            for family, genes in family_genes.items():
                if family == extracted_family:
                    extracted_genes = genes
                    break
            
            if extracted_genes:
                # 创建输出文件名
                base_name = os.path.splitext(os.path.basename(args.gene_file))[0]
                output_file = f"{extracted_family}_genes_{base_name}.txt"
                output_path = os.path.join(args.gene_list_dir, output_file)
                
                # 写入提取的基因
                with open(output_path, 'w') as fout:
                    fout.write("\n".join(sorted(extracted_genes)))
                
                print(f"\n已提取家族 '{extracted_family}' 的 {len(extracted_genes)} 个基因")
                print(f"- 输出文件: {output_path}")
            else:
                print(f"\n警告: 未找到家族 '{extracted_family}' 或该家族在输入基因中不存在")
        
        # 控制台输出摘要
        print(f"\n分析完成! 结果已保存到 {args.output}")
        print(f"- 总基因数: {len(gene_ids)}")
        print(f"- 分类基因数: {len(gene_ids) - len(unclassified)}")
        print(f"- 未分类基因数: {len(unclassified)}")
        print(f"- 发现家族数: {len(sorted_families)}")
        
        if sorted_families:
            print("\nTop 5 基因家族:")
            for i, (family, genes) in enumerate(sorted_families[:5], 1):
                print(f"{i}. {family}: {len(genes)} 个基因")
        
        # 如果输出了基因列表
        if args.list_genes:
            print(f"\n基因列表已保存到目录: {args.gene_list_dir}")
            if unclassified:
                print(f"- 未分类基因列表: {os.path.join(args.gene_list_dir, 'unclassified_genes.txt')}")
        
    except Exception as e:
        print(f"错误: 无法写入输出文件: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
