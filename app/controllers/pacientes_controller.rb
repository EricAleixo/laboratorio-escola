class PacientesController < ApplicationController
  before_action :set_paciente, only: [:show, :edit, :update, :destroy, :adicionar_exame]

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

  private

  def set_paciente
    paciente_id = params[:id] || params[:paciente_id]
    @paciente = Paciente.find(paciente_id)
  end

  def paciente_params
    params.require(:paciente).permit(:nome, :data_nascimento, :sexo)
  end
end
