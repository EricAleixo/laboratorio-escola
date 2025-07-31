class UnidadeReferencia < ApplicationRecord
  self.table_name = "unidade_referencias"
  
  belongs_to :exame
  belongs_to :unidade_medida
  
  validates :valor_minimo, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_maximo, presence: true, numericality: { greater_than: 0 }
  validates :sexo, presence: true, inclusion: { in: %w[M F A] }
  validates :unidade_medida, presence: true
  validates :idade_minima, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :idade_maxima, presence: true, numericality: { greater_than: 0 }
  
  validate :valor_maximo_maior_que_minimo
  validate :idade_maxima_maior_que_minima
  
  def idade_dentro_da_faixa?(idade_paciente)
    return false unless idade_paciente
    idade_paciente >= idade_minima && idade_paciente <= idade_maxima
  end

  def faixa_etaria
    if idade_minima == 0 && idade_maxima >= 120
      "Todas as idades"
    elsif idade_minima == 0
      "Até #{idade_maxima} anos"
    elsif idade_maxima >= 120
      "#{idade_minima}+ anos"
    else
      "#{idade_minima} a #{idade_maxima} anos"
    end
  end
  
  private
  
  def valor_maximo_maior_que_minimo
    if valor_maximo.present? && valor_minimo.present? && valor_maximo <= valor_minimo
      errors.add(:valor_maximo, "deve ser maior que o valor mínimo")
    end
  end
  
  def idade_maxima_maior_que_minima
    if idade_maxima.present? && idade_minima.present? && idade_maxima < idade_minima
      errors.add(:idade_maxima, "deve ser maior ou igual à idade mínima")
    end
  end
end
