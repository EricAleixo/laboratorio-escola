class UnidadeReferenciasController < ApplicationController
  before_action :set_exame
  before_action :set_unidade_referencia, only: [:show, :edit, :update, :destroy]

  def index
    @unidade_referencias = @exame.unidade_referencias.includes(:unidade_medida)
  end

  def show
  end

  def new
    @unidade_referencia = @exame.unidade_referencias.build
  end

  def create
    @unidade_referencia = @exame.unidade_referencias.build(unidade_referencia_params)
    
    if @unidade_referencia.save
      redirect_to exame_path(@exame), notice: 'Unidade de referência criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @unidade_referencia.update(unidade_referencia_params)
      redirect_to exame_path(@exame), notice: 'Unidade de referência atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unidade_referencia.destroy
    redirect_to exame_path(@exame), notice: 'Unidade de referência excluída com sucesso.'
  end

  private

  def set_exame
    @exame = Exame.find(params[:exame_id])
  end

  def set_unidade_referencia
    @unidade_referencia = @exame.unidade_referencias.find(params[:id])
  end

  def unidade_referencia_params
    params.require(:unidade_referencia).permit(:unidade_medida_id, :valor_minimo, :valor_maximo, :sexo, :idade_minima, :idade_maxima)
  end
end
