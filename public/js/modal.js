//Build and place jobs onto schedule. Major function that should run everytime a job state changes.
	function placeScheduledJobs() {
		 $('#ScheduledJobs').html(' ');	
		 var scheduledJob = '';
	  	
		 for(var index in jobBucket) {
	  			if (jobBucket[index].resource != 'none') {

	  				var attributeString = '';

	  				//Loop through the attribute values
					for ( var i=1 ; i <= numberOfAttributes ; i++) {
						var attrIndex = 'attr' + i
						attributeString = attributeString + jobBucket[index][attrIndex]  + ' | ';
					}

		  			scheduledJob =  "<div id=s" + index + " class='draggable ui-draggable' style='position: absolute; width:" + jobBucket[index].width 
		  			+ "px; height:" + jobBucket[index].height 
		  			+ "px; background-color:" + jobBucket[index].color 
		  			+ "; left:" + jobBucket[index].left + "px; top:" + jobBucket[index].top + "px; z-index: 5; draggable:true;'>" 
		  			+ "<button class=editButton id=s" + index + ">E</button>"
		  			+ "<button class=dropButton id=d" + index + ">D</button>"
		  			+ attributeString
		  			+ "</div>";
		      		$('#ScheduledJobs').append(scheduledJob);
		      	}	
		 }

	}; 
	
	//Populate the Listview with job data. Major function that runs everytime a job state changes. 
	function buildList() {
	  $('#ListView').html(' ');	
	  var jobRow = '';
	  
	  	for(var index in jobBucket) {
	  			if (jobBucket[index].resource == 'none') {
		  			jobRow =  '<tr height=50><td width=130>' + 
		  			'<img id=drag'+ index + ' src=./30day.gif draggable=true width=30 ondragstart=drag(event)>' +
		      		'<button class=editButton id=l'+ index + '>E</button> &nbsp;' +
		      		'<button class=deleteButton id='+ index + '>D</button> &nbsp;' +
					index + '</td>><td>';

					//Loop through the attribute values
					for ( var i=1 ; i <= numberOfAttributes ; i++) {
						var attrIndex = 'attr' + i
						jobRow = jobRow + jobBucket[index][attrIndex]  + '</td>><td>';
					}

					+ '</td>></tr>'; 
		      		$('#ListView').append(jobRow);
		      	}	
		}

	};

