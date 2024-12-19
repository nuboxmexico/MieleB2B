$(document).ready(function(){
  $('.item-price-input').each(function(){
    inputCurrencyFormat($(this)[0]);
  });

  var backup_document_container = $('#backup-document-container');
  if (document.contains(backup_document_container[0])) {
    backup_document_container.hide();
  }
  $('#quotation-payment-type').change(function(){
    if ($(this).val() == 'saldo a favor') {
      backup_document_container.fadeIn();
      $('#backup_document').attr('required', true);
    }
    else {
      backup_document_container.fadeOut();
      $('#backup_document').attr('required', false);
    }
  });

  $('.link-to-tab').click(function(){
    $("#"+$(this).data('to')).click();
  });

  $('.change-quotation-item-quantity').click(function(){
    var container = $(this).parent().parent();
    var value = parseInt(container.find('input[type="hidden"]').val());
    if ($(this).data('action') == 'up') {
      value += 1;
    }
    else if (value > 1) {
      value -= 1;
    }
    container.find('input[type="hidden"]').val(value);
    container.find('.cart-item-quantity').val(value);
    calculateQuotationTotalPrice();
  });

  $('.cart-item-quantity').keyup(function() {
    var container = $(this).parent().parent();
    var value = parseInt($(this).val());
    container.find('input[type="hidden"]').val(value);
    calculateQuotationTotalPrice();
  });

  $('.product-row').on('keyup', '.item-price-input', function() {
    calculateQuotationTotalPrice();
  });

  $('#delete-version').click(function(){
    var url = $(this).data('url');
    swal({
      title: "Se eliminará la versión de la vista actual",
      text: '¿Desea continuar?',
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Continuar",
      cancelButtonText: "Cancelar"
    })
      .then(function (result) {
        $(".loader-page").fadeIn();
        $.ajax({
          url: url + '.json',
          type: 'DELETE'
        }).done(function(response){
          toastr['info']('Cotización borrada con éxito');
          window.location.href = response.url;
        }).fail(function(){
          $('.loader-page').fadeOut('slow');
          toastr['error']('Ocurrió un error al borrar la cotización');
          window.location.href = url;
        });
      });
  });

  $('#save-product-changes').click(function(){
    var url = $(this).data('url');
    swal({
      title: "Se creará una nueva versión de la cotización",
      text: '¿Desea continuar?',
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Continuar",
      cancelButtonText: "Cancelar"
    })
      .then(function (result) {
        $(".loader-page").fadeIn();
        var items = [];
        let quotation = {
          currency: $("#cart-currency-selector").val(),
          exchange_rate_date: $("#exchange_rate_date").val(),
          exchange_rate: $("#exchange_rate").val(),
        }
        $('.product-row').each(function(){
          items.push({
            id: $(this).find('input[name="id"]').val(),
            quantity: $(this).find('input[name="quantity"]').val(),
            price: $(this).find('input[name="price"][type="hidden"]').val()
          });
        });
        $.post(url+'.json', {items: items, quotation: quotation})
          .done(function(response){
            toastr['info']('Nueva versión creada con éxito');
            window.location.href = response.url;
          })
          .fail(function(){
            $('.loader-page').fadeOut('slow');
            toastr['error']('Ocurrió un error al actualizar los cambios');
            window.location.href = url.replace('/new_version', '');
          });
      });
  });

  $('#new-product-to-project-quotation-submit').click(function(e){
    e.preventDefault();
    var form = $('#new-product-to-project-quotation-form');
    var inputs_to_validate = [form.find('input[name="quotation_product[name]"]')[0], 
                              form.find('input[name="quotation_product[sku]"]')[0]];
    var valid_form = true;
    inputs_to_validate.forEach(function(input){
      if (input.value.trim() === '') {
        valid_form = false;
        $(input).parent().find('.invalid-alert').removeClass('hidden');
      }
      else {
        $(input).parent().find('.invalid-alert').addClass('hidden');
      }
    });
    if (valid_form) {
      var input = $("<input>", { type: "hidden", name: "in_current_version", value: "true" })
      form.append($(input));
      form.submit();
    }
  });

  $('#new-quotation-product-tnr').change(function(){
    $.get('/quotation/'+$(this).data('quotation-id')+'/quotation_products/'+$(this).val()+'.json')
      .done(function(item){
        var input_name = $('#add-product-form form input[name="quotation_product[name]"');
        if (item === null) {
          input_name.attr('readonly', false);
        } 
        else {
          input_name.val(item.name);
          input_name.attr('readonly', true);
          if (item.quantity) {
            $('#add-product-form form input[name="quotation_product[quantity]"').val(item.quantity);
            $('#add-product-form form input[type="text"][name="quotation_product[price]"').val(numberWithDelimiter(item.price));
            $('#add-product-form form input[type="hidden"][name="quotation_product[price]"').val(item.price);
            toastr['info']('Este producto ya se encuentra en la cotización');
          }
        }
      });
  });

  $('#open-sidebar-link').click(function(e){
    e.preventDefault();
    $('#versions-sidebar').toggleClass('show-sidebar');
  });

  $('.close-sidebar a').click(function(e){
    e.preventDefault();
    $('#versions-sidebar').toggleClass('show-sidebar');
  });

  $('#download-quotations').click(function(){
    var form = $(this).closest('form');
    var action = form.attr('action');
    form.attr('action', action+'.xlsx');
    form.submit();
    // $(".loader-page").fadeIn();
  });

  if ($('.select2-input-for-project').length > 0) {
    // Truco sucio para que funcione los select en la cotización de proyectos
    // Fue la única forma :me-perdonas:
    setTimeout(function(){
      $('.select2-input-for-project').select2();
    }, 1000);
  }
});

function calculateQuotationTotalPrice() {
  var total = 0.0;
  $('.product-row').each(function(){
    var quantity = parseInt($(this).find('.cart-item-quantity').val());
    var price = parseFloat($(this).find('input[name="price"][type="hidden"]').val());
    total += quantity * price;
    $(this).find('.price-quotation').text(numberWithDelimiter(quantity * price));
  });
  $('.detail-quotation').find('.quotation-total-amount')
                        .text(numberWithDelimiter(total));
}