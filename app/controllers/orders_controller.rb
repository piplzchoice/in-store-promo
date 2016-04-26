class OrdersController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: OrdersController

  def create
    client = Client.find params[:client_id]
    order = clients.order.build(order_params)
    order.location_ids = params[:order_locations].split(",").map{|x| x.to_i}
    order.product_ids = params[:order_products_ids]
    order.save
    redirect_to edit_client_order_url({client_id: params[:client_id], id: order.id}), notice: "Order Created"
  end

  def show
    @client = Client.find(params[:client_id])
    @order = @client.orders.find(params[:id])
    @services = @order.service_copy.nil? ? [] : @order.service_copy
    @order.services.collect{|x| @services.push x.format_react_component}
    @services.flatten!
  end

  def update_status
    @client = Client.find(params[:client_id])
    @order = @client.orders.find(params[:id])
    @order.update_attribute(:status, params[:status].to_i)
    respond_to do |format|
      format.json { render json: {success: true} }
    end
  end

  def recurring
    client = Client.find(params[:client_id])
    order = client.orders.find(params[:id])
    recurring_order = order.recurring
    respond_to do |format|
      format.json { render json: recurring_order }
    end
  end

  def removecopy
    client = Client.find(params[:client_id])
    order = client.orders.find(params[:id])
    order.service_copy.delete_at(params[:index].to_i)
    order.save
    respond_to do |format|
      format.json { render json: {success: true} }
    end
  end

  private
  def order_params
    params.require(:order).permit(:number, :client_id, :status)
  end
end
