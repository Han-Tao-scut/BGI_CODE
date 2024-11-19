### 基于序列ID对文件进行去冗余和文件间的差异比较

### 输入

```python
文件1 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/vOTU_LabGovImgvrBGI.fasta_ht"
文件2 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/all_vOTU.fasta_ht"
```

### 输出

#### /Files/ResultData/Notebook/hantao/NB20241112105321480/difference_base_name/

![image-20241112220511966](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241112220511966.png)

![image-20241112111845109](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241112111845109.png)

```python
from Bio import SeqIO

def process_fasta(input_fasta, output_unique_fasta, output_duplicates_fasta):
    """基于序列内容去除FASTA文件中的冗余序列，并输出唯一序列和重复序列的相关信息"""
    unique_sequences = {}  # 存储第一次遇到的唯一序列及其对应的 SeqRecord 对象
    duplicate_sequences = {}  # 存储重复序列及其所有 SeqRecord 对象
    try:
        for record in SeqIO.parse(input_fasta, "fasta"):
            sequence = str(record.seq)
            if sequence not in unique_sequences:
                # 第一次遇到的序列，存储在 unique_sequences 中
                unique_sequences[sequence] = record
            else:
                # 如果已经遇到过该序列，将其加入到重复列表中
                if sequence not in duplicate_sequences:
                    # 初始化重复序列列表并加入第一次遇到的序列记录
                    duplicate_sequences[sequence] = [unique_sequences[sequence].id]
                # 将当前序列记录的 ID 加入到重复序列的 ID 列表中
                duplicate_sequences[sequence].append(record.id)
    except FileNotFoundError:
        print(f"错误：找不到文件 {input_fasta}")
    except Exception as e:
        print(f"读取文件时发生错误：{e}")
    # 将唯一的序列写入输出文件
    with open(output_unique_fasta, "w") as output_handle:
        for record in unique_sequences.values():
            record.description = ""  # 清空描述信息
            SeqIO.write(record, output_handle, "fasta")
    print(f"首次遇到的唯一序列已保存到：{output_unique_fasta}")
    print(f"唯一序列的数量：{len(unique_sequences)}")
    # 将重复的序列及其对应的所有名称写入输出文件
    with open(output_duplicates_fasta, "w") as output_handle:
        for sequence, names in duplicate_sequences.items():
            # 合并所有序列名，格式为 ">name1|name2|name3"
            combined_header = ">" + "|".join(names)
            output_handle.write(combined_header + "\n")
            output_handle.write(sequence + "\n")
    print(f"重复的序列及其所有名称已保存到：{output_duplicates_fasta}")
    print(f"重复序列的数量：{len(duplicate_sequences)}")

# 示例使用
input_fasta = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/vOTU_LabGovImgvrBGI.fasta_ht"
output_unique_fasta = "/data/output/difference_base_sequence/redundant_validations/vOTU_LabGovImgvrBGI_output_unique_file_seq.fasta"
output_duplicates_fasta = "/data/output/difference_base_sequence/redundant_validations/vOTU_LabGovImgvrBGI_output_duplicates_file_seq.fasta"
process_fasta(input_fasta, output_unique_fasta, output_duplicates_fasta)
input_fasta = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/all_vOTU.fasta_ht"
output_unique_fasta = "/data/output/difference_base_sequence/redundant_validations/all_vOTU_output_unique_file_seq.fasta"
output_duplicates_fasta = "/data/output/difference_base_sequence/redundant_validations/all_vOTU_output_duplicates_file_seq.fasta"
```

### 基于序列Sequence对文件进行去冗余和文件间的差异比较

### 输入

```python
文件1 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/vOTU_LabGovImgvrBGI.fasta_ht"
文件2 = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/all_vOTU.fasta_ht"
```

### 输出

#### /Files/ResultData/Notebook/hantao/NB20241112105321480/difference_base_sequence/

![image-20241112220255623](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241112220255623.png)



![image-20241112121217354](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241112121217354.png)

