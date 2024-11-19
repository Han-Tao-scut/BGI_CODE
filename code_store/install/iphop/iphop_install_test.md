# Overview

**iPHoP** stands for **i**ntegrated **P**hage **Ho**st **P**rediction. It is an automated command-line pipeline for predicting host genus of novel bacteriophages and archaeoviruses based on their genome sequences.

The pipeline can be broken down into 6 main steps:

![](https://bitbucket.org/srouxjgi/iphop/raw/7fae8a738133bb69ab6ed24b2d1d266ff616457b/pipeline.png)

**A: Step 1: Running individual host prediction tools**

* Phage-based tool:
  * RaFAH (https://doi.org/10.1016/j.patter.2021.100274): yield a prediction of host genus with associated score, stored for later (see Step 5)
* Host-based tools:
  * blastn to host genomes. All hits with ≥ 80% identity and ≥ 500bp are considered. Hits covering ≥ 50% of the "host" contig length are ignored as these often derive from contigs (nearly) entirely viral, and can easily be contaminant in genomes or MAGs and thus not reliable for host prediction
  * blastn to CRISPR spacer database. All hits with up to 4 mistmaches are considered.
  * WIsH (https://doi.org/10.1093/bioinformatics/btx383) : host association based on k-mer composition similarity between virus and host genome
  * VHM - s2\* similarity (https://doi.org/10.1093/nar/gkw1002 / https://doi.org/10.1093/nargab/lqaa044): host association based on k-mer composition similarity between virus and host genome
  * PHP (https://doi.org/10.1186/s12915-020-00938-6): host association based on k-mer composition similarity between virus and host genome

**B: Step 2: Collect all scores and all distances between hits for host-based tools** \* Distance between two potential hosts, i.e., two hits for a given tool and a given query virus, is based on the GTDB trees (https://doi.org/10.1093/nar/gkab776)

**C: Steps 3 and 4: Compile an organized list of hits for each virus - tool - candidate host combination** \* For each hit, the top other hits from the same virus with the same tool are compiled and organized according to the distance between the base hit host and the other hit host (see step 2) \* These series of hits are used as input for automated classifiers to derive a score for the given virus - candidate host pair \* This enables the evaluation of every potential host (every hit) when considering the context of the top hits obtained for this virus

**D: Step 5: Derive 3 scores for host-based tools for each virus - candidate host combination** \* The top scores based only on blast or crispr matches are retained, as these methods can be reliable enough by themselves for host prediction \* A third score is obtained by considering all scores from all individual classifiers (see step 4), i.e. taking into account all 5 host-based methods

**E: Step 6: Calculate a composite score for each virus - candidate host genus combination integrating host-based and phage-based signals** \* The 3 host-based scores (see step 5) are then considered alongside the phage-based score (RaFAH - https://doi.org/10.1016/j.patter.2021.100274) to obtain a single score for all pairs of virus - candidate host genus.

# Install

Stable versions of iPHoP are available as bioconda packages.

## Bioconda

iPHoP is available on the Bioconda channel: -- **Note - the bioconda installation is only possible for linux machines, not Mac OS X.**

```bash
$ conda create -n iphop_env python=3.8 git dvc dvc-ssh
$ conda activate iphop_env
$ conda install -c bioconda iphop
```

If you want to install fast, you can use manba.

We can now test that the installation was successful by running.

```
iPHoP v1.3.3: integrating Host Phage Predictions
https://bitbucket.org/srouxjgi/iphop

usage: iphop <task> [options]

task:
	predict         run full pipeline to generate host prediction for some input phage genome(s)
	download	download and setup the latest host database
	add_to_db       add some host genomes to the database of hosts (e.g. MAGs derived from the same metagenome(s))

other:
	split           small utility to split a fasta file into smaller batches (can be useful if you would like to split your input and run iPHoP separately for each batch)
	clean           small utility to clean the output directory of iPHoP by compressing some of the larger files.

optional arguments:
  -h, --help  show this help message and exit
```

Host genomes were selected to be used with the phage genomes provided in the "test_input_phages.fna" file (see folder "test") The test_db_rw database is a smaller database that should be quick to download, and enable users to proceed with a test of their iPHoP installation before downloading the entire (and much larger) host database.

# Test

\#https://portal.nersc.gov/cfs/m342/iphop/db/, the database and database for test can be downloaded from the url(using md5 to verify the file integrity，then unzip).

## Host databases for Test

Do you think you have already installed iPhop successfully？How to comfirm? Test the iPHoP installation with a small database.

**Note:** We just want to comfire iPHoP which is able to run on our computer, in order to save time and resources, we just downlaod the iPHoP_db_rw_for-test(Subset of the database, used with the test input file to check iPHoP installation) before we comfire iPHoP installation successfully.

```
$ export path_of_db_input=Input/Rawdata/iphop_install_test
$ mkdir $path_of_db_input/iphop_db_test
$ iphop download --db_dir $path_of_db_input/iphop_db_test/ -dbv iPHoP_db_rw_for-test
#when dowload the latest whole database, "-dbv iPHoP_db_Aug23_rw"
```

(iPHoP database is pretty big, and will require around \~ 350Gb of disk space and some time to download and set up, however, the test database only \~ 5Gb.)

## the Phage Genomes for Test

Host genomes were selected to be used with the phage genomes provided in the "test_input_phages.fna" file.

```
$ mkdir $path_of_db_input/iphop_input_test
$ cd $path_of_db_input/iphop_input_test
$ wget https://bitbucket.org/srouxjgi/iphop/raw/d27b6bbdcd39a6a1cb8407c44ccbcc800d2b4f78/test/test_input_phages.fna
```

## Run and Test iPHoP



Now, you have the database and input data for test, let's run iPHoP, to comfirm your device be able to run iPHoP.

(When you change the node, please do

```
 export path_of_db_input=Input/Rawdata/iphop_install_test
```

again.)

```
$ export path_of_output=Output/iphop_install_test
$ mkdir $path_of_output/iphop_results_test
$ iphop predict --fa_file $path_of_db_input/iphop_input_test/test_input_phages.fna --db_dir $path_of_db_input/iphop_db_test/Test_db_rw/ --out_dir  $path_of_output/iphop_results_test/
# Note: you can replace "Test_db_rw" by the version of the database you have
```

![image-20241028164014299](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241028164014299.png)

Congratulations, you install iPhop successfully！

# Main output files

#### Host_prediction_to_genus_mXX.csv, where XX is the minimum score cutoff selected (default: Host_prediction_to_genus_m90.csv)

This contains integrated results from host-based and phage-based tools at the host genus level:

| Virus                        | AAI to closest RaFAH reference | Host genus                                                   | Confidence score | List of methods                                     |
| ---------------------------- | ------------------------------ | ------------------------------------------------------------ | ---------------- | --------------------------------------------------- |
| IMGVR_UViG_3300029435_000002 | 48.49                          | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella | 98.50            | RaFAH;91.30 iPHoP-RF;89.50 CRISPR;70.20             |
| IMGVR_UViG_3300029435_000003 | 53.00                          | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Agathobacter | 92.20            | blast;94.40                                         |
| IMGVR_UViG_3300029435_000003 | 53.00                          | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Bacteroides_F | 90.90            | CRISPR;93.30 iPHoP-RF;51.70                         |
| IMGVR_UViG_3300029435_000005 | 42.95                          | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Oscillospirales;f__Ruminococcaceae;g__Gemmiger | 95.30            | blast;96.70 CRISPR;92.70 iPHoP-RF;82.50             |
| IMGVR_UViG_3300029435_000007 | 35.09                          | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella | 98.40            | CRISPR;98.80 iPHoP-RF;95.40 blast;93.60             |
| IMGVR_UViG_3300029435_000009 | 99.62                          | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Lachnospira | 99.00            | CRISPR;98.80 blast;92.60 iPHoP-RF;70.90 RaFAH;65.80 |
| IMGVR_UViG_3300029435_000009 | 99.62                          | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Roseburia | 95.70            | CRISPR;97.00 iPHoP-RF;56.80                         |
| IMGVR_UViG_3300029435_000010 | 22.47                          | d__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Burkholderiales;f__Burkholderiaceae;g__Sutterella | 97.60            | blast;98.30 CRISPR;80.00 iPHoP-RF;78.30             |

* This output file lists for each prediction the virus sequence ID, the level of amino-acid similarity (AAI) between the query and the genomes in the RaFAH phage database, the predicted host genus, the confidence score calculated from all tools, and the list of scores for individual classifiers obtained for this virus-host pair.
* For the detailed score by classifier, "RaFAH" represents the score derived from RaFAH (https://www.sciencedirect.com/science/article/pii/S2666389921001008), iPHoP-RF is the score derived from all host-based tools, CRISPR the score derived only from CRISPR hits, and blast the score derived only from blastn hits
* All virus-host pairs for which the confidence score is higher than the selected cutoff (default = 90) are included, so each virus may be associated with multiple predictions (e.g. IMGVR_UViG_3300029435_000003 and IMGVR_UViG_3300029435_000009).
* When multiple predictions are available for a query virus, typical standard practices is to use the one with the highest score

#### Host_prediction_to_genome_mXX.csv, where XX is the minimum score cutoff selected (default: Host_prediction_to_genome_m90.csv)

This contains integrated results from host-based tools only (i.e., no RaFAH) at the host genome representative level:

| Virus                        | Host genome        | Host taxonomy                                                | Main method | Confidence score | Additional methods          |
| ---------------------------- | ------------------ | ------------------------------------------------------------ | ----------- | ---------------- | --------------------------- |
| IMGVR_UViG_3300029435_000003 | RS_GCF_000020605.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Agathobacter;s__Agathobacter rectalis | blast       | 94.40            | None                        |
| IMGVR_UViG_3300029435_000003 | RS_GCF_000155855.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Bacteroides_F;s__Bacteroides_F pectinophilus | CRISPR      | 93.30            | iPHoP-RF;51.70              |
| IMGVR_UViG_3300029435_000003 | GB_GCA_000437735.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Lachnospira;s__Lachnospira sp000437735 | CRISPR      | 91.00            | blast;79.50                 |
| IMGVR_UViG_3300029435_000003 | RS_GCF_003478035.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__CAG-81;s__CAG-81 sp900066785 | blast       | 90.80            | None                        |
| IMGVR_UViG_3300029435_000005 | RS_GCF_900167555.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Oscillospirales;f__Ruminococcaceae;g__Gemmiger;s__Gemmiger formicilis | blast       | 96.70            | iPHoP-RF;82.50 CRISPR;68.10 |
| IMGVR_UViG_3300029435_000005 | GB_GCA_900540775.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Oscillospirales;f__Ruminococcaceae;g__Gemmiger;s__Gemmiger sp900540775 | blast       | 96.50            | iPHoP-RF;82.50              |
| IMGVR_UViG_3300029435_000005 | RS_GCF_003324125.1 | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Oscillospirales;f__Ruminococcaceae;g__Gemmiger;s__Gemmiger qucibialis | CRISPR      | 92.70            | blast;81.60 iPHoP-RF;67.50  |

* This output file lists for each host-based prediction the virus sequence ID, the representative host genome ID, the corresponding host genome taxonomy, the main method supporting this prediction (i.e., highest score), the confidence score for this main method, and the list of additional methods and scores obtained for this virus-host pair. The first 3 contigs (IMGVR_UViG_3300029435_000002, IMGVR_UViG_3300029435_000003, and IMGVR_UViG_3300029435_000005) from the Host_prediction_to_genus_m90.csv are included in this example.
* Note: IMGVR_UViG_3300029435_000002 is not mentioned in this output file because no host-based predictions reached the minimum score of 90 (see above the example file "Host_prediction_to_genus_m90.csv")
* Note: For IMGVR_UViG_3300029435_000003, predictions to the genera g__Lachnospira and g__CAG-81 are not included in the Host_prediction_to_genus_m90.csv file (see above), because once aggregated at the genus level, these predictions do not reach the minimum score of 90

#### Detailed_output_by_tool.csv file

| Virus                        | Method   | Host               | Host taxonomy                                                | Metric 1          | Score 1  | Metric 2      | Score 2  | Rank | Host representative |
| ---------------------------- | -------- | ------------------ | ------------------------------------------------------------ | ----------------- | -------- | ------------- | -------- | ---- | ------------------- |
| IMGVR_UViG_3300029435_000002 | crispr   | GCA_003447235.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella sp003447235 | N_mismatches      | 0.000    | Spacer_length | 30.0     | 1    | GB_GCA_003447235.1  |
| IMGVR_UViG_3300029435_000002 | crispr   | GCF_003576475.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Prolixibacteraceae;g__Draconibacterium;s__Draconibacterium luteus | N_mismatches      | 3.000    | Spacer_length | 36.0     | 2    | RS_GCF_003576475.1  |
| IMGVR_UViG_3300029435_000002 | crispr   | GCF_001683355.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella scopos | N_mismatches      | 4.000    | Spacer_length | 35.0     | 3    | RS_GCF_001683355.1  |
| IMGVR_UViG_3300029435_000002 | crispr   | 3300029716_17      | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Coprococcus;s__Coprococcus eutactus_A | N_mismatches      | 4.000    | Spacer_length | 27.0     | 3    | RS_GCF_001404675.1  |
| IMGVR_UViG_3300029435_000002 | iPHoP-RF | RS_GCF_000179055.1 | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella bryantii | Confidence_score  | 0.954    | FDR           | 0.105    | 1    | RS_GCF_000179055.1  |
| IMGVR_UViG_3300029435_000002 | iPHoP-RF | RS_GCF_001683355.1 | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella scopos | Confidence_score  | 0.946    | FDR           | 0.118    | 2    | RS_GCF_001683355.1  |
| IMGVR_UViG_3300029435_000002 | iPHoP-RF | GB_GCA_003447235.1 | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella sp003447235 | Confidence_score  | 0.934    | FDR           | 0.137    | 3    | GB_GCA_003447235.1  |
| IMGVR_UViG_3300029435_000002 | iPHoP-RF | RS_GCF_003576475.1 | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Prolixibacteraceae;g__Draconibacterium;s__Draconibacterium luteus | Confidence_score  | 0.774    | FDR           | 0.332    | 4    | RS_GCF_003576475.1  |
| IMGVR_UViG_3300029435_000002 | iPHoP-RF | RS_GCF_000373185.1 | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella paludivivens | Confidence_score  | 0.726    | FDR           | 0.394    | 5    | RS_GCF_000373185.1  |
| IMGVR_UViG_3300029435_000002 | rafah    | Prevotella         | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella | Confidence_score  | 0.709    | FDR           | 0.087    | 1    | NA                  |
| IMGVR_UViG_3300029435_000002 | rafah    | Bacteroides        | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides | Confidence_score  | 0.140    | FDR           | 0.865    | 2    | NA                  |
| IMGVR_UViG_3300029435_000002 | rafah    | Polynucleobacter   | d__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Burkholderiales;f__Burkholderiaceae;g__Polynucleobacter | Confidence_score  | 0.019    | FDR           | 0.991    | 3    | NA                  |
| IMGVR_UViG_3300029435_000002 | rafah    | Alistipes          | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__Alistipes | Confidence_score  | 0.016    | FDR           | 0.994    | 4    | NA                  |
| IMGVR_UViG_3300029435_000002 | rafah    | Alistipes          | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__Alistipes_A | Confidence_score  | 0.016    | FDR           | 0.994    | 4    | NA                  |
| IMGVR_UViG_3300029435_000002 | vhm      | 3300019761_11      | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Marinifilaceae;g_\_;s_\_ | S2star_similarity | 0.485    | NA            | NA       | 1    | 3300019761_11       |
| IMGVR_UViG_3300029435_000002 | vhm      | GCA_003648395.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__UBA1556;g__4572-112;s__4572-112 sp003648395 | S2star_similarity | 0.434    | NA            | NA       | 2    | GB_GCA_003648395.1  |
| IMGVR_UViG_3300029435_000002 | vhm      | GCA_002505585.1    | d__Archaea;p__Nanoarchaeota;c__Nanoarchaeia;o__SCGC-AAA011-G17;f__UBA489;g__UBA489;s__UBA489 sp002505585 | S2star_similarity | 0.433    | NA            | NA       | 3    | GB_GCA_002505585.1  |
| IMGVR_UViG_3300029435_000002 | vhm      | GCF_003290445.1    | d__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Francisellales;f__Francisellaceae;g__Francisella_A;s__Francisella_A adeliensis | S2star_similarity | 0.425    | NA            | NA       | 4    | RS_GCF_003290445.1  |
| IMGVR_UViG_3300029435_000002 | vhm      | GCF_000764555.1    | d__Bacteria;p__Proteobacteria;c__Gammaproteobacteria;o__Francisellales;f__Francisellaceae;g__Francisella;s__Francisella sp000764555 | S2star_similarity | 0.421    | NA            | NA       | 5    | RS_GCF_000764555.1  |
| IMGVR_UViG_3300029435_000002 | wish     | GCF_005217565.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Prolixibacteraceae;g__Puteibacter;s__Puteibacter caeruleilacunae | Log-likelihood    | \-1.364  | p-value       | 0.196538 | 1    | RS_GCF_005217565.1  |
| IMGVR_UViG_3300029435_000002 | wish     | GCF_001637225.1    | d__Bacteria;p__Firmicutes;c__Bacilli;o__Paenibacillales;f__Paenibacillaceae;g__Paenibacillus;s__Paenibacillus antarcticus | Log-likelihood    | \-1.365  | p-value       | 0.17717  | 2    | RS_GCF_001637225.1  |
| IMGVR_UViG_3300029435_000002 | wish     | GCF_002964605.1    | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Vallitaleaceae_A;g__Vallitalea_A;s__Vallitalea_A okinawensis | Log-likelihood    | \-1.366  | p-value       | 0.180156 | 3    | RS_GCF_002964605.1  |
| IMGVR_UViG_3300029435_000002 | wish     | GCF_900142955.1    | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Anaerosporobacter;s__Anaerosporobacter mobilis | Log-likelihood    | \-1.367  | p-value       | 0.19196  | 4    | RS_GCF_900142955.1  |
| IMGVR_UViG_3300029435_000002 | wish     | GCF_000373185.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella paludivivens | Log-likelihood    | \-1.367  | p-value       | 0.177472 | 5    | RS_GCF_000373185.1  |
| IMGVR_UViG_3300029435_000002 | php      | GCA_003045065.1    | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Prolixibacteraceae;g__Puteibacter;s__Puteibacter caeruleilacunae | Score             | 1442.476 | NA            | 0.NA     | 1    | GB_GCA_003045065.1  |
| IMGVR_UViG_3300029435_000002 | php      | 3300019761_11      | d__Bacteria;p__Firmicutes;c__Bacilli;o__Paenibacillales;f__Paenibacillaceae;g__Paenibacillus;s__Paenibacillus antarcticus | Score             | 1442.311 | NA            | NA       | 2    | 3300019761_11       |
| IMGVR_UViG_3300029435_000002 | php      | GCF_000325745.1    | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Vallitaleaceae_A;g__Vallitalea_A;s__Vallitalea_A okinawensis | Score             | 1439.722 | NA            | NA       | 3    | RS_GCF_000325745.1  |
| IMGVR_UViG_3300029435_000002 | php      | GCF_000373185.1    | d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Anaerosporobacter;s__Anaerosporobacter mobilis | Score             | 1439.305 | NA            | NA       | 4    | RS_GCF_000373185.1  |
| IMGVR_UViG_3300029435_000002 | php      | 3300027828_61      | d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Prevotella;s__Prevotella paludivivens | Score             | 1438.882 | NA            | NA       | 5    | 3300027828_61       |

* This output files lists the 5 best hits for each method for each input virus. The first contig (IMGVR_UViG_3300029435_000002) from the Host_prediction_to_genus_m90.csv is included in this example.
* When no hits were obtained, the corresponding method is not listed in this output file for the query virus. For instance, here, IMGVR_UViG_3300029435_000002 did not yield any significant and reliable blast hit, and no blast results are listed.