class Diamond::CourseThesis < ActiveRecord::Base

    belongs_to :course
    belongs_to :thesis, :class_name => "Diamond::Thesis"

end