```python
#基于序列进行冗余验证
from Bio import SeqIO

def process_fasta(input_fasta, output_unique_fasta, output_duplicates_fasta):
    """基于序列内容去除FASTA文件中的冗余序列，并输出唯一序列和重复序列的相关信息"""
    unique_sequences = {}  # 存储第一次遇到的唯一序列及其对应的 SeqRecord 对象
    duplicate_sequences = {}  # 存储重复序列及其所有 SeqRecord 对象
    try:
        for record in SeqIO.parse(input_fasta, "fasta"):
            sequence = str(record.seq)
            if sequence not in unique_sequences:
                # 第一次遇到的序列，存储在 unique_sequences 中
                unique_sequences[sequence] = record
            else:
                # 如果已经遇到过该序列，将其加入到重复列表中
                if sequence not in duplicate_sequences:
                    # 初始化重复序列列表并加入第一次遇到的序列记录
                    duplicate_sequences[sequence] = [unique_sequences[sequence].id]
                # 将当前序列记录的 ID 加入到重复序列的 ID 列表中
                duplicate_sequences[sequence].append(record.id)
    except FileNotFoundError:
        print(f"错误：找不到文件 {input_fasta}")
    except Exception as e:
        print(f"读取文件时发生错误：{e}")
    # 将唯一的序列写入输出文件
    with open(output_unique_fasta, "w") as output_handle:
        for record in unique_sequences.values():
            record.description = ""  # 清空描述信息
            SeqIO.write(record, output_handle, "fasta")
    print(f"首次遇到的唯一序列已保存到：{output_unique_fasta}")
    print(f"唯一序列的数量：{len(unique_sequences)}")
    # 将重复的序列及其对应的所有名称写入输出文件
    with open(output_duplicates_fasta, "w") as output_handle:
        for sequence, names in duplicate_sequences.items():
            # 合并所有序列名，格式为 ">name1|name2|name3"
            combined_header = ">" + "|".join(names)
            output_handle.write(combined_header + "\n")
            output_handle.write(sequence + "\n")
    print(f"重复的序列及其所有名称已保存到：{output_duplicates_fasta}")
    print(f"重复序列的数量：{len(duplicate_sequences)}")

# 示例使用
input_fasta = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/vOTU_LabGovImgvrBGI.fasta_ht"
output_unique_fasta = "/data/output/difference_base_sequence/redundant_validations/vOTU_LabGovImgvrBGI_output_unique_file_seq.fasta"
output_duplicates_fasta = "/data/output/difference_base_sequence/redundant_validations/vOTU_LabGovImgvrBGI_output_duplicates_file_seq.fasta"
process_fasta(input_fasta, output_unique_fasta, output_duplicates_fasta)
input_fasta = "/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/govc/Input/fromCooperate/marine-bgi/all_vOTU.fasta_ht"
output_unique_fasta = "/data/output/difference_base_sequence/redundant_validations/all_vOTU_output_unique_file_seq.fasta"
output_duplicates_fasta = "/data/output/difference_base_sequence/redundant_validations/all_vOTU_output_duplicates_file_seq.fasta"
process_fasta(input_fasta, output_unique_fasta, output_duplicates_fasta)
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

```

### 对DH数据库比对后的蛋白序列去除NA和提取序列

### 输入：

![image-20241112220703519](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241112220703519.png)

#### /Files/ResultData/Notebook/limin/Final_marine_checkv/final/

### 输出

#### /Files/ResultData/Notebook/hantao/NB20241112160740203/Diamond_hmmsearch_non_NA_11_12/

![image-20241113090342926](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241113090342926.png)

#### 比对结果summary

说明：注意：由于比对过程中存在一条序列可能比对上多次，因此在比对结果文件中存在多条记录，在寻回序列的过程中，没有考虑到这一点，导致基于比对结果文件的非NA行数比总的非NA序列多，但我们的主要目的是的到比对上序列的sequence，实际上并无影响，因此不做更改

![0c3f6170ece2caaff9f4b6bcecfec70](C:\Users\hantao\Documents\WeChat Files\wxid_duuck0rnlk5j22\FileStorage\Temp\0c3f6170ece2caaff9f4b6bcecfec70.png)

