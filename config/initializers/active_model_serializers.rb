# frozen_string_literal: true

ActiveModelSerializers.config.adapter = :json
ActiveModelSerializers.config.key_transform = :underscore
ActiveModelSerializers.config.default_includes = '**'
