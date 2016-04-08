// # cari tau cara pakai react-dom
// # buat component utk select2
// # buat component utk date
// # buat form nya

var SelectLocation = React.createClass({
  getInitialState: function() {
     return {
         value: '-'
     }
  },
  componentDidMount: function(){
    $(ReactDOM.findDOMNode(this.refs.select_location)).select2({
      allowClear: true,
      placeholder: "-",
      minimumInputLength: 4,
      ajax: {
          url: "/clients/1/services/autocomplete_location_name",
          dataType: 'json',
          data: function (term, page) { return { q: term}; },
          results: function (data, page) {
              return {results: data};
          },
          cache: true
      },
      formatResult: function (location) { return location.name },
      formatSelection: function (location) { return location.name },
      escapeMarkup: function (m) { return m; },
      data:[],
    })
  },  
  handleSelectedLocation: function(event){
    this.setState({value: event.target.value});
    alert(ReactDOM.findDOMNode(this.refs.location_id).value)
  },
  render: function() {
    return (
      <div className="form-group">
        <label className="control-label">Select Location</label>
        <select ref="select_location" onChange={this.handleSelectedLocation} value={this.state.value}>
          <option>-</option>
        </select>          
        <p>{this.state.value}</p>
      </div>      
    );
  }
});