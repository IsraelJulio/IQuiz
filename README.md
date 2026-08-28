# IQuiz

Sistema de estudos por flash cards com perfil gamificado. Mobile-first, construído com Ruby on Rails + Hotwire + Tailwind CSS + PostgreSQL.

---

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Rodando a aplicação](#rodando-a-aplicação)
- [Login](#login)
- [Funcionalidades](#funcionalidades)
- [Modos de jogo](#modos-de-jogo)
- [Decisões técnicas](#decisões-técnicas)

---

## Pré-requisitos

| Dependência | Versão mínima |
|-------------|---------------|
| Ruby        | 3.2.0         |
| Rails (via Bundler) | 7.2.x |
| PostgreSQL   | 14+           |
| Bundler      | 2.4+          |

### Instalar Ruby (Windows)

Use o **RubyInstaller** (recomendado para Windows):

1. Baixe o instalador em <https://rubyinstaller.org/downloads/>  
   → Escolha **Ruby+Devkit 3.3.x (x64)** (versão mais recente da série 3.3)
2. Execute o instalador e marque **"Add Ruby executables to your PATH"**
3. Ao final, execute o MSYS2 quando solicitado (opção 1 ou 3)

Após a instalação, abra um novo terminal e confirme:

```bash
ruby --version   # ruby 3.3.x
gem --version
```

### Instalar PostgreSQL (Windows)

Baixe em <https://www.postgresql.org/download/windows/> e instale.  
Durante a instalação, defina a senha do usuário `postgres`.

---

## Instalação

```bash
# 2. Instale as gems
gem install bundler
bundle install

# 3. Configure o banco
#    Se sua senha do PostgreSQL for diferente de "postgres",
#    edite config/database.yml ou use variáveis de ambiente:
#      DB_USERNAME=meuuser DB_PASSWORD=minhasenha rails db:setup
rails db:create
rails db:migrate
rails db:seed
```

> **Variáveis de ambiente opcionais:**
> ```
> DB_HOST=localhost
> DB_PORT=5432
> DB_USERNAME=postgres
> DB_PASSWORD=postgres
> ```

---

## Rodando a aplicação

```bash
# Em dois terminais simultâneos:

# Terminal 1 — servidor Rails
bin/rails server

# Terminal 2 — build do Tailwind CSS (obrigatório para os estilos)
bin/rails tailwindcss:watch
```

Acesse: **<http://localhost:3000>**

> **Alternativa (um único terminal):** alguns sistemas suportam `./bin/dev` se você adicionar o Foreman (`gem install foreman`). Crie um `Procfile.dev` com:
> ```
> web: bin/rails server
> css: bin/rails tailwindcss:watch
> ```
> E rode `foreman start -f Procfile.dev`.

---

## Login

| Usuário | Como logar | Senha |
|---------|-----------|-------|
| **Israel** | Clique em "Login" ou acesse `/login` | `123` |
| **Player One** | Nenhum login necessário — é o padrão | — |

Para fazer **logout**: clique em "Sair" no menu superior (canto direito).

**Permissões:**
- **Israel:** criar, editar e deletar listas; criar/editar/deletar cards; importar CSV; criar metas.
- **Player One:** jogar todas as listas existentes e acumular pontuação.

---

## Funcionalidades

### Listas (Flash Cards)
- Criar / editar / deletar listas (Israel only)
- Adicionar cards manualmente (frente + verso)
- **Importar CSV**: 2 colunas sem cabeçalho — coluna A = frente, coluna B = verso
- Adicionar a lista existente OU criar nova lista no import

### Jogo
- 6 modos (veja abaixo)
- Direção: **Frente→Verso** ou **Verso→Frente** (placares separados)
- Ordem embaralhada em toda nova sessão

### Pontuação
- **+1 ponto base** por acerto
- **Multiplicador de streak:**

| Acertos seguidos | Multiplicador |
|-----------------|---------------|
| 1–2             | ×1            |
| 3–4             | ×1,5          |
| 5–9             | ×2            |
| 10+             | ×3            |

- **Regra anti-grind:** mesma lista em menos de 3h → base 0,5pt e multiplicadores divididos por 2
- **Errar** zera o streak

### Dashboard
- Stats por direção (pontos e % de acerto)
- **Calendário heatmap** (12 meses) — clique num dia para ver o detalhe
- **Conquistas** com badges
- **Metas** com barras de progresso
- **Histórico de sessões** com filtros

### Conquistas - TODO
| Conquista | Condição |
|-----------|----------|
| 🎮 Primeiro Jogo | Concluir a 1ª sessão |
| 🏃 Maratonista | 7 dias seguidos |
| ⭐ Perfeição | 100% numa lista |
| 🛡️ Centurião | 100 pontos totais |
| 👑 Lenda | 1000 pontos totais |
| 🔥 Imparável | 10 acertos seguidos numa sessão |
| 📥 Importador | Importar 1ª lista via CSV |
| 🔄 Revisor | Concluir sessão de Spaced Repetition |
| 🤲 Ambidestro | Jogar nos dois sentidos |
| 🗺️ Explorador | Jogar 5 listas diferentes |
| 🦉 Coruja | Jogar entre meia-noite e 4h |
| 🎯 Meta Batida | Atingir uma meta de porcentagem |

---

## Modos de jogo

| # | Modo | Descrição |
|---|------|-----------|
| 1 | **Base** | Vê a frente, clica para revelar, informa se acertou |
| 2 | **Spaced Repetition (Lista)** | Só os cards com erros nessa lista |
| 3 | **Spaced Repetition (Geral)** | Só os cards com erros em todas as listas |
| 4 | **Base — Escrita** | Digita a resposta antes de revelar |
| 5 | **SR (Lista) — Escrita** | Idem ao 2, com digitação |
| 6 | **SR (Geral) — Escrita** | Idem ao 3, com digitação |

> **Nota:** nos modos de Spaced Repetition, se não houver histórico de erros, o sistema avisará para jogar no modo Base primeiro.

---

## Decisões técnicas

- **"Player One"** é o usuário anônimo padrão (criado via seed com `id: 1`). Todo acesso sem login usa este usuário.
- **Soft-delete em listas:** ao deletar, `deleted_at` é preenchido. Histórico de sessões mantém snapshot do nome (`deck_name`).
- **Spaced Repetition simples:** cards ordenados por taxa de erro (erros ÷ tentativas), desempate por erro mais recente.
- **Tailwind CSS** é compilado pelo binário standalone incluído na gem `tailwindcss-rails` — não requer Node.js.
- **Turbo Drive** (Hotwire) intercepta navegações para SPA-like sem full reloads. O heatmap usa **Turbo Stream** para atualizar só o painel de detalhes do dia.
- **Multiplier de streak** é calculado em tempo de execução usando o `current_streak` da `GameSession`, nunca armazenado como campo separado.
