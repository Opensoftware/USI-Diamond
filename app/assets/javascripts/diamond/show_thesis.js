$(document).ready(function() {
  $(".button-delete").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_delete')
    });
    $(this).yesnoDialog("show");
    return false;
  });
});