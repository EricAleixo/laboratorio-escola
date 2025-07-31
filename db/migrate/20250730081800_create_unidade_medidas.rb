class CreateUnidadeMedidas < ActiveRecord::Migration[7.1]
  def change
    create_table :unidade_medidas do |t|
      t.string :nome
      t.string :simbolo

      t.timestamps
    end
  end
end
