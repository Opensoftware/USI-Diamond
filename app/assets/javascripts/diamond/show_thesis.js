$(document).ready(function() {
  $(".button-delete").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_delete')
    });
    $(this).yesnoDialog("show");
    return false;
  });

  $(".action-accept").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_student_accept'),
      confirmation_action: function() {
        var _t = this;
        this.footer.find("button.btn-confirmation").click(function() {
          $(_t.element).clone().removeClass("action-accept")[0].click();
        });

      }
    });
    $(this).yesnoDialog("show");
    return false;
  });
});