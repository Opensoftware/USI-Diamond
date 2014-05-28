//= require diamond/thesis_menu

$(document).ready(function() {

  $(".link-export").click(function() {
    $(this).attr("href", $.clear_query_params($(this).attr("href"))+window.location.search);
  });

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

$.widget( "core.per_page_paginator", $.core.loader, {

  before_state_changed: function(ctxt, e) {
    $("input[name='per_page']", ctxt).val($(e.currentTarget).html());
    $("input[name='page']", ctxt).val(1);
  }

});