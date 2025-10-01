class Exame < ApplicationRecord
  has_many :unidade_referencias, dependent: :destroy
  has_many :unidade_medidas, through: :unidade_referencias
  has_many :exame_pacientes, dependent: :destroy
  has_many :pacientes, through: :exame_pacientes

  TIPOS = %w[quantitativo qualitativo]

  validates :nome, presence: true, uniqueness: true
  validates :ativo, inclusion: { in: [true, false] }
  validates :tipo, presence: true, inclusion: { in: TIPOS }

  # Armazena opções qualitativas como array serializado em YAML
  serialize :opcoes_qualitativo, Array, coder: YAML

  scope :ativos, -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }
end