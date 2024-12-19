json.extract! quotation, :id, :code, :f12_number, :oc_number
json.set! :commune, quotation.try(:dispatch_commune).try(:name)
json.set! :created_at, quotation.created_at.strftime("%d/%m/%Y")
json.set! :name, quotation.customer_name