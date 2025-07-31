class ExamePacientesController < ApplicationController
  before_action :set_exame_paciente, only: [:show, :edit, :update, :destroy]

  def index
    @exame_pacientes = ExamePaciente.includes(:paciente, :exame).order(data_exame: :desc)
    
    if params[:search].present?
      @exame_pacientes = @exame_pacientes.joins(:paciente, :exame)
                                        .where("LOWER(pacientes.nome) LIKE ? OR LOWER(exames.nome) LIKE ?", 
                                               "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
    end
  end

  def show
  end

  def new
    @exame_paciente = ExamePaciente.new
    @exames = Exame.ativos.order(:nome)
  end

  def create
    paciente = Paciente.new(params[:exame_paciente][:novo_paciente].permit(:nome, :data_nascimento, :sexo))
    if paciente.save
      @exame_paciente = ExamePaciente.new(exame_paciente_params.merge(paciente_id: paciente.id))
    else
      @exame_paciente = ExamePaciente.new(exame_paciente_params)
      @exames = Exame.ativos.order(:nome)
      paciente.errors.full_messages.each { |msg| @exame_paciente.errors.add(:base, "Paciente: #{msg}") }
      return render :new, status: :unprocessable_entity
    end

    if @exame_paciente.save
      redirect_to @exame_paciente, notice: 'Exame do paciente criado com sucesso.'
    else
      @exames = Exame.ativos.order(:nome)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @exames = Exame.ativos.order(:nome)
  end

  def update
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
    params.require(:exame_paciente).permit(:exame_id, :data_exame, :resultado, :observacoes)
  end
end
