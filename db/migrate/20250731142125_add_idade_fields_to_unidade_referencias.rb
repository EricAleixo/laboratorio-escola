class AddIdadeFieldsToUnidadeReferencias < ActiveRecord::Migration[7.1]
  def change
    add_column :unidade_referencias, :idade_minima, :integer, null: false, default: 0
    add_column :unidade_referencias, :idade_maxima, :integer, null: false, default: 120
  end
end
