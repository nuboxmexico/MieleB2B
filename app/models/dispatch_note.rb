class DispatchNote < ApplicationRecord
  belongs_to :user
  belongs_to :dispatch_group

  has_many :image_notes

  enum category: [
    :dispatch,
    :reception,
    :instalation
  ]

  scope :dispatch, -> {where(category: :dispatch)}
  scope :reception, -> {where(category: :reception)}
  scope :instalation, -> {where(category: :instalation)}
  scope :to_display, -> {where.not(observation: nil).order(created_at: :asc)}
end
