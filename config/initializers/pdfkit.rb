PDFKit.configure do |config|
  if Rails.env == "development"
    config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  end
    
  config.default_options = {
    :page_size => 'A4',
    :print_media_type => true
  }
end
