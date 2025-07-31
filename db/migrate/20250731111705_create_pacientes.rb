class CreatePacientes < ActiveRecord::Migration[7.1]
  def change
    create_table :pacientes do |t|
      t.string :nome, null: false
      t.date :data_nascimento, null: false
      t.string :sexo, null: false, limit: 1

      t.timestamps
    end
    
    add_index :pacientes, :nome
    add_index :pacientes, :data_nascimento
  end
end
