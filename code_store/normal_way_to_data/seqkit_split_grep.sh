#!/bin/bash

#所有的目录都需要提前创建，否则会报错
# Step 1: Split FASTA file using seqkit
mkdir -p /data/output/internal/
seqkit split2 --force --by-part 20 --threads 32 ./all_vOTU_output_unique_file_seq.fasta  --out-dir /data/output/internal

# Step 2: Parallel processing with GNU Parallel
mkdir -p /data/output/result/

#-j 4 表示并行运行的进程数4个
cd /data/output/internal
ls *.fasta | parallel -j 4 seqkit grep -f in_all_vOTU_not_in_vOTU_LabGovImgvrBGI_name.txt {} '>'/data/output/result/{.}_found.fasta

# Step 3: Concatenate all found sequences into one file
mkdir -p /data/output/final/
cat /data/output/result/{.}_found.fasta > /data/output/final/all_sequences_found.fasta

#统计验证
grep -c "^>" /data/output/final/all_sequences_found.fasta

#按照序列数目切割
seqkit split2 --force -s 8000 --threads 32 ./in_all_vOTU_not_in_vOTU_LabGovImgvrBGI_name.fasta  --out-dir /data/output/final/

#任务完成
echo "All sequences found have been saved to /path/to/all_sequences_found.fasta"
