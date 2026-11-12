# GitEasy网页教材：维护与发布

网页入口为`website/index.html`，完整静态产物随仓库保存，支持直接打开HTML，也可通过HTTP预览。不依赖CDN、登录或后端服务；搜索索引与脚本均为本地文件。项目Pages的发布地址为`https://tsingke.github.io/GitEasy/`，以实际部署成功状态为准。

## 内容来源

网页正文来自作者的LaTeX书稿，命令块保持原始文本，习题解析来自结构化数据，251幅编号图从已确认书稿及原始图片导出。网页重排独立于纸本分页，保留图号与正文引用。原始高清素材及可编辑图源继续保留在仓库assets目录。

- 页面模板：`tools/site_templates/`。
- 内容导出：`tools/export_book_site.py`。
- 界面样式与行为：`website/style.css`、`website/app.js`。
- 生成页面：`website/chapters/`、`website/reference/`与首页。
- 搜索索引：`website/search-data.js`。
- 来源哈希及图形导出记录：`website/build-manifest.json`。

正文应优先修改教材源文件，再生成网页；不要只改生成HTML后遗漏书稿。维护UI时直接修改样式、脚本及模板；运行导出器会更新页面、索引和图片，不覆盖style.css与app.js。

## 更新与验证

导出器在作者工作目录使用，默认通过相对位置寻找`6-GitBook修订稿`，也支持`--book`指定书稿。需要已编译的主PDF及对应aux文件、pandoc、PyMuPDF、Pillow和BeautifulSoup。普通读者预览和CI验证无需安装这些导出依赖。

```bash
python3 tools/export_book_site.py
python3 tools/check_site.py
python3 tools/check_materials.py
python3 -m http.server 8000 --directory website
```

打开`http://localhost:8000`。每次改版检查章节数量、题目与图表对应关系、代码复制、搜索定位、高清图片、手机导航、主题切换、完成标记和键盘操作。搜索与学习进度在浏览器中处理，完成记录只存本地；清理浏览器数据可能丢失记录。三份状态实验是单文件内容模型，不会执行Git或访问用户文件。

`tools/check_site.py`核对静态页面、资源路径、内部锚点、图题、习题数和Pages子路径兼容性。网页展示准确性仍需人工审读，特别是图像裁取、表格、公式和跨章引用。

## GitHub Pages

工作流见`.github/workflows/pages.yml`，检查静态产物后仅上传website目录。PR运行检查；main上的推送或手动触发进入部署。部署使用GitHub官方Pages Actions，权限限制在需要的任务中。

仓库Settings → Pages中选择GitHub Actions作为发布来源。私有仓库能否启用Pages取决于账户方案及组织策略；不要为绕过限制自动修改仓库可见性。部署网站的访问范围与仓库可见性并非同一概念，应按作者授权设置。

[GitHub自定义Pages工作流说明](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)提供现行配置依据。发布成功前不要把预期URL描述为已经上线。

## 内容许可

教材仍是未出版学习交流稿，非商业使用，权利归作者所有；程序代码与第三方材料依各自许可。展示网站不改变这些权利边界。

发布前还需在仓库Actions变量中设置`ENABLE_GITEASY_PAGES=true`。该变量默认未开启，允许先在私有仓库保存完整站点并运行检查；确认Pages可用及预期访问范围后再开启部署。

2026年11月12日：作者明确授权将GitEasy设为公开仓库并启用Pages，已完成仓库可见性调整及workflow发布来源配置。页面发布结果以Actions实际运行记录为准。
