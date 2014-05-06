$(document).ready(function() {

  $("div.theses-list")
  .on("click", "button.button-delete", function() {
    $(this).yesnoDialogRemote({
      topic: $.i18n._('confirmation_thesis_delete')
    });
    $(this).yesnoDialogRemote("show");
  })
  .on("checkbox-change-state", "button.button-checkbox", function() {
    $(this).toggleClass('button-small-checkbox-selected');
    $(this).next().prop('disabled', !$(this).next().is(":disabled"));
  })
  .on("checkbox-uncheck", "button.button-checkbox", function() {
    $(this).removeClass('button-small-checkbox-selected');
    $(this).next().prop('disabled', true);
  })
  .on("click", "button.button-checkbox", function() {
    $(this).trigger("checkbox-change-state");
  })
  .on("click", "a.button-accept", function() {
    $(this).confirmable_action({
      topic: 'confirmation_thesis_accept',
      success_action: function(obj, key, value) {
        $("#thesis-"+key).replaceWith($.parseHTML(value));
      }
    });
    $(this).confirmable_action("show");
    return false;
  });


});