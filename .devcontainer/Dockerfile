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
    less \
    curl \
    && rm -rf /var/cache/apk/*

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME -s /bin/bash $USERNAME \
    && mkdir -p /home/$USERNAME/.bundle \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set up gem and bundler cache directories
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=/home/$USERNAME/.bundle
ENV PATH=$GEM_HOME/bin:$PATH

# Create and set permissions for bundle cache
RUN mkdir -p $GEM_HOME && chown -R $USERNAME:$USERNAME $GEM_HOME

# Switch to non-root user
USER $USERNAME

# Set working directory
WORKDIR /workspace

# Install bundler
RUN gem install bundler

# Keep container running
CMD ["sleep", "infinity"]
