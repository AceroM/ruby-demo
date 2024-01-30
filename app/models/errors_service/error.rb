module ErrorsService
  class Error < Record
    has_prefix_id :err
    self.table_name = "errors"

    SEVERITY_TO_EMOJI = {
      error: "🔥",
      warning: "⚠️",
      info: "ℹ️"
    }

    has_many :occurrences, class_name: "ErrorsService::ErrorOccurrence", dependent: :destroy
    validates :exception_class, presence: true
    validates :message, presence: true
    validates :severity, presence: true

    scope :resolved, -> { where.not(resolved_at: nil) }
    scope :unresolved, -> { where(resolved_at: nil) }

    def emoji
      SEVERITY_TO_EMOJI[severity.to_sym]
    end
  end
end