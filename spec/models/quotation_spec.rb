require 'rails_helper'

RSpec.describe Quotation, type: :model do
	context 'cost' do
		it 'evaluate levels' do
			quotation = create(:quotation_retirement, user: create(:user))
			expect(Quotation.cost_next_section(Quotation.first.quotation_products, [])[0..3]).to eq [6300010, 900, 0, 5]
			Quotation.first.quotation_products.update(quantity: 14)
			Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, quotation.apply_discount)
			expect(Quotation.cost_next_section(Quotation.first.quotation_products, [])[0..3]).to eq [7200140, 73, 0.05, 10]
			Quotation.first.quotation_products.update(quantity: 20)
			Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, quotation.apply_discount)
			expect(Quotation.cost_next_section(Quotation.first.quotation_products, [])[0..3]).to eq [3000200, 21, 0.05, 10] 
			Quotation.first.quotation_products.update(quantity: 30)
			Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, quotation.apply_discount)
			expect(Quotation.cost_next_section(Quotation.first.quotation_products, [])[0..3]).to eq [6000300, 28, 0.1, 15]
			Quotation.first.quotation_products.update(quantity: 40)
			Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, quotation.apply_discount)
			expect(Quotation.cost_next_section(Quotation.first.quotation_products, [])[0..3]).to eq [0, 0, 0.15, 15]
		end

		it 'check MCA commission' do 
			quotation = create(:quotation_retirement, user: create(:mca_user))
			quotation.check_commission
			expect(quotation.mca_commission).to eq 0

			quotation.quotation_products.last.update(quantity: 5)
			quotation.check_commission
			expect(quotation.mca_commission).to eq 17499

			quotation.quotation_products.last.update(quantity: 12)
			quotation.check_commission
			expect(quotation.mca_commission).to eq 41999

			quotation.quotation_products.last.update(quantity: 40)
			quotation.check_commission
			expect(quotation.mca_commission).to eq 419994

			quotation.quotation_products.last.update(quantity: 80)
			quotation.check_commission
			expect(quotation.mca_commission).to eq 839988
		end

		it 'check partner commission' do 
			CommissionParameter.create(lower_bound: 0, upper_bound: 6_999_999, level_a: 17, level_b: 16, level_c: 15)

			quotation = create(:quotation_retirement, user: create(:mca_user), preferential_customer: true, referred_user: create(:mca_seller_user, miele_role: create(:test_miele_role)), partner_referred: create(:test_2_miele_role))
			quotation.update(total: quotation.total_calc)
			customer = create(:customer, user: create(:project_user, miele_role: create(:test_3_miele_role)), rut: '1-9', email: 'mail@mail.com')
			#primera jerarquia cliente preferencial
			quotation.check_partner_commission(customer)
			expect(quotation.partner_commission).to eq 34_999
			#segunda jerarquia referido
			quotation.update(preferential_customer: false)
			quotation.check_partner_commission(customer)
			expect(quotation.partner_commission).to eq 104_998
			#tercera jerarquia usuario mca con clasificación
			quotation.update(partner_referred: nil)
			quotation.check_partner_commission(customer)
			expect(quotation.partner_commission).to eq 118_998
			# cuarta jerarquia rut asociado a cliente
			quotation.update(user: nil)
			quotation.check_partner_commission(Customer.last)
			expect(quotation.partner_commission).to eq 111_998
			# cuando no hay comisión
			Customer.last.update(user: nil)
			quotation.check_partner_commission(Customer.last)
			expect(quotation.partner_commission).to eq 0
		end

		it 'check miele discount' do 
			quotation = create(:quotation_retirement)
			Product.last.families << create(:lavadoras)
			expect(Quotation.discount_miele(quotation.quotation_products)).to eq [0, []]
			quotation.quotation_products.last.update(quantity: 2)
			expect(Quotation.discount_miele(quotation.quotation_products)).to eq [10, QuotationProduct.where(id: quotation.quotation_products.first.id)]
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.discount_miele(quotation.quotation_products)).to eq [15, QuotationProduct.where(id: quotation.quotation_products.first.id)]
		end

		it 'check dispatch value SDA' do 
			create(:valparaiso)
			quotation = create(:quotation_retirement)
			# 1 SDA RM

			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 0

			# 1 SDA DESPACHO RM
			quotation.quotation_products.last.update(dispatch: true)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 5900

			# 3 SDA DESPACHO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 17700

			# 6 SDA DESPACHO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 35400

			# 1 SDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(instalation: true, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 44900

			# 3 SDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 119700

			# 6 SDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 209400

			# SDA NO RM
			quotation.update(dispatch_commune: Commune.find_by(name: 'Valparaíso'))
			# 1 SDA + Despacho NO RM
			quotation.quotation_products.last.update(dispatch: true, instalation: false, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 30800

			# 3 SDA DESPACHO NO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 83400

			# 6 SDA DESPACHO NO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 148800

			# 1 SDA + Despacho + Instalación NO RM
			quotation.quotation_products.last.update(instalation: true, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 44900

			# 3 SDA DESPACHO + INSTALACION NO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 119700

			# 6 SDA DESPACHO + INSTALACION NO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 209400
		end

		it 'check dispatch value MDA' do 
			create(:valparaiso)
			quotation = create(:quotation_retirement)
			quotation.quotation_products.last.product.update(product_type: 'MDA')
			# 1 MDA RM

			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 0

			# 1 MDA DESPACHO RM
			quotation.quotation_products.last.update(dispatch: true)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 9900

			# 3 MDA DESPACHO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 29700

			# 6 MDA DESPACHO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 59400

			# 1 MDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(instalation: true, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 44900

			# 3 MDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 119700

			# 6 MDA DESPACHO + INSTALACION RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 209400

			# MDA NO RM
			quotation.update(dispatch_commune: Commune.find_by(name: 'Valparaíso'))
			# 1 MDA + Despacho NO RM
			quotation.quotation_products.last.update(dispatch: true, instalation: false, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 34800

			# 3 MDA DESPACHO NO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 95400

			# 6 MDA DESPACHO NO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 172800

			# 1 MDA + Despacho + Instalación NO RM
			quotation.quotation_products.last.update(instalation: true, quantity: 1)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 94800

			# 3 MDA DESPACHO + INSTALACION NO RM
			quotation.quotation_products.last.update(quantity: 3)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 254400

			# 6 MDA DESPACHO + INSTALACION NO RM
			quotation.quotation_products.last.update(quantity: 6)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 448800
		end

		it 'check dispatch value PAI' do 
			create(:valparaiso)
			quotation = create(:quotation_retirement)
			quotation.quotation_products.last.update(is_pai: true)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 0

			quotation.quotation_products.last.update(dispatch: true)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 5_900

			quotation.update(dispatch_commune: Commune.find_by(name: 'Valparaíso'))
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 40_899

			quotation.quotation_products.last.update(instalation: true)
			expect(Quotation.check_dispatch(quotation.dispatch_commune_id, quotation.quotation_products)).to eq 40_899
		end
	end

	context 'dispatch groups' do 
		let(:quotation){create(:quotation_with_products)}
		before do 
			create(:en_preparacion)
		end

		it 'zero dispatchs by default' do 
			quotation = create(:quotation)
			expect(quotation.dispatch_groups.count).to be 0
		end

		it 'check pending products' do 
			quotation_products_hash = quotation.pending_products_in_dispatch
			expect(quotation_products_hash.class).to be Hash
			expect(quotation_products_hash.size).to be 3
			expect(quotation_products_hash.has_key?(quotation.quotation_products[0].product)).to be true
			expect(quotation_products_hash.has_key?(quotation.quotation_products[1].product)).to be true
			expect(quotation_products_hash.has_key?(quotation.quotation_products[2].product)).to be true

			expect(quotation_products_hash.values.sort).to eq [1, 2, 3]
		end

		it 'changes quotation state' do 
			create(:quotation_state, name: 'Despachos e Instalaciones')
			quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group

			expect(quotation.dispatch_groups.count).to be 1
			expect(quotation.get_state).not_to eq 'En preparación'

			quotation.check_dispatch_groups_states

			expect(quotation.get_state).to eq quotation.dispatch_groups.first.state.name

			quotation.dispatch_groups << create(:dispatch_group)
			expect(quotation.dispatch_groups.count).to be 2
			quotation.dispatch_groups.last.update(state: create(:despachado))

			expect(quotation.dispatch_groups.first.state).not_to eq quotation.dispatch_groups.last.state

			quotation.check_dispatch_groups_states
			expect(quotation.get_state).to eq 'Despachos e Instalaciones'
		end
	end

	context 'data' do 
		it 'set products from lead' do 
			lead = create(:lead)
			expect(lead.products.count).to be 2

			quotation = create(:quotation)
			expect(quotation.products.count).to be 0

			quotation.set_products_from_lead(lead)

			expect(quotation.products.count).to be 2
		end

		it 'can activate?' do 
			quotation_1 = create(:quotation)
			quotation_1.update(quotation_state: create(:enviada))
			quotation_2 = create(:quotation)
			quotation_2.update(quotation_state: create(:en_negociacion))
			quotation_3 = create(:quotation)
			quotation_3.update(quotation_state: create(:en_preparacion))
			quotation_4 = create(:quotation)
			quotation_4.update(quotation_state: create(:instalado))

			expect(quotation_1.can_activate?).to be true
			expect(quotation_2.can_activate?).to be true
			expect(quotation_3.can_activate?).to be true
			expect(quotation_4.can_activate?).to be false
		end

		it 'pending amount' do 
			quotation = create(:quotation)
			quotation.update(total: 1000)
			quotation.payments << create(:payment, state: 'complete', ammount: 100)
			quotation.payments << create(:payment, state: 'complete', ammount: 200)

			expect(quotation.total).to be 1000.0
			expect(quotation.payments.count).to be 2

			total_paid = quotation.payments.completed.sum(:ammount)
			expect(total_paid).to be 300
			expect(quotation.pending_amount).to be quotation.total - total_paid
		end

		it 'check if type is proyect' do 
			normal_quotation = create(:quotation)
			expect(normal_quotation.channel).not_to eq 'Proyectos'
			expect(normal_quotation.for_project?).to be false

			project_quotation = create(:quotation_for_project)
			expect(project_quotation.channel).to eq 'Proyectos'
			expect(project_quotation.for_project?).to be true
		end
	end

	context 'versions' do 
		it '# create' do 
			quotation = create(:quotation_with_products)
			new_version = quotation.create_new_version
			expect(new_version.class).to be Quotation
			expect(new_version.id).not_to be quotation.id
			expect(new_version.products.count).to be quotation.products.count
			expect(quotation.next_version).to eq new_version
			expect(quotation.get_state).to eq new_version.get_state

			new_version_product = new_version.quotation_products.first
			old_version_product = quotation.quotation_products.first
			expect(new_version_product.id).not_to be old_version_product.id
			expect(new_version_product.price).to be old_version_product.price
			expect(new_version_product.quantity).to be old_version_product.quantity
		end

		it '# create without products' do 
			quotation = create(:quotation_with_products)
			new_version = quotation.create_new_version(false)
			expect(new_version.class).to be Quotation
			expect(new_version.id).not_to be quotation.id
			expect(new_version.products.count).to be 0
			expect(quotation.next_version).to eq new_version
			expect(quotation.get_state).to eq new_version.get_state
		end

		it 'get last' do 
			quotation = create(:quotation_with_later_versions)
			expect(quotation.next_version).not_to be nil

			last_version = quotation.last_version
			expect(last_version.class).to be Quotation
			expect(last_version.next_version).to be nil
		end

		it 'get all' do 
			quotation = create(:quotation_with_later_versions)
			second_version = create(:quotation, next_version: quotation)
			first_version = create(:quotation, next_version: second_version)

			versions = quotation.all_versions
			expect(versions.class).to be Array
			expect(versions.size).to be 5
			expect(versions[0]).to eq quotation.last_version
			expect(versions[1]).to eq quotation.next_version
			expect(versions[2]).to eq quotation
			expect(versions[3]).to eq second_version
			expect(versions[4]).to eq first_version
		end
	end

	context 'render as pdf' do 
		it 'if is for project' do 
			quotation = create(:quotation)

			pdf_hash = quotation.to_pdf
			expect(pdf_hash.has_key?(:template)).to be true
			expect(pdf_hash.has_key?(:pdf)).to be true
			expect(pdf_hash.has_key?(:disposition)).to be true
			expect(pdf_hash.has_key?(:layout)).to be true
			expect(pdf_hash.has_key?(:title)).to be true
			expect(pdf_hash.has_key?(:page_size)).to be true
			expect(pdf_hash.has_key?(:locals)).to be true
			expect(pdf_hash.has_key?(:margin)).to be true
			expect(pdf_hash.has_key?(:header)).to be true

			expect(pdf_hash[:template]).to eq 'quotations/new_quotation.pdf.erb'
			expect(pdf_hash[:pdf]).to eq "documento_#{quotation.id}"
			expect(pdf_hash[:disposition]).to eq 'inline'
			expect(pdf_hash[:layout]).to eq 'document_in_pdf.html'
			expect(pdf_hash[:title]).to eq "documento_#{quotation.id}"
			expect(pdf_hash[:page_size]).to eq 'Letter'
			expect(pdf_hash[:header][:html][:template]).to eq 'layouts/_header_pdf.html.erb'
		end

		it 'if is for project' do 
			quotation = create(:quotation_for_project)

			pdf_hash = quotation.to_pdf
			expect(pdf_hash.has_key?(:template)).to be true
			expect(pdf_hash.has_key?(:pdf)).to be true
			expect(pdf_hash.has_key?(:disposition)).to be true
			expect(pdf_hash.has_key?(:layout)).to be true
			expect(pdf_hash.has_key?(:title)).to be true
			expect(pdf_hash.has_key?(:page_width)).to be true
			expect(pdf_hash.has_key?(:page_height)).to be true
			expect(pdf_hash.has_key?(:locals)).to be true
			expect(pdf_hash.has_key?(:margin)).to be true

			expect(pdf_hash[:template]).to eq 'quotations/for_project.pdf.erb'
			expect(pdf_hash[:pdf]).to eq "Cotización_proyecto_#{quotation.code}"
			expect(pdf_hash[:disposition]).to eq 'attachment'
			expect(pdf_hash[:layout]).to eq 'document_in_pdf.html'
			expect(pdf_hash[:title]).to eq "Cotización_proyecto_#{quotation.code}"
			expect(pdf_hash[:page_width]).to eq '25.4cm'
			expect(pdf_hash[:page_height]).to eq '16.28cm'
		end
	end
end
