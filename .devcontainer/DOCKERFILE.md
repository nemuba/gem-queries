# Documentação do Dockerfile

Este documento explica detalhadamente cada seção do Dockerfile usado no devcontainer deste projeto, descrevendo o propósito e a necessidade de cada comando.

## 📋 Visão Geral

O Dockerfile cria um ambiente de desenvolvimento Ruby on Rails otimizado usando Alpine Linux, que resulta em uma imagem Docker leve (~350-450MB) e eficiente para desenvolvimento de gems Rails.

---

## 🏗️ Estrutura do Dockerfile

### 1. Imagem Base

```dockerfile
FROM ruby:3.4.1-alpine3.21
```

**Por quê?**
- Usa a imagem oficial Ruby com a versão específica do projeto (3.4.1)
- Alpine Linux reduz drasticamente o tamanho da imagem (base ~100MB vs ~1GB+ do Debian/Ubuntu)
- Mantém consistência com a versão Ruby usada no CI/CD
- Alpine é seguro e otimizado para containers

**Necessidade do projeto:**
- Garante que o ambiente de desenvolvimento use exatamente a mesma versão do Ruby do ambiente de produção/CI

---

### 2. Instalação de Dependências do Sistema

```dockerfile
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
```

#### Pacotes Instalados:

**`build-base`**
- **Por quê?** Contém ferramentas de compilação (gcc, make, etc.) necessárias para compilar gems nativas escritas em C
- **Necessidade:** Gems como `sqlite3`, `pg`, `nokogiri` precisam compilar código C

**`git`**
- **Por quê?** Necessário para clonar repositórios Git (usado pelo Oh My Zsh e plugins)
- **Necessidade:** Instalação de plugins do zsh via Git e controle de versão do código

**`sqlite-dev` e `sqlite`**
- **Por quê?** Headers e bibliotecas de desenvolvimento do SQLite
- **Necessidade:** A gem `sqlite3` precisa compilar bindings nativos que dependem dessas bibliotecas

**`tzdata`**
- **Por quê?** Dados de timezone para tratamento correto de datas
- **Necessidade:** Rails precisa de timezone data para operações de data/hora corretas

**`bash`**
- **Por quê?** Shell bash padrão (necessário para alguns scripts)
- **Necessidade:** Alguns scripts e comandos Rails podem depender do bash

**`zsh` e `zsh-vcs`**
- **Por quê?** Shell zsh com suporte a controle de versão para Git integration
- **Necessidade:** Shell preferido do desenvolvedor com recursos avançados e integração Git

**`less`**
- **Por quê?** Pager para visualização de saídas longas
- **Necessidade:** Git e outros comandos usam `less` para paginação

**`curl`**
- **Por quê?** Ferramenta para fazer requisições HTTP
- **Necessidade:** Instalação do Oh My Zsh via script de download

**`sudo`**
- **Por quê?** Permite execução de comandos como root com privilégios elevados
- **Necessidade:** Usuário não-root precisa de sudo para algumas operações de configuração

**`openssh-client`**
- **Por quê?** Cliente SSH para conexões Git remotos
- **Necessidade:** Push/pull do Git via SSH requer cliente SSH instalado

#### Limpeza e Validação:
- **`rm -rf /var/cache/apk/*`**: Remove cache do gerenciador de pacotes para reduzir tamanho da imagem
- **Validação do zsh**: Garante que o zsh está disponível em `/bin/zsh` (criando link simbólico se necessário)

---

### 3. Criação do Usuário Não-Root

```dockerfile
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
```

**Por quê criar usuário não-root?**
- **Segurança**: Evita execução de processos como root, reduzindo risco de comprometimento
- **Boas práticas**: Containers devem rodar com privilégios mínimos
- **Compatibilidade**: VS Code espera trabalhar com usuário não-root

**Detalhes:**
- **`ARG USERNAME=vscode`**: Define o nome do usuário (padrão do VS Code)
- **`ARG USER_UID=1000`**: Define UID/GID padrão (geralmente o primeiro usuário do sistema)
- **`addgroup` e `adduser`**: Cria grupo e usuário no Alpine Linux
- **`-s /bin/zsh`**: Define zsh como shell padrão do usuário
- **`.bundle` e `.ssh`**: Cria diretórios necessários com permissões corretas
- **`sudo sem senha`**: Permite usar sudo sem senha (necessário para configurações do devcontainer)

