class ProductsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @client = Client.find params[:client_id]
    @products = @client.products
    @product = Product.new
  end

  def create
    @client = Client.find params[:client_id]
    @product = @client.products.build(product_params)

    if @client.products.count == 15
      msg = "Max Product is 15"
    else
      msg = "Product Created"
      @product.save      
    end

    respond_to do |format|
      format.html {redirect_to client_products_url(client_id: @client.id), notice: msg}
    end        
  end

  def destroy
    @client = Client.find params[:client_id]
    @product = @client.products.find params[:id]
    @product.destroy
    respond_to do |format|
      format.html {redirect_to client_products_url(client_id: @client.id), notice: "Product Deleted"}
    end            
  end

  private
  def product_params
    params.require(:product).permit(:name)
  end  
end