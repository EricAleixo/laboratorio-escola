class ExamePaciente < ApplicationRecord
  belongs_to :paciente
  belongs_to :exame
  
  validates :data_exame, presence: true
  validates :resultado, presence: true, numericality: { greater_than: 0 }
  validates :observacoes, length: { maximum: 500 }
  
  validate :data_exame_nao_futura
  validate :paciente_maior_que_data_nascimento

  # Busca a unidade de referência correta para o paciente (idade + sexo)
  def unidade_referencia
    idade_paciente = paciente.idade
    return nil unless idade_paciente
    
    # Primeiro tenta encontrar por sexo específico e idade
    ref = exame.unidade_referencias.find_by(sexo: paciente.sexo) do |r|
      r.idade_dentro_da_faixa?(idade_paciente)
    end
    
    # Se não encontrar, tenta por sexo "Ambos" e idade
    if ref.nil?
      ref = exame.unidade_referencias.find_by(sexo: 'A') do |r|
        r.idade_dentro_da_faixa?(idade_paciente)
      end
    end
    
    ref
  end

  # Retorna :abaixo, :normal ou :acima
  def situacao_resultado
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