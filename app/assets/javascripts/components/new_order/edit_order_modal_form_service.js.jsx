var EditOrderModalFormService = React.createClass({
  getInitialState: function() {
    return {
      location_id: this.props.service.location_id,
      brand_ambassador_ids: this.props.service.brand_ambassador_ids,
      first_date: this.props.service.first_date,
      second_date: this.props.service.second_date,
      no_need_second_date: false
    };
  },
  componentWillMount: function(){
    noneedSecondDate = false
    if(this.props.service.no_need_second_date !== undefined) {
      noneedSecondDate = this.props.service.no_need_second_date
    }    

    this.setState({
      no_need_second_date: noneedSecondDate
    });
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
  updateService: function(){
    obj = {status : 0}
    if(this.props.service.index !== undefined) {
      obj = _.extend(obj, {index : this.props.service.index})
    }
    this.props.handleUpdateService(this.props.service, _.extend(this.state, obj));
    $(ReactDOM.findDOMNode(this)).modal('hide');
  },
  render: function(){
    locationOptions = [];
    locationOptions.push(<option key='0' disabled value='0'>
      -- select an location -- </option>)
    this.props.locations.forEach(function(location) {
      locationOptions.push(<option key={location.id}
        value={location.id}>{location.name}</option>)
    });

    var selectDateTimeSecond = null;
    if(this.state.no_need_second_date == false) {
      selectDateTimeSecond = 
        <SelectDateTime handleDateTime={this.addDatetime}
            dateOrder="second_date"
            serviceDate={this.props.service.second_date}
          />
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
              <h4 className="modal-title">Edit Service</h4>
            </div>
            <div className="modal-body">

              <div className="form-group">
                <label className="control-label">Select Location</label>
                <select className="form-control"
                    value={this.state.location_id}
                    onChange={this.handleLocationChange}>
                  {locationOptions}
                </select>
              </div>

              <SelectDateTime handleDateTime={this.addDatetime}
                  dateOrder="first_date"
                  serviceDate={this.props.service.first_date}
                />

              <div className="form-group">
                <label>
                  <input type="checkbox"
                    onClick={this.noNeedSecondDate}
                    defaultChecked={this.state.no_need_second_date}
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
                  brand_ambassador_ids={this.state.brand_ambassador_ids}
                  handleSelectBA={this.addBrandAmbassadorIds}
                  noNeedSecondDate={this.state.no_need_second_date}
                />
              </div>

            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-default"
                data-dismiss="modal">Close</button>
              <button type="button" onClick={this.updateService} className="btn btn-primary">Update</button>
            </div>
          </div>
        </div>
      </div>
    )
  },
});
