class AddUuidToConfigUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    add_column :config_unit_real_states, :config_uuid, :string

    ConfigUnitRealState.all.each { |item| item.update(config_uuid: SecureRandom.uuid) if item.config_uuid.nil? || item.config_uuid.blank? }
  end
end
