class DispatchGroupMailer < ApplicationMailer

  def change_state(dispatch_group, new_state, is_for_miele = false)
    @is_for_miele = is_for_miele
    @dispatch_group = dispatch_group
    @quotation = dispatch_group.quotation
    @recipients = @quotation.get_recipients(@is_for_miele)
    @subject = @dispatch_group.notification_subject(new_state, @is_for_miele)
    @template = new_state.name.downcase.gsub(' ', '_')
    mail to: @recipients, subject: @subject, template_path: 'dispatch_group_mailer', template_name: @template
  end
end
