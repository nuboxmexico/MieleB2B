class QuotationState < ApplicationRecord
	scope :finance, -> {where.not(name: ["Enviada", "Ingresada", "Cancelada", "Vencida","En Negociación", "Lead"])}
	scope :dispatcher, -> {where.not(name: ["Enviada", "Ingresada", "Cancelada", "Vencida", "En curso", "Pendiente","En Negociación", "Lead"])}
	scope :instalator, -> {where(name: ["En preparación", "Despachado","Entrega Pendiente","Por instalar","Instalado", "Instalación Pendiente", "Por activar", "Productos activados", "Despachos e Instalaciones"])}
	scope :in_progress, -> {where.not(name: ["Enviada", "Cerrado", "Ingresada", "Cancelada", "Vencida","En Negociación","Lead"])}
	scope :for_commission, -> {where.not(name: ["Enviada", "Ingresada", "Cancelada", "Vencida", "En curso", "Pendiente","En Negociación"])}
	scope :project, -> {where(name: ["Ingresada", "Cerrado", "En Negociación", "En curso", "Vencida", "Por activar","Productos activados"])}
  scope :edit_estimated_dates, -> {where(stage: [1, 2])}
	has_many :quotations
end
