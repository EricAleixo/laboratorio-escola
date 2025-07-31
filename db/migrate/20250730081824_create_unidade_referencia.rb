class CreateUnidadeReferencia < ActiveRecord::Migration[7.1]
  def change
    create_table :unidade_referencias do |t|
      t.references :exame, null: false, foreign_key: true
      t.references :unidade_medida, null: false, foreign_key: true
      t.decimal :valor_minimo
      t.decimal :valor_maximo
      t.string :sexo

      t.timestamps
    end
  end
end
