
	//Modal for adding new jobs
	$(function newJobModal() {

		$( "#dialog-form" ).dialog({
		autoOpen: false,
		height: 400,
		width: 400,
		modal: true,
		buttons: {

			"Create New Job": function newJobModal() {
				//console.log(test);
				//Create new job object, add to jobBucket and regenerate ListView
				inputId = $("#id").val();
				jobBucket[ inputId ] = new jobCreate($("#id").val(),'none',100,20,200,20,'blue',$("#attr1").val(),$("#attr2").val(),$("#attr3").val(),$("#attr4").val(),$("#attr5").val(),$("#attr6").val(),$("#attr7").val());
				buildList();

				$( this ).dialog( "close" );
			},

			Cancel: function newJobModal() {
				$( this ).dialog( "close" );
				}
			},

		});

		$( "#create-user" ).button().click(function newJobModal() {
			$( "#dialog-form" ).dialog( "open" );

			//Clear field values each time its opened. Somehow if the dialog is used repeated it has the old values. 
			$("#id").val('');
			$("#attr1").val('');
			$("#attr2").val('');
			$("#attr3").val('');
			$("#attr4").val('');
			$("#attr5").val('');
			$("#attr6").val('');
			$("#attr7").val('');

		});
	});

	//Modal for editing existing jobs: listview and scheduled jobs
	$(function editJobModal() {

		$( "#edit-form" ).dialog({
		autoOpen: false,
		height: 400,
		width: 400,
		modal: true,
		buttons: {

			"Save Job Edit": function editJobModal() {
				//console.log(test);
				//Create new job object, add to jobBucket and regenerate ListView
				inputId = $("#eid").val();
				jobToEdit = jobBucket[ inputId];
				jobToEdit.attr1 = $("#eattr1").val();
				jobToEdit.attr2 = $("#eattr2").val();
				jobToEdit.attr3 = $("#eattr3").val();
				jobToEdit.attr4 = $("#eattr4").val();
				jobToEdit.attr5 = $("#eattr5").val();
				jobToEdit.attr6 = $("#eattr6").val();
				jobToEdit.attr7 = $("#eattr7").val();
				
				//jobBucket[ inputId ] = new jobCreate($("#jName").val(), $("#jEmail").val(), $("#jPassword").val(),'','');

				//Trying to implement Ajax for a job edit
				$.ajax({
				type: 'POST',
				url: '/jobs/update/' + '20',  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&job[resource_id]=none&job[schedPixelVal]=0&commit=Update+Job", //{ _method:'PUT', msg : msg },
				dataType: 'text',
				async: true,
					success: function(data){
						alert("success");
						console.log(data); //place around methods to allow success return to initiate action
					},				 				
				});

				buildList();
				placeScheduledJobs();

				$( this ).dialog( "close" );
			},

			Cancel: function editJobModal() {
				$( this ).dialog( "close" );
				}
			},

		});

		$("#buildList").live('click', function(){
			//alert("build List");
			buildList();
		});	

	});
