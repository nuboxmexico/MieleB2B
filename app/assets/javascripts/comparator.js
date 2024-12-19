$(document).ready(function(){
  var scroll_trigger = 220;
  var comparator_resume = $('#comparator-resume');
  $(window).on('scroll', function(){
    if ($(window).scrollTop() > scroll_trigger) {
      if (comparator_resume.css('display') != 'flex') {
        comparator_resume.css('display', 'flex')
                         .hide()
                         .fadeIn(500);
      }
    }
    else {
      comparator_resume.fadeOut(500);
    }
  });
});