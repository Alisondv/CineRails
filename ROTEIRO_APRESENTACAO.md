# Roteiro da apresentação: "Como o Rails funciona" com o CineRails (~15 min)

**Antes de começar**
- Servidor rodando com o `TMDB_TOKEN` configurado (Mac: `bin/dev`; Windows: `ruby bin/rails server`
  — ver README seção 3).
- Abra a home uma vez antes da aula para "aquecer" o `Rails.cache`. Assim as fileiras carregam
  na hora durante a demo.
- Deixe abertos: o navegador em `localhost:3000/login` (desconectado, pra mostrar o login de
  verdade), o editor e um terminal.
- Zoom do editor em ~150% para a turma enxergar.
- Para resetar os dados: `bin/rails db:reset` (apaga tudo, roda as migrations e recria a conta
  de demonstração pelo seed).
- Conta de demonstração: `demo@cinerails.test` / `cinerails123` (está no README).

---

## 0:00–1:30 · Abertura com demo rápida
**Mostrar:** a tela de login, entrar com a conta de demonstração, escolher o perfil e rolar a home.

**Falar:**
- "Isto é um app Rails com login, perfis por conta (no modelo da Netflix) e um catálogo de
  filmes. Contando HTML, são menos de mil linhas de código nosso."
- "Os filmes vêm de uma API externa, o TMDB. O nosso banco guarda só o que é do usuário: contas,
  perfis, lista e avaliações."
- "Vamos seguir o caminho de **uma requisição** pelo Rails, começando pelo login: rota,
  controller, model, view."

## 1:30–3:00 · Convenção sobre configuração (estrutura)
**Abrir:** a árvore de pastas `app/` (controllers, models, views, helpers, services).

**Falar:**
- "O Rails decide onde cada coisa mora. `RegistrationsController#new` renderiza
  `app/views/registrations/new.html.erb` **automaticamente**, sem nenhuma configuração."
- "Muita coisa foi gerada com generators (mostrar a seção 7 do README):
  `bin/rails g model Review profile:references rating:integer...`"

## 3:00–4:30 · Contas: cadastro, login e senha criptografada
**Abrir:** `app/models/user.rb`

**Falar:**
- "O model `User` usa `has_secure_password` pra guardar a senha criptografada. A gem por trás
  é a `bcrypt` — ela nunca grava a senha em texto puro, só um hash."
- "`normalizes :email` garante que `Ana@Email.com` e `ana@email.com` sejam a mesma conta."

**Terminal (`bin/rails console`):**
```ruby
u = User.find_by(email: "demo@cinerails.test")
u.password_digest   # mostra o hash bcrypt, não "cinerails123"
u.authenticate("cinerails123")   # => o próprio user (senha certa)
u.authenticate("errada")         # => false
```
**Ponto alto da demo:** ninguém, nem olhando direto no banco, vê a senha de verdade.

**Abrir:** `app/controllers/registrations_controller.rb` e `user_sessions_controller.rb`
- "Cadastro cria um `User` e já guarda `session[:user_id]`. Login busca pelo e-mail e chama
  `authenticate`; se bater, mesma coisa."
- "São dois controllers separados de propósito: um cria a CONTA, outro escolhe o PERFIL dentro
  dela — já vem a seguir."

## 4:30–6:00 · Perfis por conta ("Quem está assistindo?")
**Abrir:** `app/models/profile.rb` — `belongs_to :user`.

**Falar:**
- "Cada perfil pertence a uma conta. A tela 'Quem está assistindo?' lista só
  `current_user.profiles`, nunca `Profile.all`."
- "Mesma ideia na hora de escolher um perfil: `current_user.profiles.find(id)`. Se alguém tentar
  adulterar o formulário com o id de um perfil de OUTRA conta, dá 404 — o Rails nem acha o
  registro, porque ele procura só dentro dos perfis daquela conta."

**Mostrar no navegador:** a tela "Quem está assistindo?" com o botão "Adicionar perfil"
(`app/views/profiles/new.html.erb`) — nome + cor, nada além disso.

## 6:00–7:00 · Rotas
**Abrir:** `config/routes.rb`

