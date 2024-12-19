require "tzinfo"
set :output, "log/cron.log"
def local(time)
  TZInfo::Timezone.get('America/Santiago').local_to_utc(Time.parse(time))
end

every 1.day, at: '7:00' do
	rake 'check_indicators'
end

every 1.day, at: '8:00' do
	rake 'check_expired_quotations'
end

every 1.day, at: '8:00' do
	rake 'check_expired_quotations_for_project'
end

every 1.day, at: '8:05' do
	rake 'check_customers_link'
end

every 1.day, at: '8:10' do 
	rake 'check_for_expire'
end

every 1.day, at: '8:15' do
	rake 'check_pending_quotations'
end

every 1.day, at: '8:20' do
	rake 'check_instalation_deadline'
end

every 1.day, at: '8:25' do
	rake 'check_finance_reminder'
end

every 1.day, at: '8:30' do 
	rake 'warehouse_check'
end

every :saturday, at: local("6:30 pm") do
	rake 'update_customer_core_ids'
	rake 'update_product_core_ids'
end
   
every :saturday, at: local("6:30 pm") do
	rake 'create_or_update_products_with_miele_core'
end