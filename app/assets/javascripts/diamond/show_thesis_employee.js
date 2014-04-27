$(document).ready(function() {
  var students_provider = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    //    prefetch: '/students.json',
    remote: '/students?q=%QUERY'
  });

  students_provider.initialize();

  $('.typeahead').typeahead(null, {
    name: 'students',
    displayKey: 'value',
    source: students_provider.ttAdapter(),
    templates: {
      empty: [
      '<div class="empty-message">',
      $.i18n._('notice_students_not_found'),
      '</div>'
      ].join('\n'),
      suggestion: Handlebars.compile([
        '<p class="student-idx-number">{{index_number}}</p>',
        '<p class="student-data">{{value}}</p>',
        '<p class="student-studies">{{studies}}</p>'
        ].join(''))
    }
  }).on('typeahead:selected', function(event, datum) {
    $(event.target).closest("div").children().last().val(datum.id);
  });
  $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
  $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');

});