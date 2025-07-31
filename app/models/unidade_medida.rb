class UnidadeMedida < ApplicationRecord
  has_many :unidade_referencias, dependent: :destroy
  has_many :exames, through: :unidade_referencias
  
  validates :nome, presence: true, uniqueness: true
  validates :simbolo, presence: true, uniqueness: true
end
