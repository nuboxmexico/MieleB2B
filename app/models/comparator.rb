class Comparator < ApplicationRecord
  belongs_to :user
  has_many :comparator_products, dependent: :destroy
  has_many :products, through: :comparator_products

  def add_product(product)
  	if comparator_products.size == 0
  		products << product
  		self.save!
  		return true, ''
  	elsif comparator_products.size == 3
  		return false, 'Haz alcanzado el límite de productos en el comparador.'
  	else
      is_from_same_family = false
      products.first.families.where(depth: 1).each do |prod|
        is_from_same_family = true if product.families.where(depth: 1).include?(prod)
      end
      if is_from_same_family
       products << product
       self.save!
       return true, ''
     else
       return false, 'El producto que intentas agregar no pertenece a la misma familia del comparador.'
     end
   end
 end

 def remove_product(product)
   comparator_products.find_by(product: product).try(:destroy)
 end
end