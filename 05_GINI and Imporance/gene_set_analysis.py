#!/usr/bin/env python3
import argparse
import os
import sys
from collections import defaultdict

def read_gene_ids(file_path):
    """读取基因ID文件，返回基因集合"""
    gene_set = set()
    try:
        with open(file_path, 'r') as f:
            for line in f:
                gene_id = line.strip()
                if gene_id:  # 忽略空行
                    gene_set.add(gene_id)
        return gene_set
    except Exception as e:
        print(f"错误: 无法读取文件 {file_path}: {str(e)}")
        sys.exit(1)

def process_gene_sets(file_paths):
    """处理所有基因集文件"""
    gene_sets = {}
    file_names = {}
    
    # 读取所有文件
    for file_path in file_paths:
        base_name = os.path.basename(file_path)
        file_key = os.path.splitext(base_name)[0]  # 不带扩展名的文件名
        gene_set = read_gene_ids(file_path)
        gene_sets[file_key] = gene_set
        file_names[file_key] = base_name  # 保存原始文件名
    
    # 计算所有文件的并集
    all_union = set()
    for gene_set in gene_sets.values():
        all_union |= gene_set
    
    # 计算所有文件的交集
    all_intersection = all_union.copy()  # 从并集开始
    for gene_set in gene_sets.values():
        all_intersection &= gene_set
    
    # 计算两两之间的交集和并集
    pairwise_results = defaultdict(dict)
    file_keys = list(gene_sets.keys())
    
    for i in range(len(file_keys)):
        for j in range(i + 1, len(file_keys)):
            key1, key2 = file_keys[i], file_keys[j]
            set1, set2 = gene_sets[key1], gene_sets[key2]
            
            # 计算交集和并集
            intersection = set1 & set2
            union = set1 | set2
            
            # 保存结果
            pairwise_results[(key1, key2)] = {
                'intersection': intersection,
                'union': union,
                'intersection_size': len(intersection),
                'union_size': len(union),
                'jaccard': len(intersection) / len(union) if len(union) > 0 else 0
            }
    
    return {
        'gene_sets': gene_sets,
        'all_intersection': all_intersection,
        'all_union': all_union,
        'pairwise_results': pairwise_results,
        'file_names': file_names
    }

def save_results(results, output_dir):
    """保存所有结果到文件"""
    os.makedirs(output_dir, exist_ok=True)
    
    # 保存全局交集
    with open(os.path.join(output_dir, "global_intersection.txt"), 'w') as f:
        f.write("\n".join(sorted(results['all_intersection'])))
    
    # 保存全局并集
    with open(os.path.join(output_dir, "global_union.txt"), 'w') as f:
        f.write("\n".join(sorted(results['all_union'])))
    
    # 保存各文件基因集
    for key, gene_set in results['gene_sets'].items():
        with open(os.path.join(output_dir, f"{key}_genes.txt"), 'w') as f:
            f.write("\n".join(sorted(gene_set)))
    
    # 保存两两比较结果
    pairwise_dir = os.path.join(output_dir, "pairwise_comparisons")
    os.makedirs(pairwise_dir, exist_ok=True)
    
    for (key1, key2), data in results['pairwise_results'].items():
        # 交集文件
        with open(os.path.join(pairwise_dir, f"intersection_{key1}_{key2}.txt"), 'w') as f:
            f.write("\n".join(sorted(data['intersection'])))
        
        # 并集文件
        with open(os.path.join(pairwise_dir, f"union_{key1}_{key2}.txt"), 'w') as f:
            f.write("\n".join(sorted(data['union'])))
    
    # 生成统计报告
    generate_statistics_report(results, output_dir)

def generate_statistics_report(results, output_dir):
    """生成统计报告"""
    report_path = os.path.join(output_dir, "gene_set_statistics.txt")
    
    with open(report_path, 'w') as report:
        # 文件基本信息
        report.write("基因集分析报告\n")
        report.write("=" * 50 + "\n\n")
        
        # 各文件统计
        report.write("各文件基因数量:\n")
        report.write("-" * 50 + "\n")
        for key, gene_set in results['gene_sets'].items():
            report.write(f"{results['file_names'][key]}: {len(gene_set)} 个基因\n")
        
        # 全局统计
        report.write("\n全局统计:\n")
        report.write("-" * 50 + "\n")
        report.write(f"全局交集基因数量: {len(results['all_intersection'])}\n")
        report.write(f"全局并集基因数量: {len(results['all_union'])}\n")
        
        # 两两比较统计
        report.write("\n两两比较统计:\n")
        report.write("-" * 50 + "\n")
        for (key1, key2), data in results['pairwise_results'].items():
            file1 = results['file_names'][key1]
            file2 = results['file_names'][key2]
            report.write(f"{file1} vs {file2}:\n")
            report.write(f"  交集大小: {data['intersection_size']}\n")
            report.write(f"  并集大小: {data['union_size']}\n")
            report.write(f"  Jaccard相似系数: {data['jaccard']:.4f}\n\n")
        
        # 基因ID示例
        report.write("\n全局交集基因示例 (最多10个):\n")
        report.write("-" * 50 + "\n")
        for gene in sorted(results['all_intersection'])[:10]:
            report.write(f"{gene}\n")
        
        if not results['all_intersection']:
            report.write("(无交集基因)\n")

def main():
    parser = argparse.ArgumentParser(
        description='提取多个基因ID文件间的交集与并集',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('files', nargs='+', help='输入文件列表（包含基因ID的单列文件）')
    parser.add_argument('-o', '--output', default='gene_set_results', 
                        help='输出目录（默认: "gene_set_results"）')
    
    args = parser.parse_args()
    
    # 验证输入文件
    for file_path in args.files:
        if not os.path.isfile(file_path):
            print(f"错误: 文件不存在 - {file_path}")
            sys.exit(1)
    
    # 处理基因集
    results = process_gene_sets(args.files)
    
    # 保存结果
    save_results(results, args.output)
    
    print(f"\n分析完成! 结果已保存到 {args.output} 目录")
    print(f"- 全局交集基因数: {len(results['all_intersection'])}")
    print(f"- 全局并集基因数: {len(results['all_union'])}")
    
    # 显示两两比较的Jaccard系数
    if results['pairwise_results']:
        print("\n文件间相似性 (Jaccard系数):")
        for (key1, key2), data in results['pairwise_results'].items():
            file1 = results['file_names'][key1]
            file2 = results['file_names'][key2]
            print(f"- {file1} vs {file2}: {data['jaccard']:.4f}")

if __name__ == "__main__":
    main()
