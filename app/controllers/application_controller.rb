class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  def index
    # Dados atuais
    @total_exames = ExamePaciente.count
    @exames_hoje = ExamePaciente.where(data_exame: Date.current).count
    @aguardando_resultado = ExamePaciente.where("resultado IS NULL OR resultado = ''").count
    @tipos_exame = Exame.count
    @ultimos_exames = ExamePaciente.includes(:paciente, :exame).order(created_at: :desc).limit(5)
    
    # Análises comparativas
    calculate_analytics
  end

  def historico
    @exames = ExamePaciente.all.includes(:paciente, :exame)
    @ultimos_exames = ExamePaciente.includes(:paciente, :exame).order(created_at: :desc).limit(5)

    # Estatísticas úteis
    exames_array = @exames.to_a
    @total_exames = exames_array.size
    @exames_aguardando = exames_array.count { |e| e.observacoes.blank? }
    @exames_emitidos = exames_array.count { |e| e.observacoes.present? }

    # Exames do mês atual e anterior
    @exames_mes_atual = ExamePaciente.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    @exames_mes_anterior = ExamePaciente.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
    @variacao_exames_mes = calculate_percentage_change(@exames_mes_anterior, @exames_mes_atual)

    # Exames aguardando esta semana e semana passada
    @aguardando_semana_atual = ExamePaciente.where("resultado IS NULL OR resultado = ''").where(created_at: Date.current.beginning_of_week..Date.current.end_of_week).count
    @aguardando_semana_anterior = ExamePaciente.where("resultado IS NULL OR resultado = ''").where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).count
    @variacao_aguardando = calculate_percentage_change(@aguardando_semana_anterior, @aguardando_semana_atual)

    # Top 5 exames do mês atual
    @top_exames_mes = ExamePaciente.joins(:exame)
      .where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
      .group('exames.nome')
      .count
      .sort_by { |_, v| -v }
      .first(5)
  
    # Filtros
    if params[:status].present?
      case params[:status]
      when 'aguardando'
        @exames = @exames.where("observacoes IS NULL OR observacoes = ''")
      when 'emitidos'
        @exames = @exames.where("observacoes IS NOT NULL AND observacoes != ''")
      end
    end

    if params[:data_inicio].present?
      @exames = @exames.where("data_exame >= ?", params[:data_inicio])
    end

    if params[:data_fim].present?
      @exames = @exames.where("data_exame <= ?", params[:data_fim])
    end

    if params[:search].present?
      @exames = @exames.joins(:paciente, :exame)
                       .where("LOWER(pacientes.nome) LIKE ? OR LOWER(exames.nome) LIKE ?", 
                              "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
    end

    @exames = @exames.order(data_exame: :desc)

    render 'historico'
  end
  
  private
  
  def calculate_analytics
    # Exames cadastrados - comparação com mês anterior
    exames_mes_atual = ExamePaciente.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    exames_mes_anterior = ExamePaciente.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
    @variacao_exames_mes = calculate_percentage_change(exames_mes_anterior, exames_mes_atual)
    
    # Exames emitidos hoje vs ontem
    exames_ontem = ExamePaciente.where(data_exame: Date.yesterday).count
    @variacao_exames_hoje = calculate_percentage_change(exames_ontem, @exames_hoje)
    
    # Aguardando resultado - comparação com semana anterior
    aguardando_semana_atual = ExamePaciente.where(
      "resultado IS NULL OR resultado = ''"
    ).where(created_at: Date.current.beginning_of_week..Date.current.end_of_week).count
    
    aguardando_semana_anterior = ExamePaciente.where(
      "resultado IS NULL OR resultado = ''"
    ).where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).count
    
    @variacao_aguardando = calculate_percentage_change(aguardando_semana_anterior, aguardando_semana_atual)
    
    # Novos tipos de exame - comparação com período anterior
    tipos_mes_atual = Exame.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    tipos_mes_anterior = Exame.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
    @novos_tipos = tipos_mes_atual
    @variacao_tipos = calculate_percentage_change(tipos_mes_anterior, tipos_mes_atual)
  end
  
  def calculate_percentage_change(old_value, new_value)
    return 0 if old_value == 0 && new_value == 0
    return 100 if old_value == 0 && new_value > 0
    return -100 if old_value > 0 && new_value == 0
    
    ((new_value.to_f - old_value.to_f) / old_value.to_f * 100).round(1)
  end

  # ... other public methods ...

  def analise_exames
    # Initialize all variables with default values to prevent nil errors
    @total_exames = ExamePaciente.count || 0
    @exames_hoje = ExamePaciente.where(data_exame: Date.current).count || 0
    @exames_semana = ExamePaciente.where(data_exame: 1.week.ago..Date.current).count || 0
    @exames_mes = ExamePaciente.where(data_exame: 1.month.ago..Date.current).count || 0
    
    # Exames por mês (últimos 6 meses)
    @exames_por_mes = ExamePaciente.group("strftime('%Y-%m', data_exame)")
                                   .where("data_exame >= ?", 6.months.ago)
                                   .count
                                   .sort_by { |k, v| k } || {}
    
    # Top 5 exames mais solicitados
    @top_exames = ExamePaciente.joins(:exame)
                               .group('exames.nome')
                               .count
                               .sort_by { |k, v| -v }
                               .first(5) || []
    
    # Distribuição por faixa etária
    @faixas_etarias = ExamePaciente.joins(:paciente)
                                   .group("CASE 
                                     WHEN pacientes.data_nascimento > ? THEN 'Criança (0-12)'
                                     WHEN pacientes.data_nascimento > ? THEN 'Adolescente (13-17)'
                                     WHEN pacientes.data_nascimento > ? THEN 'Adulto (18-59)'
                                     ELSE 'Idoso (60+)'
                                   END", 12.years.ago, 17.years.ago, 59.years.ago)
                                   .count || {}
    
    # Distribuição por sexo - ensure we always have 'M' and 'F' keys with 0 as default
    @distribuicao_sexo = ExamePaciente.joins(:paciente)
                                      .where('pacientes.sexo IS NOT NULL')
                                      .group('pacientes.sexo')
                                      .count
                                      .transform_keys(&:upcase) # Ensure case consistency
    
    # Initialize with default 0 values for 'M' and 'F' if they don't exist
    @distribuicao_sexo = { 'M' => 0, 'F' => 0 }.merge(@distribuicao_sexo || {})
  end

  def analise_emitidos
    # Inicializa as variáveis com valores padrão
    @exames_emitidos = ExamePaciente.none
    @total_emitidos = 0
    @emitidos_hoje = 0
    @emitidos_semana = 0
    @emitidos_mes = 0
    @resultados_normais = 0
    @resultados_abnormais = 0
    @top_emitidos = []
    
    # Aplica os filtros
    @exames_emitidos = ExamePaciente.where("observacoes IS NOT NULL AND observacoes != ''")
    
    if params[:data_inicio].present?
      @exames_emitidos = @exames_emitidos.where("data_exame >= ?", params[:data_inicio])
    end
    
    if params[:data_fim].present?
      @exames_emitidos = @exames_emitidos.where("data_exame <= ?", params[:data_fim])
    end
    
    # Calcula as estatísticas apenas se houver exames
    if @exames_emitidos.exists?
      @total_emitidos = @exames_emitidos.count
      @emitidos_hoje = @exames_emitidos.where(data_exame: Date.current).count
      @emitidos_semana = @exames_emitidos.where(data_exame: 1.week.ago..Date.current).count
      @emitidos_mes = @exames_emitidos.where(data_exame: 1.month.ago..Date.current).count
      
      # Análise de resultados
      exames_com_resultado = @exames_emitidos.where("resultado IS NOT NULL AND resultado != ''")
      
      exames_com_resultado.includes(:exame).each do |exame_paciente|
        situacao = exame_paciente.situacao_resultado
        case situacao
        when :normal
          @resultados_normais += 1
        when :acima, :abaixo
          @resultados_abnormais += 1
        end
      end
      
      # Top exames emitidos
      @top_emitidos = @exames_emitidos.joins(:exame)
                                    .group('exames.nome')
                                    .count
                                    .sort_by { |k, v| -v }
                                    .first(5) || []
    end
  end

  def analise_aguardando
    # Inicializa as variáveis com valores padrão
    @exames_aguardando = ExamePaciente.none
    @total_aguardando = 0
    @aguardando_vencidos = 0
    @aguardando_hoje = 0
    @aguardando_futuros = 0
    @espera_1_dia = 0
    @espera_2_7_dias = 0
    @espera_mais_7_dias = 0
    @top_aguardando = []
    
    # Aplica os filtros
    @exames_aguardando = ExamePaciente.where("observacoes IS NULL OR observacoes = ''")
    
    if params[:data_inicio].present?
      @exames_aguardando = @exames_aguardando.where("data_exame >= ?", params[:data_inicio])
    end
    
    if params[:data_fim].present?
      @exames_aguardando = @exames_aguardando.where("data_exame <= ?", params[:data_fim])
    end
    
    # Calcula as estatísticas apenas se houver exames
    if @exames_aguardando.exists?
      @total_aguardando = @exames_aguardando.count
      @aguardando_vencidos = @exames_aguardando.where("data_exame < ?", Date.current).count
      @aguardando_hoje = @exames_aguardando.where(data_exame: Date.current).count
      @aguardando_futuros = @exames_aguardando.where("data_exame > ?", Date.current).count
      
      # Análise por tempo de espera
      @espera_1_dia = @exames_aguardando.where("data_exame = ?", Date.current).count
      @espera_2_7_dias = @exames_aguardando.where("data_exame BETWEEN ? AND ?", 2.days.ago, Date.current).count
      @espera_mais_7_dias = @exames_aguardando.where("data_exame < ?", 7.days.ago).count
      
      # Top exames aguardando
      @top_aguardando = @exames_aguardando.joins(:exame)
                                        .group('exames.nome')
                                        .count
                                        .sort_by { |k, v| -v }
                                        .first(5) || []
    end
  end

  def analise_tipos
    # Inicializa todas as variáveis com valores padrão
    @total_tipos = Exame.count || 0
    @tipos_ativos = Exame.where(ativo: true).count || 0
    @tipos_inativos = Exame.where(ativo: false).count || 0
    
    # Exames por tipo (últimos 30 dias)
    @exames_por_tipo = ExamePaciente.joins(:exame)
                                    .where("data_exame >= ?", 30.days.ago)
                                    .group('exames.nome')
                                    .count
                                    .sort_by { |k, v| -v } || {}
    
    # Tipos com mais unidades de referência
    @tipos_com_referencias = Exame.joins(:unidade_referencias)
                                  .group('exames.nome')
                                  .count
                                  .sort_by { |k, v| -v } || {}
    
    # Análise de complexidade (por número de referências)
    @tipos_simples = Exame.joins(:unidade_referencias)
                          .group('exames.nome')
                          .having('COUNT(unidade_referencias.id) <= 2')
                          .count
                          .to_h || {}
    
    @tipos_complexos = Exame.joins(:unidade_referencias)
                            .group('exames.nome')
                            .having('COUNT(unidade_referencias.id) > 2')
                            .count
                            .to_h || {}
  end
end
