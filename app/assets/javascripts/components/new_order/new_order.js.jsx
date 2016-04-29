var NewOrder = React.createClass({
  getInitialState: function() {
    return {
      services: this.props.services,
      product_ids: []
    };
  },
  getDefaultProps: function(){
    return {
      services: [],
      product_ids: []
    };
  },
  addService: function(service){
    services = React.addons.update(this.state.services, { $push: [service] })
    this.setState({services: services})
  },
  updateService: function(service, data){
    index = this.state.services.indexOf(service)
    services = React.addons.update(this.state.services, { $splice: [[index, 1, data]] })
    this.replaceState({services: services})
  },
  deleteService: function(service){
    index = this.state.services.indexOf(service)
    services = React.addons.update(this.state.services, { $splice: [[index, 1]] })
    this.replaceState({services: services})
  },
  render: function() {
    return (
      <div>
        <div className="row">
          <NewOrderAddService
            locations={this.props.locations}
            client_id={this.props.client_id}
            order_status={this.props.order_status}
            handleNewService={this.addService}
          />
          <ButtonActionOrder
              order_id={this.props.order_id}
              order_status={this.props.order_status}
              client_id={this.props.client_id}
              services={this.state.services}
            />
        </div>
        <hr />
        <NewOrderTableServices
          services={this.state.services}
          locations={this.props.locations}
          order_id={this.props.order_id}
          client_id={this.props.client_id}
          product_ids={this.props.product_ids}
          handleUpdateService={this.updateService}
          handleDeleteService={this.deleteService}
        />
      </div>
    );
  }
});