//Function binding for dropping a scheduled job to ListView
	$(".dropButton").live('click', function(){
		var $id = parseInt(this.id.substring(1));

		jobBucket[$id].resource='none';
		buildList();
 		placeScheduledJobs();

	});


	$("#buttonTest").live('click', function(){
	alert("test text");
	});


	//Function for moving scheduled jobs around on the schedule
	function handleDragStop( event, ui ) {
		resource = "none";
 		var xPosition = parseInt( ui.offset.left );
  		var yPosition = parseInt( ui.offset.top );

  		console.log(event.target);
  				
  		//alert(event.target);

	 	//Work through the associative array and find the right resource that the job landed in 	
  		for( var resourceIndex in resourceDict) {
  			
  			if ( (resourceDict[resourceIndex]) < xPosition ) {
	  				console.log("resource: " + resource);
	  				resource = resourceIndex;
	  			 	i = 1;
  			}
  		}	
  		var $id = parseInt(this.id.substring(1));

  		//alert( " xPosition: " + xPosition + "Resource: " + resource + "id: " + $id );

  		var divString = "#s" + $id;
  		var divPosition = resourceDict[resource];
  		$(divString).css({ left: divPosition });

	}

		//functions for supporting drag and drop from ListView to schedule
		function allowDrop(ev) {
			ev.preventDefault();
		}

		function drag(ev) {
			ev.dataTransfer.setData("Text",ev.target.id);
		}

		function drop(ev) {
			var data = ev.dataTransfer.getData("Text");
			ev.target.appendChild(document.getElementById(data));
			console.log(ev.screenX);
			console.log(ev.screenY);
			
			var x = ev.screenX;
			var y = ev.screenY;
			alert('x ' + x + ' y ' + y);
			ev.preventDefault();
		}

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
			$("#attr8").val('');
			$("#attr9").val('');
			$("#attr10").val('');
			$("#attr11").val('');
			$("#attr12").val('');
			$("#attr13").val('');
			$("#attr14").val('');
			$("#attr15").val('');

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
				//Take imputs from Job Edit modal, update the job attributes
				inputId = $("#eid").val();
				jobToEdit = jobBucket[ inputId];
				jobToEdit.attr1 = $("#eattr1").val();
				jobToEdit.attr2 = $("#eattr2").val();
				jobToEdit.attr3 = $("#eattr3").val();
				jobToEdit.attr4 = $("#eattr4").val();
				jobToEdit.attr5 = $("#eattr5").val();
				jobToEdit.attr6 = $("#eattr6").val();
				jobToEdit.attr7 = $("#eattr7").val();
				jobToEdit.attr8 = $("#eattr8").val();
				jobToEdit.attr9 = $("#eattr9").val();
				jobToEdit.attr10 = $("#eattr10").val();
				jobToEdit.attr11 = $("#eattr11").val();
				jobToEdit.attr12 = $("#eattr12").val();
				jobToEdit.attr13 = $("#eattr13").val();
				jobToEdit.attr14 = $("#eattr14").val();
				jobToEdit.attr15 = $("#eattr15").val();

				//Build the URL string for posting the data
				editJobString = 'job[attr1]='+jobToEdit.attr1+'&job[attr2]='+jobToEdit.attr2+'&job[attr3]='+jobToEdit.attr3+'&job[attr4]='+jobToEdit.attr4+	
								'&job[attr5]='+jobToEdit.attr5+'&job[attr6]='+jobToEdit.attr6+'&job[attr7]='+jobToEdit.attr7+'&job[attr8]='+jobToEdit.attr8+
								'&job[attr9]='+jobToEdit.attr9+'&job[attr10]='+jobToEdit.attr10+'&job[attr11]='+jobToEdit.attr11+'&job[attr12]='+jobToEdit.attr12+
								'&job[attr13]='+jobToEdit.attr13+'&job[attr14]='+jobToEdit.attr14+'&job[attr15]='+jobToEdit.attr15
				//Trying to implement Ajax for a job edit
				$.ajax({
				type: 'POST',
				url: '/jobs/update/' + inputId,  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&" + editJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
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

	});

		//Function binding for rebuilding the ListView
		$("#buildList").live('click', function(){
			//alert("build List");
			buildList();
			console.log("BuildListPing");
		});	

		//Function binding for rebuilding the ListView
		$("#placeScheduledJobs").live('click', function(){
			//alert("build List");
			placeScheduledJobs();
			console.log("placeScheduledJobsPing");
		});

		//Define Edit button to bring up Edit Modal to change data. Need to add Ajax call back to Rails. 
	  	$(".editButton").live('click', function editJobModal() {

			    // get your id here
			    var $id = parseInt(this.id.substring(1));

				$("#eid").val(jobBucket[$id].id);
				$("#eattr1").val(jobBucket[$id].attr1);
				$("#eattr2").val(jobBucket[$id].attr2);
				$("#eattr3").val(jobBucket[$id].attr3);
				$("#eattr4").val(jobBucket[$id].attr4);
				$("#eattr5").val(jobBucket[$id].attr5);
				$("#eattr6").val(jobBucket[$id].attr6);
				$("#eattr7").val(jobBucket[$id].attr7);
				$("#eattr8").val(jobBucket[$id].attr8);
				$("#eattr9").val(jobBucket[$id].attr9);
				$("#eattr10").val(jobBucket[$id].attr10);
				$("#eattr11").val(jobBucket[$id].attr11);
				$("#eattr12").val(jobBucket[$id].attr12);
				$("#eattr13").val(jobBucket[$id].attr13);
				$("#eattr14").val(jobBucket[$id].attr14);
				$("#eattr15").val(jobBucket[$id].attr15);

				$( "#edit-form" ).dialog( "open" );
	    });

	  	//Delete button removes the job from the List view currently. Need to add Ajax call back to Rails. 
	  	$(".deleteButton").click(function() {

	  		if (confirm('Please confirm you would like to delete a job?')) { 
	  			var $id = parseInt(this.id.substring(0));
				delete jobBucket[$id];
	    		buildList();
			}

	    });

	  	//Build the job javascript objects
		function jobCreate(id,resource,left,top,width,height,color,attr1,attr2,attr3,attr4,attr5,attr6,attr7,attr8,attr9,attr10,attr11,attr12,attr13,attr14,attr15) {
		this.id = id;

		//Set values relevant to showing scheduled jobs
		this.resource = resource;
		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;
		this.color = color;

        //Set Attribute values
		this.attr1 = attr1;
		this.attr2 = attr2;
		this.attr3 = attr3;
		this.attr4 = attr4;
		this.attr5 = attr5;
		this.attr6 = attr6;
		this.attr7 = attr7;
		this.attr8 = attr8;
		this.attr9 = attr9;
		this.attr10 = attr10;
		this.attr11 = attr11;
		this.attr12 = attr12;
		this.attr13 = attr13;
		this.attr14 = attr14;
		this.attr15 = attr15;
	
	}; 

/*

   //Next 2 methods are for long polling the job data from Rails for synching job data between the separate users of the same schedule
	var FREQ = 1000000 ;
	var repeat = true;
		
	//Endless loop that triggers the Ajax call below	
	function startAJAXcalls(){
	
		if(repeat){
			setTimeout( function() {
					getJobData();
					startAJAXcalls();
				}, 	
				FREQ
			);
		}
	}
	

	//Pull the proper job data for this schedule. Does it need to include a query perhaps? 
	function getJobData(){
		$.ajax({
			url: "./jobDataFile2.js",
			cache: false,
			dataType: "script",
			success: function(){
				
				buildList();
 				placeScheduledJobs();

			}

		});
	}

	//Kick of the looping of Ajax calls
	getJobData();
	startAJAXcalls();

*/

buildList();
placeScheduledJobs();