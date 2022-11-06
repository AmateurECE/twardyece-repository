---
title: Git
---

# Sort Branches by Most Recently Updated

Replace `refs/heads/` with `refs/remotes/` to see remote branches.

```bash-session
$ git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
```
