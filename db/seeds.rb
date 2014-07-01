if User.find_by_email('admin@ism.com').blank?
  user = User.create(email: 'admin@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :admin
  puts "user admin created"
end

if User.find_by_email('ismp@ism.com').blank?
  user = User.create(email: 'ismp@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :ismp
  puts "user ismp created"
end

if User.find_by_email('ba@ism.com').blank?
  user = User.create(email: 'ba@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :ba
  puts "user ba created"
end

if User.find_by_email('client@ism.com').blank?
  user = User.create(email: 'client@ism.com',
    password: '1q2w3e4r5t', password_confirmation: '1q2w3e4r5t')
  user.add_role :client
  puts "user client created"
end