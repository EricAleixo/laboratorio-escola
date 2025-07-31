class ApplicationController < ActionController::Base
  def index
    @total_exames = Exame.count
    @exames_hoje = ExamePaciente.where(data_exame: Date.current).count
    @aguardando_resultado = ExamePaciente.where("observacoes IS NULL OR observacoes = ''").count
    @tipos_exame = Exame.count
    @ultimos_exames = ExamePaciente.includes(:paciente, :exame).order(created_at: :desc).limit(5)
  end

  def historico
    @exames = ExamePaciente.includes(:paciente, :exame)
    
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
    
    # Estatísticas
    @total_exames = @exames.count
    @exames_aguardando = @exames.where("observacoes IS NULL OR observacoes = ''").count
    @exames_emitidos = @exames.where("observacoes IS NOT NULL AND observacoes != ''").count
  end

  def analise_exames
    @total_exames = ExamePaciente.count
    @exames_hoje = ExamePaciente.where(data_exame: Date.current).count
    @exames_semana = ExamePaciente.where(data_exame: 1.week.ago..Date.current).count
    @exames_mes = ExamePaciente.where(data_exame: 1.month.ago..Date.current).count
    
    # Exames por mês (últimos 6 meses)
    @exames_por_mes = ExamePaciente.group("strftime('%Y-%m', data_exame)")
                                   .where("data_exame >= ?", 6.months.ago)
                                   .count
                                   .sort_by { |k, v| k }
    
    # Top 5 exames mais solicitados
    @top_exames = ExamePaciente.joins(:exame)
                               .group('exames.nome')
                               .count
                               .sort_by { |k, v| -v }
                               .first(5)
    
    # Distribuição por faixa etária
    @faixas_etarias = ExamePaciente.joins(:paciente)
                                   .group("CASE 
                                     WHEN pacientes.data_nascimento > ? THEN 'Criança (0-12)'
                                     WHEN pacientes.data_nascimento > ? THEN 'Adolescente (13-17)'
                                     WHEN pacientes.data_nascimento > ? THEN 'Adulto (18-59)'
                                     ELSE 'Idoso (60+)'
                                   END", 12.years.ago, 17.years.ago, 59.years.ago)
                                   .count
    
    # Distribuição por sexo
    @distribuicao_sexo = ExamePaciente.joins(:paciente)
                                      .group('pacientes.sexo')
                                      .count
  end

  def analise_emitidos
    @exames_emitidos = ExamePaciente.where("observacoes IS NOT NULL AND observacoes != ''")
    
    # Filtros
    if params[:data_inicio].present?
      @exames_emitidos = @exames_emitidos.where("data_exame >= ?", params[:data_inicio])
    end
    
    if params[:data_fim].present?
      @exames_emitidos = @exames_emitidos.where("data_exame <= ?", params[:data_fim])
    end
    
    @total_emitidos = @exames_emitidos.count
    @emitidos_hoje = @exames_emitidos.where(data_exame: Date.current).count
    @emitidos_semana = @exames_emitidos.where(data_exame: 1.week.ago..Date.current).count
    @emitidos_mes = @exames_emitidos.where(data_exame: 1.month.ago..Date.current).count
    
    # Análise de resultados
    @resultados_abnormais = @exames_emitidos.joins(:exame)
                                            .where("exame_pacientes.resultado IS NOT NULL")
                                            .select { |ep| ep.situacao_resultado == :acima || ep.situacao_resultado == :abaixo }
                                            .count
    
    @resultados_normais = @exames_emitidos.joins(:exame)
                                         .where("exame_pacientes.resultado IS NOT NULL")
                                         .select { |ep| ep.situacao_resultado == :normal }
                                         .count
    
    # Top exames emitidos
    @top_emitidos = @exames_emitidos.joins(:exame)
                                    .group('exames.nome')
                                    .count
                                    .sort_by { |k, v| -v }
                                    .first(5)
  end

  def analise_aguardando
    @exames_aguardando = ExamePaciente.where("observacoes IS NULL OR observacoes = ''")
    
    # Filtros
    if params[:data_inicio].present?
      @exames_aguardando = @exames_aguardando.where("data_exame >= ?", params[:data_inicio])
    end
    
    if params[:data_fim].present?
      @exames_aguardando = @exames_aguardando.where("data_exame <= ?", params[:data_fim])
    end
    
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
                                        .first(5)
  end

  def analise_tipos
    @total_tipos = Exame.count
    @tipos_ativos = Exame.where(ativo: true).count
    @tipos_inativos = Exame.where(ativo: false).count
    
    # Exames por tipo (últimos 30 dias)
    @exames_por_tipo = ExamePaciente.joins(:exame)
                                    .where("data_exame >= ?", 30.days.ago)
                                    .group('exames.nome')
                                    .count
                                    .sort_by { |k, v| -v }
    
    # Tipos com mais unidades de referência
    @tipos_com_referencias = Exame.joins(:unidade_referencias)
                                  .group('exames.nome')
                                  .count
                                  .sort_by { |k, v| -v }
    
    # Análise de complexidade (por número de referências)
    @tipos_simples = Exame.joins(:unidade_referencias)
                          .group('exames.nome')
                          .having('COUNT(unidade_referencias.id) <= 2')
                          .count
    
    @tipos_complexos = Exame.joins(:unidade_referencias)
                            .group('exames.nome')
                            .having('COUNT(unidade_referencias.id) > 2')
                            .count
  end
end
