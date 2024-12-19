$(document).ready(function(){
  $('.dispatch-group-container').on('show.bs.collapse', function (e) {
    if (e.target.dataset.type == this.dataset.type) {
      $(this).find('.collapse-dispatch-group-link i').addClass('inverse');
    }
  });
  $('.dispatch-group-container').on('hide.bs.collapse', function (e) {
    if (e.target.dataset.type == this.dataset.type) {
      $(this).find('.collapse-dispatch-group-link i').removeClass('inverse');
    }
  });
  $('.notes-container').on('show.bs.collapse', function (e) {
    if (e.target.dataset.type == this.dataset.type) {
      $(this).find('.collapse-note-link i').addClass('inverse');
    }
  });
  $('.notes-container').on('hide.bs.collapse', function (e) {
    if (e.target.dataset.type == this.dataset.type) {
      $(this).find('.collapse-note-link i').removeClass('inverse');
    }
  });

  $('#dispatch-configuration .collapse-dispatch-group-link').last().click();
  $('#dispatch .collapse-dispatch-group-link').last().click();
  $('#instalation .collapse-dispatch-group-link').last().click();

  $(document).on('click', '.fake-destroy-dispatch-group', function(e){
    e.preventDefault();
    var is_new_record = $(this).data('new');
    var container = $(this).parent();
    swal({
      title: "¿Desea borrar este grupo de despacho?",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Eliminar",
      cancelButtonText: "Cancelar"
    }).then(function (result) {
      if (is_new_record) {
        $(".loader-page").fadeIn();
        location.reload();
      }
      else {
        container.find('.destroy-dispatch-group').click();
      }
    });
  });

  $('.select2-reception-type').select2({
    placeholder: 'Seleccione el tipo de recepción'
  });

  $('.select2-reception-type').change(function(){
    var dispatch_container = $('#'+$(this).data('container-id'));
    var inputs = dispatch_container.find('.input-product-quantity');
    var spans = dispatch_container.find('.span-product-quantity');
    if ($(this).val() == 'partial_reception') {
      inputs.removeClass('hidden');
      spans.addClass('hidden');
    }
    else {
      inputs.addClass('hidden');
      spans.removeClass('hidden');
    }
  });

  $('.installation-confirm-option').change(function(){
    var dispatch_container = $('#'+$(this).data('container-id'));
    if ($(this).val() == 'pending') {
      dispatch_container.find('.pending-installation-note').removeClass('hidden');
    }
    else {
      dispatch_container.find('.pending-installation-note').addClass('hidden');
    }
  });

  $('#add-dispatch-group').click(function(){
    $(".loader-page").fadeIn();
  });
})