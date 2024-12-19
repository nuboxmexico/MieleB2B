function ToggleCardContent(id) { $(id).slideToggle('fast'); }

function homologateBoxHeights(class_name) {
  var heights = []; 
  $(class_name).each(function(){
    heights.push($(this).height());
  });
  var max_height = Math.max.apply(null, heights);
  $(class_name).each(function(){
    $(this).height(max_height);
  });
}