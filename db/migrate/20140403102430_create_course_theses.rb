class CreateCourseTheses < ActiveRecord::Migration
  def change
    create_table :diamond_course_theses do |t|
	    t.references :course, :thesis
	    t.timestamps
    end
  end
end
