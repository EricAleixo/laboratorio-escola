class Historico < ApplicationRecord
  belongs_to :paciente
  belongs_to :exame_paciente
end
