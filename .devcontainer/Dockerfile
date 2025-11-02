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
    && rm -rf /var/cache/apk/*

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME -s /bin/zsh $USERNAME \
    && mkdir -p /home/$USERNAME/.bundle \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up gem and bundler cache directories
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=/home/$USERNAME/.bundle
ENV PATH=$GEM_HOME/bin:$PATH

# Create and set permissions for bundle cache
RUN mkdir -p $GEM_HOME && chown -R $USERNAME:$USERNAME $GEM_HOME

# Switch to non-root user
USER $USERNAME

# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Configure zsh plugins
RUN sed -i 's/plugins=(git)/plugins=(git ruby bundler zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc \
    && echo 'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Install bundler and ruby-lsp globally
RUN gem install bundler ruby-lsp

# Keep container running
CMD ["sleep", "infinity"]
