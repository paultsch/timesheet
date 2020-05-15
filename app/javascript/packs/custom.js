// Preloader JS
jQuery(window).on('load', function () {
    console.log("Worksin!")

    $("#user_usertype_id").change(function() {
      if ($(this).val() == 1) {
        console.log("it works!")
        $('#student-options').show();
      } else if ($(this).val() == null) {
        $('#student-options').hide();
      } else {
        $('#student-options').hide();
      }
    });
    $("#user_usertype_id").trigger("change");

});
