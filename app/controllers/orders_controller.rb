class OrdersController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: OrdersController

  def create
    client = Client.find params[:client_id]
    order = client.orders.build(order_params)
    order.location_ids = params[:order_locations].split(",").map{|x| x.to_i}
    order.product_ids = params[:order_products_ids]
    order.save
    redirect_to client_order_url({client_id: params[:client_id], id: order.id}), notice: "Order Created"
  end

  def add_location
    client = Client.find params[:client_id]
    order = client.orders.find params[:id]    
    loc_ids = order.location_ids
    params[:order_locations].split(",").each{|x| loc_ids.push x.to_i}
    order.location_ids = loc_ids.uniq
    order.save
    redirect_to client_order_url({client_id: params[:client_id], id: order.id}), notice: "Location Added"  
  end

  def remove_location
    client = Client.find params[:client_id]
    order = client.orders.find params[:id]
    msg = "Location Removed"
    if order.services.where(location_id: params[:location_id].to_i).size == 0
      loc_ids = order.location_ids
      loc_ids.delete(params[:location_id].to_i)
      order.location_ids = loc_ids 
      order.save
    else
      msg = "can't remove location, is been used by demo"
    end
    redirect_to client_order_url({client_id: params[:client_id], id: order.id}), notice: msg  
  end

  def add_product
    client = Client.find params[:client_id]
    order = client.orders.find params[:id]    
    order.product_ids = params[:order_products_ids]
    order.save
    redirect_to client_order_url({client_id: params[:client_id], id: order.id}), notice: "Product Added"  
  end

  def update
    @client = Client.find(params[:client_id])
    @order = @client.orders.find(params[:id])
    @order.update_attributes(order_params)
    redirect_to client_order_url({client_id: @client.id, id: @order.id}), notice: "Order Updated"
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

  def archive
    client = Client.find(params[:client_id])
    order = client.orders.find(params[:id])
    order.update_attribute(:archived, true)
    respond_to do |format|
      format.json { render json: {success: true} }
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
    params.require(:order).permit(:number, :client_id, :status,
      :dot_number, :product_sample, :to_be_completed_by, :distributor, :comments)
  end
end
