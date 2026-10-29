# 🎬 CineRails

Catálogo de filmes com visual de streaming, feito em **Ruby on Rails 8** para uma apresentação
didática sobre como o Rails funciona: **MVC, rotas, Active Record, migrations, views/partials,
Hotwire (Turbo + Stimulus) e consumo de API externa**.

Os filmes, pôsteres e trailers vêm da API do [TMDB](https://www.themoviedb.org). O app guarda
no banco local apenas os dados do usuário: perfis, **Minha Lista** e **avaliações**.

| Tela | O que mostra |
|---|---|
| Quem está assistindo? | Escolha de perfil (sem senha, o id fica na sessão) |
| Início | Banner "hero" + fileiras: Em alta, Populares, Mais bem avaliados, Ação, Comédia, Ficção científica |
| Filme | Backdrop, pôster, ano, duração, gêneros, nota TMDB, sinopse, trailer do YouTube e avaliações |
| Minha Lista | Grade com os filmes salvos pelo perfil atual |
| Busca | Resultados da busca do TMDB em grade |

Adicionar/remover da lista e enviar uma avaliação **não recarregam a página** (Turbo Streams).

---

## 1. Pré-requisitos

- **Ruby 3.4.12** (o arquivo `.ruby-version` indica a versão)
- SQLite 3 (já vem no macOS)
- Uma conta grátis no TMDB

> **Ruby nesta máquina:** o Ruby do macOS (2.6) é antigo demais para o Rails 8. Por isso o
> Ruby 3.4.12 foi compilado com `ruby-build` em `~/.rubies/ruby-3.4.12`. Para usá-lo, adicione
> esta linha ao `~/.zshrc` e abra um terminal novo:
>
> ```sh
> export PATH="$HOME/.rubies/ruby-3.4.12/bin:$PATH"
> ```
>
> Para conferir: `ruby -v` deve mostrar 3.4.12, e `rails -v` deve mostrar 8.1.4.

## 2. Configurar o token do TMDB

1. Crie uma conta em <https://www.themoviedb.org/signup>.
2. Em **Configurações › API** (<https://www.themoviedb.org/settings/api>), copie o
   **API Read Access Token**. É o token longo; a "API Key" curta não serve.
3. Escolha **uma** das formas abaixo. O token **nunca** vai para o código.

**Opção A: variável de ambiente** (mais simples)

```sh
export TMDB_TOKEN="eyJhbGciOi..."
```

**Opção B: credentials criptografadas do Rails**

```sh
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

```sh
bin/setup   # instala as gems, cria o banco, roda migrations + seeds e já sobe o servidor
# nas próximas vezes:
bin/dev     # sobe o Rails (porta 3000) e o watcher do Tailwind (Procfile.dev)
```

Acesse <http://localhost:3000>.

Testes dos models:

```sh
bin/rails test
```

Outros comandos úteis na apresentação:

```sh
bin/rails routes     # tabela de rotas
bin/rails console    # brincar com os models: Profile.first.movies
bin/rails db:seed    # recria os perfis
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
│   CONTROLLER     │   before_action :require_profile (há perfil na sessão?)
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
Profile ─┬─< ListItem >─┬─ Movie
         │              │
         └─<  Review   >┘

Profile has_many :list_items          Movie has_many :list_items
Profile has_many :movies, through: :list_items   (Minha Lista)
Profile has_many :reviews             Movie has_many :reviews
ListItem / Review belongs_to :profile, belongs_to :movie
```

| Model | Campos | Validações |
|---|---|---|
| `Profile` | name, color | nome obrigatório (até 20), cor da paleta |
| `Movie` | tmdb_id (único), title, poster_path, backdrop_path, release_date, overview | tmdb_id único, título obrigatório |
| `ListItem` | profile_id, movie_id | filme único por perfil (+ índice único no banco) |
| `Review` | profile_id, movie_id, rating, comment | nota inteira de 1 a 5, comentário ≤ 500, uma por perfil/filme |

O `Movie` é um **cache local mínimo**: só é salvo quando entra numa lista ou recebe avaliação
(`Movie.from_tmdb`).

## 6. Estrutura de pastas (o que importa)

```
app/
├── controllers/
│   ├── application_controller.rb  # before_action, current_profile, rescue_from do TMDB
│   ├── profiles_controller.rb     # "Quem está assistindo?"
│   ├── sessions_controller.rb     # escolhe/troca perfil (sessão)
│   ├── home_controller.rb         # hero + fileiras
│   ├── movies_controller.rb       # página do filme
│   ├── list_items_controller.rb   # Minha Lista (index/create/destroy)
│   ├── reviews_controller.rb      # avaliações (create)
│   └── search_controller.rb       # busca
├── models/                        # Profile, Movie, ListItem, Review (Active Record)
├── services/
│   └── tmdb_client.rb             # toda a comunicação com o TMDB + Rails.cache
├── helpers/
│   ├── tmdb_helper.rb             # poster_url, backdrop_url, release_year, format_runtime
│   └── application_helper.rb      # profile_avatar
├── views/
│   ├── layouts/                   # application (esqueleto), _navbar, _flash
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
└── seeds.rb                       # 3 perfis
test/models/                       # testes de validações e associações
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
| `faraday` | requisições HTTP para o TMDB |
| `rails-i18n` | traduções pt-BR |

## 9. Créditos

Dados e imagens: [TMDB](https://www.themoviedb.org).
*This product uses the TMDB API but is not endorsed or certified by TMDB.*

O visual é inspirado em serviços de streaming, mas CineRails é um projeto acadêmico sem
relação com nenhuma marca.
