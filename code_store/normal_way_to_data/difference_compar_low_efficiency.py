#基于名称进行差异比较
from Bio import SeqIO
def read_fasta_headers(fasta_file):
    """读取FASTA文件，返回序列名称集合"""
    headers = set()
    try:
        for record in SeqIO.parse(fasta_file, "fasta"):
            headers.add(record.id)
    except FileNotFoundError:
        print(f"错误：找不到文件 {fasta_file}")
    except Exception as e:
        print(f"读取文件时发生错误：{e}")
    return headers
def compare_fasta_headers(fasta_file1, fasta_file2, output1, output2, output_intersection):
    """比较两个FASTA文件的序列名称，输出它们的差异并保存到文件"""
    headers1 = read_fasta_headers(fasta_file1)
    headers2 = read_fasta_headers(fasta_file2)
    # 打印每个文件的序列数量
    print(f"文件1中序列数量：{len(headers1)}")
    print(f"文件2中序列数量：{len(headers2)}")
    # 找出差集和交集
    in_file1_not_in_file2 = headers1 - headers2
    in_file2_not_in_file1 = headers2 - headers1
    intersection = headers1 & headers2
        # 输出差集和交集的数量
    print(f"在文件1中但不在文件2中的序列数量：{len(in_file1_not_in_file2)}")
    print(f"在文件2中但不在文件1中的序列数量：{len(in_file2_not_in_file1)}")
    print(f"在文件1和文件2中的交集序列数量：{len(intersection)}")
    # 将差异和交集输出到文件
    with open(output1, 'w') as f1:
        for header in in_file1_not_in_file2:
            f1.write(header + '\n')
    print(f"在文件1中但不在文件2中的序列名称已保存到：{output1}")
    with open(output2, 'w') as f2:
        for header in in_file2_not_in_file1:
            f2.write(header + '\n')
    print(f"在文件2中但不在文件1中的序列名称已保存到：{output2}")
    with open(output_intersection, 'w') as f3:
        for header in intersection:
            f3.write(header + '\n')
    print(f"在文件1和文件2中的交集序列名称已保存到：{output_intersection}")

# 示例使用
fasta_file1 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/vOTU_LabGovImgvrBGI.fasta_ht"
fasta_file2 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/all_vOTU.fasta_ht"

# 输出差集文件的路径
output1 = "/data/output/difference_base_name/difference_files/in_vOTU_LabGovImgvrBGI_not_in_all_vOTU_name.txt"
output2 = "/data/output/difference_base_name/difference_files/in_all_vOTU_not_in_vOTU_LabGovImgvrBGI_name.txt"
output_intersection = "/data/output/difference_base_name/difference_files/intersection_vOTU_LabGovImgvrBGI_and_all_vOTU_name.txt"
compare_fasta_headers(fasta_file1, fasta_file2, output1, output2, output_intersection)



#基于序列进行差异比较
from Bio import SeqIO

def read_fasta_sequences(fasta_file):
    """读取FASTA文件，返回序列到序列名称的映射"""
    sequences = {}
    try:
        for record in SeqIO.parse(fasta_file, "fasta"):
            sequence = str(record.seq)
            if sequence not in sequences:
                sequences[sequence] = [record.id]
            else:
                sequences[sequence].append(record.id)
    except FileNotFoundError:
        print(f"错误：找不到文件 {fasta_file}")
    except Exception as e:
        print(f"读取文件时发生错误：{e}")
    return sequences
def compare_fasta_sequences(fasta_file1, fasta_file2, output1, output2, output_intersection):
    """比较两个FASTA文件的序列，输出它们的差异并保存到文件"""
    sequences1 = read_fasta_sequences(fasta_file1)
    sequences2 = read_fasta_sequences(fasta_file2)
    # 找出差集和交集
    in_file1_not_in_file2 = {seq: sequences1[seq] for seq in sequences1 if seq not in sequences2}
    in_file2_not_in_file1 = {seq: sequences2[seq] for seq in sequences2 if seq not in sequences1}
    intersection = {seq: sequences1[seq] + sequences2[seq] for seq in sequences1 if seq in sequences2}
    # 打印每个文件的序列数量
    print(f"文件1中序列数量：{len(sequences1)}")
    print(f"文件2中序列数量：{len(sequences2)}")
    # 输出差集和交集的数量
    print(f"在文件1中但不在文件2中的序列数量：{len(in_file1_not_in_file2)}")
    print(f"在文件2中但不在文件1中的序列数量：{len(in_file2_not_in_file1)}")
    print(f"在文件1和文件2中的交集序列数量：{len(intersection)}")
    # 将差异和交集输出到文件
    with open(output1, 'w') as f1:
        for sequence, ids in in_file1_not_in_file2.items():
            f1.write(f">{','.join(ids)}\n{sequence}\n")
    print(f"在文件1中但不在文件2中的序列已保存到：{output1}")
    with open(output2, 'w') as f2:
        for sequence, ids in in_file2_not_in_file1.items():
            f2.write(f">{','.join(ids)}\n{sequence}\n")
    print(f"在文件2中但不在文件1中的序列已保存到：{output2}")
    with open(output_intersection, 'w') as f3:
        for sequence, ids in intersection.items():
            f3.write(f">{','.join(ids)}\n{sequence}\n")
    print(f"在文件1和文件2中的交集序列已保存到：{output_intersection}")
# 示例使用

# 输入的去冗余后的FASTA文件路径
unique_fasta1 = "/data/output/difference_base_sequence/redundant_validations/vOTU_LabGovImgvrBGI_output_unique_file_seq.fasta"
unique_fasta2 = "/data/output/difference_base_sequence/redundant_validations/all_vOTU_output_unique_file_seq.fasta"
 
# 基于去冗余后的唯一序列进行差异比对
output1 = "/data/output/difference_base_sequence/difference_files/in_unique_vOTU_LabGovImgvrBGI_not_in_all_vOTU_seq.txt"
output2 = "/data/output/difference_base_sequence/difference_files/in_unique_all_vOTU_not_in_vOTU_LabGovImgvrBGI_seq.txt"
output_intersection = "/data/output/difference_base_sequence/difference_files/intersection_unique_vOTU_LabGovImgvrBGI_and_all_vOTU_seq.txt"

compare_fasta_sequences(unique_fasta1, unique_fasta2, output1, output2, output_intersection)

