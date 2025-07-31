class CreateExamePacientes < ActiveRecord::Migration[7.1]
  def change
    create_table :exame_pacientes do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :exame, null: false, foreign_key: true
      t.date :data_exame, null: false
      t.decimal :resultado, null: false, precision: 10, scale: 2
      t.text :observacoes

      t.timestamps
    end
    
    add_index :exame_pacientes, :data_exame
    add_index :exame_pacientes, [:paciente_id, :exame_id]
  end
end
