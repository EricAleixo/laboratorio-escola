class ExamePaciente < ApplicationRecord
  belongs_to :paciente
  belongs_to :exame
  
  validates :data_exame, presence: true
  validates :resultado, numericality: { greater_than: 0 }, allow_blank: true
  validates :observacoes, length: { maximum: 500 }
  
  validate :data_exame_nao_futura
  validate :paciente_maior_que_data_nascimento

  def unidade_referencia
    idade_paciente = paciente.idade
    return nil unless idade_paciente

    ref = exame.unidade_referencias.find_by(sexo: paciente.sexo) do |r|
      r.idade_dentro_da_faixa?(idade_paciente)
    end

    if ref.nil?
      ref = exame.unidade_referencias.find_by(sexo: 'A') do |r|
        r.idade_dentro_da_faixa?(idade_paciente)
      end
    end
    
    ref
  end

  # Retorna :abaixo, :normal ou :acima
  def situacao_resultado
    return :indefinido unless resultado.present?
    ref = unidade_referencia
    return :indefinido unless ref
    return :abaixo if resultado < ref.valor_minimo
    return :acima if resultado > ref.valor_maximo
    :normal
  end

  private
  
  def data_exame_nao_futura
    if data_exame.present? && data_exame > Date.current
      errors.add(:data_exame, "não pode ser uma data futura")
    end
  end
  
  def paciente_maior_que_data_nascimento
    if data_exame.present? && paciente&.data_nascimento.present? && data_exame < paciente.data_nascimento
      errors.add(:data_exame, "não pode ser anterior à data de nascimento do paciente")
    end
  end
end 