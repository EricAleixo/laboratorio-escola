class Exame < ApplicationRecord
  has_many :unidade_referencias, dependent: :destroy
  has_many :unidade_medidas, through: :unidade_referencias
  has_many :exame_pacientes, dependent: :destroy
  has_many :pacientes, through: :exame_pacientes
  
  validates :nome, presence: true, uniqueness: true
  validates :ativo, inclusion: { in: [true, false] }
  
  scope :ativos, -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }
end 