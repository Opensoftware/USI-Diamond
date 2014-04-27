class Diamond::ThesisEnrollmentType < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  def to_s
    name
  end

  def <=>(other)
    name <=> other.name
  end

  def self.primary
    where(code: :primary).first
  end

  def self.secondary
    where(code: :secondary).first
  end

end
