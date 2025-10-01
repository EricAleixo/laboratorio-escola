class AddEmitidoToExamePaciente < ActiveRecord::Migration[7.1]
  def change
    add_column :exame_pacientes, :emitido, :boolean
    add_index :exame_pacientes, :emitido
  end
end
