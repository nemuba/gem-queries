# Use Ruby Alpine for minimal image size
FROM ruby:3.4.1-alpine3.21

# Install only essential dependencies for Rails and SQLite
RUN apk add --no-cache \
    build-base \
    git \
    sqlite-dev \
    sqlite \
    tzdata \
    bash \
    zsh \
    zsh-vcs \
    less \
    curl \
    sudo \
    openssh-client \
    && rm -rf /var/cache/apk/* \
    && ZSH_PATH=$(which zsh) \
    && if [ -n "$ZSH_PATH" ] && [ -f "$ZSH_PATH" ]; then \
         if [ "$ZSH_PATH" != "/bin/zsh" ] && [ ! -f /bin/zsh ]; then \
           ln -sf "$ZSH_PATH" /bin/zsh; \
         fi; \
       fi \
    && test -f /bin/zsh || (echo "Error: zsh not found. Expected at /bin/zsh. Found at: $ZSH_PATH" && exit 1)

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME -s /bin/zsh $USERNAME \
    && mkdir -p /home/$USERNAME/.bundle \
    && mkdir -p /home/$USERNAME/.ssh \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up gem and bundler cache directories
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=/home/$USERNAME/.bundle
ENV PATH=$GEM_HOME/bin:$PATH
ENV SHELL=/bin/zsh

# Create and set permissions for bundle cache
RUN mkdir -p $GEM_HOME && chown -R $USERNAME:$USERNAME $GEM_HOME

# Copy SSH setup script (before switching user)
COPY setup-ssh.sh /usr/local/bin/setup-ssh.sh
RUN chmod +x /usr/local/bin/setup-ssh.sh && chown $USERNAME:$USERNAME /usr/local/bin/setup-ssh.sh

# Switch to non-root user
USER $USERNAME

# Install Oh My Zsh and plugins with shallow clones, then clean up
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone --depth 1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions \
    && rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/*/.git \
    && rm -rf ~/.oh-my-zsh/.git \
    && rm -rf /tmp/* \
    && rm -rf ~/.cache

# Configure zsh plugins
RUN sed -i 's/plugins=(git)/plugins=(git ruby bundler zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc \
    && echo 'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Install bundler and ruby-lsp globally, then clean gem cache
RUN gem install bundler ruby-lsp \
    && gem cleanup \
    && rm -rf /tmp/* \
    && rm -rf ~/.gem/cache

# Keep container running
CMD ["sleep", "infinity"]
