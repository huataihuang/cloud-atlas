cd ~/.vim_runtime
git reset --hard
git clean -d --force
git pull --rebase
python update_plugins.py  # use python3 if python is unavailable
