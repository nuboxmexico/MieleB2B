require 'rails_helper'
describe 'Quotation Cron', type: :feature do 
	include ActiveJob::TestHelper

	context 'task' do
		require 'rake'
		before do 
			Rake::Task.define_task(:environment)
			create(:enviada)
			create(:vencida)
			ActionMailer::Base.deliveries = []
			clear_enqueued_jobs
		end

		after do 
			Rake.application.clear
		end

		it 'Expired quotations' do 
			Timecop.freeze(Date.new(2020, 07, 01))
			quotation = create(:quotation_dispatch_retirement, expiration_date: Date.today)
			ActionMailer::Base.deliveries = []

			load Rails.root.join("lib/tasks/check_expired_quotations.rake")
			task = Rake::Task["check_expired_quotations"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(Quotation.last.get_state).to eq 'Vencida'
			Timecop.return
		end

		it 'Pending quotation to 14 days for expire' do 
			pending = create(:pendiente)
			quotation = create(:quotation_dispatch_retirement, estimated_dispatch_date: Date.today + 14.days)
			Quotation.last.update(quotation_state: pending)
			#aviso 14 dias
			ActionMailer::Base.deliveries = []

			load Rails.root.join("lib/tasks/check_pending_quotations.rake")
			task = Rake::Task["check_pending_quotations"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(enqueued_jobs.size).to eq(2)
			#expect(ActionMailer::Base.deliveries.count).to eq 1

		end

		it 'Pending quotation to 7 days for expire' do 
			pending = create(:pendiente)
			quotation = create(:quotation_dispatch_retirement, estimated_dispatch_date: Date.today + 7.days)
			Quotation.last.update(quotation_state: pending)

			ActionMailer::Base.deliveries = []

			load Rails.root.join("lib/tasks/check_pending_quotations.rake")
			task = Rake::Task["check_pending_quotations"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(enqueued_jobs.size).to eq(2)
			#expect(ActionMailer::Base.deliveries.count).to eq 1

		end

		it 'Pending without alert mailer' do 
			pending = create(:pendiente)
			quotation = create(:quotation_dispatch_retirement, estimated_dispatch_date: Date.today + 12.days)
			Quotation.last.update(quotation_state: pending)
			ActionMailer::Base.deliveries = []
			
			load Rails.root.join("lib/tasks/check_pending_quotations.rake")
			task = Rake::Task["check_pending_quotations"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(ActionMailer::Base.deliveries.count).to eq 0
		end

		it 'Check quotations for expire' do 
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(expiration_date: Date.today + 3.days)
			ActionMailer::Base.deliveries = []

			load Rails.root.join("lib/tasks/check_for_expire.rake")
			task = Rake::Task["check_for_expire"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(Quotation.last.get_state).to eq 'Enviada'
			expect(enqueued_jobs.size).to eq(2)
			#expect(ActionMailer::Base.deliveries.count).to eq 1
		end

		it 'Check quotations for install' do 
			for_install = create(:por_instalar)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: for_install, installation_date: Date.today+5.days)
			ActionMailer::Base.deliveries = []
			jobs_size = enqueued_jobs.size

			load Rails.root.join("lib/tasks/check_instalation_deadline.rake")
			task = Rake::Task["check_instalation_deadline"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(enqueued_jobs.size - jobs_size).to be 1
		end

		it 'Check quotations for dispatch' do 
			processing = create(:en_preparacion)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: processing, estimated_dispatch_date: Date.today+5.days)
			ActionMailer::Base.deliveries = []
			jobs_size = enqueued_jobs.size

			load Rails.root.join("lib/tasks/check_finance_reminder.rake")
			task = Rake::Task["check_finance_reminder"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(enqueued_jobs.size - jobs_size).to be 1
		end

		it 'Check quotations for warehouse storage deadline' do 
			processing = create(:en_preparacion)
			quotation = create(:quotation_dispatch_retirement)
			quotation_2 = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: processing, expiration_date: Date.today-1.days)
			Quotation.first.update(quotation_state: processing, expiration_date: Date.today)
			ActionMailer::Base.deliveries = []

			load Rails.root.join("lib/tasks/warehouse_check.rake")
			task = Rake::Task["warehouse_check"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(enqueued_jobs.size).to eq(4)
			#expect(ActionMailer::Base.deliveries.count).to eq 2
		end
	end
end