!/bin/bash

# 输入和输出目录
input_dir="input/Files/ResultData/Notebook/hantao/NB20241113202650342/fasta_classified/"
output_dir="/data/output"

# 创建输出目录，如果不存在
mkdir -p "$output_dir"

# 获取输入目录中的所有文件
input_files=("$input_dir"/*)

# 并行运行 cdhit 命令
for input_file in "${input_files[@]}"; do
    base_name=$(basename "$input_file")
    output_file="$output_dir/${base_name}_cdhit"

    # 后台运行 cd-hit 命令
    cd-hit -i "$input_file" -o "$output_file" -c 0.7 -n 5 -M 0 -d 0 -T 8 &
done
# 等待所有后台任务完成
wait

echo "所有 cd-hit 任务完成。"