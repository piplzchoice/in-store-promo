include Rails.application.routes.url_helpers

class PdfGeneratorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default
  
  def perform(type, data_id, is_update = false)
    file_name = "#{type}-#{Time.now.to_i}.pdf"
    
    case type
    when "report"
      report = Report.find(data_id)

      if is_update
        report.remove_file_pdf
        report.remove_file_pdf = true
        report.save
        report.remove_file_pdf = false
      end

      url = Rails.application.routes.url_helpers.print_report_pdf_url({id: data_id})

      kit = PDFKit.new(url)      
      report.file_pdf = kit.to_file("#{Rails.root}/tmp/#{file_name}")
      report.save
 
    when "invoice"
      invoice = Invoice.find(data_id)
      url = Rails.application.routes.url_helpers.print_invoice_pdf_url({id: data_id})
      
      kit = PDFKit.new(url)      
      invoice.file = kit.to_file("#{Rails.root}/tmp/#{file_name}")
      invoice.save

      ApplicationMailer.send_invoice(invoice.id).deliver
    when "ba_payment"
      statement = Statement.find(data_id)
      url = Rails.application.routes.url_helpers.print_ba_payment_pdf_url({id: data_id})
      
      kit = PDFKit.new(url)      
      statement.file = kit.to_file("#{Rails.root}/tmp/#{file_name}")
      statement.save 

      ApplicationMailer.ba_is_paid(statement.id).deliver     
    end
        
  end
  
end
