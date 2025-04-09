#!/bin/bash

# 设置 -e 选项，当命令出错时立即退出
set -e

# 定义基础路径和软件路径
base_dir="/home/codespace/work/data/E.coli_K12"  # 请根据实际情况修改
input_dir="$base_dir/input"
output_dir="$base_dir/output"
trimmomatic_jar="/home/codespace/miniconda3/bin/trimmomatic" # 根据实际情况修改

# 定义线程数
threads=4

# 遍历样本名参数
for sample_id in "$@"; do
    # 定义输入和输出文件
    sample_input_dir="$input_dir/$sample_id"
    read1="$sample_input_dir/${sample_id}_1.fastq"
    read2="$sample_input_dir/${sample_id}_2.fastq"
    ref_file="$sample_input_dir/${sample_id}.fa"

    # 检查输入文件是否存在
    if [ ! -f "$read1" ] || [ ! -f "$read2" ] || [ ! -f "$ref_file" ]; then
        echo "Error: Input files not found for sample $sample_id"
        continue  # 继续处理下一个样本
    fi

    # 创建样本特定的输出目录
    sample_output_dir="$output_dir/$sample_id"
    mkdir -p "$sample_output_dir/fastqc"
    mkdir -p "$sample_output_dir/trimmomatic"
    mkdir -p "$sample_output_dir/bwa"
    mkdir -p "$sample_output_dir/MarkDuplicates"
    mkdir -p "$sample_output_dir/results"

    # 运行流程
    echo "Processing sample: $sample_id"

    # FastQC 质量评估 (原始数据)
    fastqc -t "$threads" -o "$sample_output_dir/fastqc" "$read1" "$read2" &

    # Trimmomatic 质量过滤和接头去除
    /home/codespace/miniconda3/bin/trimmomatic PE -phred33 \
    -trimlog "$sample_output_dir/trimmomatic/${sample_id}_trimmomatic.log" \
    "$read1" "$read2" \
    "$sample_output_dir/trimmomatic/${sample_id}_1.trimmed.fq.gz" "$sample_output_dir/trimmomatic/${sample_id}_1.unpaired.fq.gz" \
    "$sample_output_dir/trimmomatic/${sample_id}_2.trimmed.fq.gz" "$sample_output_dir/trimmomatic/${sample_id}_2.unpaired.fq.gz" \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:5:20 LEADING:5 TRAILING:5 MINLEN:50

    wait # 等待所有后台 FastQC 进程结束

    # FastQC 质量评估 (过滤后数据)
    run_fastqc "$sample_output_dir/trimmomatic/${sample_id}_1.trimmed.fq.gz" \
         "$sample_output_dir/trimmomatic/${sample_id}_2.trimmed.fq.gz" \
         "$sample_output_dir/fastqc_after_filt" &

    # BWA 比对
    bwa mem -t "$threads" -R "@RG\tID:${sample_id}\tPL:UNKNOWN\tLB:library\tSM:${sample_id}" \
    "$ref_file" "$sample_output_dir/trimmomatic/${sample_id}_1.trimmed.fq.gz" "$sample_output_dir/trimmomatic/${sample_id}_2.trimmed.fq.gz" > "$sample_output_dir/bwa/${sample_id}.sam"

    # Samtools 格式转换、排序、标记重复、构建索引
    # 转换 SAM 到 BAM
    samtools view -S -b "$sample_output_dir/bwa/${sample_id}.sam" -o "$sample_output_dir/bwa/${sample_id}.bam"

    # 排序 BAM
    samtools sort -@ "$threads" -m 2G -O bam -o "$sample_output_dir/bwa/${sample_id}.sorted.bam" "$sample_output_dir/bwa/${sample_id}.bam"


    # 构建索引
    samtools index "$sample_output_dir/MarkDuplicates/${sample_id}.sorted.markdup.bam"
    # 测序深度
    samtools depth -a "$sample_output_dir/MarkDuplicates/${sample_id}.sorted.markdup.bam" > "$sample_output_dir/results/${sample_id}_all_position_depth.txt"

    # 覆盖度统计
    samtools coverage "$sample_output_dir/MarkDuplicates/${sample_id}.sorted.markdup.bam" > "$sample_output_dir/results/${sample_id}_coverage.txt"
    wait # 等待所有后台 FastQC 进程结束
    echo "Finished processing sample: $sample_id"
    #变异检测
    conda install bioconda::gatk4 -y
    gatk HaplotypeCaller \
    -R reference.fasta \
    -I preprocessed_reads.bam -O germline_variants.vcf
done

echo "All samples processed!"