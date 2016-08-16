include Rails.application.routes.url_helpers

class ReportPdfGeneratorWorker
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

      url = print_report_pdf_url({id: data_id})

      kit = PDFKit.new(url)      
      report.file_pdf = kit.to_file("#{Rails.root}/tmp/#{file_name}")
      report.save

      # ReportPdfGeneratorWorker.perform_async('report', 1832, true)
    end
        
  end
  
end
