mkdir -p /home/stereonote
chown -R 10000:100 /home/stereonote
conda install -y jupyter
ln -s /opt/conda/bin/jupyter /usr/bin/jupyter   
conda clean --all --yes
cd /home/stereonote
conda install git -y
#sudo,可选，非必须
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors1.sz.cngb.org/repository/os/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors1.sz.cngb.org/repository/os/repo/epel7.repo
yum clean all
yum makecache
yum install -y sudo
chmod 444 /etc/sudoers
echo -e "stereonote\tALL=(ALL)\tNOPASSWD: ALL" >> /etc/sudoers
#install rf2
git clone https://github.com/uw-ipd/RoseTTAFold2.git
cd RoseTTAFold2
#修改yml
conda install -y vim
vim RF2-linux.yml
#修改cuda版本
    name: RF2
    channels:
    - pytorch
    - nvidia
    - defaults
    - conda-forge
    dependencies:
    - python=3.10
    - pip
    - cudatoolkit=11.8
    - pytorch=2.1.1
    - pytorch-cuda=11.8
    - dglteam/label/cu117::dgl
    - pyg::pyg
    - bioconda::hhsuite
    - pandas=2.2.0
conda env create -f RF2-linux.yml -y
conda activate RF2
conda install ipython -y
conda uninstall pytorch -y
conda uninstall pytorch-cuda -y
pip install torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu118
# Test that cuda is available in ipython:
import torch 
print(torch.cuda.is_available()) # should read "True"
#pip
pip install torchdata
pip install pydantic
conda install -y wget
wget https://data.dgl.ai/wheels/cu118/dgl-2.1.0%2Bcu118-cp310-cp310-manylinux1_x86_64.whl
pip install dgl-2.1.0+cu118-cp310-cp310-manylinux1_x86_64.whl
#vim /PATH/TO/miniconda3/envs/RF2/lib/python3.10/site-packages/torch/utils/_import_utils.py
conda install -y vim
cd /PATH/TO/miniconda3/envs/RF2/lib/python3.10/site-packages/torch/utils/_import_utils.py
#内容如下：
    import functools
    import importlib.util

    import torch


    def _check_module_exists(name: str) -> bool:
        r"""Returns if a top-level module with :attr:`name` exists *without**
        importing it. This is generally safer than try-catch block around a
        `import X`. It avoids third party libraries breaking assumptions of some of
        our tests, e.g., setting multiprocessing start method when imported
        (see librosa/#747, torchvision/#544).
        """
        try:
            spec = importlib.util.find_spec(name)
            return spec is not None
        except ImportError:
            return False


    @functools.lru_cache
    def dill_available():
        return (
            _check_module_exists("dill")
            # dill fails to import under torchdeploy
            and not torch._running_with_deploy()
        )


    @functools.lru_cache
    def import_dill():
        if not dill_available():
            return None

        import dill

        # XXX: By default, dill writes the Pickler dispatch table to inject its
        # own logic there. This globally affects the behavior of the standard library
        # pickler for any user who transitively depends on this module!
        # Undo this extension to avoid altering the behavior of the pickler globally.
        dill.extend(use_dill=False)
        return dill