```PYTHON
import pandas as pd
from Bio import SeqIO

def filter_tsv_data(tsv_file):
    """读取TSV文件并筛选出非NA的行"""
    df = pd.read_csv(tsv_file, sep='\t')
    filtered_data = df[~pd.isna(df['score'])]
    print(f"过滤后的非NA数据行数: {len(filtered_data)}")
    return filtered_data

def categorize_by_hmm_db(filtered_data):
    """对筛选后的数据按hmm_db进行分类统计"""
    db_counts = filtered_data['hmm_db'].value_counts().to_dict()
    return db_counts

def index_tsv_data(filtered_data):
    """将TSV数据索引化，以便快速查找匹配"""
    indexed_data = set()
    for _, row in filtered_data.iterrows():
        key = (row['contig_id'], row['gene_num'], row['start'], row['end'])
        indexed_data.add(key)  # 使用集合来存储键
    return indexed_data

def find_matching_sequences(fasta_file, indexed_data, output_non_na_headers, output_non_na_sequences):
    """在FASTA文件中找到匹配的序列并输出结果"""
    non_na_count = 0
    with open(output_non_na_headers, 'w') as header_handle, open(output_non_na_sequences, 'w') as sequence_handle:
        for record in SeqIO.parse(fasta_file, "fasta"):
            # Parse the FASTA header
            header = record.description.split(' # ')
            contig_id_part = header[0]  # DRR000020-k63_3393||0_partial_1
            contig_id = '_'.join(contig_id_part.split('_')[:-1])  # DRR000020-k63_3393||0_partial
            gene_num = int(contig_id_part.split('_')[-1])  # 提取最后的数字部分作为 gene_num
            start, end = int(header[1]), int(header[2])

            # Find the matching row in the indexed TSV data
            key = (contig_id, gene_num, start, end)
            if key in indexed_data:
                non_na_count += 1
                header_handle.write(f">{record.description}\n")
                sequence_handle.write(f">{record.description}\n{record.seq}\n")
    
    return non_na_count

def main(tsv_file, fasta_file, output_non_na_headers, output_non_na_sequences):
    # Step 1: Filter TSV data to get non-NA rows
    filtered_data = filter_tsv_data(tsv_file)

    # Step 2: Categorize by hmm_db
    db_counts = categorize_by_hmm_db(filtered_data)

    # Step 3: Index TSV data for faster lookup
    indexed_data = index_tsv_data(filtered_data)

    # Step 4: Find matching sequences in the FASTA file and write output
    non_na_count = find_matching_sequences(fasta_file, indexed_data, output_non_na_headers, output_non_na_sequences)

    # Print statistics
    print(f"总的非NA序列数目: {non_na_count}")
    for db, count in db_counts.items():
        print(f"数据库 {db} 中比对上的序列数目: {count}")

# 示例使用
tsv_file = "/data/input/Files/ResultData/Notebook/limin/Final_marine_checkv/final/final_virus.gene_features.uniq.tsv"
fasta_file = "/data/input/Files/ResultData/Notebook/limin/Final_marine_checkv/final/final_virus.proteins.faa"
output_non_na_headers = "/data/output/Diamond_hmmsearch_non_NA/non_na_headers.txt"
output_non_na_sequences = "/data/output/Diamond_hmmsearch_non_NA/non_na_all.fasta"

main(tsv_file, fasta_file, output_non_na_headers, output_non_na_sequences)

```

### CD-HIT聚类

#### 参数设置

![b9cb1efd886456ef2c9b409663f3f5a](C:\Users\hantao\Documents\WeChat Files\wxid_duuck0rnlk5j22\FileStorage\Temp\b9cb1efd886456ef2c9b409663f3f5a.png)

#### 输入：

#### /Files/ResultData/Notebook/hantao/NB20241112160740203/Diamond_hmmsearch_non_NA_11_12/non_na_all.fasta

（备注：去除NA后的含有sequence信息的FASTA文件）

![image-20241113090342926](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241113090342926.png)

### 输出

#### /Files/ResultData/Notebook/hantao/NB20241112160740203/cdhit_11_12_non_NA_700_to_500/![image-20241113085922404](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241113085922404.png)

### 运行结果

![image-20241113090804666](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241113090804666.png)

-c 1.0 下，去除冗余后效果不佳。