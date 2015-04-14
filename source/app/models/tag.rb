class Tag < ActiveRecord::Base

  belongs_to :project

  scope :fuzzy_search, ->(query){
    query ||= ''
    query = query.downcase
    where("lower(name) LIKE ? ","%#{query}%")
  }

end
