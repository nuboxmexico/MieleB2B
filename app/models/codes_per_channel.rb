class CodesPerChannel < ApplicationRecord
  belongs_to :promotional_code
  belongs_to :sale_channel
end