cd SE3Transformer
/PATH/TO/miniconda3/envs/RF2/bin/pip install --no-cache-dir -r requirements.txt
python setup.py install
cd ..
cd network
wget https://files.ipd.uw.edu/dimaio/RF2_apr23.tgz
tar xvfz RF2_apr23.tgz
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
#install c++,此处我也不知道具体的安装方法，请自行摸索
sudo yum install -y make bison
conda install -c conda-forge make -y
conda install -c conda-forge cmake -y
conda install -c conda-forge gcc_linux-64 gxx_linux-64 -y
conda install -c conda-forge libstdcxx-ng -y
conda install -c conda-forge libgcc-ng -y
conda install binutils -y
#更新gcc
wget -P /home/common/install-package/ https://mirrors.aliyun.com/gnu/gcc/gcc-10.1.0/gcc-10.1.0.tar.gz
cd /home/common/install-package/
tar -xvf gcc-10.1.0.tar.gz -C /opt
cd /opt/gcc-10.1.0
mkdir build/
cd build/
../configure --prefix=/opt/gcc-10.1.0/ --enable-checking=release --enable-languages=c,c++ --disable-multilib
#gmp安装
wget -P /home/common/install-package/ https://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.2.1.tar.bz2
tar -vxf gmp-6.2.1.tar.bz2 -C /opt
cd /opt/gmp-6.2.1
./configure --prefix=/opt/gmp-6.2.1
make
make install
#MPFR编译
wget -P /home/common/install-package/ https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-4.1.0.tar.bz2
tar -vxf mpfr-4.1.0.tar.bz2 -C /opt
cd /opt/mpfr-4.1.0/
./configure --prefix=/opt/mpfr-4.1.0 --with-gmp=/opt/gmp-6.2.1
make
make install
#MPC编译
wget -P /home/common/install-package/ https://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.2.1.tar.gz
tar -zvxf mpc-1.2.1.tar.gz -C /opt
cd /opt/mpc-1.2.1
./configure --prefix=/opt/mpc-1.2.1 --with-gmp=/opt/gmp-6.2.1 --with-mpfr=/opt/mpfr-4.1.0
make
make install
#GCC编译
cd /opt/gcc-10.1.0
cd build
../configure --prefix=/opt/gcc-10.1.0/ --enable-checking=release --enable-languages=c,c++ --disable-multilib --with-gmp=/opt/gmp-6.2.1 --with-mpfr=/opt/mpfr-4.1.0 --with-mpc=/opt/mpc-1.2.1
make -j8 # 时间很长很长 耐心等待 也可以使用make -j8
make install
#libmpc.so.3安装
wget -P /home/common/install-package/ https://distrib-coffee.ipsl.jussieu.fr/pub/linux/altlinux/p10/branch/x86_64/RPMS.classic/libmpfr6-4.1.0-alt1.x86_64.rpm
rpm2cpio libmpfr6-4.1.0-alt1.x86_64.rpm | cpio -div
rpm2cpio libmpfr6-4.1.0-alt1.x86_64.rpm | cpio -div
mv  ./usr/lib64/libmpfr.so.6 /usr/lib64/
mv  ./usr/lib64/libmpfr.so.6.1.0 /usr/lib64/
cd /opt/gcc-10.1.0
cd build
make -j8 # 时间很长很长 耐心等待 也可以使用make -j8
make install
#gcc版本更新
mv /usr/bin/gcc /usr/bin/gcc485
mv /usr/bin/g++ /usr/bin/g++485
mv /usr/bin/c++ /usr/bin/c++485
mv /usr/bin/cc /usr/bin/cc485
ln -s /opt/gcc-10.1.0/bin/gcc /usr/bin/gcc
ln -s /opt/gcc-10.1.0/bin/g++ /usr/bin/g++
ln -s /opt/gcc-10.1.0/bin/c++ /usr/bin/c++
ln -s /opt/gcc-10.1.0/bin/gcc /usr/bin/cc
mv /usr/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6.bak
ln -s /opt/gcc-10.1.0/lib64/libstdc++.so.6.0.28 /usr/lib64/libstdc++.so.6
gcc -v
#install glibc
wget http://ftp.gnu.org/gnu/glibc/glibc-2.27.tar.gz
tar -xvf glibc-2.27.tar.gz
mkdir glibc-build
cd glibc-build
../glibc-2.27/configure --prefix=$HOME/glibc-2.27
make -j$(nproc)
make install
export LD_LIBRARY_PATH=$HOME/glibc-2.27/lib:$LD_LIBRARY_PATH

#view run_rf2.sh and predict.py for details
#Note:
#同时这连个脚本中的参数模型存在问题，需要根据你使用的版本进行修改
#bfd, pdb和 uniref database 三个的路径经检查脚本发现需要存储在run——rf2.sh脚本的同级目录下，因此需要将其拷贝到同级目录下,e.g. ./bfd/bfd/....
#predict.py中加入：
import mkl 
mkl.set_num_threads(1)

#一定需要注意，run_rf2.sh脚本一定得放在RosetaFold2目录下，否则会影响路径的创建与找寻

#下面是批量运行的脚本，可以将需要运行的pdb文件名列表存放在一个文件中，然后运行脚本，即可批量运行


#!/bin/bash

# 定义输入的 FASTA 文件
input_fasta="/data/work/input.fasta"  # 请替换为你的输入文件路径
extracted_seq_dir="/data/output/extracted_sequences"  # 存放提取的序列文件的目录
prediction_output_dir="/data/output/rosettafold_predictions"  # 存放 RosettaFold2 预测结果的目录
rosettafold_script="/ldfssz1/ST_HEALTH/P20Z10200N0206/P20Z10200N0206_pathogendb/hantao/analysis/RoseTTAFold2/run_RF2.sh"  # RosettaFold2 预测脚本的路径
time_summary_file="/data/output/average_prediction_time.txt"  # 保存平均预测时间的文件

# 创建输出目录
mkdir -p "$extracted_seq_dir"
mkdir -p "$prediction_output_dir"

# 使用 Bash 和 Awk 提取每一条序列并保存为独立的文件，同时去除结尾的 '*'
echo "提取序列到独立文件..."
awk -v outdir="$extracted_seq_dir" '
    /^>/ {
        if (seq_id) close(file);  # 关闭之前的文件
        split($0, header_parts, "#");  # 分割获取 # 前的唯一标识符
        seq_id = substr(header_parts[1], 2);  # 移除 > 符号并保存唯一标识符
        file = outdir "/" seq_id ".fasta";
        print $0 > file;  # 输出到文件
    }
    /^[^>]/ {
        gsub(/\*$/, "", $0);  # 删除序列行末尾的 '*' 符号
        print $0 >> file;  # 将序列部分追加到文件
    }
