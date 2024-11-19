# 加载必需的库
install.packages("scico")
library(scico)
library(ggsci)
library(ggplot2)
library(readr)
library(RColorBrewer)
library(viridis)
# 读取数据
data <- read_csv("C:/Users/hantao/Documents/output_summary.csv") # 请将路径替换为实际数据文件路径
data$length=log(data$length)
# 绘制小提琴图
#竖直
ggplot(data, aes(x = data$category, y = data$length)) +
  geom_violin(trim = TRUE, fill = "lightblue", color = "black",width=3,adjust=3) + # 小提琴图
  theme_minimal(base_family = "Times New Roman") + # 主题设置，使用Times New Roman字体
  labs(title = "小提琴图示例", x = "组别", y = "蛋白质长度") + # 添加标题和轴标签
  theme(axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) # 加粗字体
#水平
ggplot(data, aes(x = length, y = category,fill=category)) +
  geom_violin(trim = FALSE, color = "black", width=1.34, adjust = 3) + # 增加宽度scale = "count"改变计数方法 
  theme_minimal(base_family = "Times New Roman") + # 主题设置，使用Times New Roman字体
  #scale_fill_brewer(palette = "Set3") + # 使用 RColorBrewer 调色板
  scale_fill_viridis(discrete = TRUE) + # 使用 viridis 调色板
  labs(title = "The distribution of proetion length", x = "Log(Protein Length)", y = "Category") + # 添加标题和轴标签
  theme(axis.title.x = element_text(face = "bold.italic",family = "Times New Roman"),
        axis.title.y = element_text(face = "bold.italic"),
        plot.title = element_text(hjust = 0.5, face = "bold"))
# 绘制箱线图，交换 X 轴和 Y 轴
ggplot(data, aes(x = category, y = length,fill = category)) +
  geom_boxplot(color = "black",width=0.5) + # 箱线图
  scale_fill_viridis(discrete = TRUE) +
  theme_minimal(base_family = "Times New Roman") + # 主题设置，使用Times New Roman字体
  labs(title = "蛋白质长度分布箱式图", x = "组别", y = "蛋白质长度") + # 添加标题和轴标签
  theme(axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) # 加粗字体
#合并图层
ggplot(data, aes(x = length, y = category,fill=category)) +
  geom_violin(trim = FALSE, color = "black", width=1.34, adjust = 4) + # 增加宽度scale = "count"改变计数方法 
  geom_boxplot(color = "black",width=0.2) + # 箱线图
  theme_minimal(base_family = "Times New Roman") + # 主题设置，使用Times New Roman字体
  #scale_fill_brewer(13,palette = "set3") + # 使用 RColorBrewer 调色板
  #scale_fill_viridis(discrete = TRUE) + # 使用 viridis 调色板
  #scale_fill_npg() +  # 使用 Nature Publishing Group 调色板
  #scale_fill_manual(values = scico(30, palette = 'devon'))+
  #scale_fill_scico(13,palette = 'davos') +
  scale_color_lancet()+
  labs(title = "The distribution of proetion length", x = "Log(Protein Length)", y = "Category") + # 添加标题和轴标签
  theme(axis.title.x = element_text(face = "bold.italic",family = "Times New Roman"),
        axis.title.y = element_text(face = "bold.italic"),
        axis.text.x = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 X 轴刻度数字
        axis.text.y = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 Y 轴刻度数字
        plot.title = element_text(hjust = 0.5, face = "bold"))
# 加载 plotly 包
library(plotly)

