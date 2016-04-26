var ButtonActionOrder = React.createClass({
  getDefaultProps: function(){
    return {
      order_id: "",
      order_status: "",
      client_id: "",
      services: [],
    };
  },
  closeOrder: function(){
    if(this.props.services.length === 0 ||
      _.findWhere(this.props.services, {status: 0}) !== undefined) {
      alert("Can't close order, please add service or set service to tbs")
    } else {
      that = this;
      $.ajax({
        url: "/clients/" + that.props.client_id + "/orders/" + that.props.order_id+ "/update_status",
        method: "PUT",
        data: {status: 1}
      }).success(function(data) {
        window.location.href= "/clients/" + that.props.client_id + "/orders/" + that.props.order_id;
      });
    }
  },
  recurringOrder: function(){
    that = this;
    $.ajax({
      url: "/clients/" + that.props.client_id + "/orders/" + that.props.order_id+ "/recurring",
      method: "POST",
    }).success(function(data) {
      window.location.href= "/clients/" + that.props.client_id + "/orders/" + data.id;
    });
  },
  render: function() {
    var btnAction;
    if(this.props.order_status === "open") {
        btnAction = <button className="btn btn-primary" onClick={this.closeOrder}>Close Order</button>;
    } else {
        btnAction = <button className="btn btn-info" onClick={this.recurringOrder}>Create Recurring Order</button>;
    }

    // kalo di copy sukses, redirect ke new order page nya

    // order_id={this.props.order_id}
    // order_status={this.props.order_status}
    // client_id={this.props.client_id}
    // services={this.props.services}

    return (
      <div className="row">
        <div className="col-md-12">
          {btnAction}
        </div>
      </div>
    );
  }
});
