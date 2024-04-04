module Partners
  class ChildrenItem < ApplicationRecord
    belongs_to :child, class_name: "Partners::Child"
    belongs_to :item, class_name: "Item"
  end
end
