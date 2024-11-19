library(ggraph)
library(igraph)
library(tidyverse)
library(ggdist)
library(glue)
library(ggtext)
library(patchwork)
# 读取蛋白质数据文件
df <- read_csv("C:/Users/hantao/Documents/output_summary.csv") # 请将路径替换为实际数据文件路径
# 假设数据已加载并命名为 df
# 对蛋白质长度做对数变换
df_plot <- df %>%
  group_by(category) %>%
  summarise(mean_length = mean(length, na.rm = TRUE)) %>%
  arrange(desc(mean_length))

# 将分类设为因子，以确保在绘图时顺序不变
df_plot$category <- factor(df_plot$category, levels = unique(df_plot$category))

# 计算中位数长度
median_length <- median(df$length, na.rm = TRUE)

# 设置绘图参数
bg_color <- "grey97"
font_family <- "Times New Roman"

plot_subtitle <- glue("Protein sequence lengths for different categories.
Data shows how the lengths are distributed across the categories.
The most frequent categories are shown.")

# 拉高部分分类的密度图宽度，例如 TRNA_CLASSIFIED, LYS_CLASSIFIED, PAC_CLASSIFIED, INF_CLASSIFIED
p <- df %>%
  ggplot(aes(x = category, y = length)) +
  stat_halfeye(aes(height = ifelse(category %in% c( "PAC_CLASSIFIED","UNCLASSIFIED_CLASSIFIEIED","UNCLASSIFIED","TRNA_CLASSIFIED","REP_CLASSIFIED","REG_CLASSIFIED","INF_CLASSIFIED","HYP_CLASSIFIED","EVA_CLASSIFIED","CDS_CLASSIFIED","ASB_CLASSIFIED"), 500, 1.0)), 
               fill_type = "segments", alpha = 0.9, adjust = 30, position = position_dodge(width = 0.8)) +  # 条件调整宽度
  stat_interval(position = position_dodge(width = 0.8)) +  # 保持与密度区域一致的间距
  stat_summary(geom = "point", fun = median, position = position_dodge(width = 0.8)) +  # 中位数点，间距一致
  geom_hline(yintercept = median_length, col = "grey30", lty = "dashed") +  # 中位数虚线
  annotate("text", x = length(unique(df$category)) + 0.5, y = median_length + 0.5, 
           label = "Median length", family = font_family, size = 3, hjust = 0) +
  scale_x_discrete(labels = toupper) +  # 分类名称大写
  scale_y_continuous(breaks = seq(2, 11, by = 1), limits = c(2, 11)) +  # 限定 Y 轴范围在 2 到 11 之间
  scale_color_manual(values = MetBrewer::met.brewer("VanGogh3")) +  # 使用 VanGogh3 配色
  coord_flip() +  # 翻转坐标
  guides(color = "none") +  # 移除颜色图例
  labs(
    title = toupper("Protein Sequence Lengths Across Different Categories"),
    subtitle = plot_subtitle,
    caption = "Data source: Your CSV file.<br>Visualization by Your Name.",
    x = NULL,
    y = "Length"
  ) +
  theme_minimal(base_family = font_family) +  # 使用 minimal 主题
  theme(
    plot.background = element_rect(color = NA, fill = bg_color),
    panel.grid = element_blank(),
    panel.grid.major.x = element_line(linewidth = 0.1, color = "grey75"),
    plot.title = element_text(family = font_family, face = "bold"),
    plot.title.position = "plot",
    plot.subtitle = ggtext::element_textbox_simple(
      margin = margin(t = 4, b = 16), size = 10),
    plot.caption = ggtext::element_textbox_simple(
      margin = margin(t = 12), size = 7
    ),
    plot.caption.position = "plot",
    axis.text.y = element_text(hjust = 0, margin = margin(r = -10), family = font_family, face = "bold"),
    plot.margin = margin(4, 4, 4, 4)
  )

# 显示图表
print(p)