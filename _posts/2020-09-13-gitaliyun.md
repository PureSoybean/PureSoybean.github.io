---
title: blog同步步骤
key: jekyll
tag: jekyll
show_author_profile: true
---

windows同步初始化

git remote add origin git@github.com:PureSoybean/PureSoybean.github.io.git
git add .
git commit -m "first"
git push -u origin master

阿里云服务器同步命令
sudo pkill -f jekyll
sudo rm -rf /jekyll/TeXt
git clone https://github.com/PureSoybean/PureSoybean.github.io /jekyll/TeXt/
sudo bundle exec jekyll serve -H 0.0.0.0 -P 80 --detach --watch