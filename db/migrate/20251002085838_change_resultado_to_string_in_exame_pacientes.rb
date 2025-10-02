class ChangeResultadoToStringInExamePacientes < ActiveRecord::Migration[7.0]
  def change
    change_column :exame_pacientes, :resultado, :string
  end
end