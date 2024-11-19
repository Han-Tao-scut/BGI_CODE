import pandas as pd
import re

def categorize_by_desc_and_hmm(input_file, output_file="categorized_hmms_final.csv"):
    """根据desc中的关键词对数据进行分类，并将hmm纳入相应类"""
    # 定义类别及其对应的关键词
    categories = {
        'LYS': ['lysis', 'holin', 'lysozy', 'lysin', 'lys', 'lysozyme', 'kii', 'rii', 'rz', 'rz1'],
        'INT': ['integration', 'integrase', 'recombinase', 'excise', 'excisionase', 'recombination', 'beta', 'cre', 'transposase', 'lysogenic'],
        'REP': ['replication', 'polymerase', 'helicase', 'ligase', 'primase', 'dna synthesis', 'clamp', 'uvs', 'binding', 'helix', 'topoisomerase', 'reductase'],
        'REG': ['regulator', 'inhibition', 'operator', 'activator', 'inhibitor', 'repressor', 'transcription', 'modulator', 'c1', 'c2', 'whib', 'regulatory', 'helix', 'cro'],
        'PAC': ['terminase', 'package', 'endonuclease', 'exonuclease', 'hnh', 'maturase', 'nuclease'],
        'ASB': ['head', 'capsid', 'coat', 'collar', 'scaffold', 'core', 'neck', 'membrane', 'tapemeasure', 'tape measure', 'cp12', 'structural', 'thioredoxi', 'particle', 'assembly'],
        'INF': ['tail', 'virion', 'baseplate', 'base plate', 'chaperone', 'fiber', 'cell wall hydrolase', 'a2', 'a1', 'injection', 'infection', 'portal', 'vertex', 'attachment'],
        'EVA': ['transferase'],
        'HYP': ['hypothetical protein'],
        'TRNA': ['trna'],
        'CDS': []  # 默认分类
    }

    # 创建一个字典保存每个分类的hmm值
    categorized_hmms = {category: [] for category in categories}

    # 读取TSV文件
    filtered_data = pd.read_csv(input_file, sep="\t")

    # 遍历每行数据，根据desc列中的内容进行分类
    for i, row in filtered_data.iterrows():
        desc = row['desc']  # 获取desc列

        # 如果desc为NA或空值，直接归类为CDS
        if pd.isna(desc) or desc.strip() == "":
            categorized_hmms['CDS'].append(row['hmm'])
            continue
        
        desc = desc.lower()  # 转换为小写字母

        # 遍历分类及关键词
        for category, keywords in categories.items():
            if category == 'CDS':  # CDS类别已经通过NA或空值匹配，跳过
                continue
            for keyword in keywords:
                # 构造正则表达式，确保两侧可以有其他字符，但中间不能插入字符
                pattern = r'\b' + re.escape(keyword.lower()) + r'\b'  # \b表示单词边界
                if re.search(pattern, desc):  # 如果desc中包含关键词
                    categorized_hmms[category].append(row['hmm'])  # 将hmm值添加到相应分类
                    break  # 找到第一个匹配的关键词后停止进一步检查
            else:
                continue
            break  # 如果已经分类，则跳出外层循环

    # 使用categorized_hmms生成最终结果：将每个类别中的所有hmm值组合成一个字符串
    # 将分类的hmm值合并到一个列表里，每一列对应一个分类
    max_len = max(len(hmms) for hmms in categorized_hmms.values())
    categorized_hmms_padded = {category: hmms + [''] * (max_len - len(hmms)) for category, hmms in categorized_hmms.items()}

    # 将数据转换为DataFrame
    categorized_df = pd.DataFrame(categorized_hmms_padded)

    # 将结果保存为文件
    categorized_df.to_csv(output_file, index=False)

    return categorized_df

# 调用函数并处理文件
input_file = "/data/input/Files/ReferenceData/db-checkv/hmm_db/checkv_hmms.tsv"  # 输入的TSV文件路径
classified_hmms = categorize_by_desc_and_hmm(input_file)

# 查看并保存最终结果
print(classified_hmms.head())