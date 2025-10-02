class ExamePacientesController < ApplicationController
  before_action :set_exame_paciente, only: [:show, :edit, :update, :destroy]

  def index
    # Buscar todos os pacientes primeiro
    pacientes = Paciente.all.order(:nome)
    
    # Aplicar filtros de busca nos pacientes
    if params[:search_paciente].present?
      pacientes = pacientes.where("LOWER(nome) LIKE ?", "%#{params[:search_paciente].downcase}%")
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
      pacientes_com_busca = pacientes.where("LOWER(nome) LIKE ?", "%#{params[:search].downcase}%")
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

  def create
  @exame_paciente = ExamePaciente.new(exame_paciente_params)
  @exames = Exame.ativos.order(:nome)
  
  # Se o exame for qualitativo e vier resultado_qualitativo, usar ele como resultado
  if params[:exame_paciente][:resultado_qualitativo].present?
    @exame_paciente.resultado = params[:exame_paciente][:resultado_qualitativo]
  end
  
  # Verifica se é um paciente existente ou novo
  if params[:exame_paciente][:novo_paciente].present?
    # Criação de novo paciente
    paciente_temp = Paciente.new(params[:exame_paciente][:novo_paciente].permit(:nome, :data_nascimento, :sexo))
    
    unless paciente_temp.valid?
      paciente_temp.errors.full_messages.each { |msg| @exame_paciente.errors.add(:base, "Paciente: #{msg}") }
      return render :new, status: :unprocessable_entity
    end
    
    ActiveRecord::Base.transaction do
      paciente = Paciente.create!(params[:exame_paciente][:novo_paciente].permit(:nome, :data_nascimento, :sexo))
      @exame_paciente.paciente_id = paciente.id
      
      unless @exame_paciente.valid?
        raise ActiveRecord::Rollback
      end
      
      unless @exame_paciente.save
        raise ActiveRecord::Rollback
      end
    end
  else
    # Paciente existente (vindo do formulário de adicionar exame)
    unless @exame_paciente.valid?
      return render :new, status: :unprocessable_entity
    end
    
    unless @exame_paciente.save
      return render :new, status: :unprocessable_entity
    end
  end
  
  # Redireciona baseado no contexto
  if params[:exame_paciente][:novo_paciente].present?
    # Novo paciente - redireciona para o exame
    redirect_to @exame_paciente, notice: 'Exame do paciente criado com sucesso.'
  else
    # Paciente existente - redireciona para o paciente
    redirect_to paciente_path(@exame_paciente.paciente), notice: 'Exame adicionado com sucesso.'
  end
  rescue ActiveRecord::Rollback
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.each { |msg| @exame_paciente.errors.add(:base, msg) }
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
