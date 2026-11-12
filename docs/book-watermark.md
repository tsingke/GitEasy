# 水印与稿件流转

以下设置适用于完整书稿源码包中的 `6-GitBook修订稿` 目录，请进入该目录执行编译命令。

清洁阅读版默认关闭水印。共享未出版稿时，可使用交付目录中的“共享水印版”，也可直接在LaTeX正文上启用水印。两条生成路径共用 `styles/watermark.tex`，文字为矢量，透明度、字号、角度和坐标均可设置，水印不参与正文排版。

## 一键构建

```bash
python3 scripts/build.py --watermark on
python3 scripts/build.py --watermark off
python3 scripts/build.py --watermark on --watermark-text '张庆科版权所有 仅供课程评阅' --watermark-font-size 24 --watermark-angle 35 --watermark-opacity 0.12 --watermark-x-mm 92.5 --watermark-y-mm 130
```

`--watermark`省略时采用 `booksettings.tex` 的开关；显式命令行参数优先。文字参数按普通文本处理，百分号、下划线等字符由脚本转义。位置指定水印整体的中心，原点为纸张左上角，X向右、Y向下；本书纸张为185 × 260 mm。字号单位为pt，角度单位为度，透明度0表示完全透明、1表示完全不透明。建议透明度0.08至0.15，以保持正文与代码清晰。

## LaTeX统一设置

```latex
\providecommand{\BookWatermarkMode}{on}
\providecommand{\BookWatermarkText}{张庆科著作权所有\quad 未出版交流稿}
\providecommand{\BookWatermarkFontSize}{26pt}
\providecommand{\BookWatermarkAngle}{35}
\providecommand{\BookWatermarkOpacity}{0.11}
\providecommand{\BookWatermarkColor}{black}
\providecommand{\BookWatermarkX}{0.5\paperwidth}
\providecommand{\BookWatermarkY}{0.5\paperheight}
\providecommand{\BookWatermarkScope}{body}
```

在 `booksettings.tex` 中修改已有设置即可，不必重复追加同名命令。`body`覆盖前言、目录、正文和附录等内页，保留干净的封面、封底；`all`包括封面和封底，命令行对应 `--watermark-scope all`。水印位于前景层，可显示在图片、代码框和表格上方。使用更长文字或靠近页边的位置时，应检查样张，避免文字超出纸张。

## 快速生成共享副本

先完成清洁阅读版编译及核验，再运行：

```bash
python3 scripts/build_watermarked_copy.py
```

脚本按上述设置生成独立的矢量水印，将其叠加到已编译PDF的内页；原始PDF保持原样，页数、目录书签、页码标签与链接保留。需要改变水印文字、字号或坐标时，修改统一设置后重新生成即可。将BookWatermarkScope设为all时，共享副本也会覆盖封面封底；直接构建可使用 `--watermark-scope all`。

建议在分发给不同评阅者的副本中加入接收单位或批次，使权属、用途和流转范围清楚可辨。书稿继续适用未出版、学习交流和非商业使用的说明。
