$(document).ready(function() {
  $(".button-delete").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_delete')
    });
    $(this).yesnoDialog("show");
    return false;
  });

  $(".action-accept").click(function(e) {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_student_accept'),
      confirmation_action: function() {
        var _t = this;
        this.footer.find("button.btn-confirmation").click(function() {
          var form = $("<form method='get'>");
          form.prop("action", $(e.currentTarget).prop('href'));
          $("body").append(form);
          form.submit();
        });
      }
    });
    $(this).yesnoDialog("show");
    return false;
  });
});