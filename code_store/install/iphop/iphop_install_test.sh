#!/bin/bash

# construct the environment and install iphop
#dvc,dvc-ssh,git are installed for storing and sharing data
conda create -n iphop_env python=3.8 git dvc dvc-ssh
conda activate iphop_env
conda install -c bioconda iphop

#download database and input data for test 
export path_of_db_input=Input/Rawdata/iphop_install_test
mkdir $path_of_db_input/iphop_db_test
iphop download --db_dir $path_of_db_input/iphop_db_test/ -dbv iPHoP_db_rw_for-test#when dowload the latest whole database, "-dbv iPHoP_db_Aug23_rw"

#download the Phage Genomes for Test
mkdir $path_of_db_input/iphop_input_test
cd $path_of_db_input/iphop_input_test
wget https://bitbucket.org/srouxjgi/iphop/raw/d27b6bbdcd39a6a1cb8407c44ccbcc800d2b4f78/test/test_input_phages.fna

#Run and Test iPHoP
export path_of_db_input=Input/Rawdata/iphop_install_test
export path_of_output=Output/iphop_install_test
mkdir $path_of_output/iphop_results_test
iphop predict --fa_file $path_of_db_input/iphop_input_test/test_input_phages.fna --db_dir $path_of_db_input/iphop_db_test/Test_db_rw/ --out_dir  $path_of_output/iphop_results_test/
# Note: you can replace "Test_db_rw" by the version of the database you have