**Necessidade do projeto:**
- VS Code funciona melhor com usuário não-root
- Gems instaladas precisam de diretório `.bundle` configurado
- SSH precisa de diretório `.ssh` com permissões adequadas

---

### 4. Variáveis de Ambiente

```dockerfile
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=/home/$USERNAME/.bundle
ENV PATH=$GEM_HOME/bin:$PATH
ENV SHELL=/bin/zsh
```

**Por quê?**
- **`GEM_HOME` e `BUNDLE_PATH`**: Define onde as gems serão instaladas globalmente
- **`BUNDLE_APP_CONFIG`**: Configurações do Bundler por aplicação
- **`PATH`**: Adiciona binários das gems ao PATH (permite executar comandos como `rubocop`, `rspec` diretamente)
- **`SHELL`**: Define shell padrão (usado por vários processos, incluindo ruby-lsp)

**Necessidade do projeto:**
- Gems instaladas globalmente ficam em localização persistente (volume Docker)
- Comandos de gems devem estar disponíveis no PATH
- Ruby LSP precisa saber qual shell usar

---

### 5. Configuração de Permissões

```dockerfile
RUN mkdir -p $GEM_HOME && chown -R $USERNAME:$USERNAME $GEM_HOME
```

**Por quê?**
- Garante que o diretório de gems existe
- Define propriedade correta para o usuário `vscode`
- Necessário para evitar erros de permissão ao instalar gems

**Necessidade do projeto:**
- Volume Docker montado pode não ter permissões corretas
- Bundler precisa escrever em `$GEM_HOME`

---

### 6. Mudança para Usuário Não-Root

```dockerfile
USER $USERNAME
```

**Por quê?**
- Todos os comandos seguintes serão executados como `vscode` (não root)
- Importante para segurança e para que arquivos criados tenham propriedade correta

**Necessidade do projeto:**
- Evita criar arquivos como root que o usuário não consegue modificar
- Segurança: menor superfície de ataque

---

### 7. Instalação do Oh My Zsh e Plugins

```dockerfile
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git clone --depth 1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions \
    && rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/*/.git \
    && rm -rf ~/.oh-my-zsh/.git \
    && rm -rf /tmp/* \
    && rm -rf ~/.cache
```

**Por quê instalar Oh My Zsh?**
- Melhora significativamente a experiência de desenvolvimento
- Autocompletar, syntax highlighting e sugestões tornam o desenvolvimento mais eficiente

**Plugins instalados:**

**`zsh-autosuggestions`**
- Mostra sugestões baseadas no histórico de comandos
- **Necessidade:** Acelera desenvolvimento ao reutilizar comandos anteriores

**`zsh-syntax-highlighting`**
- Destaca sintaxe de comandos enquanto você digita
- **Necessidade:** Ajuda a detectar erros antes de executar comandos

**`zsh-completions`**
- Melhora autocompletar para diversos comandos
- **Necessidade:** Facilita uso de comandos do Git, Rails, etc.

**Otimizações:**
- **`--depth 1`**: Clona apenas o último commit (reduz tamanho em ~80-90%)
- **Remoção de `.git`**: Remove histórico Git dos plugins após instalação
- **Limpeza de cache**: Remove arquivos temporários e cache

**Necessidade do projeto:**
- Melhora produtividade do desenvolvedor
- Reduz tamanho da imagem final

---

### 8. Configuração dos Plugins Zsh

```dockerfile
RUN sed -i 's/plugins=(git)/plugins=(git ruby bundler zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc \
    && echo 'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' >> ~/.zshrc
```

**Por quê?**
- Ativa os plugins instalados no `.zshrc`
- Adiciona `fpath` para que o zsh encontre as completions

**Plugins configurados:**
- **`git`**: Integração Git (status, branch, etc.)
- **`ruby`**: Autocompletar e shortcuts para Ruby
- **`bundler`**: Completions para comandos do Bundler
- **`zsh-autosuggestions`**: Sugestões de comandos
- **`zsh-syntax-highlighting`**: Destaque de sintaxe
- **`zsh-completions`**: Completions adicionais

