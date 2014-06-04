class Xlsx::SupervisorThesesListOfFaculty < Xlsx::SupervisorThesesList

  def initialize(current_user, theses)
    super(current_user, theses)
  end
end
