var NewOrderTableServices = React.createClass({
  render: function() {
    var servicesData = null
    if(this.props.services.length !== 0) {
      var servicesData = this.props.services.map(function(service, index) {
        return (
          <ServiceOrderRow
            key={index}
            indexRow={index}
            number={index + 1}
            service={service}
            locations={this.props.locations}
            order_id={this.props.order_id}
            client_id={this.props.client_id}
            product_ids={this.props.product_ids}
            handleUpdateService={this.props.handleUpdateService}
            handleDeleteService={this.props.handleDeleteService}
          />
        )
      }.bind(this));
    }
    return (
      <div className="row">
        <div className="col-md-12">
          <table className="table">
            <thead>
              <tr>
                <th>No</th>
                <th>Location</th>
                <th>Proposed Date 1</th>
                <th>Proposed Date 2</th>
                <th>BA 1st choice</th>
                <th>BA 2nd choice</th>
                <th>Status</th>
                <th>&nbsp;</th>
              </tr>
            </thead>
            <tbody>
              {servicesData}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
});
