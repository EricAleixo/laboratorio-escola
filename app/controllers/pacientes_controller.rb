class PacientesController < ApplicationController
  before_action :set_paciente, only: [:show, :edit, :update, :destroy, :adicionar_exame, :criar_exames]

  def index
    @pacientes = Paciente.order(:nome)
    
    if params[:search].present?
      @pacientes = @pacientes.where("LOWER(nome) LIKE ?", "%#{params[:search].downcase}%")
    end
  end

  def show
  end

  def new
    @paciente = Paciente.new
  end

  def create
    @paciente = Paciente.new(paciente_params)
    
    if @paciente.save
      redirect_to @paciente, notice: 'Paciente criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @paciente.update(paciente_params)
      redirect_to @paciente, notice: 'Paciente atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @paciente.destroy
    redirect_to pacientes_path, notice: 'Paciente excluído com sucesso.'
  end

  def adicionar_exame
    @exame_paciente = ExamePaciente.new(paciente: @paciente)
    @exames = Exame.ativos.order(:nome)
  end

  def criar_exames
    @exames = Exame.ativos.order(:nome)
    
    # Validar se foram selecionados exames
    exame_ids = params[:exame_paciente][:exame_ids]&.reject(&:blank?)
    
    if exame_ids.blank?
      @exame_paciente = ExamePaciente.new(paciente: @paciente)
      @exame_paciente.errors.add(:base, "Selecione pelo menos um exame")
      return render :adicionar_exame, status: :unprocessable_entity
    end
    
    # Criar exames em uma transação
    exames_criados = 0
    data_atual = Date.current
    
    ActiveRecord::Base.transaction do
      exame_ids.each do |exame_id|
        exame_paciente = ExamePaciente.new(
          paciente_id: @paciente.id,
          exame_id: exame_id,
          data_exame: data_atual
        )
        
        unless exame_paciente.save
          # Se falhar, fazer rollback e mostrar erro
          @exame_paciente = ExamePaciente.new(paciente: @paciente)
          exame_paciente.errors.full_messages.each do |msg|
            @exame_paciente.errors.add(:base, msg)
          end
          raise ActiveRecord::Rollback
        end
        
        exames_criados += 1
      end
      
      # Sucesso - redirecionar para tela de registro de resultados
      redirect_to registrar_resultados_exame_pacientes_path(paciente_id: @paciente.id),
                  notice: "#{exames_criados} exame(s) adicionado(s) com sucesso! Agora registre os resultados."
      return
    end
    
    # Se chegou aqui, houve rollback
    @exame_paciente ||= ExamePaciente.new(paciente: @paciente)
    render :adicionar_exame, status: :unprocessable_entity
    
  rescue ActiveRecord::RecordInvalid => e
    @exame_paciente = ExamePaciente.new(paciente: @paciente)
    @exame_paciente.errors.add(:base, e.message)
    render :adicionar_exame, status: :unprocessable_entity
  end

  private

  def set_paciente
    paciente_id = params[:id] || params[:paciente_id]
    @paciente = Paciente.find(paciente_id)
  end

  def paciente_params
    params.require(:paciente).permit(:nome, :data_nascimento, :sexo)
  end
end