class Paciente < ApplicationRecord
  has_many :exame_pacientes, dependent: :destroy
  has_many :exames, through: :exame_pacientes
  
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :data_nascimento, presence: true
  validates :sexo, presence: true, inclusion: { in: %w[M F] }
  
  def idade
    return nil unless data_nascimento
    hoje = Date.current
    idade = hoje.year - data_nascimento.year
    idade -= 1 if hoje < data_nascimento + idade.years
    idade
  end
  
  def nome_completo
    "#{nome} (#{idade} anos)"
  end
end 