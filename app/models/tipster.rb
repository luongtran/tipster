class Tipster < User
  has_and_belongs_to_many :carts
end
