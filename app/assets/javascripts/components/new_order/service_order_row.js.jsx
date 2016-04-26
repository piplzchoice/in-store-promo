var ServiceOrderRow = React.createClass({
  getInitialState: function() {
      return {
        view: { showModal: false },
        location_name: "",
        first_ba: "",
        second_ba: "",
      };
  },
  getDataService: function(thatProps){
    var url = "/clients/" + thatProps.client_id + "/services/get_data_ids"
    var params = {
      location_id: thatProps.service.location_id,
      ba_ids: thatProps.service.brand_ambassador_ids
    }

    this.serverRequest = $.get(url, params, function (data) {
      this.setState({
        location_name: data.location_name,
        first_ba: data.first_ba,
        second_ba: data.second_ba,
      });
    }.bind(this), "json");
  },
  componentWillMount: function(){
    this.getDataService(this.props)
  },
  componentWillReceiveProps: function(nextProps){
    this.getDataService(nextProps)
  },
  componentWillUnmount: function() {
    this.serverRequest.abort();
  },
  handleHideModal: function() {
      this.setState({ view: { showModal: false } });
  },
  handleShowModal: function() {
      this.setState({ view: { showModal: true } });
  },
  promoteTBS: function(){
    if(this.validateService()) {
      that = this;
      $.ajax({
        url: "/clients/" + this.props.client_id + "/services/create_tbs",
        method: "POST",
        data: {
          order_id: this.props.order_id,
          product_ids: this.props.product_ids,
          service: {
            location_id: this.props.service.location_id,
            details: "",
            is_old_service: false,
            product_ids: JSON.stringify(this.props.product_ids)
          },
          tbs: {
              start_at_first: this.props.service.first_date.start_at,
              end_at_first: this.props.service.first_date.end_at,
              start_at_second: this.props.service.second_date.start_at,
              end_at_second: this.props.service.second_date.end_at,
              ba_ids: JSON.stringify(this.props.service.brand_ambassador_ids)
          },
          index: (this.props.service.index !== undefined ? this.props.service.index : null)
        }
      }).success(function(data) {
        that.props.handleUpdateService(that.props.service, data);
      });
    } else {
      alert("please complete the service")
    }
  },
  validateService: function(){
    return this.props.service.brand_ambassador_ids.length !== 0 ||
      this.props.service.first_date.start_at !== null ||
      this.props.service.second_date.start_at !== null ||
      this.props.service.location_id !== ""
  },
  removeService: function(){
    if(this.props.service.index !== undefined) {
      that = this;
      $.ajax({
        url: "/clients/" + that.props.client_id + "/orders/" + that.props.order_id+ "/removecopy",
        method: "DELETE",
        data: {index: this.props.service.index}
      }).success(function(data) {
        that.props.handleDeleteService(that.props.service)
      });
    } else {
      this.props.handleDeleteService(this.props.service)
    }
  },
  getDateService: function(date){
    dateFormat = "-"
    if(date.start_at !== null) {
      start_at = moment(new Date(date.start_at))
      end_at = moment(new Date(date.end_at))
      dateFormat = start_at.format("MM/D/YYYY H:mm A") + end_at.format(" - H:mm A");
    }
    return dateFormat
  },
  getStatusService: function(){
    var status;
    switch (this.props.service.status) {
      case 0:
        status = <span className="label label-danger">Draft</span>;
        break;
      case 1:
        status = <span className="label label-success">Scheduled</span>;
        break;
      case 12:
        status = <span className="label label-warning">TBS</span>;
        break;
      default:
        status = <span className="label label-success">On Progress</span>;
    }
    return status;
  },
  getBtnAction: function(){
    var btn = "";
    switch (this.props.service.status) {
      case 0:
        btn = <div>
          <button className="btn btn-danger" onClick={this.removeService}>Remove</button>
          <button className="btn btn-primary" onClick={this.promoteTBS}>Set to TBS</button>
        </div>

        break;
      default:
        var url = "/clients/" + this.props.client_id + "/services/" + this.props.service.id
        btn = <div>
          <a href={url} target="_blank"
            className="btn btn-info">Show</a>
        </div>
    }
    return btn;
  },
  canEditService: function(text){
    if(this.props.service.status === 0) {
      text = <a href="#" onClick={this.handleShowModal}>{text}</a>
    }
    return text
  },
  render: function() {
    return (
      <tr>
        <td>{this.props.number}</td>
        <td>{this.canEditService(this.state.location_name)}</td>
        <td>{this.canEditService(this.getDateService(this.props.service.first_date))}</td>
        <td>{this.canEditService(this.getDateService(this.props.service.second_date))}</td>
        <td>{this.canEditService(this.state.first_ba)}</td>
        <td>{this.canEditService(this.state.second_ba)}</td>
        <td>{this.getStatusService()}</td>
        <td>{this.getBtnAction()}</td>
        {this.state.view.showModal ?
          <EditOrderModalFormService
            locations={this.props.locations}
            handleHideModal={this.handleHideModal}
            client_id={this.props.client_id}
            service={this.props.service}
            handleUpdateService={this.props.handleUpdateService}
          />
          : null}
      </tr>
    );
  }
});
