var NewOrderModalFormService = React.createClass({
  getInitialState: function() {
    return {
      location_id: 0,
      brand_ambassador_ids: [],
      first_date: {
        start_at: null,
        end_at: null,
      },
      second_date: {
        start_at: null,
        end_at: null,
      },
      status: 0,
      no_need_second_date: false
    };
  },
  componentDidMount: function(){
    $(ReactDOM.findDOMNode(this)).modal('show');
    $(ReactDOM.findDOMNode(this)).on('hidden.bs.modal', this.props.handleHideModal);
  },
  handleLocationChange: function(event){
    this.setState({location_id: event.target.value});
  },
  noNeedSecondDate: function(event) {
    this.setState({no_need_second_date: event.target.checked});
    if(event.target.checked === true) {
      this.setState({second_date: {start_at: null, end_at: null}});
    }
  },
  addBrandAmbassadorIds: function(event){
    var ids = this.state.brand_ambassador_ids

    if(_.contains(ids, event.target.value)) {
      ids = _.without(ids, event.target.value);
    } else {
      if(ids.length === 2) {
        event.target.checked = false;
      } else {
        ids.push(event.target.value)
      }
    }
    this.setState({brand_ambassador_ids: ids});
  },
  addDatetime: function(selectedDt){
    this.setState(selectedDt)
  },
  addService: function(){
    var validate;
    if(this.state.noNeedSecondDate === false) {
      validate = this.state.location_id != 0 && this.state.first_date.start_at !== null && this.state.second_date.start_at !== null && this.state.brand_ambassador_ids.length != 0
    } else {
      validate = this.state.location_id != 0 && this.state.first_date.start_at !== null && this.state.brand_ambassador_ids.length != 0
    }

    if(validate) {
      this.props.handleNewService(this.state);
      $(ReactDOM.findDOMNode(this)).modal('hide');
    }    
  },
  render: function(){
    locationOptions = [];
    locationOptions.push(<option key='0' disabled value='0'>
      -- select an location -- </option>)
    this.props.locations.forEach(function(location) {
      locationOptions.push(<option key={location.id}
        value={location.id}>{location.name}</option>)
    });
    var defaultChecked = false;

    var selectDateTimeSecond = null;
    if(this.state.no_need_second_date == false) {
      selectDateTimeSecond = 
        <SelectDateTime handleDateTime={this.addDatetime}
          dateOrder="second_date"
          serviceDate="0"
        />;
    }
    return (
      <div className="modal fade">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <button type="button" className="close" data-dismiss="modal"
                aria-label="Close">
                  <span aria-hidden="true">&times;</span>
              </button>
              <h4 className="modal-title">Service Form</h4>
            </div>
            <div className="modal-body">

              <div className="form-group">
                <label className="control-label">Select Location</label>
                <select className="form-control" value={this.state.location_id}
                    onChange={this.handleLocationChange}>
                  {locationOptions}
                </select>
              </div>

              <SelectDateTime handleDateTime={this.addDatetime}
                  dateOrder="first_date"
                  serviceDate="0"
                   />

              <div className="form-group">
                <label>
                  <input type="checkbox"
                    onClick={this.noNeedSecondDate}
                    defaultChecked={defaultChecked}
                  /> No need for 2nd date
                </label>
              </div>

              {selectDateTimeSecond}              

              <div className="form-group">
                <label className="control-label">Select BA</label>
                <SelectBrandAmbassadors
                  client_id={this.props.client_id}
                  location_id={this.state.location_id}
                  first_date={this.state.first_date}
                  second_date={this.state.second_date}
                  handleSelectBA={this.addBrandAmbassadorIds}
                  noNeedSecondDate={this.state.no_need_second_date}
                />
              </div>

            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-default"
                data-dismiss="modal">Close</button>
              <button type="button" onClick={this.addService} className="btn btn-primary">Save</button>
            </div>
          </div>
        </div>
      </div>
    )
  },
});
