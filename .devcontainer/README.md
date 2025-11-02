# Dev Container Configuration

Este projeto inclui uma configuração completa de Dev Container para desenvolvimento no VS Code.

## Requisitos

- [Docker](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Como Usar

1. **Abrir o Projeto no Dev Container**
   - Abra o projeto no VS Code
   - Pressione `F1` ou `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (Mac)
   - Digite: `Dev Containers: Reopen in Container`
   - Aguarde o build do container (primeira vez demora mais)

2. **Desenvolvimento**
   - O container instala automaticamente as gems com `bundle install`
   - Todas as dependências (Ruby, SQLite, etc.) já estão configuradas
   - O cache de gems é persistente entre builds

3. **Comandos Disponíveis**
   ```bash
   # Instalar dependências
   bundle install
   
   # Rodar testes
   bundle exec rspec
   
   # Rodar linter
   bin/rubocop
   
   # Migrar banco de dados (ambiente de teste)
   cd spec/dummy && RAILS_ENV=test bin/rails db:migrate
   
   # Migrar banco de dados (ambiente de desenvolvimento)
   cd spec/dummy && bin/rails db:migrate
   
   # Iniciar servidor Rails (dummy app)
   cd spec/dummy && bin/rails server
   ```

## Características

- **Base Alpine**: Imagem leve (~100MB base vs ~1GB+ Debian)
- **Ruby 3.4.1**: Versão utilizada no CI
- **SQLite**: Pré-instalado e configurado
- **Zsh + Oh My Zsh**: Shell padrão com plugins (autosuggestions, syntax-highlighting, completions)
- **Ruby LSP**: Instalado globalmente com configurações completas
- **Usuário não-root**: Segurança com usuário `vscode`
- **Cache de Gems**: Volume persistente para builds rápidos
- **Extensões VS Code**: Ruby LSP, RuboCop, Solargraph pré-instalados
- **Auto-formatação**: Código formatado automaticamente ao salvar com RuboCop

## Estrutura

```
.devcontainer/
├── Dockerfile          # Imagem Docker otimizada
└── devcontainer.json   # Configuração do VS Code
.dockerignore           # Arquivos excluídos do build
```

## Otimizações

1. **Imagem Alpine**: Reduz tamanho da imagem significativamente
2. **Cache de Gems**: Volume Docker para persistir gems entre rebuilds
3. **Build mínimo**: Apenas dependências essenciais instaladas
4. **Layer caching**: Estrutura otimizada para cache do Docker

## Troubleshooting

### Container não inicia
- Verifique se o Docker está rodando
- Verifique logs: `Docker Desktop > Containers > queries-rails-engine`

### Gems não instalam
- Rebuild container: `Dev Containers: Rebuild Container`
- Limpar cache: `docker volume rm gem-cache`

### Performance lenta
- No Mac/Windows, a configuração já usa `consistency=cached` para melhor performance
- Considere alocar mais recursos ao Docker Desktop (Settings > Resources)
