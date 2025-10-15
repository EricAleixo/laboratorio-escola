class ExamePacientesController < ApplicationController
  before_action :set_exame_paciente, only: [:show, :edit, :update, :destroy, :atualizar_resultado]

  def index
    # Buscar todos os pacientes primeiro
    pacientes = Paciente.all.order(:nome)
    
    # Aplicar filtros de busca nos pacientes
    if params[:search_paciente].present?
      pacientes = pacientes.where("LOWER(pacientes.nome) LIKE ?", "%#{params[:search_paciente].downcase}%")
    end
    
    # Buscar exames para os pacientes filtrados
    exame_pacientes = ExamePaciente.includes(:paciente, :exame)
                                   .where(paciente: pacientes)
                                   .order(data_exame: :desc)
    
    # Aplicar filtro de exame se presente
    if params[:search_exame].present?
      exame_pacientes = exame_pacientes.joins(:exame)
                                      .where("LOWER(exames.nome) LIKE ?", 
                                             "%#{params[:search_exame].downcase}%")
      # Se há filtro de exame, só mostrar pacientes que têm esse exame
      pacientes = pacientes.joins(:exame_pacientes => :exame)
                           .where("LOWER(exames.nome) LIKE ?", 
                                  "%#{params[:search_exame].downcase}%")
                           .distinct
    end
    
    # Busca geral (mantida para compatibilidade)
    if params[:search].present?
      pacientes_com_busca = pacientes.where("LOWER(pacientes.nome) LIKE ?", "%#{params[:search].downcase}%")
      pacientes_com_exames = pacientes.joins(:exame_pacientes => :exame)
                                     .where("LOWER(exames.nome) LIKE ?", 
                                            "%#{params[:search].downcase}%")
                                     .distinct
      pacientes = pacientes_com_busca.or(pacientes_com_exames)
      
      exame_pacientes = exame_pacientes.joins(:exame)
                                      .where("LOWER(exames.nome) LIKE ?", 
                                             "%#{params[:search].downcase}%")
    end
    
    # Criar hash com todos os pacientes, incluindo os sem exames
    @pacientes_com_exames = {}
    pacientes.each do |paciente|
      @pacientes_com_exames[paciente] = exame_pacientes.select { |ep| ep.paciente_id == paciente.id }
    end
  end

  def show
  end

  def emitir_exames
    @paciente = Paciente.find(params[:paciente_id])
    @exames = @paciente.exame_pacientes.includes(:exame).order(:data_exame)
    @numero_os = sprintf('%03d-%06d-%03d', rand(999), rand(999999), rand(999))
  end

  def confirmar_emissao
    @paciente = Paciente.find(params[:paciente_id])
    @exames = @paciente.exame_pacientes
    @exames.update_all(emitido: true)
    redirect_to root_path, notice: "Emitido com sucesso!"
  end

  def preview_pdf
    @paciente = Paciente.find(params[:paciente_id])
    @exames = @paciente.exame_pacientes.includes(exame: { unidade_referencias: :unidade_medida }).order(:data_exame)
    @numero_os = sprintf('%03d-%06d-%03d', rand(999), rand(999999), rand(999))
  end
  
  def exames_pdf
    @paciente = Paciente.find(params[:paciente_id])
    @exames = @paciente.exame_pacientes.includes(:exame).order(:data_exame)
    @numero_os = sprintf('%03d-%06d-%03d', rand(999), rand(999999), rand(999))
    
    respond_to do |format|
      format.pdf do
        pdf = RelatorioExamesPdf.new(@paciente, @exames, @numero_os)
        send_data pdf.render, 
                  filename: "exames_#{@paciente.nome.parameterize}_#{Date.current.strftime('%Y%m%d')}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def new
    @exame_paciente = ExamePaciente.new
    @exames = Exame.ativos.order(:nome)
  end

  def registrar_resultados
    @paciente = Paciente.find(params[:paciente_id])
    @exame_pacientes = @paciente.exame_pacientes.includes(:exame).order(:id)
  end

  def atualizar_resultado
    if @exame_paciente.update(
      resultado: params[:resultado],
      observacoes: params[:observacoes]
    )
      render json: { success: true }
    else
      render json: { success: false, errors: @exame_paciente.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    @exames = Exame.ativos.order(:nome)
    
    # Validar se foram selecionados exames
    exame_ids = params[:exame_paciente][:exame_ids]&.reject(&:blank?)
    
    if exame_ids.blank?
      @exame_paciente = ExamePaciente.new
      @exame_paciente.errors.add(:base, "Selecione pelo menos um exame")
      return render :new, status: :unprocessable_entity
    end
    
    # Validar dados do paciente
    paciente_params = params[:exame_paciente][:novo_paciente]
    if paciente_params.blank?
      @exame_paciente = ExamePaciente.new
      @exame_paciente.errors.add(:base, "Dados do paciente são obrigatórios")
      return render :new, status: :unprocessable_entity
    end
    
    paciente_temp = Paciente.new(paciente_params.permit(:nome, :data_nascimento, :sexo))
    
    unless paciente_temp.valid?
      @exame_paciente = ExamePaciente.new
      paciente_temp.errors.full_messages.each { |msg| @exame_paciente.errors.add(:base, "Paciente: #{msg}") }
      return render :new, status: :unprocessable_entity
    end
    
    # Criar paciente e exames em uma transação
    ActiveRecord::Base.transaction do
      # Criar o paciente
      paciente = Paciente.create!(paciente_params.permit(:nome, :data_nascimento, :sexo))
      
      # Criar um ExamePaciente para cada exame selecionado
      exames_criados = 0
      data_atual = Date.current
      
      exame_ids.each do |exame_id|
        exame_paciente = ExamePaciente.new(
          paciente_id: paciente.id,
          exame_id: exame_id,
          data_exame: data_atual
        )
        
        unless exame_paciente.save
          # Se falhar, fazer rollback e mostrar erro
          exame_paciente.errors.full_messages.each do |msg|
            @exame_paciente = ExamePaciente.new
            @exame_paciente.errors.add(:base, msg)
          end
          raise ActiveRecord::Rollback
        end
        
        exames_criados += 1
      end
      
      # Sucesso - redirecionar para tela de registro de resultados
      redirect_to registrar_resultados_exame_pacientes_path(paciente_id: paciente.id),
                  notice: "Paciente cadastrado com sucesso! Agora registre os resultados dos exames."
      return
    end
    
    # Se chegou aqui, houve rollback
    @exame_paciente ||= ExamePaciente.new
    render :new, status: :unprocessable_entity
    
  rescue ActiveRecord::RecordInvalid => e
    @exame_paciente = ExamePaciente.new
    @exame_paciente.errors.add(:base, e.message)
    render :new, status: :unprocessable_entity
  end

  def edit
    @exames = Exame.ativos.order(:nome)
  end

  def update
    # Se o exame for qualitativo e vier resultado_qualitativo, usar ele como resultado
    if params[:exame_paciente][:resultado_qualitativo].present?
      @exame_paciente.resultado = params[:exame_paciente][:resultado_qualitativo]
    end
    
    if @exame_paciente.update(exame_paciente_params)
      redirect_to @exame_paciente, notice: 'Exame do paciente atualizado com sucesso.'
    else
      @exames = Exame.ativos.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exame_paciente.destroy
    redirect_to exame_pacientes_path, notice: 'Exame do paciente excluído com sucesso.'
  end

  private

  def set_exame_paciente
    @exame_paciente = ExamePaciente.find(params[:id])
  end

  def exame_paciente_params
    params.require(:exame_paciente).permit(:exame_id, :paciente_id, :data_exame, :resultado, :observacoes)
  end
end