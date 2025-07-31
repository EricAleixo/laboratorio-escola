class CreateExames < ActiveRecord::Migration[7.1]
  def change
    create_table :exames do |t|
      t.string :nome, null: false
      t.text :descricao
      t.boolean :ativo, default: true, null: false

      t.timestamps
    end
    
    add_index :exames, :nome, unique: true
  end
end 