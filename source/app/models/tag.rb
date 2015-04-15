class Tag < ActiveRecord::Base

  belongs_to :project

  scope :fuzzy_search, ->(query){
    query ||= ''
    query = query.downcase
    where("lower(name) LIKE ? ","#{query}%")
  }

  def to_s
    return "#{self.name}"
  end

end
