---
title: Git
---

# Remove some files from all commits

WARNING: This command will rewrite history, and it will automatically push
updates to the remote. This tool is probably not already installed on your
system. On Arch Linux, the package is called `git-filter-repo`.

```bash-session
git filter-repo --invert-paths --path filename
```

# Rebase onto root commit

Use the `--root` option to Git to allow rebasing onto the root commit.

```bash-session
$ git rebase --root
```

The `-i` flag will do this interactively, of course. If there is not currently
an upstream branch, this flag takes the branch name as a parameter.

```bash-session
$ git rebase -i trunk --root
```

# Sort Branches by Most Recently Updated

Replace `refs/heads/` with `refs/remotes/` to see remote branches.

```bash-session
$ git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
```

# Advanced Stash Operations

Show the contents of the stash using `git stash show [-p]`. There are also aliases
for the stash refs in the local checkout, which allows use of `git-diff` to inspect
the stash:

```
# View changes to `a.file` in the topmost stash entry
git diff stash@{0}^1 stash@{0} -- a.file
```
