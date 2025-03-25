# NGS Analysis Workflow For XIAOWA

### Abstract

该流程主要包含以下分析：

- **质控：**fastqc(原始数据质量评估)+TRIMMOMATIC(接头去除和低质量过滤)
- **序列比对：**samtools+bwa
- **测序深度+覆盖度计算**:samtools
- **标记重复序列:**Picard
- **变异检测:**GATK

### **Usage**

#### 镜像获取

```url
https://cloud.stomics.tech/library/#/image/image-detail/i6N5KwNzxbABz?zone=sz
```

在个人分析里面新建一个分析，使用刚才获取的镜像，选择所需要的配置![image-20250325231836243](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20250325231836243.png)

#### 准备工作

```bash
cd ~ #进入家目录
git clone https://gitlab.genomics.cn/hantao/hantao_NGS.git #获取脚本
cd /home/stereonote/hantao_NGS
BASE_DIR="/home/stereonote/hantao_NGS"  # 请根据实际情况修改
INPUT_DIR="$BASE_DIR/input"
OUTPUT_DIR="$BASE_DIR/output"
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"
#设置并行任务数和每个任务分配的线程
#直接修改/home/stereonote/hantao_NGS/code/NGS_DEF.sh中的以下参数
MAX_JOBS=2  # 最大并行任务数
THREADS=8 #设置线程
#根据你的处理器和内存分配
```

#### 上传数据

请将参考序列和双端测序的文件存放进入**$INPUT_DIR**
![sjksdk](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/sjksdk.png)
形如这样,但是不要求一定要满足**fq.gz,fq/fq.gz/fastq/fastq.gz**均可，但是前面的ID名一定要相同，如**FT100079151_L01_UDB-591**，这三个文件一定要相同，因为这是拆分不同样本的唯一ID。

#### 运行

```bash
bash /home/stereonote/hantao_NGS/code/NGS_DEF.sh FT100079151_L01_UDB-591 FT100079151_L01_UDB-592 
```

将你要处理的样本的ID号取代FT100079151_L01_UDB-591，理论上有多少，可以放入多少。

#### Results

结果会存放在

```
/home/stereonote/hantao_NGS/output
```

下以ID为文件名的文件中，一个样本一个文件

![image-20250325231901134](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20250325231901134.png)

如果需要保存结果，请将output存放至/data/output
