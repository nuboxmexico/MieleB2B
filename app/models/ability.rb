class Ability
  include CanCan::Ability

  def initialize(user)
    can [:choose_role, :set_role, :change_role], User

    if user.administrator?
        can :manage, Cart
        can :manage, Banner
        can :manage, PromotionalCode
        can :manage, DataUpload
        can :manage, Product
        can :manage, Comparator
        can :search, Customer
        can :manage, User
        can :manage, Lead
        can [:new, :create, :check_dispatch, :resumen, :load_billing_documents, :download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations, :quotation_document, :activate_home_program], Quotation
        can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["Enviada","Ingresada"]).pluck(:id)
        can :reactivate, Quotation, quotation_state_id: QuotationState.where(name: 'Vencida').pluck(:id)
        can :activate, Quotation, quotation_state_id: QuotationState.where(name: ['Enviada','En curso','Pendiente', 'Cerrado']).pluck(:id)
        cannot [:load_homologate_tnr,:download_tnr_homologated, :load_oc_retail, :load_quotation_project], DataUpload
        can :destroy, BillingDocument, user_type: 'seller'
        can :destroy, PaymentDocument, user_type: 'seller'
        can :destroy, SellNoteDocument
        can :destroy, BackupDocument
        can :edit_estimated_date, Quotation, quotation_state_id: QuotationState.edit_estimated_dates.pluck(:id)
        can :create_new_version, Quotation do |quotation|
            ['Ingresada', 'En Negociación'].include?(quotation.get_state) and 
            quotation.next_version.nil? and 
            quotation.payments.empty?
        end
        can :delete_version, Quotation do |quotation|
            ['Ingresada', 'En Negociación'].include?(quotation.get_state) and 
            !quotation.next_version.nil? and 
            quotation.payments.empty?
        end
    end

    if user.manager?
        can [:index, :new, :create_user, :toggle, :edit, :destroy, :update], User
        can [:business_units, :index, :show, :search], Product
        can [:new, :create, :check_dispatch, :resumen, :load_billing_documents, :download_quotations, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations, :quotation_document, :activate_home_program], Quotation
        can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["Enviada","Ingresada"]).pluck(:id)
        can :reactivate, Quotation, quotation_state_id: QuotationState.where(name: 'Vencida').pluck(:id)
        can :activate, Quotation, quotation_state_id: QuotationState.where(name: ['Enviada','En curso','Pendiente', 'Cerrado']).pluck(:id)
        can :manage, Comparator
        if !user.is_project? && !user.is_retail?
            can :manage, PromotionalCode
            can :manage, Cart
            can [:bstock, :destroy], Product
            can :search, Customer
        elsif user.is_retail?
            can [:upload_info, :load_homologate_tnr,:download_tnr_homologated, :template_tnr_retail, :load_oc_retail, :template_oc_retail], DataUpload
            can [:activate_retail], Quotation, quotation_state_id: QuotationState.where(name: 'Ingresada').pluck(:id)
            can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En curso","Pendiente","Ingresada","En preparación"]).pluck(:id)
        elsif user.is_project?
            can :manage, Cart
            can [:upload_info, :load_quotation_project, :template_project, :load_products], DataUpload
            can :template_products, Product
            can :lead_quotation, Quotation, quotation_state_id: QuotationState.where(name: ['Ingresada','Lead']).pluck(:id)
            can :negotiation_quotation, Quotation, quotation_state_id: QuotationState.where(name: ['Ingresada','En Negociación']).pluck(:id)
            can :manage, Lead
            can :create_new_version, Quotation do |quotation|
                ['Ingresada', 'En Negociación'].include?(quotation.get_state) and 
                quotation.next_version.nil? and 
                quotation.payments.empty?
            end
            can :delete_version, Quotation do |quotation|
                ['Ingresada', 'En Negociación'].include?(quotation.get_state) and 
                !quotation.next_version.nil? and 
                quotation.payments.empty?
            end
            can :activate, Quotation, quotation_state_id: QuotationState.where(name: ['En Negociación', 'Enviada','En curso','Pendiente', 'Cerrado', 'En preparación', 'Despachado', 'Despachos e Instalaciones', 'Entrega Pendiente', 'Por instalar', 'Instalación Pendiente']).pluck(:id)
            can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En curso', 'En preparación', 'Despachos e Instalaciones']).pluck(:id)
            can :dispatch_confirm, Quotation, quotation_state_id: QuotationState.where(name: ['Entrega Pendiente', 'Despachado']).pluck(:id)
            can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En preparación', 'Despachos e Instalaciones']).pluck(:id)
        end
        can :destroy, BillingDocument, user_type: 'seller'
        can :destroy, PaymentDocument, user_type: 'seller'
        can :destroy, SellNoteDocument
        can :destroy, BackupDocument
    end

    if user.seller?
        can [:business_units, :index, :show, :search], Product
        can [:new, :create, :check_dispatch, :resumen, :load_billing_documents, :download_quotations, :filter_by_state, :filter_by_date, :search_quotations, :quotation_document, :activate_home_program], Quotation
        can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["Enviada","Ingresada"]).pluck(:id)
        can :reactivate, Quotation, quotation_state_id: QuotationState.where(name: 'Vencida').pluck(:id)
        can :activate, Quotation, quotation_state_id: QuotationState.where(name: ['Enviada','En curso','Pendiente', 'Cerrado']).pluck(:id)
        can :manage, Comparator
        if !user.is_project? && !user.is_retail?
            can :manage, Cart
            can :search, Customer
        elsif user.is_retail?
            can [:upload_info, :load_homologate_tnr, :download_tnr_homologated, :template_tnr_retail, :load_oc_retail, :template_oc_retail], DataUpload
            can [:activate_retail], Quotation, quotation_state_id: QuotationState.where(name: 'Ingresada').pluck(:id)
            can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En curso","Pendiente","Ingresada","En preparación"]).pluck(:id)
        elsif user.is_project?
            can [:upload_info, :load_quotation_project, :template_project], DataUpload
            can :lead_quotation, Quotation, quotation_state_id: QuotationState.where(name: ['Ingresada','Lead']).pluck(:id)
            can :negotiation_quotation, Quotation, quotation_state_id: QuotationState.where(name: ['Ingresada','En Negociación']).pluck(:id)
        end
        can :destroy, BillingDocument, user_type: 'seller'
        can :destroy, PaymentDocument, user_type: 'seller'
        can :destroy, SellNoteDocument
        can :destroy, BackupDocument
        can :edit_estimated_date, Quotation, quotation_state_id: QuotationState.edit_estimated_dates.pluck(:id)
    end

    if user.is_finance?
        can [:business_units, :index, :show, :search], Product
        can [:download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations, :load_billing_documents], Quotation
        can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En curso","Pendiente","Ingresada","En preparación"]).pluck(:id)
        can :update, Quotation, quotation_state_id: QuotationState.where(name: ['En curso','Pendiente']).pluck(:id)
        can :activate_finance_retail, Quotation, quotation_state_id: QuotationState.where(name: ['En curso','Pendiente']).pluck(:id)
        can :update_quantities, Quotation, quotation_state_id: QuotationState.where(name: 'En curso').pluck(:id)
        can [:download_commissions_table], DataUpload
        can :destroy, Payment
        can :destroy, BillingDocument, user_type: 'finance'
        can :destroy, PaymentDocument, user_type: 'finance'
        can :destroy, CreditNote
        can :dispatch_confirm, Quotation, quotation_state_id: QuotationState.where(name: ['Entrega Pendiente', 'Despachado']).pluck(:id)
        can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En preparación', 'Despachos e Instalaciones']).pluck(:id)
    end

    if user.is_finance_manager?
        can [:business_units, :index, :show, :search], Product
        can [:index, :new, :create_user, :toggle, :edit, :destroy, :update], User
        can [:upload_info, :load_miele_roles, :template_miele_roles, :load_commission_levels, :template_commissions, :download_commissions_table], DataUpload
        can [:update_quantities, :update_quotation, :load_billing_documents, :download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations, ], Quotation
        can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En curso","Pendiente","Ingresada","En preparación"]).pluck(:id)
        can :update, Quotation, quotation_state_id: QuotationState.where(name: ['En curso','Pendiente']).pluck(:id)
        can :activate_finance_retail, Quotation, quotation_state_id: QuotationState.where(name: ['En curso','Pendiente']).pluck(:id)
        can :destroy, Payment
        can :validate_payment, Payment
        can :destroy, BillingDocument, user_type: 'finance'
        can :destroy, PaymentDocument, user_type: 'finance'
        can :destroy, CreditNote
        can :dispatch_confirm, Quotation, quotation_state_id: QuotationState.where(name: ['Entrega Pendiente', 'Despachado']).pluck(:id)
        can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En preparación', 'Despachos e Instalaciones']).pluck(:id)
    end

    if user.is_dispatch?
        can [:business_units, :index, :show, :search], Product
        can [:update_quotation, :download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations], Quotation
        can :dispatch_confirm, Quotation, quotation_state_id: QuotationState.where(name: ['Entrega Pendiente', 'Despachado']).pluck(:id)
        can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En preparación', 'Despachos e Instalaciones']).pluck(:id)
        #can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En preparación","Despachado"]).pluck(:id)
        can :destroy, DispatchGuide, role_id: Role.where(name: ['Despacho', 'Manager Despacho']).pluck(:id)
    end

    if user.is_manager_dispatch?
        can [:business_units, :index, :show, :search], Product
        can [:index, :new, :create_user, :toggle, :edit, :destroy, :update], User
        can [:update_quotation, :download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations], Quotation
        can :dispatch_confirm, Quotation, quotation_state_id: QuotationState.where(name: ['Entrega Pendiente', 'Despachado']).pluck(:id)
        can :dispatch_activation, Quotation, quotation_state_id: QuotationState.where(name: ['En preparación', 'Despachos e Instalaciones']).pluck(:id)
        #can :cancel_quotation, Quotation, quotation_state_id: QuotationState.where(name: ["En preparación","Despachado"]).pluck(:id)
        can :destroy, DispatchGuide, role_id: Role.where(name: ['Despacho', 'Manager Despacho']).pluck(:id)
    end

    if user.is_instalation?
        can [:instalation], Quotation, quotation_state_id: QuotationState.where(name: ['Por instalar','Instalación Pendiente']).pluck(:id)
        can [:download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations,], Quotation
    end

    if user.is_manager_instalation?
        can [:instalation], Quotation, quotation_state_id: QuotationState.where(name: ['Por instalar','Instalación Pendiente']).pluck(:id)
        can [:index, :new, :create_user, :toggle, :edit, :destroy, :update], User
        can [:download_quotations, :filter_by_cost_center, :filter_by_channel, :filter_by_state, :filter_by_date, :search_quotations,], Quotation
    end

    if !user.foreign?
        can [:show, :search, :index], Quotation
    end

    if user.foreign?
        can :manage, Comparator
        cannot :manage, Quotation
        can [:business_units, :index, :show, :search], Product
    end

    if user.is_manager_inventory?
        can :manage, DataUpload
        can :manage, Product
        can :manage, Comparator
        cannot :manage, Quotation
        cannot [:load_oc_retail, :load_quotation_project], DataUpload
    end
end
end