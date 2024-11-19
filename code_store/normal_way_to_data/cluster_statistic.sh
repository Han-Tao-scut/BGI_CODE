#!/bin/bash

# 定义包含 .clstr 文件的目录
clstr_dir="/data/input/Files/ResultData/Notebook/hantao/marine/classified_cdhit/classified_to_12_cdhit_c07_result"  # 请替换为你的目录路径
# 初始化总聚类数量和总序列数量的计数器
total_clusters=0
total_sequences=0

# 遍历该目录下的所有 .clstr 文件
for clstr_file in "$clstr_dir"/*.clstr; do
    # 检查文件是否存在
    if [[ -f "$clstr_file" ]]; then
        # 获取文件名
        filename=$(basename "$clstr_file")
        
        # 统计总的聚类数量
        cluster_count=$(grep -c "^>Cluster" "$clstr_file")
        
        # 统计总的被聚类的序列数量
        sequence_count=$(grep -v "^>Cluster" "$clstr_file" | grep -c "aa, >")
        
        # 输出统计信息
        echo "文件: $filename"
        echo "  总的聚类数量: $cluster_count"
        echo "  总的被聚类的序列数量: $sequence_count"
        echo "-----------------------------"

        # 更新总计数器
        total_clusters=$((total_clusters + cluster_count))
        total_sequences=$((total_sequences + sequence_count))
    else
        echo "未找到任何 .clstr 文件"
    fi
done

# 输出总和统计信息
echo "所有文件统计的汇总："
echo "  总聚类数量: $total_clusters"
echo "  总被聚类的序列数量: $total_sequences"