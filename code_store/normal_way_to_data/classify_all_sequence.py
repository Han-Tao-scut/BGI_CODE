import pandas as pd
from Bio import SeqIO
import os

# 步骤 1: 读取 header.tsv 文件并过滤 NA 的行
def read_and_filter_header(header_file):
    # 读取文件
    df_header = pd.read_csv(header_file, sep="\t")
    # 过滤掉 score 列为 NA 的行
    df_filtered = df_header[df_header['score'].notna()]
    # 只保留 contig_id, gene_num 和 hmm_name 列
    df_filtered = df_filtered[['contig_id', 'gene_num', 'hmm_name']]
    # 输出过滤后的数据大小
    print(f"步骤 1：读取并过滤 header 文件完成。过滤后的数据：{df_filtered.shape[0]} 条记录。") 
    return df_filtered

# 步骤 2: 读取分类文件并转换为字典
def read_classification_file(classification_file):
    # 读取分类文件
    df_classification = pd.read_csv(classification_file)
    # 将所有列作为一个分类，dropna() 过滤掉每列中的缺失值
    classification_dict = {col: df_classification[col].dropna().tolist() for col in df_classification.columns}
    # 输出分类字典中的类别数
    print(f"步骤 2：读取分类文件完成。分类字典中共有 {len(classification_dict)} 个类别。")
    return classification_dict


# 步骤 3: 根据 hmm_name 在分类字典中找到对应的分类
def find_category(hmm_name, classification_dict):
    for category, hmm_names in classification_dict.items():
        if hmm_name in hmm_names:
            return category
    return 'Unclassified'

# 步骤 4: 从 non_na_all.fasta 文件中提取序列并按分类输出
def classify_sequences_by_category(df_filtered, fasta_file, output_dir):
    fasta_dict = SeqIO.to_dict(SeqIO.parse(fasta_file, "fasta"))
    os.makedirs(output_dir, exist_ok=True)
    
    # 统计每个分类的序列数量
    category_counts = {}

    for category, group in df_filtered.groupby('category'):
        output_fasta = os.path.join(output_dir, f"{category}_classified.fasta")
        with open(output_fasta, 'w') as output_handle:
            for index, row in group.iterrows():
                contig_gene = f"{row['contig_id']}_{row['gene_num']}"
                fasta_header = f"{row['contig_id']}|{row['gene_num']}"
                
                # 查找匹配的序列
                for seq_record in fasta_dict.values():
                    fasta_id_part = seq_record.id.split('#')[0]
                    if fasta_id_part == fasta_header:
                        seq_record.description = f"{fasta_header} | {category}"
                        SeqIO.write(seq_record, output_handle, "fasta")
        
        # 更新分类统计
        category_counts[category] = category_counts.get(category, 0) + len(group)
        print(f"写入 {category} 分类的序列到文件：{output_fasta}。该分类共有 {len(group)} 条序列。")

    # 输出分类统计信息
    print("\n分类统计：")
    for category, count in category_counts.items():
        print(f"分类 {category}: {count} 条序列")

# 主函数
def main(header_file, classification_file, fasta_file, output_dir):
    # 步骤 1: 读取并过滤 header 文件
    df_filtered = read_and_filter_header(header_file)

    # 步骤 2: 读取分类文件并生成分类字典
    classification_dict = read_classification_file(classification_file)

    # 步骤 3: 根据分类文件为每个序列添加分类列
    df_filtered['category'] = df_filtered['hmm_name'].apply(find_category, args=(classification_dict,))
    print(f"步骤 3：根据 hmm_name 为每个序列添加分类完成。分类统计：")
    category_counts = df_filtered['category'].value_counts()
    for category, count in category_counts.items():
        print(f"  分类 {category}: {count} 条序列")

    # 步骤 4: 按照分类输出 fasta 文件
    classify_sequences_by_category(df_filtered, fasta_file, output_dir)

# 用户输入的文件路径和输出路径
if __name__ == "__main__":
    header_file = "/data/input/Files/ResultData/Notebook/limin/Final_marine_checkv/final/final_virus.gene_features.uniq.tsv"  # 输入文件路径
    classification_file = "/data/input/Files/ResultData/Notebook/hantao/NB20241112160740203/categorized_hmms_final/categorized_hmms_final.csv"  # 分类文件路径
    fasta_file = "/data/input/Files/ResultData/Notebook/hantao/NB20241112160740203/Diamond_hmmsearch_non_NA_11_12/non_na_all.fasta"  # 完整的 FASTA 文件路径
    output_dir = "/data/output/fasta_classified"  # 输出文件夹路径
    
    # 执行主函数
    main(header_file, classification_file, fasta_file, output_dir)