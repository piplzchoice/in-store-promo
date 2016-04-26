var SelectDateTime = React.createClass({
  setDateTime: function(start_at, end_at){
    dateTime = {}
    dateTime[this.props.dateOrder] = {
      start_at: start_at,
      end_at: end_at
    }

    this.props.handleDateTime(dateTime);
  },
  componentDidMount: function(){
    var that = this;
    var startDp = $(ReactDOM.findDOMNode(this.refs.startDp));
    var endDp = $(ReactDOM.findDOMNode(this.refs.endDp));
    var startInput = $(ReactDOM.findDOMNode(this.refs.start_input));
    var endInput = $(ReactDOM.findDOMNode(this.refs.end_input));

    // $('#start_at_first_tbs_datetimepicker').data("DateTimePicker").setDate($("#start_at_first_tbs_datetimepicker").data("date"))
    // $('#end_at_first_tbs_datetimepicker').data("DateTimePicker").setDate($("#end_at_first_tbs_datetimepicker").data("date"))
    startDp.datetimepicker();
    endDp.datetimepicker();

    if(this.props.serviceDate !== "0") {
      startDp.data("DateTimePicker").setDate(this.props.serviceDate.start_at);
      endDp.data("DateTimePicker").setDate(this.props.serviceDate.end_at);
    }

    startDp.on("dp.change", function (e) {
      if(e.date.minute() === 30) {
        e.date.minute(30);
      } else {
        e.date.minute(0);
      }

      $(this).data("DateTimePicker").setDate(e.date);

      // if(!$("#manual-override").prop('checked')) {
        end_at_date = moment(e.date.format());
        end_at_date.hour(end_at_date.hour() + startDp.data("est-service"));
        endDp.data("DateTimePicker").setDate(end_at_date);
      // }
      that.setDateTime(startInput.val(), endInput.val());
    });

    endDp.on("dp.change", function (e) {
      // if(!$("#manual-override").prop('checked')) {
        start_at_date = moment(e.date.format());
        start_at_date.hour(start_at_date.hour() - startDp.data("est-service"));
        startDp.data("DateTimePicker").setDate(start_at_date);
      // }
      // that.setDateTime(startInput.val(), endInput.val());
    });

  },
  handleSelectedLocation: function(value){
    this.setState({value: value});
  },
  render: function() {
    return (
      <div>
        <div className="form-group">
          <label className="control-label">Start at</label>
          <div className='input-group date'
              ref='startDp'
              data-est-service="4">
            <input className="form-control"
                data-url="/clients/3/services/generate_select_ba"
                ref="start_input" name="tbs[start_at_first]"
                readOnly="true" type="text" />
            <span className="input-group-addon">
              <span className="glyphicon glyphicon-calendar"></span>
            </span>
          </div>
        </div>

        <div className="form-group">
          <label className="control-label">End at</label>
            <div className='input-group date' ref='endDp'>
              <input className="form-control"
                  ref="end_input" name="tbs[end_at_first]"
                  readOnly="true" type="text" />
              <span className="input-group-addon">
                <span className="glyphicon glyphicon-calendar"></span>
              </span>
            </div>
        </div>
      </div>
    );
  }
});
