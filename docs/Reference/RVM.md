# Using RVM

1. Install RVM
2. Add the snipped to `~/.bash_aliases`. The RVM install script may report a
   different path--use that one.
   ```
   if [[ -f $HOME/.rvm/scripts/rvm ]]; then
       source $HOME/.rvm/scripts/rvm
   fi
   ```
2. `rvm install 3.0.0`, or any other ruby version
3. `rvm --default use 3.0.0`, or the installed version
4. Check the output of `which gem`. It should point to the installed one.
5. `gem install bundler`
6. `bundle install` to install the gems needed for a project
7. `bundle exec jekyll serve`
