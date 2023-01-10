FROM jelaniwoods/appdev2023-helper-methods

WORKDIR /base-rails
COPY Gemfile /base-rails/Gemfile
COPY Gemfile.lock /base-rails/Gemfile.lock
# For some reason, the copied files were owned by root so bundle could not succeed
RUN /bin/bash -l -c "sudo chown -R $(whoami):$(whoami) Gemfile Gemfile.lock"
RUN /bin/bash -l -c "bundle config set --local path 'gems'"
RUN /bin/bash -l -c "gem install bundler:2.2.32"

RUN /bin/bash -l -c "bundle install"
# Disable skylight dev warning
RUN /bin/bash -l -c "bundle exec skylight disable_dev_warning"

# Install Node and npm
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
    && sudo apt-get update \
    && sudo apt-get install -y yarn \
    && sudo npm install -g n \
    && sudo n stable \
    && hash -r

# Install fuser
RUN sudo apt install -y libpq-dev psmisc lsof

# Install JS dependencies
COPY package.json /base-rails/package.json
COPY yarn.lock /base-rails/yarn.lock
# For some reason, the copied files were owned by root so bundle could not succeed
RUN /bin/bash -l -c "sudo chown -R $(whoami):$(whoami) yarn.lock package.json"
RUN /bin/bash -l -c "yarn"

# Install parity gem
RUN wget -qO - https://apt.thoughtbot.com/thoughtbot.gpg.key | sudo apt-key add - \
    && echo "deb http://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list \
    && sudo apt-get update \
    && sudo apt-get -y install parity

# Install heroku-cli
RUN /bin/bash -l -c "curl https://cli-assets.heroku.com/install.sh | sh"

# Git global configuration
RUN git config --global push.default upstream \
    && git config --global merge.ff only \
    && git config --global alias.acm '!f(){ git add -A && git commit -am "${*}"; };f' \
    && git config --global alias.as '!git add -A && git stash' \
    && git config --global alias.p 'push' \
    && git config --global alias.sla 'log --oneline --decorate --graph --all' \
    && git config --global alias.co 'checkout' \
    && git config --global alias.cob 'checkout -b'

# Alias 'git' to 'g'
RUN echo 'export PATH="$PATH:$GITPOD_REPO_ROOT/bin"' >> ~/.bashrc
RUN echo "# No arguments: 'git status'\n\
# With arguments: acts like 'git'\n\
g() {\n\
  if [[ \$# > 0 ]]; then\n\
    git \$@\n\
  else\n\
    git status\n\
  fi\n\
}\n# Complete g like git\n\
source /usr/share/bash-completion/completions/git\n\
__git_complete g __git_main" >> ~/.bash_aliases

# Add current git branch to bash prompt
RUN echo "# Add current git branch to prompt\n\
parse_git_branch() {\n\
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \\\(.*\\\)/:(\\\1)/'\n\
}\n\
\n\
PS1='\[]0;\u \w\]\[[01;32m\]\u\[[00m\] \[[01;34m\]\w\[[00m\]\[\e[0;38;5;197m\]\$(parse_git_branch)\[\e[0m\] \\\$ '" >> ~/.bashrc

# Hack to pre-install bundled gems
RUN echo "rvm use 3.0.3" >> ~/.bashrc
RUN echo "rvm_silence_path_mismatch_check_flag=1" >> ~/.rvmrc
