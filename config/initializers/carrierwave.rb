CarrierWave.configure do |config|
  if Rails.env != 'development'
    config.storage    = :aws
    config.aws_bucket = ENV['AWS_DIRECTORY']
    config.aws_acl    = :public_read
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

    config.aws_credentials = {
      access_key_id:     ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']

    }
  else
    config.storage = :file
  end
end