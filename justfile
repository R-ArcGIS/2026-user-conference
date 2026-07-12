default:
  just --list

update:
  git add . && git commit -m "updates" && git push