#读取和写入是性能瓶颈，因此线程数4即可
# 准备序列ID文件 sequence_id.txt
vim sequence_id.txt 
#-j 4 表示并行运行的进程数4个
cd /path/to/fasta/files
seqkit grep -f -j 4 sequence_id.txt {} '>'/path/to/output/directory/{.}_found.fasta  # 并行搜索序列ID并输出到指定目录