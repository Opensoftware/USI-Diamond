$(document).ready(function() {
  $(".button-delete").click(function() {
    $(this).yesnoDialog({
      topic: $.i18n._('confirmation_thesis_delete')
    });
    $(this).yesnoDialog("show");
    return false;
  });

  var bestPictures = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: '/students.json',
    remote: '/students?q=%QUERY'
  });

  bestPictures.initialize();

  $('.typeahead').typeahead(null, {
    name: 'best-pictures',
    displayKey: 'value',
    source: bestPictures.ttAdapter()
  });
  $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
  $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');

});