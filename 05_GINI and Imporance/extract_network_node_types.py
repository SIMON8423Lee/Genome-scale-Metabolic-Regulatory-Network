#!/usr/bin/env python3
import argparse
import os
import sys
import re
from collections import defaultdict

def determine_node_type(node_id):
    """根据节点ID确定节点类型"""
    # 检查SG基因ID格式 (SG.model.contig...)
    if node_id.startswith("SG.") and len(node_id.split('.')) >= 4:
        return "SG"
    
    # 检查TF基因ID格式 (TF.model.contig...)
    if node_id.startswith("TF.") and len(node_id.split('.')) >= 4:
        return "TF"
    
    # 检查代谢物ID格式 (TM后跟数字)
    if re.match(r'^TM\d+$', node_id):
        return "TM"
    
    # 特殊处理可能的TM.model格式
    if node_id.startswith("TM.") and len(node_id.split('.')) >= 4:
        return "TM_gene"  # 可能是转录代谢基因
    
    return "Unknown"

def main():
    # 设置命令行参数
    parser = argparse.ArgumentParser(
        description='从基因调控网络文件中提取节点并标注类型',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('network_file', help='基因调控网络文件（四列：node1 node2 Source Corr）')
    parser.add_argument('-o', '--output', default='node_types.txt', 
                        help='输出文件名（默认: "node_types.txt"）')
    parser.add_argument('--strict', action='store_true',
                        help='严格模式：只接受标准格式的ID')
    
    args = parser.parse_args()
    
    # 存储所有节点及其类型
    node_types = {}
    total_nodes = 0
    
    # 用于统计的字典
    type_counts = defaultdict(int)
    format_issues = defaultdict(list)
    
    try:
        with open(args.network_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                # 跳过空行和注释行
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                    
                parts = line.split()
                
                # 验证行格式
                if len(parts) < 4:
                    print(f"警告: 第 {line_num} 行格式错误 (跳过): {line}")
                    continue
                
                node1, node2 = parts[:2]
                
                # 处理节点1
                if node1 not in node_types:
                    total_nodes += 1
                    node_type = determine_node_type(node1)
                    
                    # 检查格式问题
                    if node_type == "Unknown":
                        if node1.startswith("SG") and '.' not in node1:
                            format_issues["SG_missing_dot"].append(node1)
                        elif node1.startswith("TF") and '.' not in node1:
                            format_issues["TF_missing_dot"].append(node1)
                        elif node1.startswith("TM") and not re.match(r'^TM\d+$', node1):
                            format_issues["TM_invalid"].append(node1)
                    
                    node_types[node1] = node_type
                    type_counts[node_type] += 1
                
                # 处理节点2
                if node2 not in node_types:
                    total_nodes += 1
                    node_type = determine_node_type(node2)
                    
                    # 检查格式问题
                    if node_type == "Unknown":
                        if node2.startswith("SG") and '.' not in node2:
                            format_issues["SG_missing_dot"].append(node2)
                        elif node2.startswith("TF") and '.' not in node2:
                            format_issues["TF_missing_dot"].append(node2)
                        elif node2.startswith("TM") and not re.match(r'^TM\d+$', node2):
                            format_issues["TM_invalid"].append(node2)
                    
                    node_types[node2] = node_type
                    type_counts[node_type] += 1
    
    except Exception as e:
        print(f"错误: 无法读取网络文件 {args.network_file}: {str(e)}")
        sys.exit(1)
    
    # 步骤3: 输出结果
    try:
        with open(args.output, 'w') as fout:
            # 写入标题行
            fout.write("Node_ID\tNode_Type\n")
            
            # 按节点ID排序后输出
            for node_id, node_type in sorted(node_types.items()):
                fout.write(f"{node_id}\t{node_type}\n")
        
        # 控制台输出摘要
        print(f"分析完成! 结果已保存到 {args.output}")
        print(f"- 总节点数: {total_nodes}")
        print(f"- 节点类型分布:")
        for type_name, count in sorted(type_counts.items()):
            print(f"  - {type_name}: {count} 个 ({count/total_nodes*100:.2f}%)")
        
        # 显示节点示例
        print("\n节点示例:")
        sample_nodes = sorted(node_types.keys())[:5]
        for node in sample_nodes:
            print(f"- {node}: {node_types[node]}")
        
        # 报告格式问题
        if format_issues:
            print("\n警告: 检测到可能的ID格式问题:")
            if "SG_missing_dot" in format_issues:
                print(f"- {len(format_issues['SG_missing_dot'])} 个SG节点缺少点号 (如 'SGmodel' 应为 'SG.model')")
            if "TF_missing_dot" in format_issues:
                print(f"- {len(format_issues['TF_missing_dot'])} 个TF节点缺少点号 (如 'TFmodel' 应为 'TF.model')")
            if "TM_invalid" in format_issues:
                print(f"- {len(format_issues['TM_invalid'])} 个TM节点格式无效 (正确格式应为 'TM123')")
            
            # 保存格式问题报告
            issues_file = "node_id_format_issues.txt"
            with open(issues_file, 'w') as f:
                f.write("Node_ID\tIssue_Type\n")
                for issue_type, nodes in format_issues.items():
                    for node in nodes:
                        f.write(f"{node}\t{issue_type}\n")
            print(f"- 详细问题已保存到: {issues_file}")
    
    except Exception as e:
        print(f"错误: 无法写入输出文件 {args.output}: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
