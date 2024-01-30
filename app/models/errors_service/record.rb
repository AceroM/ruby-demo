module ErrorsService
  class Record < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: { writing: :errors, reading: :errors }
  end
end

ActiveSupport.run_load_hooks :solid_errors_record, ErrorsService::Record
