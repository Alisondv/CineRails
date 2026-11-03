# 🎬 CineRails

Catálogo de filmes com visual de streaming, feito em **Ruby on Rails 8** para uma apresentação
didática sobre como o Rails funciona: **MVC, rotas, Active Record, migrations, views/partials,
Hotwire (Turbo + Stimulus) e consumo de API externa**.

Os filmes, pôsteres e trailers vêm da API do [TMDB](https://www.themoviedb.org). O app guarda
no banco local apenas os dados do usuário: perfis, **Minha Lista** e **avaliações**.

| Tela | O que mostra |
|---|---|
| Entrar / Criar conta | Login e cadastro com e-mail e senha (`has_secure_password`, gem bcrypt) |
| Quem está assistindo? | Perfis da conta logada + botão para adicionar um novo |
| Início | Banner "hero" + fileiras: Em alta, Populares, Mais bem avaliados, Ação, Comédia, Ficção científica |
| Filme | Backdrop, pôster, ano, duração, gêneros, nota TMDB, sinopse, trailer do YouTube e avaliações |
| Minha Lista | Grade com os filmes salvos pelo perfil atual |
| Busca | Resultados da busca do TMDB em grade |

Fluxo de acesso, no modelo da Netflix: **Entrar/Criar conta → Quem está assistindo? → catálogo**.
Cada conta só vê os próprios perfis.

Adicionar/remover da lista e enviar uma avaliação **não recarregam a página** (Turbo Streams).

---

## 1. Pré-requisitos

- **Ruby 3.4.x** (o arquivo `.ruby-version` indica a versão; 3.4.11 ou 3.4.12 funcionam igual)
- SQLite 3
- Uma conta grátis no TMDB
- Git

O projeto roda igual nas duas plataformas, mas a forma de **instalar o Ruby** e de **chamar os
comandos do Rails** muda. O resto do guia (a partir da seção 2) é o mesmo para as duas.

### Windows

1. Instale o **Ruby+Devkit 3.4** pelo [RubyInstaller](https://rubyinstaller.org/downloads/)
   (marque a opção de instalar o MSYS2/Devkit quando o instalador perguntar — é ele que compila
   gems com extensão nativa, como a `bcrypt` usada no login).
2. Confira no PowerShell: `ruby -v` deve mostrar 3.4.x, e `gem -v` deve funcionar.
3. **Importante:** neste projeto, no Windows, chame o Rails sempre como `ruby bin/rails ...`
   (nunca só `bin/rails ...` nem `rails ...`). O motivo: o binstub `bin/rails` depende de um
   shebang Unix que o Windows não interpreta sozinho; `ruby bin/rails` contorna isso rodando o
   script explicitamente pelo interpretador. Por essa mesma razão, `bin/dev` (que usa `foreman`,
   dependente de `fork()`) **não funciona** no Windows — use `ruby bin/setup` e, se quiser o CSS
   recompilando ao vivo, `ruby bin/rails tailwindcss:watch` num segundo terminal (seção 3).

### macOS

1. O Ruby do sistema é antigo demais para o Rails 8. Instale o 3.4.x com
   [rbenv](https://github.com/rbenv/rbenv), [asdf](https://asdf-vm.com) ou compilando com
   `ruby-build` (ex.: `ruby-build 3.4.12 ~/.rubies/ruby-3.4.12`, adicionando
   `export PATH="$HOME/.rubies/ruby-3.4.12/bin:$PATH"` ao `~/.zshrc`).
2. Confira: `ruby -v` deve mostrar 3.4.x, e `rails -v` deve mostrar 8.1.4.
3. Os comandos do Rails rodam normalmente como `bin/rails ...` e `bin/dev` funciona (sobe o
   servidor e o watcher do Tailwind juntos, via `Procfile.dev`).

## 2. Configurar o token do TMDB

1. Crie uma conta em <https://www.themoviedb.org/signup>.
2. Em **Configurações › API** (<https://www.themoviedb.org/settings/api>), copie o
   **API Read Access Token**. É o token longo; a "API Key" curta não serve.
3. Escolha **uma** das formas abaixo. O token **nunca** vai para o código.

**Opção A: variável de ambiente** (mais simples — vale só para o terminal aberto)

```powershell
# Windows (PowerShell)
$env:TMDB_TOKEN = "eyJhbGciOi..."
```

```sh
# macOS (zsh/bash)
export TMDB_TOKEN="eyJhbGciOi..."
```

**Opção B: credentials criptografadas do Rails**

```sh
# Windows
EDITOR="notepad" ruby bin/rails credentials:edit

# macOS
EDITOR="code --wait" bin/rails credentials:edit
```

Adicione:

```yaml
tmdb:
  token: eyJhbGciOi...
```

O arquivo `config/credentials.yml.enc` é criptografado com `config/master.key`, que está no
`.gitignore` e **não deve ser commitado**.

O `TmdbClient` procura primeiro em `ENV["TMDB_TOKEN"]` e depois nas credentials. Sem token, o app
abre normalmente e mostra uma tela explicando esses passos.

## 3. Rodar

```powershell
# Windows
ruby bin/setup   # instala as gems, cria o banco, roda migrations + seeds, compila o CSS e já sobe o servidor
```

```sh
# macOS
bin/setup   # instala as gems, cria o banco, roda migrations + seeds e já sobe o servidor
# nas próximas vezes:
bin/dev     # sobe o Rails (porta 3000) e o watcher do Tailwind (Procfile.dev)
```

No Windows, `bin/dev` não funciona (explicado na seção 1), então nas próximas vezes suba o
servidor e o watcher do Tailwind **em dois terminais**:

```powershell
# terminal 1
ruby bin/rails server

# terminal 2 (recompila o CSS ao vivo enquanto você edita as views)
ruby bin/rails tailwindcss:watch
```

Acesse <http://localhost:3000>. O seed cria uma **conta de demonstração** pronta para a
apresentação, já com um perfil:

```
E-mail: demo@cinerails.test
Senha:  cinerails123
```

Testes dos models:

```powershell
ruby bin/rails test   # Windows
```

```sh
bin/rails test        # macOS
```

Outros comandos úteis na apresentação (Windows: prefixe tudo com `ruby`, ex. `ruby bin/rails routes`):

```sh
bin/rails routes     # tabela de rotas
bin/rails console    # brincar com os models: User.first.profiles, Profile.first.movies
bin/rails db:seed    # recria a conta de demonstração
```

---

## 4. Como uma requisição percorre o Rails

```
 Navegador
    │  GET /movies/603
    ▼
┌──────────────────┐   config/routes.rb
│      ROTA        │   resources :movies, only: [:show]
└────────┬─────────┘   => MoviesController#show, params[:id] = "603"
         ▼
┌──────────────────┐   app/controllers/movies_controller.rb
│   CONTROLLER     │   before_action :require_login, :require_profile (conta e perfil na sessão?)
└──┬────────────┬──┘
   │            │
   ▼            ▼
┌──────────┐ ┌─────────────────┐
│ SERVICE  │ │     MODEL       │  app/models/*.rb (Active Record)
│TmdbClient│ │ Movie, Review...│  SELECT ... FROM reviews (SQLite)
└────┬─────┘ └─────────────────┘
     │ Rails.cache? ── sim ──► devolve sem chamar a API
     │      └─ não ──► HTTP GET api.themoviedb.org (Faraday) e guarda no cache por 6h
     ▼
┌──────────────────┐   app/views/movies/show.html.erb
│      VIEW        │   + partials (_list_button, _rating_stars, reviews/_form...)
└────────┬─────────┘   dentro de layouts/application.html.erb
         ▼
     HTML para o navegador
```

**Com Turbo** (ex.: clicar em "+ Minha Lista"):

```
<form> (button_to) ──Turbo intercepta──► POST /movies/603/list_item  (Accept: turbo-stream)
   ListItemsController#create ─► Movie.from_tmdb + ListItem salvo
   ◄── create.turbo_stream.erb: <turbo-stream action="replace" target="list_button_603">
Turbo troca SÓ o elemento #list_button_603. A página não recarrega.
```

## 5. Modelo de dados

```
User ─< Profile ─┬─< ListItem >─┬─ Movie
                  │              │
                  └─<  Review   >┘

User has_many :profiles, dependent: :destroy     Profile belongs_to :user
Profile has_many :list_items                     Movie has_many :list_items
Profile has_many :movies, through: :list_items   (Minha Lista)
Profile has_many :reviews                        Movie has_many :reviews
ListItem / Review belongs_to :profile, belongs_to :movie
```

| Model | Campos | Validações |
|---|---|---|
| `User` | email, password_digest | e-mail obrigatório/único/formato válido, senha ≥ 6 caracteres (`has_secure_password`) |
| `Profile` | name, color, user_id | nome obrigatório (até 20), cor da paleta, pertence a uma conta |
| `Movie` | tmdb_id (único), title, poster_path, backdrop_path, release_date, overview | tmdb_id único, título obrigatório |
| `ListItem` | profile_id, movie_id | filme único por perfil (+ índice único no banco) |
| `Review` | profile_id, movie_id, rating, comment | nota inteira de 1 a 5, comentário ≤ 500, uma por perfil/filme |

O `Movie` é um **cache local mínimo**: só é salvo quando entra numa lista ou recebe avaliação
(`Movie.from_tmdb`).

A senha nunca é guardada em texto puro: `password_digest` armazena só o hash gerado pela gem
`bcrypt`. Perfis só existem dentro de uma conta — tanto a tela "Quem está assistindo?" quanto a
troca de perfil usam `current_user.profiles.find(...)`, nunca `Profile.find(...)` sozinho, para
que a conta A nunca consiga acessar um perfil da conta B.

## 6. Estrutura de pastas (o que importa)

```
app/
├── controllers/
│   ├── application_controller.rb  # before_action require_login/require_profile, current_user/current_profile, rescue_from do TMDB
│   ├── registrations_controller.rb # cadastro de conta (new/create)
│   ├── user_sessions_controller.rb # login/logout da conta (new/create/destroy)
│   ├── profiles_controller.rb     # "Quem está assistindo?" + adicionar perfil
│   ├── sessions_controller.rb     # escolhe/troca perfil (sessão), restrito a current_user.profiles
│   ├── home_controller.rb         # hero + fileiras
│   ├── movies_controller.rb       # página do filme
│   ├── list_items_controller.rb   # Minha Lista (index/create/destroy)
│   ├── reviews_controller.rb      # avaliações (create)
│   └── search_controller.rb       # busca
├── models/                        # User, Profile, Movie, ListItem, Review (Active Record)
├── services/
│   └── tmdb_client.rb             # toda a comunicação com o TMDB + Rails.cache
├── helpers/
│   ├── tmdb_helper.rb             # poster_url, backdrop_url, release_year, format_runtime
│   └── application_helper.rb      # profile_avatar
├── views/
│   ├── layouts/                   # application (esqueleto), _navbar, _flash, _auth_card (login/cadastro)
│   ├── registrations/ user_sessions/ # formulários de cadastro e login
│   ├── movies/                    # show + partials _hero, _movie_row, _movie_card, _rating_stars
│   ├── list_items/                # index, _button, create/destroy.turbo_stream.erb
│   ├── reviews/                   # _form, _list, _review, _summary, create.turbo_stream.erb
│   ├── home/ search/ profiles/    # telas
│   └── errors/tmdb.html.erb       # erro amigável (token ausente/inválido, rede)
├── javascript/controllers/
│   └── autohide_controller.js     # Stimulus: esconde as mensagens depois de 3s
└── assets/tailwind/application.css # tema (cores) + estrelas do formulário
config/
├── routes.rb                      # rotas RESTful
└── locales/pt-BR.yml              # nomes dos models/atributos em português
db/
├── migrate/                       # migrations (histórico do banco)
├── schema.rb                      # retrato atual do banco (gerado)
└── seeds.rb                       # conta de demonstração + 1 perfil
test/models/                       # testes de validações e associações (User, Profile, Movie, ListItem, Review)
```

## 7. Comandos usados para criar o projeto

```sh
gem install rails -v 8.1.4

rails new . --name=cinerails --css=tailwind \
  --skip-kamal --skip-thruster --skip-docker --skip-ci --skip-jbuilder \
  --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-mailer --skip-git

bundle add faraday       # cliente HTTP
bundle add rails-i18n    # traduções pt-BR (mensagens de validação, datas)

# Models + migrations + testes/fixtures
bin/rails g model Profile name:string color:string
bin/rails g model Movie tmdb_id:integer:uniq title:string poster_path:string backdrop_path:string release_date:date overview:text
bin/rails g model ListItem profile:references movie:references
bin/rails g model Review profile:references movie:references rating:integer comment:text

# Controllers (as rotas foram escritas à mão em config/routes.rb)
bin/rails g controller Profiles index --skip-routes --no-helper
bin/rails g controller Sessions --skip-routes --no-helper
bin/rails g controller Home index --skip-routes --no-helper
bin/rails g controller Movies show --skip-routes --no-helper
bin/rails g controller ListItems index --skip-routes --no-helper
bin/rails g controller Reviews --skip-routes --no-helper
bin/rails g controller Search index --skip-routes --no-helper
bin/rails g helper Tmdb

bin/rails db:migrate
bin/rails db:seed

# Contas (adicionado depois, por cima do projeto inicial sem login)
bundle add bcrypt                           # has_secure_password
bin/rails g migration CreateUsers
bin/rails g migration AddUserToProfiles
bin/rails g controller Registrations new create --skip-routes --no-helper
bin/rails g controller UserSessions new create destroy --skip-routes --no-helper

bin/rails db:migrate
bin/rails db:seed
```

Depois dos generators, as migrations ganharam `null: false` e índices únicos compostos.
Também foram apagados os testes de controller gerados automaticamente, porque o foco aqui são
os testes de model.

## 8. Bibliotecas

| Gem | Para quê |
|---|---|
| `rails` 8.1 | o framework (inclui Active Record, Action View, Turbo, Stimulus, importmap) |
| `sqlite3` | banco de dados |
| `tailwindcss-rails` | CSS utilitário (Tailwind v4) sem precisar de Node |
| `bcrypt` | hash da senha das contas (`has_secure_password`) |
| `faraday` | requisições HTTP para o TMDB |
| `rails-i18n` | traduções pt-BR |

## 9. Créditos

Dados e imagens: [TMDB](https://www.themoviedb.org).
*This product uses the TMDB API but is not endorsed or certified by TMDB.*

O visual é inspirado em serviços de streaming, mas CineRails é um projeto acadêmico sem
relação com nenhuma marca.
