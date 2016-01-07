$(function() {  

  $('.fileupload').fileupload({
    dataType: 'json',
    type: "POST",
    done: function (e, data) {
      $.each(data.result.files, function (index, file) {
        span_id = file.key + "-" + file.id;
        $("#preview-image-" + file.key).append("<span id='" + span_id + "'><br /><img src='" + file.url + 
          "'style='width:300px;height:auto'><input type='hidden' name='image-" + file.key + "[]' value='"+ file.id +"' />" +
          "&nbsp;&nbsp;<a href='#" + span_id + "' class='remove-report-image'" + 
          "data-id='" + span_id + "' data-url='/reports/delete_upload/" + file.key + "/" + file.id +  "'>remove</a><br /></span>");
      });
    }
  });

  $(document).on("click", ".remove-report-image", function(){
    $("#" + $(this).data("id")).remove();
    $.ajax({
        url: $(this).data("url"),
        type: 'DELETE',
        success: function(res){          
        },
    });    
  });

  $(document).on("click", "#view-ba-calendar", function(){
    url = $(this).data("url");
    if($("#location_name").val() !== "") {
      url = url + "?&location_name=" + $("#location_name").val()
    }
    window.location = url;
  });  

  $(document).on("click", "#show-hide-client-name", function(){
    if($("#report_hide_client_name").val() === "f") {
      $("#report_hide_client_name").val("t");
      $("#show-hide-client-name").html("(Client is Hidden)");
    } else if($("#report_hide_client_name").val() === "t") {
      $("#report_hide_client_name").val("f");
      $("#show-hide-client-name").html("(Client is Shown)");
    }
  });  

  $(document).on("click", "#show-hide-client-product", function(){
    if($("#report_hide_client_product").val() === "f") {
      $("#report_hide_client_product").val("t");
      $("#show-hide-client-product").html("(Product is Hidden)");
    } else if($("#report_hide_client_product").val() === "t") {
      $("#report_hide_client_product").val("f");
      $("#show-hide-client-product").html("(Product is Shown)");
    }    
  });  

  $(document).on("click", "#show-hide-client-name-coop", function(){
    if($("#report_hide_client_coop_name").val() === "f") {
      $("#report_hide_client_coop_name").val("t");
      $("#show-hide-client-name-coop").html("(Client is Hidden)");
    } else if($("#report_hide_client_coop_name").val() === "t") {
      $("#report_hide_client_coop_name").val("f");
      $("#show-hide-client-name-coop").html("(Client is Shown)");
    }
  });  

  $(document).on("click", "#show-hide-client-product-coop", function(){
    if($("#report_hide_client_coop_product").val() === "f") {
      $("#report_hide_client_coop_product").val("t");
      $("#show-hide-client-product-coop").html("(Product is Hidden)");
    } else if($("#report_hide_client_coop_product").val() === "t") {
      $("#report_hide_client_coop_product").val("f");
      $("#show-hide-client-product-coop").html("(Product is Shown)");
    }    
  });    

  $(document).on("click", "#selecctall-location", function(){
    if(this.checked) { 
        $('.locations-checkbox').each(function() {
            this.checked = true;
            $("#location_ids").val($("#all_loc_ids").val());
            $("#checked_all_location").val(true);
        });
    }else{
        $('.locations-checkbox').each(function() {
            $("#checked_all_location").val(true);
            this.checked = false;
            $("#location_ids").val("");
        });         
    }
  });

  $("#co_op_client_id").on("change", function(){    
    
    // data_ids = JSON.parse($("#ids-coop-products").val())

    // if(data_ids.length !== 0) {
    //   data = JSON.parse($("#service_product_ids").val())    
    //   data_ids.forEach(function(ids){
    //     index = data.indexOf(""+ ids + "");
    //     if(index !== -1) {
    //       data.splice(index, 1);      
    //     }        
    //   });    
    //   $("#service_product_ids").val(JSON.stringify(data));
    // }

    $.ajax({
      url: "/clients/" + $(this).val() + "/products/get_product_by_client",
    })
    .done(function(data) {
      elm = "";
      // data_ids = [];
      $("#ids-coop-products").val("[]");
      data.forEach(function(dt){
        elm += "<li>" +
            "<input class=\"coop_product_ids\" id=\"product-" + dt.id + "\" name=\"product-" + dt.id + "\" type=\"checkbox\" value=\"" + dt.id + "\">" +
          "&nbsp;" + dt.name + "" +
        "</li>";    
        // data_ids.push(dt.id)     
      });
      $("#coop-products-list").html(elm);
      // $("#ids-coop-products").val(JSON.stringify(data_ids))
    });      
  });

  $(document).on("click", ".coop_product_ids", function(){
    data = JSON.parse($("#ids-coop-products").val())
    if($(this).is(":checked")) {
      data.push($(this).val())
    } else {
      index = data.indexOf($(this).val());
      data.splice(index, 1);
    }
    $("#ids-coop-products").val(JSON.stringify(data))
  });

  $("#export-location").on("click", function(){
    $("#loc_ids").val($("#location_ids").val());
    $("#loc_status").val($("#is_active").val());
    $("#export-data-location").submit();
  })

  $("#deactive-location").on("click", function(){
    $("#loc_deactive_ids").val($("#location_ids").val());
    $("#deactive-data-location").submit();
  })

  $("#save-ba-location").on("click", function(){
    $("#location_ids_save").val($("#location_ids").val());
    $("#create-ba-location").submit();
  })

  $(".filter-location").on("click", function(){
    $("#location_ids").val("");

    if($("#original_location_ids").length === 1) {
      $("#location_ids").val($("#original_location_ids").val());
    }
    
    $("#checked_all_location").val("");
    $("#selecctall-location").prop("checked", false);
    return true;
  });

  $(document).on("change", ".locations-checkbox", function(){
    checked_location(this);
  });    

  if($("#report-product").size() !== 0) {
    if($("#report-product").data("new") && $("#report-product").data("size") === 0) {
      alert("Please notify Admin to add products for this Client");
      $("#submit-report-data").hide();
      $("#new_report").attr("action", "/")
      $("#new_report").attr("method", "get")
    }
  }

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

  if($("#co-op-price-box").is(':checked')) {
    $("#co-op-client-name").show();
  } else {
    $("#co-op-client-name").hide();
  }  

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

  $("#add-product-button").on("click", function(){
    $("#add-product-modal").modal("show");  
  });

  $("#create-invoice").on("click", function(){
    // $("#create-invoice").prop('disabled', true);
    $("#create-invoice").hide();
    if(document.getElementById('invoice_invoice_number').checkValidity() && 
      document.getElementById('invoice-date').checkValidity()) {    
      if($("#add-email").prop('checked')) {
        $('#insert-add-email-modal').modal({
          backdrop: 'static',
          keyboard: true
        })
        
        $("#insert-add-email-modal").modal("show");  
        return false;        
      }
    }      
  });

  $("#update-invoice").on("click", function(){
    if($("#add-email").prop('checked')) {
      $('#insert-add-email-modal').modal({
        backdrop: 'static',
        keyboard: true
      })
      
      $("#insert-add-email-modal").modal("show");  
      return false;        
    }
  });

  $("#btn-add-item-email").on("click", function(){    
    if(document.getElementById('insert-add-email').checkValidity()) {
      elm = "<span class='email-lists' data-email='" + $("#insert-add-email").val() + "'>" + $("#insert-add-email").val() + " <a href='#' class='rm-add-email'>(x)</a></span><br />";
      $("#list-add-email").append(elm);
      $("#insert-add-email").val("");
      return false
    }    
  });

  $("#btn-generate-invoice").on("click", function(){
    val_list_emails = "";
    $(".email-lists").each(function(i, obj) {
      val_list_emails = val_list_emails + $(obj).data("email") + ";";      
    });   
    $("#list_emails").val(val_list_emails);
    $("#form-invoice").submit();
  });

  $(document).on("click", ".rm-add-email", function(){
    $(this).parent().remove()
  });

  $("#form-confirm-inventory").on("submit", function(){
    if($("#service_inventory_confirm_false").is(':checked') === false) {
      if($("#inventory-confirmed-date").val() === "") {
        alert("Please add inventory confirmed date")
        return false
      }
    }    
  });

  $("#form-add-item").on("submit", function(){
    if(document.getElementById('insert-add-item-description').checkValidity() && 
      document.getElementById('insert-add-item-amount').checkValidity()) {
        
        // valAmount = "$" + $("#insert-add-item-amount").val();
        valAmount = accounting.formatMoney($("#insert-add-item-amount").val());        
        if($("#reduction").prop('checked')) {
          valAmount = "(" + valAmount + ")";
        }

        row = "<tr>" +
            "<td>&nbsp;</td>" +
            "<td>" + $("#insert-add-item-description").val() + "</td>" +
            "<td><input type='hidden' name='line-items[]desc' value='" + $("#insert-add-item-description").val() + "' /></td>" +
            "<td>&nbsp;</td>" +
            "<td>&nbsp;</td>" +
            "<td>" +
            "<input type='hidden' name='line-items[]amount' value='" + $("#insert-add-item-amount").val() + "' />" +
            "<input type='hidden' name='line-items[]reduction' value='" + $("#reduction").prop('checked') + "' />" +
            "</td>" +
            "<td class='amount-add-item' data-reduction='" + $("#reduction").prop('checked') + "' data-amout='" + $("#insert-add-item-amount").val() + "'> " + 
              valAmount + " <a href='#add-item-result' class='remove-line-item'>(X)</a> " + 
            "</td>" +
          "</tr>";
        $("#add-item-result").before(row);

        sum = 0;
        $.each($(".amount-add-item"), function( index, value ) { 
          if($($(".amount-add-item")[index]).data("reduction")) {
            sum -= parseFloat($($(".amount-add-item")[index]).data("amout"));
          } else {
            sum += parseFloat($($(".amount-add-item")[index]).data("amout"));            
          }
        });

        

        // $("#due-total-all").html("$" + (parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));
        $("#due-total-all").html(accounting.formatMoney((parseFloat($("#grand-total-all").data("total")) + parseFloat(sum))));
        $("#grand_total_all").val((parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));
        
        $("#insert-add-item-modal").modal("hide");
        $("#insert-add-item-description").val("");
        $("#insert-add-item-amount").val("");
        $("#reduction").prop('checked', false);
        return false;
      }
  });

  $(document).on("click", ".remove-line-item", function(){
    $(this).parent().parent().remove();
    sum = 0;
    $.each($(".amount-add-item"), function( index, value ) { 
      if($($(".amount-add-item")[index]).data("reduction")) {
        sum -= parseFloat($($(".amount-add-item")[index]).data("amout"));
      } else {
        sum += parseFloat($($(".amount-add-item")[index]).data("amout"));            
      }
    });
    // $("#due-total-all").html("$" + (parseFloat($("#grand-total-all").data("total")) + parseFloat(sum)));       
    $("#due-total-all").html(accounting.formatMoney((parseFloat($("#grand-total-all").data("total")) + parseFloat(sum))));
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

  $('.date-received-invoice').datetimepicker({pickTime: false});
  
  $('#invoice-date').datetimepicker({pickTime: false});
  // $("#invoice-date").on("dp.change", function (e) {  
  //   inv_date = e.date.calendar();
  //   due_date = moment(inv_date);
  //   toDate = new Date(inv_date);
  //   toDate.setDate(toDate.getDate() + 15);
  //   $("#invoice-due-date").val(toDate);
  // });

  $(".inv-upper").on("keyup", function(){
    $(this).val($(this).val().toUpperCase());
  });

  $(document).on("click", ".update-invoice", function(){
    console.log("wew");
    amount_received = $("#amount_received_" + $(this).data("id"));
    date_received = $("#date_received_" + $(this).data("id"));

    if(amount_received.val() === "") {
      date_received.val("");
    } else {
      if(amount_received[0].checkValidity() && date_received.val() === "") {
        date_received[0].setCustomValidity('Please fill Date Received');
        date_received[0].validity.valid = false;
      } else {
        date_received[0].setCustomValidity("");
        date_received[0].validity.valid = true;
      }
    }
    return true;
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

  $(".filter-params-invoice").on("change", function(){
    $("#page").val(1);
    $("#direction").val("desc");
    $("#sort").val("issue_date");
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

  if($("#service_product_ids").length !== 0) {
    data = JSON.parse($("#service_product_ids").val())
    if(data.length !== 0) {
      data.forEach(function(val){
        $('#product-' + val).prop('checked', true);
      })
    }
  }

  $(document).on("click", ".product_ids", function(){
    data = JSON.parse($("#service_product_ids").val())
    if($(this).is(":checked")) {
      data.push($(this).val())
    } else {
      index = data.indexOf($(this).val());
      data.splice(index, 1);
    }
    $("#service_product_ids").val(JSON.stringify(data))
  });

  $("#new_service").submit(function(){
    var status = true
    if($("#service_start_at").val() !== "" && $("#service_end_at").val() !== "") {
      start_at_value = moment($("#service_start_at").val());
      end_at_value = moment($("#service_end_at").val());
      if(start_at_value.isValid() && end_at_value.isValid()) {
        status = true;
      } else {
        alert("Date format wrong");
        // return false
        status = false;
      }          
    }

    if(JSON.parse($("#service_product_ids").val()).length === 0) {
      alert("Please select product");
      status = false;
    }    

    return status

  });

  $('#inventory-confirmed-date').datetimepicker({pickTime: false});

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
      
      name = "-"
      // if($("#location_fullname").length !== 0 && $("#location_fullname").val() !== "") {
      //   name = $("#location_fullname").val();
      // }

      $("#service_location_id").select2({    
          allowClear: true,
          placeholder: name,          
          minimumInputLength: 4,
          ajax: {
              url: $("#service_location_id").data("url"),
              dataType: 'json',
              data: function (term, page) { return { q: term}; },
              results: function (data, page) { 
                  $("#location-contact").hide();
                  return {results: data};
              }
          },
          formatResult: function (location) { return location.name },
          formatSelection: function (location) { return location.name },
          dropdownCssClass: "bigdrop",
          escapeMarkup: function (m) { return m; },
          data:[],
          initSelection : function (element, callback) {
            $.ajax($("#service_location_id").data("url"), {
                data: {q: $("#location_fullname").val()},
                dataType: "json"
            }).done(function(data) {
                console.log("done");
                callback(data[0]);
            });
          },          
      }).select2('val', $("#location_name").val());

      $(document).on("click", "abbr", function(e){
        console.log("wew");
        $("#location_name").val("");
      })
      
      $("#service_location_id").on("select2-search-choice-close", function(e){
        console.log("crot");
      })

      $("#service_location_id").on("select2-selecting", function(e){
        if($("#location_fullname").length !== 0) {
          $("#location_name").val(e.choice.id);
        }

        console.log("val=" + e.choice.id);
        // console.log("contact=" + e.choice.contact);
        // console.log("phone=" + e.choice.phone);
        if(e.choice.contact === null && e.choice.phone === null) {
          html = "" +
            "<div class=\"form-group\">" +
              "<label>Contact: </label>" +
              "&nbsp;&nbsp;&nbsp;<input type=\"text\" name=location[contact] required>" +
              "<br>" +
              "<label>Phone: </label>" +
              "&nbsp;&nbsp;&nbsp;<input type=\"text\" name=location[phone] required>" +
            "</div>";

          $("#location-contact").html(html);
          $("#location-contact").show();
        } else {
          html = "" +
            "<div class=\"form-group\">" +
              "<label>Contact: </label>" +
              "<span id=\"location-contact-data\"> " + e.choice.contact + "</span>" +
              "<br>" +
              "<label>Phone: </label>" +
              "<span id=\"location-contact-phone\"> " + e.choice.phone + "</span>" +
            "</div>";

          $("#location-contact").html(html);
          $("#location-contact").show();
        }

      })

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
    url = $('#calendar').data("url")
    if($("#calendar").data("location") !== undefined) {
      url = url + "?location_name=" + $("#calendar").data("location");
    }

    $('#calendar').fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      editable: false,
      events: {
        url: url,
        error: function() {
          $('#script-warning').show();
        }
      },
      loading: function(bool) {
        $('#loading').toggle(bool);
      }
    });
  }


  $("#export-csv").click(function(){
    $("#status-csv").val($("#status").val())
    $("#assigned-csv").val($("#assigned_to").val())
    $("#client-csv").val($("#client_name").val())
    $("#project-csv").val($("#project_name").val())
    $("#sort-csv").val($("#sort").val())
    $("#direction-csv").val($("#direction").val())
    $("#location-csv").val($("#location_name").val())
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


$(document).on("click", ".remove-product", function(){
  $("#row-product-" + $(this).data("id")).remove();

  if($(".row-products").length == 0) {
    alert("Please add products minimum 1");
    $("#submit-report-data").hide();
    $("#new_report").attr("action", "/");
    $("#new_report").attr("method", "get");
  } else {
    $.each($(".row-products"), function(i, v) {
      $(v).find(".counter-product").html(i + 1);
    });
  }

});

$(document).on("click", "#add-product-report", function(){    

  $.each($(".product-lists-modal"), function(i, v){ 
    $(v).show();
  });
  
  $.each($(".row-products"), function(i, v) {
    $("#list-product-" + $(v).data("id")).hide();
  });    

  $("#insert-add-product-report-modal").modal("show");
});

$(document).on("click", "#add-product-coop-report", function(){    

  $.each($(".product-coop-lists-modal"), function(i, v){ 
    $(v).show();
  });
  
  $.each($(".row-coop-products"), function(i, v) {
    $("#list-product-coop-" + $(v).data("id")).hide();
  });    

  $("#insert-add-product-coop-report-modal").modal("show");
});

$(document).on("click", "#submit-list-products", function(){
  $(".checkbox-products:checked").each(function(i, v){ 
    elm =  "" +
    "<tr class=\"row-products\" id=\"row-product-" + $(v).data("id") + "\" data-id=\"" + $(v).data("id") + "\">" +
      "<td>Product <span class=\"counter-product\">x</span></td>" +
      "<td class=\"product-info-id\" data-id=\"" + $(v).data("id") + "\">" +
        "<div class=\"dropdown\">" +
          "<button class=\"btn btn-default dropdown-toggle\" type=\"button\" id=\"dropdownMenu1\" " + 
            "data-toggle=\"dropdown\" aria-expanded=\"true\">" + $(v).data("name") + " <span class=\"caret\"></span></button>" +
          "<ul class=\"dropdown-menu\" role=\"menu\" aria-labelledby=\"dropdownMenu1\">" +
            "<li role=\"presentation\"><a role=\"menuitem\" tabindex=\"-1\" data-id=\"" + $(v).data("id") + "\"" + 
              "class=\"remove-product\" href=\"#add-product-report\">Remove</a></li>" +
          "</ul>" +
          "<input id=\"report_client_products_name\" name=\"report[client_products][]name\" type=\"hidden\" value=\"" + $(v).data("name") + "\">" +
        "</div>" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-price\" data-id=\"" + $(v).data("id") + "\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_price\" name=\"report[client_products][]price\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-sample\" data-id=\"" + $(v).data("id") + "\" class=\"product-sample\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_sample\" name=\"report[client_products][]sample\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-beginning\" data-id=\"" + $(v).data("id") + "\" class=\"product-beginning\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_beginning\" name=\"report[client_products][]beginning\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-end\" data-id=\"" + $(v).data("id") + "\" class=\"product-end\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_end\" name=\"report[client_products][]end\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-sold\" data-id=\"" + $(v).data("id") + "\" class=\"product-sold\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_sold\" name=\"report[client_products][]sold\" type=\"text\">" +
      "</td>" +
    "</tr>";          

    $("#row-products").append(elm)
    $.each($(".row-products"), function(i, v) {
      $(v).find(".counter-product").html(i + 1);
    });      

    $("#submit-report-data").show();
    $("#new_report").attr("action", "/reports");
    $("#new_report").attr("method", "post");    
  });

  $("#insert-add-product-report-modal").modal("hide");
});

$(document).on("click", ".remove-coop-product", function(){
  $("#row-product-" + $(this).data("id")).remove();

  if($(".row-coop-products").length == 0) {
    alert("Please add products minimum 1");
    $("#submit-report-data").hide();
    $("#new_report").attr("action", "/");
    $("#new_report").attr("method", "get");
  } else {
    $.each($(".row-coop-products"), function(i, v) {
      $(v).find(".counter-product").html(i + 1);
    });
  }

});

$(document).on("click", "#add-product-coop-report", function(){    

  $.each($(".product-coop-lists-modal"), function(i, v){ 
    $(v).show();
  });
  
  $.each($(".row-coop-products"), function(i, v) {
    $("#list-product-coop-" + $(v).data("id")).hide();
  });    

  $("#insert-add-product-coop-report-modal").modal("show");
});


$(document).on("click", "#submit-list-coop-products", function(){
  $(".checkbox-coop-products:checked").each(function(i, v){ 
    elm =  "" +
    "<tr class=\"row-coop-products\" id=\"row-product-" + $(v).data("id") + "\" data-id=\"" + $(v).data("id") + "\">" +
      "<td>Product <span class=\"counter-product\">x</span></td>" +
      "<td class=\"product-info-id\" data-id=\"" + $(v).data("id") + "\">" +
        "<div class=\"dropdown\">" +
          "<button class=\"btn btn-default dropdown-toggle\" type=\"button\" id=\"dropdownMenu1\" " + 
            "data-toggle=\"dropdown\" aria-expanded=\"true\">" + $(v).data("name") + " <span class=\"caret\"></span></button>" +
          "<ul class=\"dropdown-menu\" role=\"menu\" aria-labelledby=\"dropdownMenu1\">" +
            "<li role=\"presentation\"><a role=\"menuitem\" tabindex=\"-1\" data-id=\"" + $(v).data("id") + "\"" + 
              "class=\"remove-coop-product\" href=\"#add-product-coop-report\">Remove</a></li>" +
          "</ul>" +
          "<input id=\"report_client_products_name\" name=\"report[client_coop_products][]name\" type=\"hidden\" value=\"" + $(v).data("name") + "\">" +
        "</div>" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-price\" data-id=\"" + $(v).data("id") + "\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_price\" name=\"report[client_coop_products][]price\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-sample\" data-id=\"" + $(v).data("id") + "\" class=\"product-sample\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_sample\" name=\"report[client_coop_products][]sample\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-beginning\" data-id=\"" + $(v).data("id") + "\" class=\"product-beginning\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_beginning\" name=\"report[client_coop_products][]beginning\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-end\" data-id=\"" + $(v).data("id") + "\" class=\"product-end\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_end\" name=\"report[client_coop_products][]end\" type=\"text\">" +
      "</td>" +
      "<td id=\"product-" + $(v).data("id") + "-sold\" data-id=\"" + $(v).data("id") + "\" class=\"product-sold\">" +
        "<input class=\"width_35px\" id=\"report_product_" + $(v).data("id") + "_sold\" name=\"report[client_coop_products][]sold\" type=\"text\">" +
      "</td>" +
    "</tr>";          

    $("#row-coop-products").append(elm)
    $.each($(".row-coop-products"), function(i, v) {
      $(v).find(".counter-product").html(i + 1);
    });      

    $("#submit-report-data").show();
    $("#new_report").attr("action", "/reports");
    $("#new_report").attr("method", "post");    
  });

  $("#insert-add-product-coop-report-modal").modal("hide");
});

$(document).on("keyup", ".product-beginning", function(){  
  if($("#report_product_" + $(this).data("id") +"_beginning").val() === "") {
    $("#report_product_" + $(this).data("id") +"_beginning").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_end").val() === "") {
    $("#report_product_" + $(this).data("id") +"_end").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_sample").val() === "") {
    $("#report_product_" + $(this).data("id") +"_sample").val(0)
  }


  prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());
  prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())
  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())
  calculate = prod_beginning - (prod_end + prod_sample);

  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
});

$(document).on("keyup", ".product-end", function(){  
  prod_beginning = 0;

  if($("#report_product_" + $(this).data("id") +"_beginning").val() === "") {
    $("#report_product_" + $(this).data("id") +"_beginning").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_end").val() === "") {
    $("#report_product_" + $(this).data("id") +"_end").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_sample").val() === "") {
    $("#report_product_" + $(this).data("id") +"_sample").val(0)
  }

  prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())
  prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());  
  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())

  calculate = prod_beginning - (prod_end + prod_sample);
  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
});

$(document).on("keyup", ".product-sample", function(){  
  if($("#report_product_" + $(this).data("id") +"_beginning").val() === "") {
    $("#report_product_" + $(this).data("id") +"_beginning").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_end").val() === "") {
    $("#report_product_" + $(this).data("id") +"_end").val(0)
  }

  if($("#report_product_" + $(this).data("id") +"_sample").val() === "") {
    $("#report_product_" + $(this).data("id") +"_sample").val(0)
  }
  
  prod_beginning = parseInt($("#report_product_" + $(this).data("id") +"_beginning").val())
  prod_end = parseInt($("#report_product_" + $(this).data("id") +"_end").val());  
  prod_sample = parseInt($("#report_product_" + $(this).data("id") +"_sample").val())
  calculate = prod_beginning - (prod_end + prod_sample);
  $("#report_product_" + $(this).data("id") +"_sold").val(calculate);
});

function generate_select_ba(){
  $.ajax({
    url: $("#service_start_at").data("url"),
    data: { 
      start_at: $("#service_start_at").val(),
      end_at: $("#service_end_at").val(),
      action_method: $("#select-ba").data("action"),
      service_id: $("#checkbox-service").data("service-id"),
      location_id: $("#service_location_id").val()
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
  });  
}

function getParameterByName(name, url) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(url);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function checked_location(obj) {
  var arr_ids = [];
  if($("#location_ids").val() !== "") {
    arr_ids = $("#location_ids").val().split(",");
  }

  if($(obj).is(':checked')) {
    arr_ids.push($(obj).val());
  } else {
    var index = arr_ids.indexOf($(obj).val());
    arr_ids.splice(index, 1);
  }

  $("#location_ids").val(arr_ids.join(","));    
}