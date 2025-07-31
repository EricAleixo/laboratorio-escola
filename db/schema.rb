# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_31_142125) do
  create_table "exame_pacientes", force: :cascade do |t|
    t.integer "paciente_id", null: false
    t.integer "exame_id", null: false
    t.date "data_exame", null: false
    t.decimal "resultado", precision: 10, scale: 2, null: false
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_exame"], name: "index_exame_pacientes_on_data_exame"
    t.index ["exame_id"], name: "index_exame_pacientes_on_exame_id"
    t.index ["paciente_id", "exame_id"], name: "index_exame_pacientes_on_paciente_id_and_exame_id"
    t.index ["paciente_id"], name: "index_exame_pacientes_on_paciente_id"
  end

  create_table "exames", force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.boolean "ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_exames_on_nome", unique: true
  end

  create_table "pacientes", force: :cascade do |t|
    t.string "nome", null: false
    t.date "data_nascimento", null: false
    t.string "sexo", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_nascimento"], name: "index_pacientes_on_data_nascimento"
    t.index ["nome"], name: "index_pacientes_on_nome"
  end

  create_table "unidade_medidas", force: :cascade do |t|
    t.string "nome"
    t.string "simbolo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "unidade_referencias", force: :cascade do |t|
    t.integer "exame_id", null: false
    t.integer "unidade_medida_id", null: false
    t.decimal "valor_minimo"
    t.decimal "valor_maximo"
    t.string "sexo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "idade_minima", default: 0, null: false
    t.integer "idade_maxima", default: 120, null: false
    t.index ["exame_id"], name: "index_unidade_referencias_on_exame_id"
    t.index ["unidade_medida_id"], name: "index_unidade_referencias_on_unidade_medida_id"
  end

  add_foreign_key "exame_pacientes", "exames"
  add_foreign_key "exame_pacientes", "pacientes"
  add_foreign_key "unidade_referencias", "exames"
  add_foreign_key "unidade_referencias", "unidade_medidas"
end
