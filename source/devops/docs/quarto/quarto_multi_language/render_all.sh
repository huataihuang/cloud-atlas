# 1. 编译根目录（生成根目录的 index.html 门户）
quarto render

# 2. 编译英文子项目（产物输出到 en/_site）
cd en && quarto render && cd ..

# 3. 编译中文子项目（产物输出到 zh/_site）
cd zh && quarto render && cd ..

# 4. 组装到统一的发布目录 _site/
mkdir -p _site/en _site/zh
cp -r en/_site/* _site/en/
cp -r zh/_site/* _site/zh/
