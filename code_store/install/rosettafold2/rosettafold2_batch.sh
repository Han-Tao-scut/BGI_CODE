#!/bin/bash

# 定义输入的 FASTA 文件
input_fasta="/data/work/input.fasta"  # 请替换为你的输入文件路径
extracted_seq_dir="/data/output/extracted_sequences"  # 存放提取的序列文件的目录
prediction_output_dir="/data/output/rosettafold_predictions"  # 存放 RosettaFold2 预测结果的目录
rosettafold_script="/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/RoseTTAFold2/run_RF2.sh"  # RosettaFold2 预测脚本的路径
time_summary_file="/data/output/average_prediction_time.txt"  # 保存平均预测时间的文件

# 创建输出目录
mkdir -p "$extracted_seq_dir"
mkdir -p "$prediction_output_dir"

# 使用 Bash 和 Awk 提取每一条序列并保存为独立的文件，同时去除结尾的 '*'
echo "提取序列到独立文件..."
awk -v outdir="$extracted_seq_dir" '
    /^>/ {
        if (seq_id) close(file);  # 关闭之前的文件
        split($0, header_parts, "#");  # 分割获取 # 前的唯一标识符
        seq_id = substr(header_parts[1], 2);  # 移除 > 符号并保存唯一标识符
        file = outdir "/" seq_id ".fasta";
        print $0 > file;  # 输出到文件
    }
    /^[^>]/ {
        gsub(/\*$/, "", $0);  # 删除序列行末尾的 '*' 符号
        print $0 >> file;  # 将序列部分追加到文件
    }
' "$input_fasta"

echo "FASTA 文件中所有序列已单独保存到 $extracted_seq_dir"

# 初始化用于记录各个长度区间的总时间和计数
declare -A time_sums
declare -A count_sums

# 获取可用的 GPU 数量
gpu_count=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
echo "检测到 ${gpu_count} 块 GPU 可用，将进行任务分配。"

# 读取所有的序列文件列表
seq_files=("$extracted_seq_dir"/*.fasta)
total_files=${#seq_files[@]}

# 定义一个函数来执行 RosettaFold2 预测
run_prediction() {
    local seq_file=$1
    local gpu_id=$2
    local seq_name=$(basename "$seq_file" .fasta)
    local output_prediction_dir="$prediction_output_dir/${seq_name}_prediction"

    # 创建该序列的预测输出目录
    mkdir -p "$output_prediction_dir"

    # 读取序列长度
    local seq_length=$(grep -v ">" "$seq_file" | tr -d '\n' | wc -c)

    # 记录开始时间
    local start_time=$(date +%s)

    # 设置 GPU ID 并运行 RosettaFold2 进行预测
    CUDA_VISIBLE_DEVICES="$gpu_id" bash "$rosettafold_script" -i "$seq_file" -o "$output_prediction_dir" --use-gpu

    # 记录结束时间
    local end_time=$(date +%s)

    # 计算用时
    local elapsed_time=$((end_time - start_time))

    # 计算所属长度区间 (以 50 为间隔)
    local length_group=$(( (seq_length + 49) / 50 * 50 ))

    # 更新该长度区间的总时间和计数
    echo "$length_group $elapsed_time" >> "${time_summary_file}.tmp"

    echo "预测完成: $seq_file -> $output_prediction_dir (使用 GPU: $gpu_id)"
}

# 分配任务给 GPU，使用后台任务和 `wait` 来实现并行化
for ((i=0; i<$total_files; i++)); do
    seq_file="${seq_files[$i]}"
    gpu_id=$((i % gpu_count))  # 根据 GPU 数量循环分配 GPU ID

    # 运行预测任务到后台
    run_prediction "$seq_file" "$gpu_id" &
    
    # 每次启动的任务数量不超过 GPU 数量
    if (( (i + 1) % gpu_count == 0 )); then
        wait  # 等待当前所有任务完成，然后继续下一批任务
    fi
done

# 等待所有后台任务完成
wait

echo "所有 RosettaFold2 预测任务已完成。"

# 计算并输出每个长度区间的平均时间，并写入到文件
echo "每个长度区间的平均预测时间 (秒):" > "$time_summary_file"

# 汇总各区间的时间和计数
declare -A total_times
declare -A total_counts

while read length_group elapsed_time; do
    total_times[$length_group]=$(( ${total_times[$length_group]:-0} + elapsed_time ))
    total_counts[$length_group]=$(( ${total_counts[$length_group]:-0} + 1 ))
done < "${time_summary_file}.tmp"

# 计算并写入平均时间
for length_group in "${!total_times[@]}"; do
    avg_time=$(echo "${total_times[$length_group]} / ${total_counts[$length_group]}" | bc -l)
    echo "  序列长度在 $((length_group - 49)) 到 $length_group 残基之间: 平均时间 = ${avg_time} 秒" | tee -a "$time_summary_file"
done

# 清理临时文件
rm -f "${time_summary_file}.tmp"

echo "平均预测时间已写入到文件: $time_summary_file"
