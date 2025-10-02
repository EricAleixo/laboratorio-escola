class ExamePaciente < ApplicationRecord
  belongs_to :paciente
  belongs_to :exame
  
  validates :data_exame, presence: true
  validates :observacoes, length: { maximum: 500 }
  
  validate :data_exame_nao_futura
  validate :paciente_maior_que_data_nascimento
  validate :resultado_valido

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
    
    # Se for qualitativo, retorna baseado em Presente/Ausente
    if exame.tipo == 'qualitativo'
      return resultado == 'Presente' ? :presente : :ausente
    end
    
    # Para quantitativo, usa a lógica original
    ref = unidade_referencia
    return :indefinido unless ref
    
    resultado_numerico = resultado.to_f
    return :abaixo if resultado_numerico < ref.valor_minimo
    return :acima if resultado_numerico > ref.valor_maximo
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
  
  def resultado_valido
    return if resultado.blank? # Permite resultado em branco
    
    if exame.tipo == 'qualitativo'
      # Para exames qualitativos, só aceita "Presente" ou "Ausente"
      unless ['Presente', 'Ausente'].include?(resultado)
        errors.add(:resultado, "deve ser 'Presente' ou 'Ausente' para exames qualitativos")
      end
    else
      # Para exames quantitativos, valida se é numérico e maior que 0
      unless resultado.to_s.match?(/\A-?\d+(\.\d+)?\z/)
        errors.add(:resultado, "deve ser um número válido para exames quantitativos")
        return
      end
      
      if resultado.to_f <= 0
        errors.add(:resultado, "deve ser maior que 0")
      end
    end
  end
end