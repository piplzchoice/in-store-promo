function generate_select_ba(){
  $.ajax({
    url: $("#service_start_at").data("url"),
    data: { 
      start_at: $("#service_start_at").val(), 
      action_method: $("#select-ba").data("action"),
      ba_id: $("#select-ba").data("old-id")
    }
  })
  .done(function( html ) {    
    $("#select-ba").html("");
    $("#select-ba").append(html);

    if($("#select-ba").data("id") !== "")
      $("#service_brand_ambassador_id").val($("#select-ba").data("id"))
  });  
  
}

$(function() {  
  // if($(".alert").length !== 0) {
  //   setTimeout($(".alert").hide(), 5000);
  // }
  var date = new Date();

  if($('.dp-service').length !== 0) {

    $("#service_start_at").val("");
    $("#service_end_at").val("");

    $('.dp-service').datetimepicker();

    $(".dp-service#start_at_datetimepicker").on("dp.change",function (e) {   
      e.date.hour(e.date.hour() + 4);
      $('.dp-service#end_at_datetimepicker').data("DateTimePicker").setDate(e.date);
      generate_select_ba();
    });

    $(".dp-service#end_at_datetimepicker").on("dp.change",function (e) {     
      e.date.hour(e.date.hour() - 4);
      $('.dp-service#start_at_datetimepicker').data("DateTimePicker").setDate(e.date);
      // generate_select_ba();
    });

    if($("#start_at_datetimepicker").data("date") !== "")
      $('#start_at_datetimepicker').data("DateTimePicker").setDate($("#start_at_datetimepicker").data("date"))

    if($("#end_at_datetimepicker").data("date") !== "")
      $('#end_at_datetimepicker').data("DateTimePicker").setDate($("#end_at_datetimepicker").data("date"))
  }

  if($(".dp-project#start_at_datetimepicker").length !== 0) {
    $('.dp-project').datetimepicker({
      pickTime: false
    });
    
    $(".dp-project#start_at_datetimepicker").data("DateTimePicker").setDate(moment());      

    if($("#start_at_datetimepicker").data("date") !== "")
      $('#start_at_datetimepicker').data("DateTimePicker").setDate($("#start_at_datetimepicker").data("date"))

    if($("#end_at_datetimepicker").data("date") !== "")
      $('#end_at_datetimepicker').data("DateTimePicker").setDate($("#end_at_datetimepicker").data("date"))    
  }

  if($("#availablty_datetimepicker").length !== 0) {
    $("#availablty_datetimepicker").datetimepicker({
      pickTime: false,
      disabledDates: $("#dates").data("disable")
    });
  }


  $("#new_service").submit(function(){
    if($("#service_start_at").val() !== "" && $("#service_end_at").val() !== "") {
      start_at_value = moment($("#service_start_at").val());
      end_at_value = moment($("#service_end_at").val());
      if(start_at_value.isValid() && end_at_value.isValid()) {
        return true
      } else {
        alert("Date format wrong");
        return false
      }          
    }

  });

  $("#new_project").submit(function(){
    var cond = 0;

    if($("#project_start_at").val() !== "") {
      if(moment($("#project_start_at").val()).isValid()) {
        if($("#project_end_at").val() === "") {
          return true
        } else {
          cond = cond + 1;
        }        
      } else {
        cond = cond + 2;
        alert("Project start date format wrong")
      }
    }

    if($("#project_end_at").val() !== "") {
      if(moment($("#project_end_at").val()).isValid()) {
        cond = cond + 1;
      } else {
        cond = cond + 2;
        alert("Project end date format wrong")
      }
    }  

    if(cond === 0 || cond === 2) {
      return true
    } else {
      return false
    }
  });  
  

  if($("#service_location_id").length !== 0) {
    $("#service_location_id").select2({
        placeholder: "-",
        minimumInputLength: 1,
        ajax: {
            url: $("#service_location_id").data("url"),
            dataType: 'json',
            data: function (term, page) { return { q: term}; },
            results: function (data, page) { 
                return {results: data};
            }
        },
        formatResult: function (location) { return location.name; },
        formatSelection: function (location) { return location.name; },
        dropdownCssClass: "bigdrop",
        escapeMarkup: function (m) { return m; }
    });

    $("#service_location_id").select2("data", { 
      id: $("#service_location_id").data("location-id"), 
      name: $("#service_location_id").data("name")
    });

  }

  if($("#project_client_id").length !== 0) {
    $("#project_client_id").select2({
        placeholder: "-",
        minimumInputLength: 1,
        ajax: {
            url: $("#project_client_id").data("url"),
            dataType: 'json',
            data: function (term, page) { return { q: term}; },
            results: function (data, page) { 
                return {results: data};
            }
        },
        formatResult: function (client) { return client.company_name + " - " + client.first_name + " " + client.last_name; },
        formatSelection: function (client) { return client.company_name + " - " + client.first_name + " " + client.last_name; },
        dropdownCssClass: "bigdrop",
        escapeMarkup: function (m) { return m; }
    });

    // $("#project_client_id").select2("data", { 
    //   id: $("#project_client_id").data("client-id"), 
    //   name: $("#project_client_id").data("name")
    // });    
  }

  if($('#calendar').length !== 0 ) {
    $('#calendar').fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      editable: false,
      events: {
        url: $('#calendar').data("url"),
        error: function() {
          $('#script-warning').show();
        }
      },
      loading: function(bool) {
        $('#loading').toggle(bool);
      }
    });
  }

});  
