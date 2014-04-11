class Diamond::Thesis < ActiveRecord::Base

    translates :title, :description
    globalize_accessors :locales => I18n.available_locales

    belongs_to :annual
    belongs_to :supervisor, :class_name => "Employee"
    belongs_to :thesis_type

    has_many :course_thesis, :class_name => "Diamond::CourseThesis", :dependent => :destroy
    has_many :courses, :through => :course_thesis


    def assigned_to_course?(course)
        courses.include?(course)
    end
end