**Falar:**
- `resources :profiles, only: [:index, :new, :create]` gera as rotas da tela de perfis de uma vez.
- Rotas **aninhadas**: `POST /movies/603/list_item`. A URL já diz de qual filme se trata.
- `resource :session` (singular): não tem id, porque só existe "a" sessão (perfil) atual —
  diferente do login/logout da conta, que são outras rotas (`/login`, `/logout`).

**Terminal:** `bin/rails routes -c movies` (mostra a tabela gerada).

## 7:00–8:30 · Migrations e Active Record
**Abrir:** `db/migrate/..._add_user_to_profiles.rb` e depois `db/schema.rb`.

**Falar:**
- "Migration é uma receita versionada do banco. `add_reference` cria `user_id`, o índice e a
  foreign key de uma vez — foi o jeito que ligamos Profile a User depois que o projeto já
  existia."
- "Índice único composto: o próprio banco impede o mesmo filme duas vezes na lista."

**Abrir:** `app/models/profile.rb`, depois `review.rb`.
- **Ponto alto:** `has_many :movies, through: :list_items`. Faz o JOIN sozinho.

**Terminal (`bin/rails console`):**
```ruby
p = Profile.first
p.user            # a conta dona deste perfil
p.movies          # mostrar o SQL com JOIN que aparece no console
p.movies.to_sql
```

## 8:30–9:30 · Controller enxuto + before_action
**Abrir:** `app/controllers/application_controller.rb`

**Falar:**
- `before_action :require_login, :require_profile`, NESSA ORDEM: sem conta logada não faz
  sentido nem perguntar qual perfil usar.
- `helper_method :current_user, :current_profile`: a navbar e as views usam os mesmos métodos.
- `rescue_from TmdbClient::Error`: se a API cair, aparece uma página amigável, sem erro 500.

**Abrir:** `app/controllers/home_controller.rb`
- "O controller não sabe nada de HTTP nem de JSON. Ele só pede `tmdb.popular`."

## 9:30–10:30 · Service object + API externa + cache
**Abrir:** `app/services/tmdb_client.rb`

**Falar:**
- Por que um service: a lógica de integração fica num lugar só, o controller fica limpo e dá
  para trocar de API mexendo em um arquivo.
- O token vem de `ENV` ou de `credentials`, **nunca do código** (igual a senha: nada sensível
  fica hardcoded).
- Método `get` com `Rails.cache.fetch(..., expires_in: 6.hours)`: "a home faz 7 chamadas; da
  segunda visita em diante, nenhuma."

## 10:30–11:15 · Views e partials
**Abrir:** `app/views/home/index.html.erb` (poucas linhas).
- `render "movies/hero"` e `render "movies/movie_row"`.
- "O mesmo card de filme (`movies/_movie_card`) é usado na home, na busca e na Minha Lista."

## 11:15–13:30 · Hotwire / Turbo Streams (o ponto forte)
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
- **Demo:** escolher 5 estrelas, comentar e enviar. A média e a lista atualizam na hora, sem
  recarregar.

## 13:30–14:15 · Persistência, contas e testes
- Recarregar a página (F5): a avaliação e a lista continuam lá, porque estão no SQLite.
- Sair da conta (botão "Sair da conta" na tela de perfis) e entrar de novo: tudo continua onde
  estava — é tudo ligado à conta, não ao navegador.
- **Terminal:** `bin/rails test` → 31 testes (models de conta, perfil, filme, lista e avaliação)
  passando.

## 14:15–15:00 · Fechamento
- Recapitular o caminho: **login/conta → perfil → rota → controller → (service/TMDB + model/banco)
  → view/partial → Turbo Stream**.
- "Convenção sobre configuração: quase nada foi configurado, tudo foi seguir os nomes."
- Perguntas.

---

### Plano B (sem internet ou com o TMDB fora)
- **Login, cadastro e perfis não dependem do TMDB** — essa parte inteira (blocos de 0:00 a 6:00)
  funciona normalmente sem internet, porque é só o nosso banco local. Dá pra fazer ao vivo
  mesmo sem conexão.
- Pro catálogo: mostre a tela de erro amigável (também é um bom exemplo de `rescue_from`).
- Siga com o código, o `bin/rails console` (models e associações) e o `bin/rails test`, que não
  dependem da API.
- Se o cache foi aquecido antes, as páginas já visitadas continuam funcionando enquanto o
  servidor não for reiniciado.
