class AddTipoToExames < ActiveRecord::Migration[7.1]
  def change
    add_column :exames, :tipo, :string, null: false, default: "quantitativo"
    add_column :exames, :opcoes_qualitativo, :text
  end
end
