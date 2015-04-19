class Tag < ActiveRecord::Base
  has_many  :projects_tags
  has_many  :votes
  has_many  :projects, :through => :projects_tags

  scope :fuzzy_search, ->(query){
    query ||= ''
    query = query.downcase
    where("lower(name) LIKE ? ","#{query}%")
  }

  def to_s
    return "#{self.name}"
  end

end
