# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_12_21_123448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "backup_documents", force: :cascade do |t|
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quotation_id"], name: "index_backup_documents_on_quotation_id"
  end

  create_table "banners", force: :cascade do |t|
    t.text "url"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner_image_file_name"
    t.string "banner_image_content_type"
    t.integer "banner_image_file_size"
    t.datetime "banner_image_updated_at"
    t.string "banner_mobile_file_name"
    t.string "banner_mobile_content_type"
    t.integer "banner_mobile_file_size"
    t.datetime "banner_mobile_updated_at"
  end

  create_table "billing_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.bigint "quotation_id"
    t.string "user_type", default: "seller"
    t.index ["quotation_id"], name: "index_billing_documents_on_quotation_id"
  end

  create_table "builder_companies", force: :cascade do |t|
    t.string "name"
    t.string "rut"
    t.string "sector"
    t.bigint "real_state_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["real_state_company_id"], name: "index_builder_companies_on_real_state_company_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id"
    t.bigint "product_id"
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.boolean "instalation", default: true
    t.boolean "dispatch", default: true
    t.boolean "mandatory", default: false
    t.boolean "is_service", default: false
    t.bigint "instalation_id"
    t.integer "order_item", default: 0
    t.boolean "linked_mandatory", default: false
    t.boolean "available", default: true
    t.string "name"
    t.boolean "is_pai", default: false
    t.integer "discount", default: 0
    t.string "discount_type"
    t.decimal "discount_percent", default: "0.0"
    t.boolean "profit_center", default: true
    t.boolean "is_price_UF"
    t.integer "dispatch_quantity", default: 0
    t.boolean "backorderable", default: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["instalation_id"], name: "index_cart_items_on_instalation_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pay_percent", default: 100
    t.bigint "promotional_code_id"
    t.integer "dispatch_value", default: 0
    t.bigint "dispatch_code_id"
    t.boolean "bstock", default: false
    t.boolean "apply_discount", default: false
    t.bigint "quotation_id"
    t.integer "installation_value", default: 0
    t.index ["dispatch_code_id"], name: "index_carts_on_dispatch_code_id"
    t.index ["promotional_code_id"], name: "index_carts_on_promotional_code_id"
    t.index ["quotation_id"], name: "index_carts_on_quotation_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "codes_per_channels", force: :cascade do |t|
    t.bigint "promotional_code_id"
    t.bigint "sale_channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promotional_code_id"], name: "index_codes_per_channels_on_promotional_code_id"
    t.index ["sale_channel_id"], name: "index_codes_per_channels_on_sale_channel_id"
  end

  create_table "commission_parameters", force: :cascade do |t|
    t.integer "lower_bound"
    t.integer "upper_bound"
    t.integer "level_a"
    t.integer "level_b"
    t.integer "level_c"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level_d"
    t.integer "level_e"
  end

  create_table "communes", force: :cascade do |t|
    t.string "name"
    t.bigint "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "core_id"
    t.index ["region_id"], name: "index_communes_on_region_id"
  end

  create_table "comparable_attributes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comparator_products", force: :cascade do |t|
    t.bigint "comparator_id"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comparator_id"], name: "index_comparator_products_on_comparator_id"
    t.index ["product_id"], name: "index_comparator_products_on_product_id"
  end

  create_table "comparators", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_comparators_on_user_id"
  end

  create_table "config_unit_real_states", force: :cascade do |t|
    t.string "config_type"
    t.string "config_number"
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "config_uuid"
    t.index ["quotation_id"], name: "index_config_unit_real_states_on_quotation_id"
  end

  create_table "cost_centers", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_cost_centers_on_deleted_at"
  end

  create_table "credit_notes", force: :cascade do |t|
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.index ["quotation_id"], name: "index_credit_notes_on_quotation_id"
  end

  create_table "custom_roles", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "sale_channel_id"
    t.bigint "cost_center_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_center_id"], name: "index_custom_roles_on_cost_center_id"
    t.index ["role_id"], name: "index_custom_roles_on_role_id"
    t.index ["sale_channel_id"], name: "index_custom_roles_on_sale_channel_id"
    t.index ["user_id"], name: "index_custom_roles_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "lastname"
    t.string "second_lastname"
    t.string "email"
    t.string "phone"
    t.string "rut"
    t.string "dispatch_address"
    t.string "dispatch_address_number"
    t.string "dispatch_dpto_number"
    t.string "personal_address"
    t.string "personal_address_number"
    t.string "personal_dpto_number"
    t.string "business_rut"
    t.string "business_name"
    t.string "business_sector"
    t.string "billing_address"
    t.string "billing_address_number"
    t.string "billing_dpto_number"
    t.string "instalation_address"
    t.string "instalation_address_number"
    t.string "instalation_dpto_number"
    t.bigint "dispatch_commune_id"
    t.bigint "personal_commune_id"
    t.bigint "instalation_commune_id"
    t.bigint "billing_commune_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "quotation_id"
    t.date "expiration_date"
    t.bigint "core_id"
    t.string "billing_address_street_type"
    t.string "dispatch_address_street_type"
    t.string "personal_address_street_type"
    t.string "instalation_address_street_type"
    t.string "mobile_phone"
    t.boolean "customer_project"
    t.index ["billing_commune_id"], name: "index_customers_on_billing_commune_id"
    t.index ["dispatch_commune_id"], name: "index_customers_on_dispatch_commune_id"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["instalation_commune_id"], name: "index_customers_on_instalation_commune_id"
    t.index ["personal_commune_id"], name: "index_customers_on_personal_commune_id"
    t.index ["quotation_id"], name: "index_customers_on_quotation_id"
    t.index ["rut"], name: "index_customers_on_rut"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "detail_quotation_products", force: :cascade do |t|
    t.string "name"
    t.string "state"
    t.string "tnr"
    t.string "serial_id"
    t.string "core_id"
    t.bigint "quotation_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dispatched"
    t.boolean "installed"
    t.bigint "dispatch_group_id"
    t.boolean "dispatch"
    t.boolean "instalation"
    t.boolean "home_program"
    t.date "admission_date"
    t.date "instalation_date"
    t.index ["dispatch_group_id"], name: "index_detail_quotation_products_on_dispatch_group_id"
    t.index ["quotation_product_id"], name: "index_detail_quotation_products_on_quotation_product_id"
  end

  create_table "discount_sale_channels", force: :cascade do |t|
    t.bigint "product_discount_id"
    t.bigint "sale_channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_discount_id"], name: "index_discount_sale_channels_on_product_discount_id"
    t.index ["sale_channel_id"], name: "index_discount_sale_channels_on_sale_channel_id"
  end

  create_table "dispatch_groups", force: :cascade do |t|
    t.string "dispatch_order"
    t.integer "reception_type"
    t.text "observations"
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dispatch_guide_file_name"
    t.string "dispatch_guide_content_type"
    t.integer "dispatch_guide_file_size"
    t.datetime "dispatch_guide_updated_at"
    t.date "dispatch_date"
    t.bigint "quotation_state_id"
    t.string "freight_order"
    t.date "installation_date"
    t.integer "installation_confirm", default: 0
    t.string "technician_id"
    t.string "visit_report_url"
    t.boolean "finance_validation", default: false
    t.string "provider_type"
    t.string "dispatch_uuid"
    t.string "installation_sheet"
    t.index ["quotation_id"], name: "index_dispatch_groups_on_quotation_id"
    t.index ["quotation_state_id"], name: "index_dispatch_groups_on_quotation_state_id"
  end

  create_table "dispatch_guides", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.bigint "quotation_id"
    t.bigint "role_id"
    t.bigint "dispatch_group_id"
    t.index ["dispatch_group_id"], name: "index_dispatch_guides_on_dispatch_group_id"
    t.index ["quotation_id"], name: "index_dispatch_guides_on_quotation_id"
    t.index ["role_id"], name: "index_dispatch_guides_on_role_id"
  end

  create_table "dispatch_instructions_files", force: :cascade do |t|
    t.bigint "quotation_id"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quotation_id"], name: "index_dispatch_instructions_files_on_quotation_id"
  end

  create_table "dispatch_notes", force: :cascade do |t|
    t.text "observation"
    t.bigint "user_id"
    t.bigint "dispatch_group_id"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispatch_group_id"], name: "index_dispatch_notes_on_dispatch_group_id"
    t.index ["user_id"], name: "index_dispatch_notes_on_user_id"
  end

  create_table "dispatch_rules", force: :cascade do |t|
    t.string "region_name"
    t.integer "min_amount"
    t.integer "max_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mda"
    t.integer "sda"
    t.integer "pai"
  end

  create_table "ecommerce_sales", force: :cascade do |t|
    t.datetime "selled_at"
    t.bigint "commune_id"
    t.integer "total"
    t.string "order_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quotation_id"
    t.index ["commune_id"], name: "index_ecommerce_sales_on_commune_id"
  end

  create_table "email_addressees", force: :cascade do |t|
    t.bigint "user_id"
    t.string "process", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_email_addressees_on_deleted_at"
    t.index ["user_id"], name: "index_email_addressees_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.integer "depth", default: 0
    t.index ["family_id"], name: "index_families_on_family_id"
  end

  create_table "image_notes", force: :cascade do |t|
    t.bigint "quotation_note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.bigint "dispatch_note_id"
    t.index ["dispatch_note_id"], name: "index_image_notes_on_dispatch_note_id"
    t.index ["quotation_note_id"], name: "index_image_notes_on_quotation_note_id"
  end

  create_table "indicators", force: :cascade do |t|
    t.string "name"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instalations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.index ["product_id"], name: "index_instalations_on_product_id"
  end

  create_table "lead_attachments", force: :cascade do |t|
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.index ["lead_id"], name: "index_lead_attachments_on_lead_id"
  end

  create_table "lead_products", force: :cascade do |t|
    t.string "sku"
    t.string "name"
    t.integer "quantity", default: 1
    t.float "unit_price"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_lead_products_on_lead_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.string "real_state_name"
    t.text "contacts"
    t.string "project_address"
    t.date "start_date_estimated"
    t.integer "currency", default: 0
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.float "net_price"
  end

  create_table "mandatory_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.bigint "instalation_id"
    t.index ["instalation_id"], name: "index_mandatory_products_on_instalation_id"
    t.index ["product_id"], name: "index_mandatory_products_on_product_id"
  end

  create_table "miele_roles", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "classification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_miele_roles_on_deleted_at"
  end

  create_table "payment_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.bigint "quotation_id"
    t.string "user_type", default: "seller"
    t.index ["quotation_id"], name: "index_payment_documents_on_quotation_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "description"
    t.float "ammount"
    t.datetime "pay_date"
    t.boolean "verified"
    t.string "tbk_transaction_id"
    t.string "tbk_token"
    t.string "state"
    t.string "webpay_data"
    t.string "miele_tx_code"
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_type"
    t.datetime "deleted_at"
    t.string "backup_document_file_name"
    t.string "backup_document_content_type"
    t.integer "backup_document_file_size"
    t.datetime "backup_document_updated_at"
    t.boolean "finance_validation", default: false
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["quotation_id"], name: "index_payments_on_quotation_id"
  end

  create_table "product_attributes", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "comparable_attribute_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comparable_attribute_id"], name: "index_product_attributes_on_comparable_attribute_id"
    t.index ["product_id"], name: "index_product_attributes_on_product_id"
  end

  create_table "product_discounts", force: :cascade do |t|
    t.decimal "discount"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_id"
    t.index ["product_id"], name: "index_product_discounts_on_product_id"
  end

  create_table "product_families", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_product_families_on_family_id"
    t.index ["product_id"], name: "index_product_families_on_product_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.bigint "product_id"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_in_dispatch_groups", force: :cascade do |t|
    t.bigint "dispatch_group_id"
    t.bigint "product_id"
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispatch_group_id"], name: "index_product_in_dispatch_groups_on_dispatch_group_id"
    t.index ["product_id"], name: "index_product_in_dispatch_groups_on_product_id"
  end

  create_table "product_in_unit_real_states", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.integer "quantity"
    t.bigint "quotation_product_id"
    t.bigint "config_unit_real_state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["config_unit_real_state_id"], name: "index_product_in_unit_real_states_on_config_unit_real_state_id"
    t.index ["quotation_product_id"], name: "index_product_in_unit_real_states_on_quotation_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sku"
    t.boolean "mandatory", default: false
    t.boolean "dispatch", default: false
    t.integer "discount", default: 0
    t.text "description"
    t.boolean "can_retire"
    t.string "product_type"
    t.boolean "built_in", default: false
    t.boolean "instalation", default: false
    t.boolean "outlet", default: false
    t.integer "stock", default: 0
    t.boolean "stock_break", default: false
    t.text "specs"
    t.text "features"
    t.text "technical_specs"
    t.text "product_functions"
    t.text "drink_specialty"
    t.text "basket_design"
    t.text "wash_program"
    t.text "dry_program"
    t.text "maintenance_care"
    t.text "security"
    t.text "efficiency_sustain"
    t.text "accessories"
    t.boolean "profit_center", default: true
    t.boolean "bstock", default: false
    t.string "ean"
    t.bigint "cost_center_id"
    t.string "category"
    t.string "state"
    t.datetime "deleted_at"
    t.boolean "only_for_project", default: false
    t.bigint "core_id"
    t.float "price_eur"
    t.float "cost"
    t.index ["cost_center_id"], name: "index_products_on_cost_center_id"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "products_sale_channels", id: false, force: :cascade do |t|
    t.bigint "sale_channel_id", null: false
    t.bigint "product_id", null: false
  end

  create_table "project_installation_discounts", force: :cascade do |t|
    t.integer "min_amount"
    t.integer "max_amount"
    t.float "discount_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_installation_values", force: :cascade do |t|
    t.integer "min_amount"
    t.integer "max_amount"
    t.integer "cost_RM"
    t.integer "cost_additional_region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promotional_codes", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.integer "use_limit"
    t.date "start_date"
    t.date "end_date"
    t.integer "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_for_product", default: false
  end

  create_table "quotation_documents", force: :cascade do |t|
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.index ["quotation_id"], name: "index_quotation_documents_on_quotation_id"
  end

  create_table "quotation_notes", force: :cascade do |t|
    t.text "observation"
    t.bigint "user_id"
    t.bigint "quotation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note_type"
    t.index ["quotation_id"], name: "index_quotation_notes_on_quotation_id"
    t.index ["user_id"], name: "index_quotation_notes_on_user_id"
  end

  create_table "quotation_products", force: :cascade do |t|
    t.bigint "quotation_id"
    t.bigint "product_id"
    t.string "name"
    t.float "price"
    t.integer "quantity", default: 1
    t.string "sku"
    t.boolean "mandatory", default: false
    t.boolean "dispatch", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "activation_ready", default: false
    t.boolean "is_service", default: false
    t.boolean "instalation", default: false
    t.boolean "available", default: true
    t.integer "packing"
    t.string "sku_model"
    t.string "branch_number"
    t.string "branch_name"
    t.integer "product_order"
    t.integer "max_quantity"
    t.string "tnr_retail"
    t.bigint "ecommerce_sale_id"
    t.integer "total"
    t.boolean "is_pai", default: false
    t.integer "discount", default: 0
    t.string "discount_type"
    t.decimal "discount_percent", default: "0.0"
    t.boolean "profit_center", default: true
    t.integer "order_item", default: 0
    t.bigint "instalation_id"
    t.bigint "core_id"
    t.integer "quantity_assigned"
    t.integer "dispatch_quantity", default: 0
    t.boolean "backorderable", default: false
    t.index ["ecommerce_sale_id"], name: "index_quotation_products_on_ecommerce_sale_id"
    t.index ["instalation_id"], name: "index_quotation_products_on_instalation_id"
    t.index ["product_id"], name: "index_quotation_products_on_product_id"
    t.index ["quotation_id"], name: "index_quotation_products_on_quotation_id"
  end

  create_table "quotation_products_auxes", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "dispatch_group_id"
    t.integer "quantity"
    t.string "name"
    t.string "sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispatch_group_id"], name: "index_quotation_products_auxes_on_dispatch_group_id"
    t.index ["product_id"], name: "index_quotation_products_auxes_on_product_id"
  end

  create_table "quotation_states", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stage"
  end

  create_table "quotations", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "email"
    t.string "rut"
    t.string "phone"
    t.text "observations"
    t.string "dispatch_address"
    t.string "dispatch_address_number"
    t.string "personal_address"
    t.string "personal_address_number"
    t.bigint "dispatch_commune_id"
    t.bigint "personal_commune_id"
    t.string "dispatch_dpto_number"
    t.string "personal_dpto_number"
    t.date "estimated_dispatch_date"
    t.string "business_rut"
    t.string "business_name"
    t.string "document_type"
    t.integer "pay_percent", default: 100
    t.string "code"
    t.date "installation_date"
    t.bigint "promotional_code_id"
    t.float "dispatch_value", default: 0.0
    t.bigint "dispatch_code_id"
    t.bigint "sale_channel_id"
    t.integer "mca_commission", default: 0
    t.string "billing_address"
    t.integer "billing_address_number"
    t.integer "billing_dpto_number"
    t.string "instalation_address"
    t.integer "instalation_address_number"
    t.integer "instalation_dpto_number"
    t.bigint "instalation_commune_id"
    t.bigint "billing_commune_id"
    t.bigint "quotation_state_id"
    t.string "so_code"
    t.integer "paid_ammount", default: 0
    t.string "business_sector"
    t.string "v1"
    t.date "retirement_date"
    t.string "dispatch_guide"
    t.string "dispatch_type"
    t.string "dispatch_order"
    t.boolean "activation_confirm", default: false
    t.string "lastname"
    t.string "second_lastname"
    t.string "project_name"
    t.string "f12_number"
    t.string "oc_number"
    t.bigint "retail_id"
    t.date "agreed_dispatch_date"
    t.string "dispatch_city"
    t.string "upc"
    t.string "receiver_name"
    t.string "oc_validation"
    t.bigint "cost_center_id"
    t.boolean "bstock", default: false
    t.float "total", default: 0.0
    t.bigint "miele_role_id"
    t.bigint "partner_referred_id"
    t.bigint "referred_user_id"
    t.boolean "preferential_customer", default: false
    t.integer "partner_commission"
    t.date "expiration_date"
    t.date "progress_date"
    t.bigint "partner_selected_commission_id"
    t.boolean "apply_discount", default: false
    t.string "correlative"
    t.string "credit_note"
    t.integer "currency", default: 1
    t.string "real_state_name"
    t.bigint "lead_id"
    t.bigint "next_version_id"
    t.datetime "deleted_at"
    t.datetime "exchange_rate_date"
    t.float "exchange_rate"
    t.string "billing_address_street_type"
    t.string "dispatch_address_street_type"
    t.string "personal_address_street_type"
    t.string "instalation_address_street_type"
    t.boolean "valid_quotation", default: false
    t.bigint "customer_id"
    t.string "mobile_phone"
    t.string "installment_service_id"
    t.float "installation_value", default: 0.0
    t.string "guest_token"
    t.float "percentage_discount_dispatch"
    t.boolean "instalation_check"
    t.bigint "builder_company_id"
    t.float "uf_day"
    t.index ["billing_commune_id"], name: "index_quotations_on_billing_commune_id"
    t.index ["builder_company_id"], name: "index_quotations_on_builder_company_id"
    t.index ["cost_center_id"], name: "index_quotations_on_cost_center_id"
    t.index ["customer_id"], name: "index_quotations_on_customer_id"
    t.index ["deleted_at"], name: "index_quotations_on_deleted_at"
    t.index ["dispatch_code_id"], name: "index_quotations_on_dispatch_code_id"
    t.index ["dispatch_commune_id"], name: "index_quotations_on_dispatch_commune_id"
    t.index ["instalation_commune_id"], name: "index_quotations_on_instalation_commune_id"
    t.index ["lead_id"], name: "index_quotations_on_lead_id"
    t.index ["miele_role_id"], name: "index_quotations_on_miele_role_id"
    t.index ["next_version_id"], name: "index_quotations_on_next_version_id"
    t.index ["partner_referred_id"], name: "index_quotations_on_partner_referred_id"
    t.index ["partner_selected_commission_id"], name: "index_quotations_on_partner_selected_commission_id"
    t.index ["personal_commune_id"], name: "index_quotations_on_personal_commune_id"
    t.index ["promotional_code_id"], name: "index_quotations_on_promotional_code_id"
    t.index ["quotation_state_id"], name: "index_quotations_on_quotation_state_id"
    t.index ["referred_user_id"], name: "index_quotations_on_referred_user_id"
    t.index ["retail_id"], name: "index_quotations_on_retail_id"
    t.index ["sale_channel_id"], name: "index_quotations_on_sale_channel_id"
    t.index ["user_id"], name: "index_quotations_on_user_id"
  end

  create_table "real_state_companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mda_a"
    t.integer "mda_b"
    t.integer "mda_c"
    t.integer "sda_a"
    t.integer "sda_b"
    t.integer "sda_c"
    t.integer "pai_a"
  end

  create_table "retail_products", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "retail_id"
    t.string "tnr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_retail_products_on_product_id"
    t.index ["retail_id"], name: "index_retail_products_on_retail_id"
  end

  create_table "retails", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sale_channels", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "sell_note_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.bigint "quotation_id"
    t.index ["quotation_id"], name: "index_sell_note_documents_on_quotation_id"
  end

  create_table "technical_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.bigint "product_id"
    t.index ["product_id"], name: "index_technical_images_on_product_id"
  end

  create_table "unit_real_states", force: :cascade do |t|
    t.bigint "quotation_id"
    t.string "name"
    t.integer "quantity"
    t.integer "products_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "unit_value"
    t.float "total_value"
    t.boolean "is_rm"
    t.index ["quotation_id"], name: "index_unit_real_states_on_quotation_id"
  end

  create_table "upload_logs", force: :cascade do |t|
    t.string "file_name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_upload_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "role_id"
    t.string "name"
    t.string "lastname"
    t.string "shop"
    t.string "phone"
    t.string "workday"
    t.boolean "active", default: true
    t.bigint "sale_channel_id"
    t.string "authentication_token", limit: 30
    t.bigint "cost_center_id"
    t.string "second_lastname"
    t.bigint "miele_role_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "deleted_at"
    t.string "api_key"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["cost_center_id"], name: "index_users_on_cost_center_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["miele_role_id"], name: "index_users_on_miele_role_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["sale_channel_id"], name: "index_users_on_sale_channel_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "backup_documents", "quotations"
  add_foreign_key "billing_documents", "quotations"
  add_foreign_key "builder_companies", "real_state_companies"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "instalations"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "promotional_codes"
  add_foreign_key "carts", "promotional_codes", column: "dispatch_code_id"
  add_foreign_key "carts", "quotations"
  add_foreign_key "carts", "users"
  add_foreign_key "codes_per_channels", "promotional_codes"
  add_foreign_key "codes_per_channels", "sale_channels"
  add_foreign_key "communes", "regions"
  add_foreign_key "comparator_products", "comparators"
  add_foreign_key "comparator_products", "products"
  add_foreign_key "comparators", "users"
  add_foreign_key "config_unit_real_states", "quotations"
  add_foreign_key "credit_notes", "quotations"
  add_foreign_key "custom_roles", "cost_centers"
  add_foreign_key "custom_roles", "roles"
  add_foreign_key "custom_roles", "sale_channels"
  add_foreign_key "custom_roles", "users"
  add_foreign_key "customers", "communes", column: "billing_commune_id"
  add_foreign_key "customers", "communes", column: "dispatch_commune_id"
  add_foreign_key "customers", "communes", column: "instalation_commune_id"
  add_foreign_key "customers", "communes", column: "personal_commune_id"
  add_foreign_key "customers", "quotations"
  add_foreign_key "customers", "users"
  add_foreign_key "detail_quotation_products", "dispatch_groups"
  add_foreign_key "detail_quotation_products", "quotation_products"
  add_foreign_key "discount_sale_channels", "product_discounts"
  add_foreign_key "discount_sale_channels", "sale_channels"
  add_foreign_key "dispatch_groups", "quotation_states"
  add_foreign_key "dispatch_groups", "quotations"
  add_foreign_key "dispatch_guides", "dispatch_groups"
  add_foreign_key "dispatch_guides", "quotations"
  add_foreign_key "dispatch_guides", "roles"
  add_foreign_key "dispatch_instructions_files", "quotations"
  add_foreign_key "dispatch_notes", "dispatch_groups"
  add_foreign_key "dispatch_notes", "users"
  add_foreign_key "ecommerce_sales", "communes"
  add_foreign_key "email_addressees", "users"
  add_foreign_key "families", "families"
  add_foreign_key "image_notes", "dispatch_notes"
  add_foreign_key "image_notes", "quotation_notes"
  add_foreign_key "instalations", "products"
  add_foreign_key "lead_attachments", "leads"
  add_foreign_key "lead_products", "leads"
  add_foreign_key "mandatory_products", "instalations"
  add_foreign_key "payment_documents", "quotations"
  add_foreign_key "payments", "quotations"
  add_foreign_key "product_attributes", "comparable_attributes"
  add_foreign_key "product_attributes", "products"
  add_foreign_key "product_discounts", "products"
  add_foreign_key "product_families", "families"
  add_foreign_key "product_families", "products"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_in_dispatch_groups", "dispatch_groups"
  add_foreign_key "product_in_dispatch_groups", "products"
  add_foreign_key "product_in_unit_real_states", "config_unit_real_states"
  add_foreign_key "product_in_unit_real_states", "quotation_products"
  add_foreign_key "products", "cost_centers"
  add_foreign_key "quotation_documents", "quotations"
  add_foreign_key "quotation_notes", "quotations"
  add_foreign_key "quotation_notes", "users"
  add_foreign_key "quotation_products", "ecommerce_sales"
  add_foreign_key "quotation_products", "instalations"
  add_foreign_key "quotation_products", "products"
  add_foreign_key "quotation_products", "quotations"
  add_foreign_key "quotation_products_auxes", "dispatch_groups"
  add_foreign_key "quotation_products_auxes", "products"
  add_foreign_key "quotations", "builder_companies"
  add_foreign_key "quotations", "communes", column: "billing_commune_id"
  add_foreign_key "quotations", "communes", column: "dispatch_commune_id"
  add_foreign_key "quotations", "communes", column: "instalation_commune_id"
  add_foreign_key "quotations", "communes", column: "personal_commune_id"
  add_foreign_key "quotations", "cost_centers"
  add_foreign_key "quotations", "customers"
  add_foreign_key "quotations", "leads"
  add_foreign_key "quotations", "miele_roles"
  add_foreign_key "quotations", "miele_roles", column: "partner_referred_id"
  add_foreign_key "quotations", "miele_roles", column: "partner_selected_commission_id"
  add_foreign_key "quotations", "promotional_codes"
  add_foreign_key "quotations", "promotional_codes", column: "dispatch_code_id"
  add_foreign_key "quotations", "quotation_states"
  add_foreign_key "quotations", "quotations", column: "next_version_id"
  add_foreign_key "quotations", "retails"
  add_foreign_key "quotations", "sale_channels"
  add_foreign_key "quotations", "users"
  add_foreign_key "quotations", "users", column: "referred_user_id"
  add_foreign_key "retail_products", "products"
  add_foreign_key "retail_products", "retails"
  add_foreign_key "sell_note_documents", "quotations"
  add_foreign_key "technical_images", "products"
  add_foreign_key "unit_real_states", "quotations"
  add_foreign_key "upload_logs", "users"
  add_foreign_key "users", "cost_centers"
  add_foreign_key "users", "miele_roles"
  add_foreign_key "users", "roles"
  add_foreign_key "users", "sale_channels"
end
