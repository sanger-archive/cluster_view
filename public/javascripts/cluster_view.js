$(function() {
  // Handle prefilled fields by clearing their value and that prefilled marker.
  $('.prefilled').click(function(event) {
    $(this).val('');
    $(this).removeClass('prefilled');
    $(this).unbind('click', $(this).data('events').click[ 0 ]);
  });
});
