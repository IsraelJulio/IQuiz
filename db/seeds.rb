puts "Seeding IQuiz..."

# ── Users ──────────────────────────────────────────────────────────────────
player_one = User.find_or_create_by!(id: User::PLAYER_ONE_ID) do |u|
  u.name       = "Player One"
  u.is_israel  = false
end

israel = User.find_or_create_by!(id: User::ISRAEL_ID) do |u|
  u.name      = "Israel"
  u.is_israel = true
end

puts "  ✓ Users: #{User.count}"

# ── Achievements ────────────────────────────────────────────────────────────
Achievement::DEFINITIONS.each do |attrs|
  Achievement.find_or_create_by!(key: attrs[:key]) do |a|
    a.name        = attrs[:name]
    a.description = attrs[:description]
    a.icon        = attrs[:icon]
  end
end

puts "  ✓ Achievements: #{Achievement.count}"

# ── Decks & Cards ───────────────────────────────────────────────────────────

# Deck 1 — Inglês Básico
deck_en = Deck.find_or_create_by!(name: "Inglês Básico") do |d|
  d.description = "Vocabulário essencial de inglês para iniciantes"
end

en_cards = [
  ["house",    "casa"],
  ["water",    "água"],
  ["fire",     "fogo"],
  ["sun",      "sol"],
  ["moon",     "lua"],
  ["tree",     "árvore"],
  ["book",     "livro"],
  ["chair",    "cadeira"],
  ["door",     "porta"],
  ["window",   "janela"],
  ["dog",      "cachorro"],
  ["cat",      "gato"],
  ["bird",     "pássaro"],
  ["fish",     "peixe"],
  ["apple",    "maçã"],
  ["bread",    "pão"],
  ["milk",     "leite"],
  ["school",   "escola"],
  ["city",     "cidade"],
  ["road",     "estrada"],
]

en_cards.each do |front, back|
  deck_en.cards.find_or_create_by!(front: front, back: back)
end

# Deck 2 — Capitais do Mundo
deck_capitals = Deck.find_or_create_by!(name: "Capitais do Mundo") do |d|
  d.description = "Capitais dos principais países do mundo"
end

capitals = [
  ["Brasil",          "Brasília"],
  ["Argentina",       "Buenos Aires"],
  ["França",          "Paris"],
  ["Alemanha",        "Berlim"],
  ["Japão",           "Tóquio"],
  ["China",           "Pequim"],
  ["Austrália",       "Camberra"],
  ["Canadá",          "Ottawa"],
  ["México",          "Cidade do México"],
  ["Itália",          "Roma"],
  ["Espanha",         "Madri"],
  ["Portugal",        "Lisboa"],
  ["Reino Unido",     "Londres"],
  ["Rússia",          "Moscou"],
  ["Estados Unidos",  "Washington, D.C."],
  ["Índia",           "Nova Déli"],
  ["África do Sul",   "Pretória"],
  ["Egito",           "Cairo"],
  ["Grécia",          "Atenas"],
  ["Turquia",         "Ancara"],
]

capitals.each do |front, back|
  deck_capitals.cards.find_or_create_by!(front: front, back: back)
end

# Deck 3 — Matemática Básica
deck_math = Deck.find_or_create_by!(name: "Tabuada") do |d|
  d.description = "Multiplicação — tabuada do 7 ao 9"
end

math_cards = [
  ["7 × 1", "7"],   ["7 × 2", "14"],  ["7 × 3", "21"],
  ["7 × 4", "28"],  ["7 × 5", "35"],  ["7 × 6", "42"],
  ["7 × 7", "49"],  ["7 × 8", "56"],  ["7 × 9", "63"],
  ["7 × 10", "70"],
  ["8 × 1", "8"],   ["8 × 2", "16"],  ["8 × 3", "24"],
  ["8 × 4", "32"],  ["8 × 5", "40"],  ["8 × 6", "48"],
  ["8 × 7", "56"],  ["8 × 8", "64"],  ["8 × 9", "72"],
  ["8 × 10", "80"],
  ["9 × 1", "9"],   ["9 × 2", "18"],  ["9 × 3", "27"],
  ["9 × 4", "36"],  ["9 × 5", "45"],  ["9 × 6", "54"],
  ["9 × 7", "63"],  ["9 × 8", "72"],  ["9 × 9", "81"],
  ["9 × 10", "90"],
]

math_cards.each do |front, back|
  deck_math.cards.find_or_create_by!(front: front, back: back)
end

puts "  ✓ Decks: #{Deck.count}, Cards: #{Card.count}"

