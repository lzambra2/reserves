// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require underscore
//= require jquery
//= require jquery_ujs
// require dataTables/jquery.dataTables
// require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/effects/effect-highlight
//= require_self
//= require_tree .


$(document).ready(function () {

	$('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });

	$("form").on("click", ".remove_fields", function (event) {
		var parent = $(this).parents(".fields_for");
		$(parent).find('input.remove_field').val('1');
		$(this).closest('.fields_for').hide();
		event.preventDefault();
	});

	$("form").on("click", ".add_fields", function (event) {
		event.preventDefault();
		var time = new Date().getTime();
		regexp = new RegExp($(this).data("id"), "g");
		var attach_to = $(this).data("attach-to");
		console.log(attach_to);

		if (attach_to) {
			$(attach_to).prepend($(this).data('fields').replace(regexp, time));
			$(attach_to).find(".fields_for:first-child").effect("highlight", 2000);

		} else {
			$(this).before($(this).data('fields').replace(regexp, time));
		}


	});

});
