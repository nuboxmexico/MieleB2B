// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require select2
//= require adminlte
//= require toastr
//= require bootstrapValidator.min
//= require sweetalert2
//= require sweet-alert2-rails
//= require jquery.validate.min
//= require additional-methods.min
//= require file_input
//= require comparator
//= require moment
//= require moment/es
//= require bootstrap-datetimepicker
//= require swiper.min
//= require slick.min
//= require tinymce-jquery
//= require rut_validator
//= require cocoon
//= require cleave.min
//= require_tree .


toastr.options = Object.assign({}, toastr.options, {
  closeButton: true,
  positionClass: "toast-bottom-right-custom"
});

$(document).ready(function(){
  $(".loader-page").fadeOut("slow");
  $('.select2-input').select2();
  Highcharts.setOptions({
    lang: {
      thousandsSep: '.',
      decimalPoint: ',',
      drillUpText: 'Volver',
      numericSymbols: ['$ M', '$ MM']
    }
  });
  $("a").click(function(){
    if($(this).attr("data-remote") != "true" && 
       !$(this).attr("href").includes("#") && 
       $(this).attr("target") != "_blank" && 
       $(this).attr("data-download") != "template" && 
       $(this).attr("data-confirm-button-text") != "Sí" && 
       $(this).attr("data-method") != "post" && 
       !$(this).hasClass('no-loader')){
      $(".loader-page").fadeIn();
    }
  });
  $(document).on("submit", function(e){
    if(($(e.target).attr("data-remote") != "true" && !$(e.target).hasClass('no-loader'))){
      $(".loader-page").fadeIn();
    }
  });
  $('.bform').bootstrapValidator();

  displayDatePicker('.date-picker');

  $('.date-range').daterangepicker({
    "autoUpdateInput": true,
    "minDate": new Date(2012, 0, 1),
    "locale": {
      "format": "DD/MM/YYYY",
      "separator": " - ",
      "applyLabel": "Guardar",
      "cancelLabel": "Cancelar",
      "fromLabel": "Desde",
      "toLabel": "Hasta",
      "customRangeLabel": "Custom",
      "weekLabel": "S",
      "daysOfWeek": [
      "Do",
      "Lu",
      "Ma",
      "Mi",
      "Ju",
      "Vi",
      "Sa"
      ],
      "monthNames": [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
      ],
      "firstDay": 1
    },
    "cancelClass": "btn-secondary",
    "applyClass": "btn-miele",
    "singleDatePicker": false
  }, function(init_date, end_date) {
    $('.date-range').val(init_date.format('DD/MM/YYYY')+' - '+end_date.format('DD/MM/YYYY'));
    $(".date-range").trigger('change');
  });
});

function change_percent(percent){
  $.ajax({
    type: "POST",
    url: "/change_payment/" + percent
  });
}

function applyDiscount(value){
  $.post("/cart/apply_discount.js");
}

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

homologateBoxHeights(".card");
$(document).ready(function(){
  homologateBoxHeights(".card");
});

function toggleUser(id){
  $.post("/user/toggle/"+id+".js");
}

function getMandatories(id, item){
  $.ajax({
    url: '/cart/'+item+'/mandatories_by_instalation/'+id,
    type: 'get',
    dataType: 'json',
    success: function(data) {       
      if(data.length == 0){
        $('#mandatory'+item).html('Esta instalación no necesita productos mandatorios.');
        $("#add-mandatory-"+item).addClass("hidden");
      } else {
        $('#mandatory'+item).html(data.join(','));
        $("#add-mandatory-"+item).removeClass("hidden");
        $("#instalation-parent-"+item).html('<input type="hidden" name="instalation_id" value="'+id+'">');
      }
    },
    error: function(data) {
      $(".toast-bottom-right-custom").remove();
      toastr['error']('Debes eliminar todos los mandatorios existentes para cambiar el tipo de instalación.');
      // console.log(data.responseJSON.previous_value);
      $("#instalation"+item).val(data.responseJSON.previous_value);
    }
  });
}

function setInstalation(id, value){
  $.ajax({
    url: '/set_instalation/'+id,
    type: 'post',
    data: {value: value}
  });
}

function setDispatch(id, value){
  $.post('/set_dispatch/'+id+'/'+value+'.js');
}

function add_p(sku) {
  event.prevent
  var sku_product = sku;
  if(sku_product != undefined){
    window.location.href = '/product/'+sku_product
  }
}

var format_number = function(number){
  return '$ '+parseInt(number).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
}

function numberWithDelimiter(number) {
  return parseFloat(number).toFixed(2)
                           .replace('.', ',')
                           .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
}

function inputCurrencyFormat(input) {
  new Cleave(input, {
    numeral: true,
    swapHiddenInput: true,
    numeralDecimalMark: ',',
    delimiter: '.',
  });
}

function displayDatePicker(selector) {
  $(selector).daterangepicker({
    singleDatePicker   : true,
    showDropdowns      : true,
    autoUpdateInput    : false,
    drops              : "up",
    applyButtonClasses : "btn btn-small btn-miele",
    cancelClass        : "btn btn-flat btn-small",
    minDate            : new Date,
    locale: {
      format      : 'DD/MM/YYYY',
      applyLabel  : "Aplicar",
      cancelLabel : "Limpiar",
      daysOfWeek  : [
        "Do",
        "Lu",
        "Ma",
        "Mi",
        "Ju",
        "Vi",
        "Sa"
      ],
      monthNames  : [
        "Enero",
        "Febrero",
        "Marzo",
        "Abril",
        "Mayo",
        "Junio",
        "Julio",
        "Agosto",
        "Septiembre",
        "Octubre",
        "Noviembre",
        "Diciembre"
      ]
    }
  });
  
  $(selector).on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('DD/MM/YYYY'));
  });

  $(selector).on('cancel.daterangepicker', function(ev, picker) {
    $(this).val('');
  });
}