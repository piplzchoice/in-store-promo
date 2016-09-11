class PrintController < ApplicationController
  
  def report
    @report = Report.find(params[:id])
    @service = @report.service

    render layout: "print_report"    
  end

  def invoice
    @invoice = Invoice.find(params[:id])
    @client = @invoice.client
    @services = Service.find(@invoice.service_ids.split(","))
    
    render layout: "print_invoice"    
  end

  def ba_payment    
    @statement = Statement.find(params[:id])
    @ba = @statement.brand_ambassador
    @services = Service.find(@statement.services_ids)
    @totals_ba_paid = Service.calculate_total_ba_paid(@statement.services_ids)

    render layout: "print_report"
  end

end
