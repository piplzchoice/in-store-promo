if User.find_by_email('admin@ism.com').blank?
  user = User.create(email: 'admin@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :admin
  puts "user admin created"
end

if DefaultValue.all.size == 0
  DefaultValue.create(rate_project: 150)
  puts "default value created"
end