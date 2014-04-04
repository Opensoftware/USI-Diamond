class Diamond::Thesis < ActiveRecord::Base

    translates :title, :description

    belongs_to :annual
    belongs_to :supervisor
    belongs_to :thesis_type

    has_many :course_thesis, :class_name => "Diamond::CourseThesis", :dependent => :destroy
    has_many :courses, :through => :course_thesis

end
