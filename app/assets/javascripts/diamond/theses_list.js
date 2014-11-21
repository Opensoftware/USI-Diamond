//= require diamond/thesis_menu

$(document).ready(function() {

  $("button.select-all").click(function() {
    $("button.button-checkbox", "div.theses-list").trigger("checkbox-change-state");
  });


  $("button.destroy-all").lazy_form_confirmable_action({
    topic: 'confirmation_theses_delete',
    success_action: function(obj, key, val) {
      $("#thesis-"+key).remove();
    }
  });
  $("button.deny-selected").lazy_form_confirmable_action({
    topic: 'confirmation_theses_deny',
    success_action: function(obj, key, value) {
      $("#thesis-"+key).replaceWith($.parseHTML(value));
    }
  });
  $("button.accept-selected").lazy_form_confirmable_action({
    topic: 'confirmation_theses_accept',
    success_action: function(obj, key, value) {
      $("#thesis-"+key).replaceWith($.parseHTML(value));
    }
  });

});