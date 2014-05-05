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

  $("button.select-all").click(function() {
    $("button.button-checkbox", "div.theses-list").trigger("checkbox-change-state");
  });


  $("button.destroy-all").lazy_confirmable_action({
    topic: 'confirmation_theses_delete',
    success_action: function(obj, key, val) {
      $("#thesis-"+key).remove();
    }
  });
  $("button.deny-selected").lazy_confirmable_action({
    topic: 'confirmation_theses_deny',
    success_action: function(obj, key, value) {
      $("#thesis-"+key).replaceWith($.parseHTML(value));
    }
  });
  $("button.accept-selected").lazy_confirmable_action({
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