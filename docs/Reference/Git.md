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

# Move Some Files to Another Repo, Preserving History

```bash-session
# Clone the repository we're moving files from:
git clone https://github.com/AmateurECE/myproject.git

# Remove the remote, to prevent accidentally pushing these changes:
cd myproject && git remote rm origin

# Use git filter-repo to rewrite git history, keeping only the commits
# that touch the desired files. Note that renames are NOT followed,
# so if we want to keep commits that were made on files before any
# renames occurred, we need to specify the old paths as well
# (e.g. --path olddir --path newdir). We can use git filter-repo --analyze
# and then observing .git/filter-repo/analysis/renames.txt to determine if
# we need to do this.
#
# Additionally, we will likely need to use --force because we removed the
# origin remote, which makes this look like a clone with history.
#
# If the files are not organized in the way that is required for the
# destination repository, we can use --path-rename here to rewrite these
# commits as if they were always at the right location.
git filter-repo --force --path olddir --path newdir --path CMakeLists.txt \
    --path-rename CMakeLists.txt:fsadaptor/CMakeLists.txt

# Remove a bunch of history and data from dead commits:
git reset --hard
git gc --aggressive
git prune
git clean -fd

# Now working in the destination repository.
cd ~/newproject

# Add the myproject checkout as a remote
git remote add myproject ~/myproject

# Merge the commits from myproject/remote-branch into the current branch of
# newproject. Note that this will not perform a fast-forward on the current
# branch. It will create a merge commit that merges all commits from myproject
# into the current branch. This is extremely useful because it prevents
# creating broken commits on the current branch if some of the intermediate
# commits in myproject would introduce build problems in the current branch.
# Observe this using git log --graph after the merge!
git merge myproject remote-branch --allow-unrelated-histories

# Remove the remote
git remote rm myproject
```

Sometimes, while attempting the merge, `git` will report:

```
$ git merge myproject remote-branch --allow-unrelated-histories
myproject: not something we can merge
```

This may happen, for example, if a path filter is not used, so some of the
content appears to be identical, and the rest of the content is renamed
(as an example).

To get around this, we can create a local branch from the remote:

```bash-session
$ git fetch myproject
$ git checkout -b merge-playground myproject/remote-branch
$ git switch main
$ git merge merge-playground
```

In these scenarios, we may be dealing with rename/rename conflicts. Playing
around with different combinations of `git add` should produce the desired
behavior.

```bash-session
$ git add new-name-1 new-name-2
$ git rm old-name
$ git checkout
etc...
```

# Stash Operations

Show the contents of the stash using `git stash show [-p]`. There are also
aliases for the stash refs in the local checkout, which allows use of
`git-diff` to inspect the stash:

```
# View changes to `a.file` in the topmost stash entry
git diff stash@{0}^1 stash@{0} -- a.file
```

Running `git stash show` without `-p` will show the diff in "short form"--that
is, only the paths of the files that have changed, and not the content.
Finally, running `git stash list` will show the entries in the stash.

Sometimes, popping an entry from the stash will result in merge conflicts. To
recover from this, one easy way is to run `git reset --merge`. NOTE, however,
that this will return the index and the working tree to a completely clean
state--any staged or unstaged changes that were present before running
`git stash pop` will be lost.

As a general rule, use `git stash push` instead of `git stash save`. The
`push` subcommand can take arguments similar to `git diff`, which allows to
push, for example, only some files.

# Deleting Remote Objects

```bash-session
# Deleting branches
git push -u remote --delete branch-name
```

# Applying Patches

For patches generated from the git repository to which they are being applied,
the easiest mechanism is `git-am(1)`. Simply:

```bash-session
$ git am my-awesome-patch.patch
```

For more complicated use cases, `git-apply(1)` is the tool. Use this tool when
some hunks will not apply cleanly, patches need to be applied to files in
different directories, or the patch file does not contain a change that forms
an entire commit. For example, the following would apply a patch written for
`./Foo/a.cpp` to `./Bar/a.cpp`:

```bash-session
$ git apply \
    --rej # In case some hunks don't apply
    -v    # Be verbose, let us know if you're skipping hunks
    --directory=Bar # change to the "Bar" directory before applying
    -p2 # Strip not only the prefix ("a" or "b"), but also the first path
        # element ("Foo", in this case.)
    my-awesome-patch.patch
```

# Preparing patches to submit to a mailing list

Some flags to `git-format-patch` which may be important to remember:

* `--reroll-count,-v`: Specify the version of the patch (e.g. v2)
* `--no-stat,-p`: Generates plain patches without any diffstat. This makes it
  easier for the kernel folks to read the patch.
* `--base=auto`: Automatically compute the base commit and add its object name
  as a tag in the patch.
* `--cover-letter`: Create a cover letter patch to provide "frontmatter" for
  the email.

After generating the patches, the cover letter template generated by
`git-format-patch` needs to be filled in manually. Then, check the patches
using `scripts/checkpatch.pl`.

Some flags to `git-send-email` which may be important to remember:

* `--to-cmd`: Provide a command to obtain the addresses that should fill the
  `To:` field of the email. This is super useful for the kernel submission work
  flow. An example: `--to-cmd="scripts/get_maintainer.pl my.patch"`

# Tags

Sometimes, git doesn't fetch tags when `git pull` is run. Ensure that you're
fetching the correct remote by running `git fetch <remote>`. This helps in
multi-remote scenarios, such as Linux kernel development. If this still
doesn't work, try `git fetch --tags <remote>`.

# Cloning with Submodules

```bash-session
$ git clone --recurse-submodules <repo>
```
