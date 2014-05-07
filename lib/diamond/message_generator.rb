module Diamond
  module MessageGenerator

    def self.included(base)
      base.after_create :create_message
    end

    private
    def create_message
      ::Resque.enqueue(ThesisMessageGenerator, self.id, self.class.name, User.current.try(:id), self.thesis_id)
    end
  end
end