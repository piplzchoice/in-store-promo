$(function() {  

  $("#print_calendar_as_pdf").on("click", function(){
    html2canvas(document.getElementById("calendar-and-legend"), {
      onrendered: function(canvas) {
        $("#dataurl").val(canvas.toDataURL("image/png"));
        $("#export-calendar").submit();
      }
    });
  });  

  $("#view-calendar-filter").on("click", function(){  
    url = $(this).data("url") + "?&status=" + $("#status").val() + "&assigned_to=" + $("#assigned_to").val() + "&project_name=" + $("#project_name").val() + "&client_name=" + $("#client_name").val();
    // var win = window.open(url, '_blank');
    // win.focus();
    window.location = url;
  });

  $(document).on("click", ".pagination li a", function(){
    $("#page").val(getParameterByName("page", $(this).prop("href")));
    $("#filter-data").submit();
    return false
  });

  // if($("#co-op-price-box").is(':checked')) {
  //   $("#co-op-client-name").show();
  // } else {
  //   $("#co-op-client-name").hide();
  // }

  $(document).on("change", "#co-op-price-box", function(){
    if($("#co-op-price-box").is(':checked')) {
      $("#co-op-client-name").show();
    } else {
      $("#co-op-client-name").hide();
    }
  });  

  $(document).on("change", ".reconcile-checkbox", function(){
    sum = 0
    $(".reconcile-checkbox:checked").each(function(i, obj) {
      sum += parseFloat($(obj).data("total"))
    });      

    if(sum !== 0) {
      total = "$" + sum
    } else {
      total = 0
    }

    $("#reconcile-grand-total").html("<strong>" + total + "</strong>");
  });  

  $(document).on("change", ".ba-payments-checkbox", function(){    
    sum = 0
    $(".ba-payments-checkbox:checked").each(function(i, obj) {
      sum += parseFloat($(obj).data("total"))
    });      

    if(sum !== 0) {
      total = "$" + sum
    } else {
      total = 0
    }

    $("#total-ba-paid").html("<strong>" + total + "</strong>");
  });    

  $("#new_report, .edit_report").submit(function(){
    if($("#submit-report-data").data("mileage")) {
      if($("#can_submit").val() === "0") {
        if(!$("#no-travel-expense").prop('checked')) {
          if($("#report_travel_expense").val() !== "") {
            $("#travel-expense-field").val($("#report_travel_expense").val());
          }

          $('#travel-expense-modal').modal({
            backdrop: 'static',
            keyboard: true
          })
          
          $("#travel-expense-modal").modal("show");  
          return false;
        } else {
          $("#report_travel_expense").val("");
        }
      }
    }
  });

  $("#insert_add_item").on("click", function(){
    $('#insert-add-item-modal').modal({
      backdrop: 'static',
      keyboard: true
    })
    
    $("#insert-add-item-modal").modal("show");  
    return false;    
  });

  $("#submit-insert-add-item-amount").on("click", function(){
    row = "<tr>" +
        "<td>&nbsp;</td>" +
        "<td>" + $("#insert-add-item-description").val() + "</td>" +
        "<td><input type='hidden' name='line-items[]desc' value='" + $("#insert-add-item-description").val() + "' /></td>" +
        "<td>&nbsp;</td>" +
        "<td>&nbsp;</td>" +
        "<td><input type='hidden' name='line-items[]amount' value='" + $("#insert-add-item-amount").val() + "' /></td>" +
        "<td class='amount-add-item' data-amout='" + $("#insert-add-item-amount").val() + "'>$" + 
          $("#insert-add-item-amount").val() + " <a href='#add-item-result' class='remove-line-item'>(X)</a></td>" +
      "</tr>";
    $("#add-item-result").before(row);

    sum = 0;
    $.each($(".amount-add-item"), function( index, value ) { 
      sum += parseFloat($($(".amount-add-item")[index]).data("amout"));
    });
    $("#due-total-all").html("$" + (parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));
    $("#grand_total_all").val((parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));
    
    $("#insert-add-item-modal").modal("hide");
    $("#insert-add-item-description").val("");
    $("#insert-add-item-amount").val("");
  });

  $(document).on("click", ".remove-line-item", function(){
    $(this).parent().parent().remove();
    sum = 0;
    $.each($(".amount-add-item"), function( index, value ) { 
      sum += parseFloat($($(".amount-add-item")[index]).data("amout"));
    });
    $("#due-total-all").html("$" + (parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));       
    $("#grand_total_all").val((parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));
  });
  
  $("#submit-travel-expense").click(function(){
    if($("#travel-expense-field").val() === "") {
      $("#travel-expense-field").val(0)
    }
    $("#report_travel_expense").val($("#travel-expense-field").val());
    $("#can_submit").val(1);
    $("#new_report, .edit_report").submit();
  });

  $(document).on("click", ".order-data", function(){
    column = $(this).data("sort")
    if(column === $("#sort").val()) {
      if($("#direction").val() === "desc") {
        $("#direction").val("asc")
      } else {
        $("#direction").val("desc")
      }
    } else {
      $("#sort").val(column)
      $("#direction").val("desc")
    }
    $("#page").val(1);
    $("#filter-data").submit();
  })

  $(".filter-params").on("change", function(){
    $("#page").val(1);
    $("#direction").val("desc");
    $("#sort").val("start_at");
  });

  $(".tooltip-legend").tooltip();
  checkbox_avalaible_click();
  generate_select_ba
  if($('.dp-service').length !== 0) {

    $("#service_start_at").val("");
    $("#service_end_at").val("");

    $('.dp-service').datetimepicker();

    $(".dp-service#start_at_datetimepicker").on("dp.change", function (e) {  
      if(e.date.minute() === 30) {
        e.date.minute(30);
      } else {
        e.date.minute(0);
      }
      
      $(this).data("DateTimePicker").setDate(e.date);

      if(!$("#manual-override").prop('checked')) {
        end_at_date = moment(e.date.format());
        end_at_date.hour(end_at_date.hour() + $("#start_at_datetimepicker").data("est-service"));
        $('.dp-service#end_at_datetimepicker').data("DateTimePicker").setDate(end_at_date);
      }

      if($('.dp-service#start_at_datetimepicker').data("DateTimePicker").getDate().date() == $('.dp-service#end_at_datetimepicker').data("DateTimePicker").getDate().date()) {
        generate_select_ba();
      } else {
        $("#select-ba").html("");
      }
      
    });

    $(".dp-service#end_at_datetimepicker").on("dp.change", function (e) {
      // e.date.minute(0);
      // $(this).data("DateTimePicker").setDate(e.date);

      if(!$("#manual-override").prop('checked')) {
        start_at_date = moment(e.date.format());
        start_at_date.hour(start_at_date.hour() - $("#start_at_datetimepicker").data("est-service"));
        $('.dp-service#start_at_datetimepicker').data("DateTimePicker").setDate(start_at_date);
      }      

      if($('.dp-service#start_at_datetimepicker').data("DateTimePicker").getDate().date() == $('.dp-service#end_at_datetimepicker').data("DateTimePicker").getDate().date()) {
        generate_select_ba();
      } else {
        $("#select-ba").html("");
      }
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
    if($("#service_location_id").data("state") === "new") {
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
          formatResult: function (location) { return location.name + " - " + location.address + ", " + location.city; },
          formatSelection: function (location) { return location.name + " - " + location.address + ", " + location.city; },
          dropdownCssClass: "bigdrop",
          escapeMarkup: function (m) { return m; }
      });

      // $("#service_location_id").select2("data", { 
      //   id: $("#service_location_id").data("location-id"), 
      //   name: $("#service_location_id").data("name")
      // });
    }
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

 $(".product-beginning").keyup(function(){  
  prod_end = 0;
  
  if($("#report_product_" + $(this).data("id") +"_end").val() !== "") {
    prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());
  }

  prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())

  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())

  calculate = prod_beginning - prod_end - prod_sample;
  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
 })
  
 $(".product-end").keyup(function(){  
  prod_beginning = 0;
  
  if($("#report_product_" + $(this).data("id") +"_beginning").val() !== "") {
    prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())
  }

  prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());  
  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())
  calculate = prod_beginning - prod_end - prod_sample;
  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
 })  

 $(".product-sample").keyup(function(){  
  prod_beginning = 0;
  
  if($("#report_product_" + $(this).data("id") +"_beginning").val() !== "") {
    prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())
  }

  prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());  
  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())
  calculate = prod_beginning - prod_end - prod_sample;
  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
 })  

  $("#export-csv").click(function(){
    $("#status-csv").val($("#status").val())
    $("#assigned-csv").val($("#assigned_to").val())
    $("#client-csv").val($("#client_name").val())
    $("#project-csv").val($("#project_name").val())
    $("#sort-csv").val($("#sort").val())
    $("#direction-csv").val($("#direction").val())
    $("#download-csv").submit();
  })  

  $("#email_template_content").redactor({
    buttons: [
      'html', 'bold', 'italic', 'underline', 'deleted', 'alignleft', 'aligncenter', 'alignright', 'justify', 
      'outdent', 'indent','unorderedlist', 'orderedlist','link', 'formatting'],
    formattingTags: ['h1', 'h2', 'p'],
    // plugins: ['undo', 'redo']
  });  

});  


