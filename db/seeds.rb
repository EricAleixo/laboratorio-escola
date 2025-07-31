# Criar unidades de medida
puts "Criando unidades de medida..."

unidades = [
  { nome: "Miligramas por decilitro", simbolo: "mg/dL" },
  { nome: "Milimoles por litro", simbolo: "mmol/L" },
  { nome: "Gramas por litro", simbolo: "g/L" },
  { nome: "Microgramas por decilitro", simbolo: "µg/dL" },
  { nome: "Unidades por litro", simbolo: "U/L" },
  { nome: "Mililitros por minuto", simbolo: "mL/min" },
  { nome: "Porcentagem", simbolo: "%" },
  { nome: "Células por microlitro", simbolo: "células/µL" }
]

unidades.each do |unidade_data|
  UnidadeMedida.find_or_create_by!(simbolo: unidade_data[:simbolo]) do |um|
    um.nome = unidade_data[:nome]
  end
end

puts "Unidades de medida criadas!"

# Criar exames
puts "Criando exames..."

exames = [
  { 
    nome: "Glicemia em Jejum", 
    descricao: "Mede a concentração de glicose no sangue após um período de jejum de pelo menos 8 horas.",
    ativo: true
  },
  { 
    nome: "Hemoglobina Glicada (HbA1c)", 
    descricao: "Mede a média da glicose no sangue nos últimos 2-3 meses.",
    ativo: true
  },
  { 
    nome: "Colesterol Total", 
    descricao: "Mede a quantidade total de colesterol no sangue.",
    ativo: true
  },
  { 
    nome: "HDL Colesterol", 
    descricao: "Mede o colesterol de alta densidade (colesterol bom).",
    ativo: true
  },
  { 
    nome: "LDL Colesterol", 
    descricao: "Mede o colesterol de baixa densidade (colesterol ruim).",
    ativo: true
  },
  { 
    nome: "Triglicerídeos", 
    descricao: "Mede a quantidade de triglicerídeos no sangue.",
    ativo: true
  },
  { 
    nome: "Creatinina", 
    descricao: "Mede a função renal através da creatinina no sangue.",
    ativo: true
  },
  { 
    nome: "Hemograma Completo", 
    descricao: "Avalia as células do sangue (hemácias, leucócitos e plaquetas).",
    ativo: true
  }
]

exames.each do |exame_data|
  Exame.find_or_create_by!(nome: exame_data[:nome]) do |e|
    e.descricao = exame_data[:descricao]
    e.ativo = exame_data[:ativo]
  end
end

puts "Exames criados!"

# Criar unidades de referência
puts "Criando unidades de referência..."

# Glicemia em Jejum
glicemia = Exame.find_by(nome: "Glicemia em Jejum")
mg_dl = UnidadeMedida.find_by(simbolo: "mg/dL")
mmol_l = UnidadeMedida.find_by(simbolo: "mmol/L")

if glicemia && mg_dl
  UnidadeReferencia.find_or_create_by!(exame: glicemia, unidade_medida: mg_dl, sexo: 'A') do |ur|
    ur.valor_minimo = 70
    ur.valor_maximo = 99
  end
end

if glicemia && mmol_l
  UnidadeReferencia.find_or_create_by!(exame: glicemia, unidade_medida: mmol_l, sexo: 'A') do |ur|
    ur.valor_minimo = 3.9
    ur.valor_maximo = 5.5
  end
end

# HbA1c
hb1ac = Exame.find_by(nome: "Hemoglobina Glicada (HbA1c)")
porcentagem = UnidadeMedida.find_by(simbolo: "%")

if hb1ac && porcentagem
  UnidadeReferencia.find_or_create_by!(exame: hb1ac, unidade_medida: porcentagem, sexo: 'A') do |ur|
    ur.valor_minimo = 4.0
    ur.valor_maximo = 5.6
  end
end

# Colesterol Total
colesterol_total = Exame.find_by(nome: "Colesterol Total")

if colesterol_total && mg_dl
  UnidadeReferencia.find_or_create_by!(exame: colesterol_total, unidade_medida: mg_dl, sexo: 'A') do |ur|
    ur.valor_minimo = 0
    ur.valor_maximo = 200
  end
end

# HDL Colesterol
hdl = Exame.find_by(nome: "HDL Colesterol")

if hdl && mg_dl
  # Masculino
  UnidadeReferencia.find_or_create_by!(exame: hdl, unidade_medida: mg_dl, sexo: 'M') do |ur|
    ur.valor_minimo = 40
    ur.valor_maximo = 60
  end
  
  # Feminino
  UnidadeReferencia.find_or_create_by!(exame: hdl, unidade_medida: mg_dl, sexo: 'F') do |ur|
    ur.valor_minimo = 50
    ur.valor_maximo = 60
  end
end

# LDL Colesterol
ldl = Exame.find_by(nome: "LDL Colesterol")

if ldl && mg_dl
  UnidadeReferencia.find_or_create_by!(exame: ldl, unidade_medida: mg_dl, sexo: 'A') do |ur|
    ur.valor_minimo = 0
    ur.valor_maximo = 100
  end
end

# Triglicerídeos
triglicerideos = Exame.find_by(nome: "Triglicerídeos")

if triglicerideos && mg_dl
  UnidadeReferencia.find_or_create_by!(exame: triglicerideos, unidade_medida: mg_dl, sexo: 'A') do |ur|
    ur.valor_minimo = 0
    ur.valor_maximo = 150
  end
end

# Creatinina
creatinina = Exame.find_by(nome: "Creatinina")

if creatinina && mg_dl
  # Masculino
  UnidadeReferencia.find_or_create_by!(exame: creatinina, unidade_medida: mg_dl, sexo: 'M') do |ur|
    ur.valor_minimo = 0.7
    ur.valor_maximo = 1.3
  end
  
  # Feminino
  UnidadeReferencia.find_or_create_by!(exame: creatinina, unidade_medida: mg_dl, sexo: 'F') do |ur|
    ur.valor_minimo = 0.6
    ur.valor_maximo = 1.1
  end
end

puts "Unidades de referência criadas!"
puts "Seed concluído com sucesso!"