# 数据
values <- c(632914,  3703, 1818000, 666084, 67101, 59620, 315388, 21870, 433958, 2786, 3589827)
value=round(values/sum(values)*100,2)
labels <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")
values <- c(632914, 2164127, 3703, 1818000, 666084, 67101, 59620, 315388, 21870, 433958, 2786, 1425700)
value1=round(values/sum(values)*100,2)
labels <- c("ASB", "CDS", "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "Unc")
values <- c(121344,367602,1405, 444371, 158900,17139 ,11381,54750, 8623, 67264, 1383, 366243)
labels <- c("ASB", "CDS", "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "Unc")
values <- c(121344,1405, 444371, 158900,17139 ,11381,54750, 8623, 67264, 1383, 733845)
labels <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")

# 设置裂开效果
explode <- rep(0.1, length(values))  # 所有部分都裂开，偏移量设置为 0.2

# 创建3D饼图
plot_ly(
  labels = labels,
  values = values,
  type = 'pie',
  hole = 0,  # 控制中空程度
  textinfo = 'percent+label',
  insidetextorientation = 'radial',
  marker = list(
    colors =RColorBrewer::brewer.pal(n = 12,name = "Set2"),  # 设置颜色
    line = list(color = 'black', width = 1)
  ),
  pull = explode  # 使用 explode 参数来控制每个)部分的裂开程度
) %>%layout(
     title = "AFTER cluster",
     showlegend = TRUE,
     scene = list(
     camera = list(eye = list(x = 1.5, y = 1.5, z = 1.5))  # 设置3D视角)
     )
)

#堆叠柱状图
# 加载必要的包
library(ggplot2)

# 定义数据和标签
values1 <- c(632914,  3703, 1818000, 666084, 67101, 59620, 315388, 21870, 433958, 2786, 3589827)
value1=round(values1/sum(values1)*100,2)
labels1 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")
values2 <- c(121344,1405, 444371, 158900,17139 ,11381,54750, 8623, 67264, 1383, 733845)
value2=round(values2/sum(values2)*100,2)
labels2 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")


# 创建数据框
data1 <- data.frame(
  label = labels1,
  value = value1,
  category = 1
)

data2 <- data.frame(
  label = labels2,
  value = value2,
  category = 2
)

# 合并数据
data <- rbind(data1, data2)

# 绘制堆叠条形图
ggplot(data, aes(y= factor(category), x = value, fill = label)) +
  geom_bar(stat = "identity", position = "stack",width = 0.5) +
  labs(
    title = "BEFORE VS AFTER",
    x = "PROP%",
    y = "CATEGORY",
    fill = "LABEL"
  ) +
  scale_fill_brewer(palette = "Set3") + # 使用调色板
  theme_minimal() +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 X 轴刻度数字
    axis.text.y = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 Y 轴刻度数字
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_blank()
  )
#肩并肩比较
# 加载必要的包
library(ggplot2)

# 假设你已经有了 labels1 和 labels2
values1 <- c(632914,  3703, 1818000, 666084, 67101, 59620, 315388, 21870, 433958, 2786, 3589827)
value1=round(values1/sum(values1)*100,2)
labels1 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")
values2 <- c(121344,1405, 444371, 158900,17139 ,11381,54750, 8623, 67264, 1383, 733845)
value2=round(values2/sum(values2)*100,2)
labels2 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")
# 创建数据框
data1 <- data.frame(
  label = labels1,
  value = value1,
  category = "before"
)

data2 <- data.frame(
  label = labels2,
  value = value2,
  category = "after"
)

# 合并数据
data <- rbind(data1, data2)

# 绘制不堆叠的条形图（每个类别有两个条形图）
ggplot(data, aes(x = label, y = value, fill = factor(category))) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +  # position_dodge 用于不堆叠
  labs(
    title = "BEFORE VS AFTER (Non-stacked)",
    x = "LABEL",
    y = "PROP%",
    fill = "CATEGORY"
  ) +
  scale_fill_brewer(palette = "Set3") +  # 使用调色板
  theme_minimal() +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 X 轴刻度数字
    axis.text.y = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),  # 修改 Y 轴刻度数字
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_blank()
  )
#背靠背对比柱状图
# 加载必要的包
library(ggplot2)
library(dplyr)

# 假设你已经有了 labels1 和 labels2
values1 <- c(632914,  3703, 1818000, 666084, 67101, 59620, 315388, 21870, 433958, 2786, 3589827)
value1=round(values1/sum(values1)*100,2)
labels1 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")
values2 <- c(121344,1405, 444371, 158900,17139 ,11381,54750, 8623, 67264, 1383, 733845)
value2=round(values2/sum(values2)*100,2)
labels2 <- c("ASB",  "EVA", "HYP", "INF", "INT", "LYS", "PAC", "REG", "REP", "TRNA", "UNS")

# 创建数据框
data1 <- data.frame(
  label = labels1,
  value = -value1,  # 将 value1 设为负值
  category = "Before"
)

data2 <- data.frame(
  label = labels2,
  value = value2,
  category = "After"
)

# 合并数据
data <- rbind(data1, data2)

# 排序数据框
data <- data %>%
  arrange(-desc(abs(value))) %>%
  mutate(label = factor(label, levels = unique(label)))

# 绘制背靠背对比柱状图
ggplot(data, aes(x = value, y = label, fill = category)) +
  geom_bar(stat = "identity", width = 0.8) +
  geom_text(aes(label = abs(value), hjust = ifelse(value < 0, 1.1, -0.1)), 
            size = 3.5, family = "Times New Roman", fontface = "bold", color = "black") +
  scale_x_continuous(labels = abs) +  # 将 X 轴的标签设为正数
  labs(
    title = "BEFORE VS AFTER CLUSTER",
    x = "PROP%",
    y = "LABEL",
    fill = "CATEGORY"
  ) +
  scale_fill_brewer(palette = "Set2") +  # 使用调色板
  theme_minimal() +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),
    axis.text.y = element_text(face = "bold", size = 10, family = "Times New Roman", color = "black"),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_text(face = "bold")
  )
