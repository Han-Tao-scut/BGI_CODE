#!/usr/bin/env python3
from Bio import SeqIO
import os

# 定义输入的 FASTA 文件路径和输出目录
input_fasta = "/data/work/input.fasta"  # 请替换为你的输入文件路径
extracted_seq_dir = "/data/output/extracted_sequences"  # 存放提取的序列文件的目录

# 创建输出目录（如果不存在）
os.makedirs(extracted_seq_dir, exist_ok=True)

# 读取输入的 FASTA 文件，提取每一条序列并保存为独立的文件
with open(input_fasta, "r") as fasta_handle:
    for record in SeqIO.parse(fasta_handle, "fasta"):
        # 获取唯一标识符（去掉#前的部分）
        seq_id = record.id.split("#")[0]

        # 删除末尾的 '*' 符号（如果存在）
        record.seq = record.seq.rstrip("*")

        # 保存为独立的 fasta 文件
        output_path = os.path.join(extracted_seq_dir, f"{seq_id}.fasta")
        with open(output_path, "w") as output_handle:
            SeqIO.write(record, output_handle, "fasta")

print(f"FASTA 文件中所有序列已单独保存到 {extracted_seq_dir}")