# ── Sample game sessions (for dashboard to have content) ────────────────────
def create_sample_session(user:, deck:, mode:, direction:, correct_pct:, days_ago:)
  cards = deck.cards.to_a.shuffle

  # Determine card_ids
  card_ids = cards.map(&:id)

  started = days_ago.days.ago + rand(8..22).hours + rand(60).minutes

  # Anti-grind: false for seeds
  gs = GameSession.create!(
    user:       user,
    deck:       deck,
    deck_name:  deck.name,
    game_mode:  mode,
    direction:  direction,
    card_order: card_ids,
    started_at: started,
    anti_grind: false
  )

  streak = 0
  max_streak = 0
  total_points = 0.0
  correct_count = 0

  card_ids.each_with_index do |card_id, idx|
    correct = rand < correct_pct

    if correct
      streak += 1
      max_streak = [max_streak, streak].max
      mult = case streak
             when 1..2 then 1.0
             when 3..4 then 1.5
             when 5..9 then 2.0
             else           3.0
             end
      total_points  += 1.0 * mult
      correct_count += 1
    else
      streak = 0
    end

    CardAttempt.create!(
      user:         user,
      card:         Card.find(card_id),
      game_session: gs,
      direction:    direction,
      correct:      correct,
      created_at:   started + (idx + 1).minutes
    )
  end

  gs.update!(
    status:             "completed",
    current_card_index: card_ids.length,
    total_points:       total_points.round(2),
    cards_total:        card_ids.length,
    cards_correct:      correct_count,
    max_streak:         max_streak,
    current_streak:     0,
    completed_at:       started + card_ids.length.minutes
  )

  gs
end

# Generate sample history for the past 2 weeks
puts "  Creating sample game sessions..."

[israel, player_one].each do |user|
  [
    { deck: deck_en,       mode: "base",         direction: "front", pct: 0.80, days: 14 },
    { deck: deck_en,       mode: "base",         direction: "back",  pct: 0.65, days: 13 },
    { deck: deck_capitals, mode: "base",         direction: "front", pct: 0.70, days: 12 },
    { deck: deck_capitals, mode: "base_written",  direction: "front", pct: 0.60, days: 11 },
    { deck: deck_math,     mode: "base",         direction: "front", pct: 0.90, days: 10 },
    { deck: deck_en,       mode: "base",         direction: "front", pct: 0.85, days:  9 },
    { deck: deck_en,       mode: "spaced_list",  direction: "front", pct: 0.75, days:  8 },
    { deck: deck_capitals, mode: "base",         direction: "front", pct: 0.72, days:  7 },
    { deck: deck_math,     mode: "base",         direction: "front", pct: 0.95, days:  6 },
    { deck: deck_en,       mode: "base",         direction: "front", pct: 0.88, days:  5 },
    { deck: deck_capitals, mode: "base",         direction: "back",  pct: 0.50, days:  4 },
    { deck: deck_en,       mode: "base",         direction: "front", pct: 0.92, days:  3 },
    { deck: deck_math,     mode: "base",         direction: "front", pct: 1.00, days: 2 },
    { deck: deck_en,       mode: "base",         direction: "front", pct: 0.90, days:  1 },
  ].each do |opts|
    next if opts.nil?
    begin
      create_sample_session(
        user:        user,
        deck:        opts[:deck],
        mode:        opts[:mode],
        direction:   opts[:direction],
        correct_pct: opts[:pct],
        days_ago:    opts[:days]
      )
    rescue => e
      puts "    (skipped session: #{e.message})"
    end
  end
end

puts "  ✓ Game sessions: #{GameSession.count}"

# ── Award some achievements to israel from seed data ────────────────────────
service_i = AchievementService.new(israel, GameSession.where(user: israel, status: "completed").last)
service_i.check_and_award!

service_p = AchievementService.new(player_one, GameSession.where(user: player_one, status: "completed").last)
service_p.check_and_award!

puts "  ✓ Achievements awarded"

# ── Sample goals for Israel ──────────────────────────────────────────────────
Goal.find_or_create_by!(user: israel, deck: deck_en) do |g|
  g.target_percentage = 90
  g.label             = "Dominar Inglês Básico"
end

Goal.find_or_create_by!(user: israel, deck: nil) do |g|
  g.target_percentage = 80
  g.label             = "80% global"
end

puts "  ✓ Goals: #{Goal.count}"

puts ""
puts "✅ Seed completo!"
puts "   Player One e Israel criados."
puts "   3 listas com #{Card.count} cards."
puts "   #{GameSession.count} sessões de exemplo."
puts ""
puts "   Para logar como Israel: acesse /login e informe a senha: 123"
