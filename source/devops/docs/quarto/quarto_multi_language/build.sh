#!/usr/bin/env bash
set -e

echo "🚀 Building Cloud Atlas - AI Hub..."

# 1. 清理旧产物
rm -rf _site

# 2. 独立构建英文站
echo "Building English site..."
cd en && quarto render && cd ..

# 3. 独立构建中文站
echo "Building Chinese site..."
cd zh && quarto render && cd ..

# 4. 组装最终的 _site 目录（将根目录的重定向 index.html 放进去，并把 en/zh 产物归位）
mkdir -p _site

cat << EOF > _site/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url=./en/">
    <title>Cloud Atlas - AI Hub</title>
</head>
<body>
    <p>Redirecting to <a href="./en/">Cloud Atlas English Hub</a>...</p>
</body>
EOF

cp -r en/_site _site/en
cp -r zh/_site _site/zh

echo "✅ Build completed successfully!"
