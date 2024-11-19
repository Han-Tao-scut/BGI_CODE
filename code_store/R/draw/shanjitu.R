extrafont::loadfonts()  # 加载系统中的字体，使它们可以用于 R 中的图表

library(tidyverse)     # 加载核心 R 包：包括 dplyr、ggplot2 等数据处理和可视化工具
library(ggridges)      # 加载 ggridges，用于绘制山脊图（类似密度分布的图表）
library(viridis)       # 加载 viridis 包，用于色彩映射（不在本代码中使用，但常用于颜色调色板）
library(extrafont)     # extrafont 用于加载自定义字体，特别是 Google 字体
library(cowplot)       # cowplot 用于创建复杂的布局
font_add_google("DM Serif Display", "abril")  # 加载 Google 字体 "DM Serif Display"，并将其命名为 "abril"
font_add_google("Tajawal", "tawa")            # 加载 Google 字体 "Tajawal"，并将其命名为 "tawa"
showtext_auto()                               # 自动显示加载的字体
theme_set(theme_light())  # 设置 ggplot2 的主题为 theme_light，使用浅色背景和黑色文字
# 从 GitHub 上加载婴儿名字数据集
babynames <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-03-22/babynames.csv")
# 计算所有时间段最受欢迎的50个女性名字
top_female <- babynames |>
  filter(sex == "F") |>               # 只保留女性名字
  group_by(name) |>                   # 按名字进行分组
  summarise(total = sum(n)) |>        # 计算每个名字的总数量
  slice_max(total, n = 50) |>         # 选择总数量最多的前50个名字
  mutate(
    rank = 1:50,                      # 为这些名字排名
    name = forcats::fct_reorder(name, -total)  # 按总数量对名字进行重新排序
  ) |>
  pull(name)                          # 提取名字
# 过滤出只包含最流行的50个女性名字的数据
female_names <- babynames |>
  filter(
    sex == "F",
    name %in% top_female              # 只保留名字在top_female中的数据
  ) |>
  mutate(name = factor(name, levels = levels(top_female))) |> # 将名字设为因子，按照top_female中的排序
  group_by(year, name) |>             # 按年份和名字分组
  summarise(n = sum(n))               # 计算每年每个名字的数量
plot1 <- ggplot(female_names, aes(year,
                                  y = fct_reorder(name, n), height = n / 50000,   # 使用年份作为X轴，名字为Y轴，数量做高度
                                  group = name, scale = 2
)) +
  geom_ridgeline(
    alpha = 0.5, scale = 4.5, linewidth = 0,      # 绘制山脊线条，透明度为0.5，使用深青色填充
    fill = "#05595B", color = "white"
  ) +
  xlim(1900, NA) +                                # 限制X轴最小值为1900
  labs(title = "Female", y = "", x = "") +        # 设置标题、X和Y轴标签为空
  theme(
    plot.title = element_text(hjust = 0, family = "Bahnschrift", size = 20),   # 设置标题的样式
    axis.ticks.y = element_blank(),               # 移除Y轴刻度
    axis.text = element_text(family = "Bahnschrift", size = 15),               # 设置轴标签字体
    panel.grid.major.x = element_blank(),         # 移除X轴主网格线
    panel.grid.minor.x = element_blank(),         # 移除X轴次网格线
    panel.grid.major.y = element_line(size = 0.5),# 设置Y轴主网格线
    panel.border = element_blank()                # 移除面板边框
  ) +
  annotate(
    geom = "text", x = 1970, y = 57, label = "73,982 babies called\n'Mary' in 1921", hjust = "left",
    size = 7, color = "#404040", family = "Bahnschrift" # 添加注释文本
  )
plot1