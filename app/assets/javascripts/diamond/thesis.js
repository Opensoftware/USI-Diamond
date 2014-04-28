$(document).ready(function() {
  var validation_form = $( "form.new-thesis" );
  var validation_handler = validation_form.validate();

  $("button.selectable-btn").click(function() {
    $(this).toggleClass('selectable-btn-hover');
    $(this).next().prop('disabled', !$(this).next().is(":disabled"));
  });

  $("input.save-and-add").click(function() {
    if (validation_handler.form()) {
      var context = $(this).closest("form");
      var form = $("form.new-thesis");
      var req = $(this).bindReq({
        context: context,
        serialized_data: [form.serialize(), context.serialize()].join("&"),
        custom: {
          success: function(response) {
            if(response.success) {
              if(response.clear) {
                form.find("input, textarea").val("");
                form.find("input[type='radio']").removeAttr('checked');
                form.find("button.selectable-btn").each(function() {
                  $(this).next().prop("disabled", true);
                  $(this).removeClass("selectable-btn-hover");
                });
              }
            }
          }
        }
      });
      req.bindReq("perform");
    }
    return false;
  });

  $("input.save-and-close").click(function() {
    var context = $(this).closest("form");

    if(validation_handler.form()) {
      var form = $("<form method='post'/>");
      form.append($("form.new-thesis").find("input[name='_method']"));
      form.prop("action", context.prop("action")+"?"+[$("form.new-thesis").serialize(), context.serialize()].join("&"));
      $("body").append(form);
      form.submit();
    }
    return false;
  });

  $("select#thesis_student_amount").change(function(e) {
    var context = $("div.enrollments > div:last");
    context.toggle();
  });


});