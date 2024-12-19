require 'rails_helper'

RSpec.describe DispatchGroup, type: :model do
  include ActiveJob::TestHelper
  before do 
    clear_enqueued_jobs
  end

  let(:dispatch_in_preparation){create(:dispatch_group_in_preparation)}

  context 'get' do 
    it 'products in a hash' do 
      products_in_dispatch = dispatch_in_preparation.products_in_dispatch
      products_hash = dispatch_in_preparation.products_hash

      expect(products_in_dispatch.size).to be 3

      expect(products_hash.class).to be Hash
      expect(products_hash.size).to be products_in_dispatch.size

      expect(products_hash.has_key?(products_in_dispatch[0].product)).to be true
      expect(products_hash.has_key?(products_in_dispatch[1].product)).to be true
      expect(products_hash.has_key?(products_in_dispatch[2].product)).to be true

      expect(products_hash[products_in_dispatch[0].product]).to be products_in_dispatch[0].quantity
      expect(products_hash[products_in_dispatch[1].product]).to be products_in_dispatch[1].quantity
      expect(products_hash[products_in_dispatch[2].product]).to be products_in_dispatch[2].quantity
    end

    it 'available products' do 
      products_in_dispatch = dispatch_in_preparation.products_in_dispatch
      available_products = dispatch_in_preparation.available_products

      expect(products_in_dispatch.size).to be 3

      expect(available_products.size).to be 3

      products_in_dispatch.last.update(quantity: 0)

      expect(available_products.size).to be 2
    end

    it 'observation by state' do 
      expect(dispatch_in_preparation.observation_by_state.dispatch?).to be true
      expect(dispatch_in_preparation.observation_by_state.reception?).to be false
      expect(dispatch_in_preparation.observation_by_state.instalation?).to be false
      
      dispatch_dispatched = create(:dispatch_group_dispatched)
      expect(dispatch_dispatched.observation_by_state.dispatch?).to be false
      expect(dispatch_dispatched.observation_by_state.reception?).to be true
      expect(dispatch_dispatched.observation_by_state.instalation?).to be false

      dispatch_to_install = create(:dispatch_group_to_install)
      expect(dispatch_to_install.observation_by_state.dispatch?).to be false
      expect(dispatch_to_install.observation_by_state.reception?).to be false
      expect(dispatch_to_install.observation_by_state.instalation?).to be true
    end

    it 'validation for dispatchment' do 
      dispatch_in_preparation.update(dispatch_order: nil, dispatch_date: nil)
      dispatch_in_preparation.observation_by_state.update(observation: nil)
      expect(dispatch_in_preparation.dispatch_guides.empty?).to be true

      expect(dispatch_in_preparation.can_dispatch?).to be false

      dispatch_in_preparation.update(dispatch_order: 'order')
      expect(dispatch_in_preparation.can_dispatch?).to be false

      dispatch_in_preparation.update(dispatch_date: Date.today)
      expect(dispatch_in_preparation.can_dispatch?).to be false

      dispatch_in_preparation.dispatch_guides << create(:dispatch_guide)
      expect(dispatch_in_preparation.can_dispatch?).to be false

      dispatch_in_preparation.observation_by_state.update(observation: 'observation')
      expect(dispatch_in_preparation.can_dispatch?).to be true
    end

    it 'reception types' do 
      reception_types = DispatchGroup.reception_types

      expect(reception_types.has_key?(:acepted_reception_by_customer)).to be true
      expect(reception_types[:acepted_reception_by_customer]).to eq 'Recepción conforme por cliente'
      
      expect(reception_types.has_key?(:acepted_reception_by_courier)).to be true
      expect(reception_types[:acepted_reception_by_courier]).to eq 'Recepción conforme por courier'
      
      expect(reception_types.has_key?(:partial_reception)).to be true
      expect(reception_types[:partial_reception]).to eq 'Recepción parcial'
      
      expect(reception_types.has_key?(:pending_reception)).to be true
      expect(reception_types[:pending_reception]).to eq 'Pendiente de recepción'
    end

    it 'notification subject' do 
      for_miele = true
      not_for_miele = false

      dispatch_dispatched = create(:dispatch_group_dispatched)
      expect(dispatch_dispatched.notification_subject(dispatch_dispatched.state, for_miele)).to eq "[Envío Despachado 36-618-1-prueba] Mielecustomers.cl"
      expect(dispatch_dispatched.notification_subject(dispatch_dispatched.state, not_for_miele)).to eq "[Confirmación Despacho Envío Miele Chile]"

      dispatch_to_install = create(:dispatch_group_to_install)
      expect(dispatch_to_install.notification_subject(dispatch_to_install.state, for_miele)).to eq "[Envío Entregado 36-618-2-prueba] Mielecustomers.cl"
      expect(dispatch_to_install.notification_subject(dispatch_to_install.state, not_for_miele)).to eq "[Productos Entregados Envío Miele Chile]"

      dispatch_installed = create(:dispatch_group_installed)
      expect(dispatch_installed.notification_subject(dispatch_installed.state, for_miele)).to eq "[Envío Instalado 36-618-3-prueba] Mielecustomers.cl"
      expect(dispatch_installed.notification_subject(dispatch_installed.state, not_for_miele)).to eq "[Productos Instalados Envío Miele Chile]"

      dispatch_pending_installation = create(:dispatch_group_pending_installation)
      expect(dispatch_pending_installation.notification_subject(dispatch_pending_installation.state, for_miele)).to eq "[Envío con Instalación PENDIENTE 36-618-4-prueba] Mielecustomers.cl"
      expect(dispatch_pending_installation.notification_subject(dispatch_pending_installation.state, not_for_miele)).to eq "[Envío con Instalación PENDIENTE 36-618-4-prueba] Mielecustomers.cl"
    end
  end

  context 'change' do 
    it 'state' do 
      dispatched_state = create(:despachado)
      expect(dispatch_in_preparation.state.name).to eq 'En preparación'
      expect(dispatch_in_preparation.quotation.channel).not_to eq 'Proyectos'

      dispatch_in_preparation.to_state('Despachado')

      expect(dispatch_in_preparation.state).to eq dispatched_state
      
      # El mail inicial es por la asignación del estado
      # De los restantes:
      # - 2 por la notificación del envío (para miele y para no miele)
      # - 2 por el cambio de estado de la cotización (para miele y para no miele)
      expect(enqueued_jobs.size - 1).to be 4 
    end

    it 'from reception type defined distinct of pending reception' do 
      create(:por_instalar)
      dispatched_group = create(:dispatch_group_dispatched)
      expect(dispatched_group.state.name).to eq 'Despachado'

      dispatched_group.acepted_reception_by_courier!
      expect(dispatched_group.acepted_reception_by_courier?).to be true
      dispatched_group.to_state_from_reception_type
      expect(dispatched_group.state.name).to eq 'Por instalar'
      expect(dispatched_group.notes.dispatch.count).to be 1
    end

    it 'from reception type defined as pending reception' do 
      create(:en_preparacion)
      dispatched_group = create(:dispatch_group_dispatched)
      expect(dispatched_group.state.name).to eq 'Despachado'

      dispatched_group.pending_reception!
      expect(dispatched_group.pending_reception?).to be true
      dispatched_group.to_state_from_reception_type
      expect(dispatched_group.state.name).to eq 'En preparación'
      expect(dispatched_group.notes.dispatch.count).to be 2
    end
  end
end
