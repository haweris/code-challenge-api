# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# ---------- Pre Load Models ----------
if Rails.env.development?
  Dir[Rails.root.join('app/models/*.rb')].each do |file_name|
    require file_name
  end
end
