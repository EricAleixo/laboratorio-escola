class UnidadeMedidasController < ApplicationController
  before_action :set_unidade_medida, only: [:show, :edit, :update, :destroy]

  def index
    @unidade_medidas = UnidadeMedida.all.order(:nome)
    
    if params[:search].present?
      @unidade_medidas = @unidade_medidas.where("LOWER(nome) LIKE ? OR LOWER(simbolo) LIKE ?", 
                                                 "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
    end
  end

  def show
  end

  def new
    @unidade_medida = UnidadeMedida.new
  end

  def create
    @unidade_medida = UnidadeMedida.new(unidade_medida_params)
    
    if @unidade_medida.save
      redirect_to @unidade_medida, notice: 'Unidade de medida criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @unidade_medida.update(unidade_medida_params)
      redirect_to @unidade_medida, notice: 'Unidade de medida atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unidade_medida.destroy
    redirect_to unidade_medidas_url, notice: 'Unidade de medida excluída com sucesso.'
  end

  private

  def set_unidade_medida
    @unidade_medida = UnidadeMedida.find(params[:id])
  end

  def unidade_medida_params
    params.require(:unidade_medida).permit(:nome, :simbolo)
  end
end
