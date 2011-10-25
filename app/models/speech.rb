class Speech < Document

  class Transcript < Speech; end
  class DraftText < Speech; end
  class SpeakingNotes < Speech; end
  class WrittenStatement < Speech; end
  class OralStatement < Speech; end

  belongs_to :role_appointment

  validates :role_appointment, :delivered_on, :location, presence: true

  before_save :populate_organisations_based_on_role_appointment

  private

  def populate_organisations_based_on_role_appointment
    self.organisations = role_appointment.role.organisations
  end
end