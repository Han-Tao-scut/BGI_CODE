#-j 4 表示并行运行的进程数4个
cd /path/to/fasta/files
vim sequence_id.txt # 输入需要搜索的序列ID
parallel -j 4 seqkit grep -f sequence_id.txt {} '>'/path/to/output/directory/{.}_found.fasta  # 并行搜索序列ID并输出到指定目录