function generate_select_ba(){
  $.ajax({
    url: $("#service_start_at").data("url"),
    data: { 
      start_at: $("#service_start_at").val(),
      end_at: $("#service_end_at").val(),
      action_method: $("#select-ba").data("action"),
      service_id: $("#checkbox-service").data("service-id")
    }
  })
  .done(function( html ) {    
    $("#select-ba").html("");
    $("#select-ba").append(html);

    if($("#select-ba").data("id") !== "") {
      $("#service_brand_ambassador_id").val($("#select-ba").data("id"))
    }

    if($("#service_brand_ambassador_id").val() === null) {
      $("#service_brand_ambassador_id").val("");
    }
  });  
}


function checkbox_avalaible_click(){
  $("#check-all-available").on("click", function(){
    $(".checkbox-avalaible").prop("checked", true)  
  });

  $(".checkbox-avalaible").on("click", function(){
    elem_parent = $(this).parents("tr");
    if($(this).hasClass("checkbox-day")) {
      if($(this).prop("checked")) {
        elem_parent.find(".checkbox-am").prop("checked", true);
        elem_parent.find(".checkbox-pm").prop("checked", true);
      } else {
        elem_parent.find(".checkbox-am").prop("checked", false);
        elem_parent.find(".checkbox-pm").prop("checked", false);
      }
    }

    if($(this).hasClass("checkbox-am")) {
      if($(this).prop("checked")) {
        elem_parent.find(".checkbox-day").prop("checked", true);
      } else {        
        if(!elem_parent.find(".checkbox-pm").prop("checked")) {
          elem_parent.find(".checkbox-day").prop("checked", false);
        }
      }
    }

    if($(this).hasClass("checkbox-pm")) {
      if($(this).prop("checked")) {
        elem_parent.find(".checkbox-day").prop("checked", true);
      } else {        
        if(!elem_parent.find(".checkbox-am").prop("checked")) {
          elem_parent.find(".checkbox-day").prop("checked", false);
        }
      }
    } 

    // ajax proses
    // kirim2x data utk create or update date nya          

    // $.ajax({
    //   url: //benerin,
    //   data: { 
    //     available_date: {
    //       availablty: $("#service_start_at").val(), 
    //       am: $("#select-ba").data("action"),
    //       pm: $("#select-ba").data("old-id")
    //     }
    //   }
    // })
    // .done(function( html ) {    
    //   $("#select-ba").html("");
    //   $("#select-ba").append(html);

    //   if($("#select-ba").data("id") !== "")
    //     $("#service_brand_ambassador_id").val($("#select-ba").data("id"))
    // });      
  });  
}

function getParameterByName(name, url) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(url);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}