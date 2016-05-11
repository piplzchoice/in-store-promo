var NewOrderAddService = React.createClass({
  getInitialState: function() {
      return { view: { showModal: false } };
  },
  handleHideModal: function() {
      this.setState({ view: { showModal: false } });
  },
  handleShowModal: function() {
      this.setState({ view: { showModal: true } });
  },
  render: function() {
    var showBtn;
    if (this.props.order_status !== "open"){
      showBtn = {display: "none"}
    }
    return(
      <div className="col-md-2">
        <button className="btn btn-info" style={showBtn} onClick={this.handleShowModal}>Add Service</button>
        {this.state.view.showModal ?
          <NewOrderModalFormService
              locations={this.props.locations}
              handleHideModal={this.handleHideModal}
              client_id={this.props.client_id}
              handleNewService={this.props.handleNewService}
            />
          : null
        }
      </div>
    );
  }
});
