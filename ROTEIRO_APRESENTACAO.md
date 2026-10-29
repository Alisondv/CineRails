# Roteiro da apresentação: "Como o Rails funciona" com o CineRails (~15 min)

**Antes de começar**
- `bin/dev` rodando, com o `TMDB_TOKEN` configurado.
- Abra a home uma vez antes da aula para "aquecer" o `Rails.cache`. Assim as fileiras carregam
  na hora durante a demo.
- Deixe abertos: o navegador em `localhost:3000/profiles`, o editor e um terminal.
- Zoom do editor em ~150% para a turma enxergar.
- Para resetar os dados: `bin/rails db:reset` (apaga tudo e roda os seeds).

---

## 0:00–1:30 · Abertura com demo rápida
**Mostrar:** a tela "Quem está assistindo?", clicar em um perfil e rolar a home.

**Falar:**
- "Isto é um app Rails com umas 650 linhas de código nosso, contando HTML."
- "Os filmes vêm de uma API externa, o TMDB. O nosso banco guarda só o que é do usuário:
  perfis, lista e avaliações."
- "Vamos seguir o caminho de **uma requisição** pelo Rails: rota, controller, model/service,
  view."

## 1:30–3:00 · Convenção sobre configuração (estrutura)
**Abrir:** a árvore de pastas `app/` (controllers, models, views, helpers, services).

**Falar:**
- "O Rails decide onde cada coisa mora. O `MoviesController#show` renderiza
  `app/views/movies/show.html.erb` **automaticamente**, sem nenhuma configuração."
- "Muita coisa foi gerada com generators (mostrar a seção 7 do README):
  `bin/rails g model Review profile:references rating:integer...`"

## 3:00–4:30 · Rotas
**Abrir:** `config/routes.rb`

**Falar:**
- `resources :movies, only: [:show]` gera `GET /movies/:id → movies#show` e o helper `movie_path`.
- Rotas **aninhadas**: `POST /movies/603/list_item`. A URL já diz de qual filme se trata.
- `resource :session` (singular): não tem id, porque só existe "a" sessão atual.

**Terminal:** `bin/rails routes -c movies` (mostra a tabela gerada).

## 4:30–6:30 · Migrations e Active Record
**Abrir:** `db/migrate/..._create_list_items.rb` e depois `db/schema.rb`.

**Falar:**
- "Migration é uma receita versionada do banco. `t.references` cria `profile_id`, o índice e
  a foreign key."
- "Índice único composto: o próprio banco impede o mesmo filme duas vezes na lista."

**Abrir:** `app/models/profile.rb`, depois `review.rb`.
- `has_many :list_items`, `belongs_to :profile`.
- **Ponto alto:** `has_many :movies, through: :list_items`. Faz o JOIN sozinho.
- Validações em `review.rb`: `numericality: { in: 1..5 }` e unicidade com `scope`.

**Terminal (`bin/rails console`):**
```ruby
p = Profile.first
p.movies          # mostrar o SQL com JOIN que aparece no console
p.movies.to_sql
Review.new(rating: 9).tap(&:valid?).errors.full_messages
```

## 6:30–8:00 · Controller enxuto + before_action
**Abrir:** `app/controllers/application_controller.rb`

**Falar:**
- `before_action :require_profile`: roda antes de toda ação. Sem perfil, redireciona.
- `helper_method :current_profile`: a navbar usa o mesmo método.
- `rescue_from TmdbClient::Error`: se a API cair, aparece uma página amigável, sem erro 500.

**Abrir:** `app/controllers/home_controller.rb`
- "O controller não sabe nada de HTTP nem de JSON. Ele só pede `tmdb.popular`."

## 8:00–9:30 · Service object + API externa + cache
**Abrir:** `app/services/tmdb_client.rb`

**Falar:**
- Por que um service: a lógica de integração fica num lugar só, o controller fica limpo e dá
  para trocar de API mexendo em um arquivo.
- O token vem de `ENV` ou de `credentials`, **nunca do código**.
- Método `get` com `Rails.cache.fetch(..., expires_in: 6.hours)`: "a home faz 7 chamadas; da
  segunda visita em diante, nenhuma."
- **Demo opcional:** mostrar no log do `bin/dev` que a primeira visita a um filme é mais lenta
  e a segunda é instantânea.

## 9:30–11:00 · Views e partials
**Abrir:** `app/views/home/index.html.erb` (são 9 linhas).
- `render "movies/hero"` e `render "movies/movie_row"`.

**Abrir:** `app/views/movies/_movie_row.html.erb`, depois `_movie_card.html.erb`.
- "O mesmo card é usado na home, na busca e na Minha Lista."
- `app/helpers/tmdb_helper.rb`: `poster_url` monta a URL da imagem.

**Mostrar no navegador:** o hover no pôster (zoom + sombra) é só Tailwind (`hover:scale-105`).

## 11:00–13:30 · Hotwire / Turbo Streams (o ponto forte)
**Abrir:** `app/views/list_items/_button.html.erb`
- `<div id="list_button_603">`: esse id é o **alvo**.
- `button_to` gera um `<form>`. O Turbo intercepta o envio.

**Abrir:** `app/controllers/list_items_controller.rb` → `respond_to` com `format.turbo_stream`.

**Abrir:** `app/views/list_items/create.turbo_stream.erb`
- `turbo_stream.replace "list_button_603"`: "o servidor manda só o HTML novo do botão, e o
  Turbo troca na página".

**Demo ao vivo** (com o DevTools › Network aberto):
1. Na página de um filme, clicar em **+ Minha Lista**. O botão vira "✓ Na Minha Lista", aparece
   o aviso e a página **não recarrega**.
2. No Network, clicar na requisição e mostrar a resposta `<turbo-stream action="replace" ...>`.
3. Ir em **Minha Lista** e clicar em **Remover**. O card some (`turbo_stream.remove`).

**Avaliações** (abrir `app/views/reviews/create.turbo_stream.erb`):
- "Uma resposta, **três** atualizações: média, lista e formulário."
- **Demo:** enviar sem escolher nota. A mensagem "Nota não pode ficar em branco" aparece (status
  422, validação do model). Depois escolher 5 estrelas, comentar e enviar. A média e a lista
  atualizam na hora.

**Bônus Stimulus (30 s):** `app/javascript/controllers/autohide_controller.js` é o JS que faz o
aviso sumir depois de 3s, ligado pelo HTML com `data-controller="autohide"`.

## 13:30–14:30 · Persistência e testes
- Recarregar a página (F5): a avaliação e a lista continuam lá, porque estão no SQLite.
- Trocar de perfil (avatar na navbar): a lista do outro perfil é diferente.
- **Terminal:** `bin/rails test` → 20 testes de validações e associações passando.
- Mostrar rapidamente `test/models/list_item_test.rb` e as fixtures (`profile: ana`).

## 14:30–15:00 · Fechamento
- Recapitular o caminho: **rota → controller → (service/TMDB + model/banco) → view/partial →
  Turbo Stream**.
- "Convenção sobre configuração: quase nada foi configurado, tudo foi seguir os nomes."
- Perguntas.

---

### Plano B (sem internet ou com o TMDB fora)
- Mostre a tela de erro amigável. Ela também é um bom exemplo de `rescue_from`.
- Siga com o código, o `bin/rails console` (models e associações) e o `bin/rails test`, que não
  dependem da API.
- Se o cache foi aquecido antes, as páginas já visitadas continuam funcionando enquanto o
  servidor não for reiniciado.
