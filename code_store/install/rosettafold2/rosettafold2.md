## Compare with AF2

![img](https://i-blog.csdnimg.cn/blog_migrate/c1d3e9eea3bb3de4ad36471a2035479b.png)

## Installation

### Clone the package

```bash
git clone https://github.com/uw-ipd/RoseTTAFold2.git
cd RoseTTAFold2
```

### Create conda environment

```
# create conda environment for RoseTTAFold2
conda env create -f RF2-linux.yml
```

### You also need to install NVIDIA's SE(3)-Transformer (**please use SE3Transformer in this repo to install**).

```bash
conda activate RF2
cd SE3Transformer
pip install --no-cache-dir -r requirements.txt
# In order to make all the research gain relevant data, store all the data need to download in govc/Input/Rawdata/rf2_db_input/, then create ln -s to software subdirectory.
python setup.py install
cd ..
```

### Download pre-trained weights under network directory

There are some questions, you should store data in network/weights/ , what's more, the  run_RF2.sh use the version RF2_apr23.pt , so it is better to modify the script or create symbolic link to rename.![image-20241031170930544](C:\Users\hantao\AppData\Roaming\Typora\typora-user-images\image-20241031170930544.png)           

```bash
mkdir network/weights
cd network/weights
wget https://files.ipd.uw.edu/dimaio/RF2_jan24.tgz
tar xvfz RF2_jan24.tgz
cd ../..
```



```
../run_RF2.sh rcsb_pdb_8HBN.fasta --pair -o 8HBN
```



### Example 3: predicting the structure of a heterotrimer with paired MSA



```
../run_RF2.sh rcsb_pdb_7ZLR.fasta --pair -o 7ZLR
```



### Example 4: predicting the structure of a C6-symmetric homodimer



```
../run_RF2.sh rcsb_pdb_7YTB.fasta --symm C6 -o 7YTB
```



### Example 5: predicting the structure of a C3-symmetric heterodimer (A3B3 complex) with paired MSA



```
../run_RF2.sh rcsb_pdb_7LAW.fasta --symm C3 --pair -o 7LAW
```



### Expected outputs

Predictions will be output to the folder 1XXX/models/model_final.pdb. B-factors show the predicted LDDT. A json file and .npz file give additional accuracy information.

### Additional information

The script `run_RF2.sh` has a few extra options that may be useful for runs:

```
Usage: run_RF2.sh [-o|--outdir name] [-s|--symm symmgroup] [-p|--pair] [-h|--hhpred] input1.fasta ... inputN.fasta
Options:
     -o|--outdir name: Write to this output directory
     -s|--symm symmgroup (BETA): run with the specified spacegroup.
                              Understands Cn, Dn, T, I, O (with n an integer).
     -p|--pair: If more than one chain is provided, pair MSAs based on taxonomy ID.
     -h|--hhpred: Run hhpred to generate templates
```