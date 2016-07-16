var SelectBrandAmbassadors = React.createClass({
  getInitialState: function(){
    return {
      service_id: "",
      checked: false,
      brand_ambassadors: []
    }
  },
  getDefaultProps: function(){
    return {
      brand_ambassador_ids: []
    };
  },
  checkValidate: function(){
    var validate;
    if(this.props.noNeedSecondDate === false) {
      validate = this.props.location_id != 0 && this.props.first_date.start_at !== null && this.props.second_date.start_at !== null
    } else {
      validate = this.props.location_id != 0 && this.props.first_date.start_at !== null
    }
    
    return validate;
  },
  getBrandAmbassadors: function(thatProps){
    if(this.checkValidate()) {
        var url = "/clients/" + thatProps.client_id + "/services/generate_select_ba_tbs"
        var params = {
          service_id: this.state.service_id,location_id: thatProps.location_id,
          first_date: thatProps.first_date, second_date: thatProps.second_date,
          no_need_second_date: thatProps.noNeedSecondDate, react: true,
        }

        this.serverRequest = $.get(url, params, function (data) {
          this.setState({brand_ambassadors: data});
        }.bind(this), "json");
    }
  },
  componentWillMount: function(){
    this.getBrandAmbassadors(this.props)
  },
  componentWillReceiveProps: function(nextProps){
    this.getBrandAmbassadors(nextProps)
  },
  componentWillUnmount: function() {
    if(this.checkValidate()) {
      this.serverRequest.abort();
    }
  },
  handleClick: function(e){
    this.props.handleSelectBA(e)
  },
  render: function() {
    var brandAmbassadors = null
    if(this.state.brand_ambassadors.length !== 0) {
      var brandAmbassadors = this.state.brand_ambassadors.map(function(ba) {
        var defaultChecked = _.contains(this.props.brand_ambassador_ids, ba.id.toString()) ? true : false;
        return (
          <div className="checkbox" key={ba.id}>
            <label key={ba.id}>
              <input type="checkbox"
                key={ba.id}
                value={ba.id}
                onClick={this.handleClick}
                defaultChecked={defaultChecked}
              /> {ba.name}
            </label>
          </div>
        )
      }.bind(this));
    }

    return (
      <div>
        {brandAmbassadors}
      </div>
    );
  }
});
