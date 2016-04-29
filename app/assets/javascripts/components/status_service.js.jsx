var StatusService = React.createClass({
  render: function() {
    var classStatus;
    var textStatus;
    switch (this.props.status) {
      case 0:
        classStatus = "label label-danger";
        textStatus = "Draft";
        break;
      case 1:
        classStatus = "label scheduled";
        textStatus = "Scheduled";
        break;
      case 2:
        classStatus = "label confirmed";
        textStatus = "Confirmed";
        break;
      case 3:
        classStatus = "label rejected";
        textStatus = "Rejected";
        break;
      case 4:
        classStatus = "label";
        textStatus = "Conducted";
        break;
      case 5:
        classStatus = "label unrespond";
        textStatus = "Unrespond";
        break;
      case 6:
        classStatus = "label reported";
        textStatus = "Reported";
        break;
      case 7:
        classStatus = "label paid";
        textStatus = "Paid";
        break;
      case 8:
        classStatus = "label ba-paid";
        textStatus = "BA Paid";
        break;
      case 9:
        classStatus = "label cancelled";
        textStatus = "Cancelled";
        break;
      case 10:
        classStatus = "label conducted";
        textStatus = "Invoiced";
        break;
      case 11:
        classStatus = "label inventory-confirmed";
        textStatus = "Inventory Confirmed";
        break;
      case 12:
        classStatus = "label tbs";
        textStatus = "TBS";
        break;
    }
    return (
      <span className={classStatus}>{textStatus}</span>
    );
  }
});
