#基于ID去重
zcat all_vOTU.fasta.gz \
    | seqkit rmdup  -i -o all_vOTU_name_clean.fa.gz -d all_vOTU_name_duplicated.fa.gz -D all_vOTU_name_duplicated.detail.txt
zcat vOTU_LabGovImgvrBGI.fasta.gz\
    | seqkit rmdup -i  -o vOTU_LabGovImgvrBGI_name_clean.fa.gz -d vOTU_LabGovImgvrBGI_name_duplicated.fa.gz -D vOTU_LabGovImgvrBGI_name_duplicated.detail.txt

#基于ID进行交集，并集，差集分析

#交集
zcat all_vOTU.fasta.gz>all_vOTU.fasta
zcat vOTU_LabGovImgvrBGI.fasta.gz >vOTU_LabGovImgvrBGI.fasta
seqkit common vOTU_LabGovImgvrBGI.fasta all_vOTU.fasta  -i -o all_labGovImgvrBGI_common.fasta    
#faster way
seqkit grep -i -f <(seqkit seq -n -i all_vOTU.fasta)  vOTU_LabGovImgvrBGI.fasta.gz > diff.fasta

#并集
zcat all_vOTU.fasta.gz vOTU_LabGovImgvrBGI.fasta.gz \
    |seqkit rmdup  -i -o all_LabGovImgvrBGI_name_clean.fa.gz -d all_LabGovImgvrBGI_name_duplicated.fa.gz -D all_LabGovImgvrBGI_name_duplicated.detail.txt

#差集
seqkit grep -i -f <(seqkit seq -n -i file2.fasta) -v file1.fasta > diff.fasta


#基于序列去重
zcat all_vOTU.fasta.gz \
    | seqkit rmdup  -s -i -o all_vOTU_seq_clean.fa.gz -d all_vOTU_seq_duplicated.fa.gz -D all_vOTU_seq_duplicated.detail.txt
zcat vOTU_LabGovImgvrBGI.fasta.gz\
    | seqkit rmdup  -s -i -o vOTU_LabGovImgvrBGI_seq_clean.fa.gz -d vOTU_LabGovImgvrBGI_seq_duplicated.fa.gz -D vOTU_LabGovImgvrBGI_seq_duplicated.detail.txt
#基于sequence进行交集，并集，差集分析

#交集
zcat all_vOTU.fasta.gz>all_vOTU.fasta
zcat vOTU_LabGovImgvrBGI.fasta.gz >vOTU_LabGovImgvrBGI.fasta
seqkit common vOTU_LabGovImgvrBGI.fasta all_vOTU.fasta  -s -i -o all_labGovImgvrBGI_common.fasta    
#faster way
seqkit grep -i -s -f <(seqkit seq -s all_vOTU.fasta)  vOTU_LabGovImgvrBGI.fasta.gz > diff.fasta

#并集
zcat all_vOTU.fasta.gz vOTU_LabGovImgvrBGI.fasta.gz \
    |seqkit rmdup  -i -s -o all_LabGovImgvrBGI_name_clean.fa.gz -d all_LabGovImgvrBGI_name_duplicated.fa.gz -D all_LabGovImgvrBGI_name_duplicated.detail.txt

#差集
seqkit grep -s -i -f <(seqkit seq -s file2.fasta) -v file1.fasta > diff.fasta
