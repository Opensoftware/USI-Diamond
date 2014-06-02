ActiveRecord::Base.transaction do

  Role.create!(:name => "Promotor", :const_name => :supervisor)
  Role.create!(:name => "Administrator katedralny", :const_name => :department_admin)
  Role.create!(:name => "Administrator wydziałowy", :const_name => :admin)
  Role.create!(:name => "Student", :const_name => :student)

  # TODO replace that with AcademicYear
  fall = Semester.create!(name_pl: "Zimowy", name_en: "Fall", const_name: "fall")
  Semester.create!(name_pl: "Letni", name_en: "Spring", const_name: "spring")

  semester = EnrollmentSemester.new(annual_id: Annual.first.id,
    thesis_enrollments_begin: DateTime.new(2014,5,1),
    thesis_enrollments_end: DateTime.new(2014,5,30),
    elective_enrollments_begin: DateTime.new(2014,6,15),
    elective_enrollments_end: DateTime.new(2014,6,21), semester_id: fall.id)
  semester.save!
  settings = Settings.new(current_annual_id: Annual.first.id, current_semester_id: semester.id)
  settings.save!

  Diamond::ThesisType.create!(name_pl: "Praca Inżynierska", name_en: "Engineering Thesis", short_name_pl: "Inż", short_name_en: "BSc")
  Diamond::ThesisType.create!(name_pl: "Praca Magisterska", name_en: "Master Thesis", short_name_pl: "Mgr", short_name_en: "MSc")
  Diamond::ThesisType.create!(name_pl: "Praca Licencjacka", name_en: "Licentiate thesis", short_name_pl: "Lic", short_name_en: "Lic")
end
