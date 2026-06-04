class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  DEFINITIONS = [
    { key: "first_game",    name: "Primeiro Jogo",  description: "Conclua sua primeira sessão.",               icon: "🎮" },
    { key: "marathoner",    name: "Maratonista",    description: "Jogue 7 dias seguidos.",                     icon: "🏃" },
    { key: "perfection",    name: "Perfeição",      description: "Acerte 100% em uma lista.",                  icon: "⭐" },
    { key: "centurion",     name: "Centurião",      description: "Acumule 100 pontos no total.",               icon: "🛡️" },
    { key: "legend",        name: "Lenda",          description: "Acumule 1000 pontos no total.",              icon: "👑" },
    { key: "unstoppable",   name: "Imparável",      description: "Faça 10 acertos seguidos em uma sessão.",    icon: "🔥" },
    { key: "importer",      name: "Importador",     description: "Importe sua primeira lista via CSV.",         icon: "📥" },
    { key: "reviewer",      name: "Revisor",        description: "Conclua uma sessão de Spaced Repetition.",   icon: "🔄" },
    { key: "ambidextrous",  name: "Ambidestro",     description: "Jogue tanto pela frente quanto pelo verso.", icon: "🤲" },
    { key: "explorer",      name: "Explorador",     description: "Jogue 5 listas diferentes.",                 icon: "🗺️" },
    { key: "night_owl",     name: "Coruja",         description: "Jogue depois da meia-noite.",                icon: "🦉" },
    { key: "goal_achieved", name: "Meta Batida",    description: "Atinja uma meta de porcentagem definida.",   icon: "🎯" },
  ].freeze
end
