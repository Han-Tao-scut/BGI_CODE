#!/bin/bash
# Install RoseTTAFold2 on Linux
# Usage: bash rf2_install.sh
micromamba create -y  git
micromamba activate RF2 
git clone https://github.com/uw-ipd/RoseTTAFold2.git
cd RoseTTAFold2
micromamba env create -f RF2-linux.yml
cd SE3Transformer
pip install --no-cache-dir -r requirements.txt
# In order to make all the research gain relevant data, store all the data need to download in govc/Input/Rawdata/rf2_db_input/, then create ln -s to software subdirectory.
python setup.py install
cd ..
#执行以下命令检查cuda环境是否可用
import torch
print(torch.cuda.is_available())
print(torch.__version__)
print(torch.__path__)
print(torch.version.cuda)
torch.backends.cudnn.version()
# 如果cuda环境不可用，则需要安装cuda环境，并安装相应的torch版本
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install jax==0.4.29
# 此处jaxlib笔者为whl本地安装
wget https://storage.googleapis.com/jax-releases/cuda12/jaxlib-0.4.29+cuda12.cudnn91-cp310-cp310-manylinux2014_x86_64.whl
pip install jaxlib-0.4.29+cuda12.cudnn91-cp310-cp310-manylinux2014_x86_64.whl 