' "$input_fasta"

echo "FASTA 文件中所有序列已单独保存到 $extracted_seq_dir"

# 初始化用于记录各个长度区间的总时间和计数
declare -A time_sums
declare -A count_sums

# 获取可用的 GPU 数量
gpu_count=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
echo "检测到 ${gpu_count} 块 GPU 可用，将进行任务分配。"

# 读取所有的序列文件列表
seq_files=("$extracted_seq_dir"/*.fasta)
total_files=${#seq_files[@]}

# 定义一个函数来执行 RosettaFold2 预测
run_prediction() {
    local seq_file=$1
    local gpu_id=$2
    local seq_name=$(basename "$seq_file" .fasta)
    local output_prediction_dir="$prediction_output_dir/${seq_name}_prediction"

    # 创建该序列的预测输出目录
    mkdir -p "$output_prediction_dir"

    # 读取序列长度
    local seq_length=$(grep -v ">" "$seq_file" | tr -d '\n' | wc -c)

    # 记录开始时间
    local start_time=$(date +%s)

    # 设置 GPU ID 并运行 RosettaFold2 进行预测
    CUDA_VISIBLE_DEVICES="$gpu_id" bash "$rosettafold_script" -i "$seq_file" -o "$output_prediction_dir" --use-gpu

    # 记录结束时间
    local end_time=$(date +%s)

    # 计算用时
    local elapsed_time=$((end_time - start_time))

    # 计算所属长度区间 (以 50 为间隔)
    local length_group=$(( (seq_length + 49) / 50 * 50 ))

    # 更新该长度区间的总时间和计数
    echo "$length_group $elapsed_time" >> "${time_summary_file}.tmp"

    echo "预测完成: $seq_file -> $output_prediction_dir (使用 GPU: $gpu_id)"
}

# 分配任务给 GPU，使用后台任务和 `wait` 来实现并行化
for ((i=0; i<$total_files; i++)); do
    seq_file="${seq_files[$i]}"
    gpu_id=$((i % gpu_count))  # 根据 GPU 数量循环分配 GPU ID

    # 运行预测任务到后台
    run_prediction "$seq_file" "$gpu_id" &
    
    # 每次启动的任务数量不超过 GPU 数量
    if (( (i + 1) % gpu_count == 0 )); then
        wait  # 等待当前所有任务完成，然后继续下一批任务
    fi
done

# 等待所有后台任务完成
wait

echo "所有 RosettaFold2 预测任务已完成。"

# 计算并输出每个长度区间的平均时间，并写入到文件
echo "每个长度区间的平均预测时间 (秒):" > "$time_summary_file"

# 汇总各区间的时间和计数
declare -A total_times
declare -A total_counts

while read length_group elapsed_time; do
    total_times[$length_group]=$(( ${total_times[$length_group]:-0} + elapsed_time ))
    total_counts[$length_group]=$(( ${total_counts[$length_group]:-0} + 1 ))
done < "${time_summary_file}.tmp"

# 计算并写入平均时间
for length_group in "${!total_times[@]}"; do
    avg_time=$(echo "${total_times[$length_group]} / ${total_counts[$length_group]}" | bc -l)
    echo "  序列长度在 $((length_group - 49)) 到 $length_group 残基之间: 平均时间 = ${avg_time} 秒" | tee -a "$time_summary_file"
done

# 清理临时文件
rm -f "${time_summary_file}.tmp"

echo "平均预测时间已写入到文件: $time_summary_file"
#执行单链的预测时，可以将所有的fasta文件放在一个fasta文件中，软件自带脚本会自动处理，你也可以自己写脚本处理。
#!/usr/bin/env python3
from Bio import SeqIO
import os

# 定义输入的 FASTA 文件路径和输出目录
input_fasta = "/data/work/input.fasta"  # 请替换为你的输入文件路径
extracted_seq_dir = "/data/output/extracted_sequences"  # 存放提取的序列文件的目录

# 创建输出目录（如果不存在）
os.makedirs(extracted_seq_dir, exist_ok=True)

# 读取输入的 FASTA 文件，提取每一条序列并保存为独立的文件
with open(input_fasta, "r") as fasta_handle:
    for record in SeqIO.parse(fasta_handle, "fasta"):
        # 获取唯一标识符（去掉#前的部分）
        seq_id = record.id.split("#")[0]

        # 删除末尾的 '*' 符号（如果存在）
        record.seq = record.seq.rstrip("*")

        # 保存为独立的 fasta 文件
        output_path = os.path.join(extracted_seq_dir, f"{seq_id}.fasta")
        with open(output_path, "w") as output_handle:
            SeqIO.write(record, output_handle, "fasta")

print(f"FASTA 文件中所有序列已单独保存到 {extracted_seq_dir}")