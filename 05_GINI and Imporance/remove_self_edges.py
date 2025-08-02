#!/usr/bin/env python3
import os
import argparse
import sys

def remove_self_edges(input_file, output_file):
    """
    从调控文件中移除自己与自己的调控对
    输入格式: Gene <tab> 系数 <tab> Metabolite <tab> Rank
    """
    removed_count = 0
    total_count = 0
    
    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        for line_num, line in enumerate(fin, 1):
            # 跳过空行
            if not line.strip():
                continue
                
            parts = line.strip().split()
            total_count += 1
            
            # 检查列数
            if len(parts) < 4:
                print(f"警告: 第 {line_num} 行只有 {len(parts)} 列，需要4列数据。已跳过该行。")
                continue
            
            gene, coefficient, metabolite, rank = parts[0], parts[1], parts[2], parts[3]
            
            # 检查并移除自己与自己的调控对
            if gene == metabolite:
                removed_count += 1
                continue
                
            # 写入有效行
            fout.write(f"{gene}\t{coefficient}\t{metabolite}\t{rank}\n")
    
    print(f"处理完成!")
    print(f"- 总行数: {total_count}")
    print(f"- 移除的自调控对: {removed_count}")
    print(f"- 保留的有效对: {total_count - removed_count}")
    print(f"- 输出文件: {output_file}")

def main():
    parser = argparse.ArgumentParser(
        description='从基因-代谢物调控文件中移除自己与自己的调控对',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('input_file', help='输入文件路径（包含Gene,系数,Metabolite,Rank四列）')
    parser.add_argument('-o', '--output', help='输出文件路径（默认：输入文件名_clean.txt）')
    args = parser.parse_args()
    
    # 设置默认输出文件名
    if args.output:
        output_file = args.output
    else:
        base_name = os.path.splitext(os.path.basename(args.input_file))[0]
        output_file = f"{base_name}_clean.txt"
    
    remove_self_edges(args.input_file, output_file)

if __name__ == "__main__":
    main()
