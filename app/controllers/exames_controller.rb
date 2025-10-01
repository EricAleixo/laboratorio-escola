class ExamesController < ApplicationController
  before_action :set_exame, only: [:show, :edit, :update, :destroy]

  def index
    @exames = Exame.all.order(:nome)
    
    if params[:search].present?
      @exames = @exames.where("LOWER(nome) LIKE ?", "%#{params[:search].downcase}%")
    end
  end

  def show
  end

  def new
    @exame = Exame.new
  end

  def create
    @exame = Exame.new(exame_params)

    if @exame.tipo == 'qualitativo'
      @exame.opcoes_qualitativo = ['Presente', 'Ausente']
    end
    
    if @exame.save
      redirect_to @exame, notice: 'Exame criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update

    if @exame.tipo == 'qualitativo'
      @exame.opcoes_qualitativo = ['Presente', 'Ausente']
    end

    if @exame.update(exame_params)
      redirect_to @exame, notice: 'Exame atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exame.destroy
    redirect_to exames_url, notice: 'Exame excluído com sucesso.'
  end

  private

  def set_exame
    @exame = Exame.find(params[:id])
  end

  def exame_params
    params.require(:exame).permit(:nome, :descricao, :ativo, :tipo)
  end
end
