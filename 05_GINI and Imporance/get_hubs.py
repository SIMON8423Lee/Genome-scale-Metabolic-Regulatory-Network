#!/usr/bin/env python3
import argparse
import sys
from collections import defaultdict

def identify_node_type(node_id):
    """根据节点ID识别节点类型"""
    if node_id.startswith("TF.") or node_id.startswith("SG."):
        return "gene"
    elif node_id.startswith("TM"):
        return "metabolite"
    else:
        return "unknown"

def extract_hubs(input_file, output_file, threshold):
    """从union调控文件中提取hub节点"""
    # 统计节点连通性
    gene_degrees = defaultdict(int)
    metabolite_degrees = defaultdict(int)
    unknown_degrees = defaultdict(int)
    total_edges = 0
    
    with open(input_file, 'r') as f:
        # 读取并跳过标题行
        header = f.readline().strip().split('\t')
        if len(header) < 4 or header[0] == "node1" and header[1] == "node2":
            # 有效标题行，已跳过
            pass
        else:
            # 可能是无标题文件，回退到文件开头
            f.seek(0)
        
        # 处理数据行
        for line in f:
            fields = line.strip().split('\t')
            if len(fields) < 4:
                continue
                
            node1 = fields[0].strip()
            node2 = fields[1].strip()
            
            # 识别节点类型并更新连通性计数
            type1 = identify_node_type(node1)
            type2 = identify_node_type(node2)
            
            if type1 == "gene":
                gene_degrees[node1] += 1
            elif type1 == "metabolite":
                metabolite_degrees[node1] += 1
            else:
                unknown_degrees[node1] += 1
                
            if type2 == "gene":
                gene_degrees[node2] += 1
            elif type2 == "metabolite":
                metabolite_degrees[node2] += 1
            else:
                unknown_degrees[node2] += 1
                
            total_edges += 1
    
    # 筛选hub节点
    gene_hubs = [(node, deg) for node, deg in gene_degrees.items() if deg >= threshold]
    metab_hubs = [(node, deg) for node, deg in metabolite_degrees.items() if deg >= threshold]
    unknown_hubs = [(node, deg) for node, deg in unknown_degrees.items() if deg >= threshold]
    
    # 按连通性降序排序
    gene_hubs.sort(key=lambda x: x[1], reverse=True)
    metab_hubs.sort(key=lambda x: x[1], reverse=True)
    unknown_hubs.sort(key=lambda x: x[1], reverse=True)
    
    # 写入输出文件
    with open(output_file, 'w') as fout:
        # 写入标题行
        fout.write("Node_ID\tNode_Type\tDegree\n")
        
        # 写入基因hub节点
        for node, degree in gene_hubs:
            fout.write(f"{node}\tgene\t{degree}\n")
        
        # 写入代谢物hub节点
        for node, degree in metab_hubs:
            fout.write(f"{node}\tmetabolite\t{degree}\n")
        
        # 写入未知类型hub节点
        for node, degree in unknown_hubs:
            fout.write(f"{node}\tunknown\t{degree}\n")
    
    # 统计信息
    print(f"分析完成! 结果已保存到 {output_file}")
    print(f"- 处理边数: {total_edges}")
    print(f"- 唯一基因数: {len(gene_degrees)}")
    print(f"- 唯一代谢物数: {len(metabolite_degrees)}")
    print(f"- 唯一未知节点数: {len(unknown_degrees)}")
    print(f"- 基因hub节点数: {len(gene_hubs)} (连通性 ≥ {threshold})")
    print(f"- 代谢物hub节点数: {len(metab_hubs)} (连通性 ≥ {threshold})")
    print(f"- 未知类型hub节点数: {len(unknown_hubs)} (连通性 ≥ {threshold})")
    
    # 显示前10个hub节点
    all_hubs = gene_hubs + metab_hubs + unknown_hubs
    all_hubs.sort(key=lambda x: x[1], reverse=True)
    
    if all_hubs:
        print("\nTop 10 hub节点:")
        for i, (node, degree) in enumerate(all_hubs[:10], 1):
            node_type = identify_node_type(node)
            print(f"{i}. {node} ({node_type}): {degree} 连接")
    else:
        print("\n警告: 未发现任何hub节点! 请尝试降低阈值")

def main():
    parser = argparse.ArgumentParser(
        description='从union调控文件中提取hub基因或代谢物',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('input', help='输入文件 (union调控文件，格式: node1 node2 Source Corr)')
    parser.add_argument('-t', '--threshold', type=int, default=10,
                        help='连通性阈值 (节点连接数必须≥此值才被视为hub)')
    parser.add_argument('-o', '--output', default='hub_nodes.txt', 
                        help='输出文件名 (默认: "hub_nodes.txt")')
    
    args = parser.parse_args()
    
    extract_hubs(args.input, args.output, args.threshold)

if __name__ == "__main__":
    main()
