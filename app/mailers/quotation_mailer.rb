class QuotationMailer < ApplicationMailer
  require 'open-uri'
  def new_quotation(quotation, reactivate = false)
    @reactivate = reactivate
    @quotation = quotation
    attachments[@quotation.quotation_document.document_file_name] = (Rails.env.production? ? open( URI.parse(@quotation.quotation_document.try(:document).expiring_url(10))).read : File.read( @quotation.quotation_document.document.path ))
    attachments['Manual Instalación.pdf'] = File.read("#{Rails.root}/public/resources/instalation_miele.pdf") if @quotation.quotation_products.to_install.size > 0
    attachments['Términos y Condiciones.pdf'] = File.read("#{Rails.root}/public/resources/terminos_y_condiciones_miele_2023.pdf")
    mail to: @quotation.email , subject: (@reactivate ? "Reactivación exitosa de Cotización #{@quotation.code}" : "Confirmación exitosa de tu cotización N° #{ @quotation.id }")
  end

  def change_state(quotation, is_for_miele = false)
    @is_for_miele = is_for_miele
  	@quotation = quotation
  	@recipients = @quotation.get_recipients(@is_for_miele)
    @subject = @quotation.get_subject(@is_for_miele)
  	@template = @quotation.get_state.downcase.gsub(' ', '_')
    if !Rails.env.test? and @quotation.get_state == "En preparación" and @quotation.quotation_document
      attachments[@quotation.quotation_document.document_file_name] = (Rails.env.production? ? open( URI.parse(@quotation.quotation_document.try(:document).expiring_url(10))).read : File.read( @quotation.quotation_document.document.path ))
    end
    mail to: @recipients, subject: @subject, template_path: 'quotation_mailer', template_name: @template
  end

  def payment_notification(quotation, payment)
    @payment_subject = EmailAddressee.where(process:'Nuevo pago').joins(:user).pluck(:email)
    @quotation = quotation
    @payment = payment
    mail to: @payment_subject.push(@quotation.user.email), subject: "[Webpay] Comprobante de pago de cotización #{@quotation.code} - #{@quotation.name} #{@quotation.lastname}"
  end

  def new_payment_method(quotation, payment)
    @payment_subject = EmailAddressee.where(process:'Nuevo pago').joins(:user).pluck(:email)
    @quotation = quotation
    @payment = payment
    mail to: @payment_subject, subject: "[AVISO nuevo método de pago #{@quotation.code}] Mielecustomers.cl"
  end

  def new_payment_added(quotation, payment)
    @quotation = quotation
    @payment = payment

    recipients_arr = []
    # Commented due to a change of requirement
    # User.all.each do |user|
    #   user.custom_roles.each { |custom_role| recipients_arr << user.email if custom_role.role.name == "Manager Finanzas" }
    # end

    EmailAddressee.where(process: 'Nuevo pago').each { |ea| recipients_arr << ea.user.email }
    recipients = recipients_arr.uniq.join(", ")

    mail to: recipients, subject: "[AVISO Nuevo pago pendiente de validar en la cotización #{@quotation.code}] Mielecustomers.cl"
  end

  def payment_validated(quotation, payment, user)
    @quotation = quotation
    @payment = payment
    @user = user

    recipients_arr = []
    EmailAddressee.where(process: 'Manager Proyectos').each { |ea| recipients_arr << ea.user.email }
    recipients = recipients_arr.uniq.join(", ")

    mail to: recipients, subject: "[AVISO Pago aprobado en la cotización #{@quotation.code}] Mielecustomers.cl"
  end

  def dispatch_validated(quotation, user)
    @quotation = quotation
    @user = user

    recipients_arr = []
    EmailAddressee.where(process: 'Despacho').each { |ea| recipients_arr << ea.user.email }
    recipients = recipients_arr.uniq.join(", ")

    mail to: recipients, subject: "[AVISO Despacho validado en la cotización #{@quotation.code}] Mielecustomers.cl"
  end

  def installation_service_created(quotation, sheet)
    @quotation = quotation
    @sheet = sheet
    
    recipients_arr = ["onlineshop@miele.cl"]
    recipients = recipients_arr.join(", ")

    mail to: recipients, subject: "[AVISO Servicio de instalación con folio #{@sheet} de la cotización #{@quotation.code} creado en Tickets] Mielecustomers.cl"
  end

  def dispatch_validated_for_customer(quotation)
    @quotation = quotation
    recipient = @quotation.email
    @customer_name = @quotation.customer_name

    mail to: recipient, subject: "[AVISO Un envío de la cotización #{@quotation.code} ha sido aprobado] Mielecustomers.cl"
  end

  def expire_reminder(quotation)
    @quotation = quotation
    mail to: @quotation.user.email, subject: "Proximidad vencimiento de cotización #{@quotation.code} Mielecustomers.cl"
  end

  def instalation_reminder(quotations_id)
    @quotations = Quotation.where(id: quotations_id)
    @recipients = EmailAddressee.where(process:'Instalación').joins(:user).pluck(:email)
    mail to: @recipients, subject: "[Fecha Próxima Instalación] Mielecustomers.cl"
  end

  def finance_reminder(quotations_id)
    @quotations = Quotation.where(id: quotations_id)
    @recipients = EmailAddressee.where(process:'En preparación').joins(:user).pluck(:email)
    mail to: @recipients, subject: "[Fecha Próximos Despachos] Mielecustomers.cl"
  end

  def warehouse_check(quotation, for_miele)
    @quotation = quotation
    @for_miele = for_miele
    @recipients = (@for_miele ? EmailAddressee.where(process:'En curso').joins(:user).pluck(:email) : @quotation.email)
    mail to: @recipients, subject: (@for_miele ? "[AVISO de 180 días corridos de Almacenaje cumplidos] Mielecustomers.cl" : "[Miele Chile Aviso IMPORTANTE de Almacenaje por Finalizar]")
  end

  def project_closed(quotation)
    @quotation = quotation
    @recipients = EmailAddressee.where(process:'Nuevo pago').joins(:user).pluck(:email)
    mail to: @recipients, subject: '[Aviso de venta de Proyectos] Mielecustomers.cl'
  end

  def reject_quotation(quotation)
    @quotation = quotation
    @recipients = EmailAddressee.where(process:'Nuevo pago').joins(:user).pluck(:email)
    mail to: @recipients, subject: "[RECHAZO Cotización] N° #{(@quotation.is_retail? ? @quotation.oc_number : @quotation.code)}"
  end

  def change_estimated_date(quotation, changed_date, recipients)
    @quotation = quotation
    @changed_date = changed_date
    mail to: recipients, subject: "Cambio en #{changed_date} de la cotización N° #{(@quotation.is_retail? ? @quotation.oc_number : @quotation.code)}"
  end

  def dispatch_configuration_alert(quotation, recipients = User.finance_roles_emails)
    @quotation = quotation
    mail to: recipients, subject: "Se ha ingresado una nueva configuración de envios para la cotización N° #{@quotation.code}"
  end

  def finish_visit_alert(quotation_code, dispatch_number, quotation_id)
    @quotation_code = quotation_code
    @dispatch_number = dispatch_number
    @visit_report_url = +Rails.application.secrets.BASE_APP + "/quotations/#{quotation_id.to_s}/" 
    recipients = "raul.salas@miele.com, onlineshop@miele.cl"
    mail to: recipients, subject: "AVISO: Cotización #{quotation_code} - Grupo de envío #{dispatch_number} finalizado"
  end
end
