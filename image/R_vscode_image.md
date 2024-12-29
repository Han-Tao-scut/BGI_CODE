## R—VScode

功能：R：该镜像为在STO平台基于VScode软件实现R语言的集成开发环境(IDE)

版本：r-base=4.1.2

已构建版本[R_VScode](https://cloud.stomics.tech/library/#/image/image-detail/i3oNKVqa5b1g7?zone=sz)  

## 0.基础镜像： **vscode_base_conda**

镜像详情：[**vscode_base_conda**](https://cloud.stomics.tech/library/#/image/image-detail/iY74boPPoKRwX?zone=sz)  

适用于需要基于基础镜像开发新的工具或工作环境的目的。  
该镜像基于预设镜像 `stereonote-code-basic`, 安装了 `conda` 包管理工具，并配置了 `conda` 的环境变量,用户可以通过 `conda` `pip` 在个性化分析中安装其他分析工具，同时设置了`chown -R 10000:100 /home/stereonote`,用户可以使用`conda`在`/home/stereonote`自由安装软件，实现个性化分析工具的快速部署。

**NOTE**:暂时无法添加sudo权限，如果需要使用`apt-get`请使用**镜像构建**

### bash构建

若需单独构建该镜像或该镜像无法访问，可以通过以下命令自行构建：
镜像来源选择: ` vscode_base_conda`  
bash指令：  

```bash
conda create -n r_env python=3.8 -y
conda activate r_env
conda install conda-forge::r-base=4.1.2 -y
R
install.packages("languageserver", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
install.packages("rmarkdown", repos="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
conda install -c conda-forge pandoc -y
pip install  radian
conda install tttpob::r-vscdebugger -y
conda install conda-forge::r-httpgd -y
conda clean --all -y
```

同时，还需要安装R-VSCODE的拓展,以及设置RPATH和Rterm

![image-20241229133238650](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20241229133238650.png)

Rpath：请更换为自己环境下R的地址，使用`whereis R`

![rPATH](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20241229133317687.png)

RTERM：radian `whereis radian`

![image-20241229133555796](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20241229133555796.png)

![hantap](https://raw.githubusercontent.com/Han-Tao-scut/photo/master/image-20241229133642543.png)

注意请添加R的二进制文件路径`whereis R`

## 1.（推荐）最新镜像： **R_VScode**

镜像详情：[R_VScode](https://cloud.stomics.tech/library/#/image/image-detail/i3oNKVqa5b1g7?zone=sz)  

适用于直接开展常见分析内容。  
最新镜像涵盖了****[R_VScode](https://cloud.stomics.tech/library/#/image/image-detail/i3oNKVqa5b1g7?zone=sz)****所需要的依赖项和github仓库，并配置了环境变量，方便直接使用。

包含环境与工具：

```bash
# conda environments:
#
base                   /home/hantao/miniconda3
r_env                  /home/hantao/miniconda3/envs/r_env
 # Name                    Version                   Build  Channel
radian                    0.6.13                   pypi_0    pypi
```

**使用指南：**

1.切换到R环境，`conda activate r_env`,

2.ctrl+shift+P:执行R create terminal，开启终端

3.下载R包时，为避免bug，请使用conda；例如下载`tidyverse`

打开bash termianl，启动`conda activate r_env`,然后使用`conda install conda-forge::r-tidyverse -y`下载，https://anaconda.org/conda-forge/可前往此进行浏览相关包的信息，然后library即可

## 2.Changelog 更新日志