**Necessidade do projeto:**
- Otimiza fluxo de trabalho com Ruby/Rails
- Melhora experiência com Git e Bundler

---

### 9. Script de Setup SSH

```dockerfile
COPY setup-ssh.sh /usr/local/bin/setup-ssh.sh
RUN chmod +x /usr/local/bin/setup-ssh.sh && chown $USERNAME:$USERNAME /usr/local/bin/setup-ssh.sh
```

**Por quê?**
- Copia script que configura chaves SSH do host para o container
- Permite usar Git via SSH (push/pull) dentro do container

**Necessidade do projeto:**
- Desenvolvedores precisam fazer push de código
- Git remoto geralmente usa SSH
- Evita configuração manual a cada rebuild

---

### 10. Diretório de Trabalho

```dockerfile
WORKDIR /workspace
```

**Por quê?**
- Define diretório padrão onde comandos serão executados
- `/workspace` é o diretório montado pelo devcontainer (código do projeto)

**Necessidade do projeto:**
- Garante que comandos executem no contexto correto do projeto
- Código do projeto fica em `/workspace`

---

### 11. Instalação de Gems Globais

```dockerfile
RUN gem install bundler ruby-lsp \
    && gem cleanup \
    && rm -rf /tmp/* \
    && rm -rf ~/.gem/cache
```

**Por quê instalar gems globalmente?**

**`bundler`**
- **Por quê?** Gerencia dependências do projeto Ruby
- **Necessidade:** Projeto usa Bundler para gerenciar gems do `Gemfile`

**`ruby-lsp`**
- **Por quê?** Servidor de linguagem para Ruby (autocomplete, go-to-definition, etc.)
- **Necessidade:** VS Code usa ruby-lsp para IntelliSense e análise de código

**Otimizações:**
- **`gem cleanup`**: Remove versões antigas de gems para economizar espaço
- **Limpeza de cache**: Remove cache temporário de gems

**Necessidade do projeto:**
- Bundler é essencial para instalar gems do projeto
- Ruby LSP melhora experiência de desenvolvimento no VS Code
- Otimizações reduzem tamanho da imagem final

---

### 12. Comando Padrão

```dockerfile
CMD ["sleep", "infinity"]
```

**Por quê?**
- Mantém o container rodando indefinidamente
- Necessário porque devcontainers precisam de um processo ativo

**Necessidade do projeto:**
- VS Code precisa de um container ativo para conectar
- `sleep infinity` é leve e eficiente para manter container vivo

---

## 📊 Resumo das Decisões de Design

### Por que Alpine Linux?
- ✅ Imagem muito menor (~100MB base vs ~1GB+)
- ✅ Mais rápido para baixar e construir
- ✅ Menos vulnerabilidades (menos pacotes)
- ✅ Suficiente para desenvolvimento Rails

### Por que Usuário Não-Root?
- ✅ Segurança (princípio do menor privilégio)
- ✅ Compatibilidade com VS Code
- ✅ Evita problemas de permissão

### Por que Oh My Zsh?
- ✅ Melhora significativamente produtividade
- ✅ Integração nativa com Git
- ✅ Plugins úteis para desenvolvimento Ruby

### Por que Gems Globais?
- ✅ Bundler e ruby-lsp disponíveis imediatamente
- ✅ Não precisa instalar toda vez que entra no container
- ✅ Cache persistente reduz tempo de rebuild

---

## 🔧 Comandos Úteis para Entender o Dockerfile

### Ver tamanho da imagem:
```bash
docker images | grep queries
```

### Entrar no container durante build (debug):
```dockerfile
# Adicionar temporariamente no Dockerfile:
RUN sleep 300  # Container fica vivo por 5 minutos para inspeção
```

### Verificar layers da imagem:
```bash
docker history <image-name>
```

### Testar build localmente:
```bash
cd .devcontainer
docker build -t queries-dev .
```

---

## 🚀 Próximos Passos

Após entender esta documentação, você pode:

1. **Personalizar plugins do zsh** conforme suas preferências
2. **Adicionar mais gems globais** se necessário
3. **Otimizar ainda mais** removendo pacotes não utilizados
4. **Entender o processo de build** completo do devcontainer

---

## 📚 Referências

- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Ruby LSP](https://shopify.github.io/ruby-lsp/)
- [Bundler Documentation](https://bundler.io/)

