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
  addService: function(event){
    alert("click");
  },
  render: function() {
    return(
      <div className="row">
        <div className="col-md-12">
          <button className="btn btn-primary" onClick={this.handleShowModal}>Add Service</button>
          {this.state.view.showModal ? <NewOrderModalFormService handleHideModal={this.handleHideModal}/> : null}
        </div>
      </div>      
    );    
  }
});