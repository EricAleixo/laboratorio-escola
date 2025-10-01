require 'prawn'
require 'prawn/table'

class RelatorioExamesPdf < Prawn::Document
  def initialize(paciente, exames, numero_os)
    super(top_margin: 70)
    @paciente = paciente
    @exames = exames
    @numero_os = numero_os
    
    font "Helvetica"
    
    build_header
    build_exams_results
    build_footer
  end

  private

  def build_header
    # Logo mockado
    bounding_box([0, cursor], width: 150, height: 60) do
      fill_color "FF8C00"
      fill_circle [30, 30], 25
      
      fill_color "000000"
      font_size 8
      text_box "LAB", at: [22, 35], width: 16, align: :center, style: :bold
      
      font_size 16
      fill_color "0066CC"
      text_box "Laboratório Escola", at: [70, 45], width: 200, style: :bold
      
      font_size 10
      fill_color "666666"
      text_box "L A B O R A T Ó R I O S", at: [70, 25], width: 200
    end
    
    # Informações do paciente - layout em duas colunas como na pré-visualização
    bounding_box([0, cursor - 80], width: bounds.width, height: 80) do
      # Coluna esquerda
      bounding_box([0, cursor], width: bounds.width / 2 - 10, height: 80) do
        font_size 9
        fill_color "000000"
        
        text "O.S.: #{@numero_os}"
        text "Sr(a): #{@paciente.nome.upcase}"
        text "Solicitante: Sem solicitação Médica"
      end
      
      bounding_box([bounds.width / 2 + 10, cursor + 80], width: bounds.width / 2 - 10, height: 80) do
        font_size 9
        fill_color "000000"
        
        text "Data Atendimento: #{Date.current.strftime('%d/%m/%Y')}"
        text "Unidade: Laboratório Escola"
        text "Idade: #{@paciente.idade} anos"
        text "Convênio: Particular"
      end
    end
    
    move_down 40
    stroke_horizontal_rule
    move_down 20
  end

  def build_exams_results
    @exames.group_by(&:exame).each do |exame, exame_pacientes|
      build_exam_section(exame, exame_pacientes)
      move_down 20
    end
  end

  def build_exam_section(exame, exame_pacientes)
    font_size 12
    fill_color "000000"
    text exame.nome.upcase, style: :bold
    move_down 10
    
    exam_data = [
      ["Parâmetro", "Resultado", "Unidade", "Valores de Referência", "Observações"]
    ]
    
    exame_pacientes.each do |exame_paciente|
      ref = exame_paciente.unidade_referencia
      
      # Valores de referência
      referencia_texto = if ref
        "#{ref.valor_minimo} a #{ref.valor_maximo}\n- #{ref.sexo == 'M' ? 'Masculino' : (ref.sexo == 'F' ? 'Feminino' : 'Ambos')}"
      else
        "Conforme padrão"
      end
      
      exam_data << [
        exame.nome,
        exame_paciente.resultado || "Normal",
        ref&.unidade_medida&.nome || "",
        referencia_texto,
        exame_paciente.observacoes || ""
      ]
    end
    
    font_size 9
    table(exam_data, 
          column_widths: [120, 60, 40, 100, 80],
          header: true) do
      row(0).font_style = :bold
      row(0).background_color = "F0F0F0"
      cells.borders = [:top, :bottom, :left, :right]
      cells.padding = 6
      cells.size = 9
    end
  end

  def build_footer
    move_down 30

    stroke_horizontal_rule
    move_down 15
    
    font_size 8
    fill_color "666666"
    
    text "* ATENÇÃO: NOVO LAYOUT A PARTIR DE 09/10/2024", style: :bold
    text "* REFERÊNCIA: PROGRAMA NACIONAL DE CONTROLE DE QUALIDADE (PNCQ)", style: :bold
    
    move_down 10
    
    bounding_box([0, cursor], width: bounds.width, height: 30) do
      bounding_box([0, cursor], width: bounds.width / 2 - 10, height: 30) do
        font_size 7
        text "Método: Contagem Automatizada por Citometria de Fluxo e Avaliação em Microscopia", style: :bold
        text "Coleta: #{Date.current.strftime('%d/%m/%Y')} - 10:05", style: :bold
      end
      
      bounding_box([bounds.width / 2 + 10, cursor + 30], width: bounds.width / 2 - 10, height: 30) do
        font_size 7
        text "Liberação: #{Date.current.strftime('%d/%m/%Y')} - 15:54", style: :bold, align: :right
        text "Material: Sangue Total", style: :bold, align: :right
      end
    end
  end
end
