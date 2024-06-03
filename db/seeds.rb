# frozen_string_literal: true

unless (user = User.find_or_initialize_by(email: 'haweris.warraich@gmail.com')).persisted?
  user.update(first_name: 'Haweris', last_name: 'Warraich', username: 'haweris', gender: 'male', date_of_birth: '19 Nov 1998',
              password: 'Password@123', is_active: true)
end
