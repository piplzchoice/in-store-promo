class PrintController < ApplicationController
  
  def report
    @report = Report.find(params[:id])
    @service = @report.service

    render layout: "print_report"    
  end

end
