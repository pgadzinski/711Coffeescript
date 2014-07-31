//Build and place jobs onto schedule. Major function that should run everytime a job state changes.
	function placeScheduledJobs() {
		 $('#ScheduledJobs').html(' ');	
		 var scheduledJob = '';
	  	
		 for(var index in jobBucket) {
	  			if (jobBucket[index].resource != '0') {

	  				//Check if color has no value, if so, set a default
	  				if (jobBucket[index].color == '') {
	  					jobBucket[index].color = 'white';	
	  			    }

	  				var attributeString = '';

	  				//Run a check on job duration. In the case where job duration is dynamic, the data may not have a good value, 0 or not a number
					//Throw an alert and use the default job length
					
					if (jobBucket[index].height == 0){
						alert("There is a small problem with this job, the job height is zero. Check that Duration has a number value. A default size of 30 pixels will be used. ");
						jobBucket[index].height = defaultJobLength;
					}	

	  				//Loop through the attribute values for div string
	  				attributeString = '';
					for ( var i=1 ; i <= numberOfAttributes ; i++) {
						var attrIndex = 'attr' + i;
						attributeString = attributeString + jobBucket[index][attrIndex]  + schedItemDelimiter;
					}

	 				//Loop through the attribute values for div tool tip
	  				toolTipString = '';
					for ( var i=1 ; i <= numberOfAttributes ; i++) {
						var attrIndex = 'attr' + i;
						toolTipString = toolTipString + jobBucket[index][attrIndex]  + '|';
					}
					toolTipString = toolTipString + 'JobId:' + index;	

					//Rails sends over the job resource_id. Need to convert this to a pixel position x.
					var resourceVal = jobBucket[index].resource; 
					var xPixelPosition = resourceDict[resourceVal];
					var divJobId = 's' + index;

					//Control wether jobs are draggable, jquery class setting didn't work, so using this hack 
					if (jobBucket[index].draggable == "yes" && (userLevel == 'Scheduler' || userLevel == 'Admin' )) {
						var draggableString = ' class=draggable ';
						var dropButtonString = "<button class=dropButton id=d" + index + " style='top: 1px; left: -4px; float: right;'>D</button>";
						$("#JobMoverForm").css("display", "block");
					}
					else{
						var draggableString = '  ';
						var dropButtonString = "";
						toolTipString = toolTipString + ' Frozen Job';
						$("#JobMoverForm").css("display", "none");
					}

					//building the div string that shows the scheduled job
					scheduledJob =  "<div id=" + divJobId + draggableString + " title='" + toolTipString + "' style='position: absolute; border-style:solid; width:" 
					+ (scheduledJobWidth - 10) 
		  			+ "px; height:" + jobBucket[index].height 
		  			+ "px; background-color:" + jobBucket[index].color 
		  			+ "; left:" + xPixelPosition + "px; top:" + jobBucket[index].top + "px; z-index: 5; draggable:true; border-width: 1px; overflow: hidden; '>" 
		  			+ "<button class=editButton id=s" + index + " style='top: 1px; left: -1px; float: right;'>E</button>"
		  			+ dropButtonString
		  			+ attributeString 
		  			+ "</div>";
		      		$('#ScheduledJobs').append(scheduledJob);
		      		//$(divJobId).addClass( 'draggable' );
		      	}	
		 }
		 $(".draggable").draggable( {
		    cursor: 'move',
		    //cursorAt: {left: 5, top: 5},
		    //containment: 'document',
		    containment: $('#schedule'),	//Pavel fix for the problem with moving around larger jobs
		    start: getJobDivStartPosition,
		    stop: handleDragStop
		  } );

	}; 
	

	//$( ".draggable" ).dblclick(function()
	//		editJobModal();
	//});

	//Populate the Listview with job data. Major function that runs everytime a job state changes. 

	//BuildList, the datatables version that break drag/drop of jobs. Arrgh!
	function buildList() {
	  
	  			listViewAry = new Array();

			  	for(var index in jobBucket) {
		  				if (jobBucket[index].resource == '0') {

		  					jobRowAry = new Array();
							jobRowAry.push('<img id=drag' + index + 
								' src=../images/greenDragDrop.gif draggable=true width=15 ondragstart=drag(event) title="Drag me onto schedule">' + 
								' ' + ' <a style="border: none;"><img src=../images/blueEdit.gif title="Edit Job" class=editButton id=l'+ index + 
								' width=15></a> <a style="border: none;"><img src=../images/redDelete.gif title="Delete Job ' + index + ' " class=deleteButton id=d' + 
								index + ' width=15 style="text-decoration: none"></a>');

							//Loop through the attribute values
							for ( var i=1 ; i <= numberOfAttributes ; i++) {
								var attrIndex = 'attr' + i
								jobRowAry.push(jobBucket[index][attrIndex]);
							}
						listViewAry.push(jobRowAry);	
						};
				};

	  	    $('#demo').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="example"></table>' );
   			$('#example').dataTable( 
   			 	{
					"sScrollY": listViewHeight,
                    "sScrollX": outsideWidth,
                    "bPaginate": false,
                    "bAutoWidth": false,
 
                      //Holds job data	
		      		  "aaData": listViewAry,

		      		  //ListView heading
		      	  	  "aoColumns": listViewHeading
   			 	} );  
   			 	//$("#example_filter").prepend('<div id=example_info class=dataTables_info></div>');
				$("#example_filter").append('&nbsp;&nbsp;&nbsp;&nbsp;<a href="../sites"><button>Configuration</button></a><input type="button" value="New Job" onclick="secondNewJob()">');
				$("#example_filter").prepend('<b>ListView</b><span style="display:inline-block; width: 350px;"></span>');
				//$("#example_info").append('&nbsp;&nbsp;&nbsp;&nbsp;<button id="create-job">Create new job</button>');
	};

	//Error handling for Ajax calls
    $.ajaxSetup({
        error: function(jqXHR, exception) {
            if (jqXHR.status === 0) {
                alert('No internet connection.\n Please verify your connected to the Internet.');
            } else if (jqXHR.status == 404) {
                alert('Requested page not found. [404]. Please contact support if this issue persists.');
            } else if (jqXHR.status == 500) {
                alert('Internal Server Error [500]. Please contact support if this issue persists.');
            } else if (exception === 'parsererror') {
                alert('Requested JSON parse failed. Please contact support if this issue persists.');
            } else if (exception === 'timeout') {
                alert('Time out error. Please contact support if this issue persists.');
            } else if (exception === 'abort') {
                alert('Ajax request aborted. Please contact support if this issue persists.');
            } else {
                alert('Uncaught Error.\n' + jqXHR.responseText);
            }
        }
    });


	//Function binding for dropping a scheduled job to ListView
	$(".dropButton").live('click', function(){
		 $id = parseInt(this.id.substring(1));

		//Ajax call to update Rails
  		editJobString = 'job[resource_id]=0';

	    $.ajax({
			type: 'POST',
			url: '/jobs/asyncUpdate/' + $id,  //MXS_posting_url+urladdon
			data: "utf8=%E2%9C%93&" + editJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
			dataType: 'text',
			async: true,
				success: function(data){
				},				 				
		});

		jobBucket[$id].resource='0';					

		buildList();
 		placeScheduledJobs();

	});

	//When multiple jobs are moved I need the delta the job has been moved. I need to get the starting position of the div and the end position
	function getJobDivStartPosition(event, ui) {
		var $id = parseInt(this.id.substring(1));
  		var divString = "#s" + $id;

  		yStartPosition = $(divString).position().top;

  		console.log('Start position: ' + yStartPosition);
	}

	//Function for moving scheduled jobs around on the schedule
	function handleDragStop( event, ui ) {
		resource = "0";

		var $id = parseInt(this.id.substring(1));
  		var divString = "#s" + $id;

 		xPosition = parseInt( ui.offset.left );

 		//Ensure the user can't place the top of the job beyond the top of the schedule
 		if ($(divString).position().top < 0) {
 			$(divString).css({top:0});
 		}

  		yPosition = $(divString).position().top;

  		//Figure out the amount changed. This is only used for the group move of jobs
  		groupMoveDiffInPixels = yPosition - yStartPosition

  		console.log('End position: ' + yPosition);
  		console.log('Delta Pixel change: ' + groupMoveDiffInPixels);
  			
	 	//Work through the associative array and find the right resource that the job landed in 	
  		for( var resourceIndex in resourceDict) {
  			
  			if ( (resourceDict[resourceIndex]) < xPosition ) {
	  				resource = resourceIndex;
  			}
  		}	

  		//Check for Shift key being pressed, this means multiple jobs are being moved in one action using drag/drop
  		if (event.shiftKey) {
  			//alert('Shift key pressed');

  			$.ajax({
				type: 'POST',
				url: '/jobs/moveDownDragDrop/',  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&jobId="+$id+"&shiftAmountInPixels="+groupMoveDiffInPixels, //{ _method:'PUT', msg : msg },				dataType: 'text',
				async: true,
					success: function(data){
						
					},				 				
		    });	
		    getJobData();
		    return;
  		}

		//Check for Control key being pressed. Pop up dialog requesting amount in time.  Will trigger a group move of jobs. 
  		if (event.ctrlKey) {
  			//alert('Shift key pressed');

  			shiftAmountInTime = prompt("Group job move, enter time amount in hours, can be a negative amount.","");

  			$.ajax({
				type: 'POST',
				url: '/jobs/moveDownForm/',  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&jobId="+$id+"&shiftAmountInTime="+shiftAmountInTime, //{ _method:'PUT', msg : msg },				dataType: 'text',
				async: true,
					success: function(data){
						
					},				 				
		    });	
		    getJobData();
		    return;
  		}

  		//BUG: There is an offset issue with moving scheduled items around. The 'offset' value needs to be substracted from the value given by ui.offset.top

  		var divPosition = resourceDict[resource];
  		$(divString).css({ left: divPosition });
  		jobBucket[$id].left = divPosition;
  		jobBucket[$id].top = yPosition;  		

  		//Ajax call to update Rails
  		editJobString = 'job[resource_id]=' + resource + '&job[schedPixelVal]=' + jobBucket[$id].top;

	    $.ajax({
			type: 'POST',
			url: '/jobs/asyncUpdate/' + $id,  //MXS_posting_url+urladdon
			data: "utf8=%E2%9C%93&" + editJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
			async: true,
				success: function(data){
					
				},				 				
		});


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
		//ev.target.appendChild(document.getElementById(data));

		var $id = data.substring(4);

		var xPos = ev.screenX;
		var yPos = ev.screenY;

		var scrollPos = document.getElementById('scheduleContainer').scrollTop;

		yPosition = yPos + scrollPos;

		console.log(scrollPos);

		//yPosition = $("#drag2").position().top;
		console.log(yPosition);

		//Adjust for screen offset		
		//yPos = yPos - 165;
		yPos = yPosition - 165;

		//Figure out what column the job is in
		for( var resourceIndex in resourceDict) {	
  			if ( (resourceDict[resourceIndex]) < (xPos) ) {
	  				resource = resourceIndex;
  			}
  		}	

  		//Ajax call to say job is now on schedule with this x and y
  		editJobString = 'job[resource_id]=' + resource + '&job[schedPixelVal]=' + (yPos) ;

	    $.ajax({
			type: 'POST',
			url: '/jobs/asyncUpdate/' + $id,  //MXS_posting_url+urladdon
			data: "utf8=%E2%9C%93&" + editJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
			async: true,
				success: function(data){
					console.log(data); //place around methods to allow success return to initiate action
				},				 				
		});


	    jobBucket[$id].resource = resource;
		jobBucket[$id].top = yPos;
		buildList();
 		placeScheduledJobs();

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
				
				//Build the URL string for posting the data
				newJobString = 'job[attr1]='+ $("#attr1").val() +'&job[attr2]='+ $("#attr2").val() +'&job[attr3]='+ $("#attr3").val() +'&job[attr4]='+ $("#attr4").val() +	
								'&job[attr5]='+ $("#attr5").val() +'&job[attr6]='+ $("#attr6").val() +'&job[attr7]='+ $("#attr7").val() +'&job[attr8]='+ $("#attr8").val() +
								'&job[attr9]='+ $("#attr9").val() +'&job[attr10]='+ $("#attr10").val() +'&job[attr11]='+ $("#attr11").val() +'&job[attr12]='+ $("#attr12").val() + 
								'&job[attr13]='+ $("#attr13").val() +'&job[attr14]='+ $("#attr14").val() +'&job[attr15]='+ $("#attr15").val() +'&job[attr16]='+ $("#attr16").val() +
								'&job[attr17]='+ $("#attr17").val()  +'&job[attr18]='+ $("#attr18").val()  +'&job[attr19]='+ $("#attr19").val()  +'&job[attr20]='+ $("#attr20").val();


				//Trying to implement Ajax for a job edit
				$.ajax({
				type: 'POST',
				url: '/jobs/asyncNew/',  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&" + newJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
				async: true,
					success: function(data){
						//alert("success");
						console.log(data); //place around methods to allow success return to initiate action
						getJobData();
					},				 				
				});



				$( this ).dialog( "close" );
			},

			Cancel: function newJobModal() {
				$( this ).dialog( "close" );
				}
			},

		});

		$( "#create-job" ).button().click(function newJobModal() {
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
			$("#attr16").val('');
			$("#attr17").val('');
			$("#attr18").val('');
			$("#attr19").val('');
			$("#attr20").val('');

		});
	});

	function secondNewJob(){

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
			$("#attr16").val('');
			$("#attr17").val('');
			$("#attr18").val('');
			$("#attr19").val('');
			$("#attr20").val('');

		$( "#dialog-form" ).dialog({
		autoOpen: false,
		height: 500,
		width: 500,
		modal: true,
		buttons: {

			"Create New Job": function newJobModal() {
				
				//Build the URL string for posting the data
				newJobString = 'job[attr1]='+ $("#attr1").val() +'&job[attr2]='+ $("#attr2").val() +'&job[attr3]='+ $("#attr3").val() +'&job[attr4]='+ $("#attr4").val() +	
								'&job[attr5]='+ $("#attr5").val() +'&job[attr6]='+ $("#attr6").val() +'&job[attr7]='+ $("#attr7").val() +'&job[attr8]='+ $("#attr8").val() +
								'&job[attr9]='+ $("#attr9").val() +'&job[attr10]='+ $("#attr10").val() +'&job[attr11]='+ $("#attr11").val() +'&job[attr12]='+ $("#attr12").val() + 
								'&job[attr13]='+ $("#attr13").val() +'&job[attr14]='+ $("#attr14").val() +'&job[attr15]='+ $("#attr15").val() +'&job[attr16]='+ $("#attr16").val() +
								'&job[attr17]='+ $("#attr17").val()  +'&job[attr18]='+ $("#attr18").val()  +'&job[attr19]='+ $("#attr19").val()  +'&job[attr20]='+ $("#attr20").val();

				//Trying to implement Ajax for a job edit
				$.ajax({
				type: 'POST',
				url: '/jobs/asyncNew/',  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&" + newJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
				async: true,
					success: function(data){
						//alert("success");
						console.log(data); //place around methods to allow success return to initiate action
						getJobData();
					},				 				
				});



				$( this ).dialog( "close" );
			},

			Cancel: function newJobModal() {
				$( this ).dialog( "close" );
				}
			},

		});

	}


	//Modal for editing existing jobs: listview and scheduled jobs
	$(function editJobModal() {

		$( "#edit-form" ).dialog({
		autoOpen: false,
		height: 500,
		width: 500,
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
				jobToEdit.attr16 = $("#eattr16").val();
				jobToEdit.attr17 = $("#eattr17").val();
				jobToEdit.attr18 = $("#eattr18").val();
				jobToEdit.attr19 = $("#eattr19").val();
				jobToEdit.attr20 = $("#eattr20").val();


				if (colorPosition) {
					colorString = '#e' + colorPosition;
					jobToEdit.color = $(colorString).val();
				}

				//Build the URL string for posting the data
				editJobString = 'job[attr1]='+jobToEdit.attr1+'&job[attr2]='+jobToEdit.attr2+'&job[attr3]='+jobToEdit.attr3+'&job[attr4]='+jobToEdit.attr4+	
								'&job[attr5]='+jobToEdit.attr5+'&job[attr6]='+jobToEdit.attr6+'&job[attr7]='+jobToEdit.attr7+'&job[attr8]='+jobToEdit.attr8+
								'&job[attr9]='+jobToEdit.attr9+'&job[attr10]='+jobToEdit.attr10+'&job[attr11]='+jobToEdit.attr11+'&job[attr12]='+jobToEdit.attr12+
								'&job[attr13]='+jobToEdit.attr13+'&job[attr14]='+jobToEdit.attr14+'&job[attr15]='+jobToEdit.attr15+
								'&job[attr16]='+jobToEdit.attr16+'&job[attr17]='+jobToEdit.attr17+'&job[attr18]='+jobToEdit.attr18+'&job[attr19]='+jobToEdit.attr19+
								'&job[attr20]='+jobToEdit.attr20+'&job[resource_id]='+jobToEdit.resource
				//Trying to implement Ajax for a job edit
				$.ajax({
				type: 'POST',
				url: '/jobs/asyncUpdate/' + inputId,  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&" + editJobString + "&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
				async: true,
					success: function(data){
						getJobData();	
						buildList();
						placeScheduledJobs();
					},				 				
				});

				
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
	});	

	//Function binding for rebuilding the ListView
	$("#placeScheduledJobs").live('click', function(){
		//alert("build List");
		placeScheduledJobs();
	});

	//Define Edit button to bring up Edit Modal to change data. Need to add Ajax call back to Rails. 
  	//$(".draggable").live('dblclick', function editJobModal() {
	$(".editButton").live('click', function editJobModal() {

		    // get your id here
		    var $id = parseInt(this.id.substring(1));

		    $("#displayJobId").html(jobBucket[$id].id);	
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
			$("#eattr16").val(jobBucket[$id].attr16);
			$("#eattr17").val(jobBucket[$id].attr17);
			$("#eattr18").val(jobBucket[$id].attr18);
			$("#eattr19").val(jobBucket[$id].attr19);
			$("#eattr20").val(jobBucket[$id].attr20);

			$( "#edit-form" ).dialog( "open" );
    });

  	//Delete button removes the job from the List view currently. Need to add Ajax call back to Rails. 
  	$(".deleteButton").live('click', function() {

  		if (confirm('Please confirm you would like to delete a job?')) { 
  			var $id = parseInt(this.id.substring(1));

  			//Ajax call to update Rails
	  		editJobString = 'job[resource_id]=0';

		    $.ajax({
				type: 'POST',
				url: '/jobs/asyncDelete/' + $id,  //MXS_posting_url+urladdon
				data: "utf8=%E2%9C%93&commit=Update+Job", //{ _method:'PUT', msg : msg },				dataType: 'text',
				dataType: 'text',
				async: true,
					success: function(data){
					},				 				
			});
			getJobData();
    		buildList();
		}

    });

  	//Build the job javascript objects
	function jobCreate(id,resource,left,top,width,height,color,draggable,attr1,attr2,attr3,attr4,attr5,attr6,attr7,attr8,attr9,attr10,attr11,attr12,attr13,attr14,attr15,attr16,attr17,attr18,attr19,attr20) {
		this.id = id;

		//Set values relevant to showing scheduled jobs
		this.resource = resource;
		this.left = left;
		this.top = top;
		this.width = width;
		this.height = height;
		this.color = color;
		this.draggable = draggable;

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
		this.attr16 = attr16;
		this.attr17 = attr17;
		this.attr18 = attr18;
		this.attr19 = attr19;
		this.attr20 = attr20;

	}; 

   //Next 2 methods are for long polling the job data from Rails for synching job data between the separate users of the same schedule
	var FREQ = 3000 ;  //This is equal to 2 minutes
	var repeat = true;
		
	//Endless loop that triggers the Ajax call below	
	function startAJAXcalls(){
		if(repeat){
			setTimeout( function() {
					checkForJobDataUpdate();   //This is not getting fired, not sure what is happening here. 
					startAJAXcalls();
				}, 	
				FREQ
			);
		}
	}
	
	//Call the server and see if job data needs to be updated. Make an Ajax call with client time stamp. The backend will make a comparison 
	//between the client time stamp and server time stamp. If the timestamps match there is no update needed. If client time stamp is behind, jobData refresh needed
	//If client time stamp is ahead? Error? Something has gone really wrong. Popup alert to contact support, cause a jobData update. 
	function checkForJobDataUpdate(){

		postingURL = '/scheduler/checkForJobDataUpdate?clientTimeStamp=' + clientScheduleTimeStamp + '&boardId=' + boardId 

		$.ajax({
			url: postingURL,
			cache: false,
			dataType: "script",
			success: function(msg){

				//String comparison to see if the client is out of date. There is weird double quotes on the string returned from the server. 
				//Perhaps fix in the future. 
				if (msg == "'Update'") {
					getJobData();
				}
				if (msg == "'Match'") {
					return;
				}
				if (msg == "'Messed'") {
					alert("Something is wrong with data synch. Please use web browser Reload to reload page. If problem continues contact Support.")
				}

			}
		});
	}

	//Pull the proper job data for this schedule. Does it need to include a query perhaps? 
	function getJobData(){
		$.ajax({
			url: "/scheduler/jobData",
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