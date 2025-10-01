class CreateHistoricos < ActiveRecord::Migration[7.1]
  def change
    create_table :historicos do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :exame_paciente, null: false, foreign_key: true
      t.string :numero_os
      t.string :acao

      t.timestamps
    end
  end
end
