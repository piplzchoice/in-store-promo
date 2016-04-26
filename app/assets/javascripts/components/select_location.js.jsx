var SelectLocation = React.createClass({
  getInitialState: function() {
     return {
         value: null,
         name: "Whole Foods Folsom FOL"
     }
  },
  componentDidMount: function(){
    var that = this;
    var url = "/clients/"+this.props.client_id+"/services/autocomplete_location_name"
    var selectElm = $(ReactDOM.findDOMNode(this.refs.select_location));

    selectElm.select2({
      allowClear: true,
      placeholder: name,
      minimumInputLength: 4,
      ajax: {
        url: url,
        dataType: 'json',
        data: function (term, page) { return { q: term}; },
        results: function (data, page) {
            return {results: data};
        }
      },
      formatResult: function (location) { return location.name },
      formatSelection: function (location) { return location.name },
      dropdownCssClass: "bigdrop",
      escapeMarkup: function (m) { return m; },
      data:[],
      // initSelection : function (element, callback) {
      //   $.ajax(url, {
      //       data: {q: that.state.name},
      //       dataType: "json"
      //   }).done(function(data) {
      //       callback(data[0]);
      //   });
      // },      
    })//.select2('val', that.state.name);

    selectElm.on("change", function() {
        that.handleSelectedLocation($(this).val())
    });    

  },  
  handleSelectedLocation: function(value){    
    this.setState({value: value});
  },
  render: function() {
    return (
      <div className="form-group">
        <label className="control-label">Select Location</label>
        <input type="text" ref="select_location" value={this.state.value} 
        className="select-2-box" type="hidden" />
      </div>      
    );
  }
});