$(function () {

  $('.show_button, .hide_button').click(function () {
    $(this).toggleClass('hide');
    $(this).next().is('span') ?
      $(this).next().toggleClass('hide') :
      $(this).prev().toggleClass('hide')
  })
});
