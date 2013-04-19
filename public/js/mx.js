//$(document).ready(function(){
	
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
	
	//Call to create the job javascript objects and store them into JobBucket associative array
	//Data file
	jobBucket = {
		23: (new jobCreate(23,'none',100,20,200,20,'blue','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		24: (new jobCreate(24,'1',140,60,250,40,'red','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		25: (new jobCreate(25,'1',140,100,300,60,'green','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		26: (new jobCreate(26,'none',100,100,300,60,'green','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
	};

	attributeNamesAry = new Array ("Cust","JobNum","PONum","Duration","Qty","Completed","Color");

	numberOfAttributes = 7;

	resourceDict = {
		0:0,
		1:130,
		2:350,
		3:585,
		4:815,
		5:1040,
	};


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

		  			scheduledJob =  "<div id=s" + index + " style='position:absolute; width:" + jobBucket[index].width 
		  			+ "px; height:" + jobBucket[index].height 
		  			+ "px; background-color:" + jobBucket[index].color 
		  			+ "; left:" + jobBucket[index].left + "px; top:" + jobBucket[index].top + "px; z-index: 5; draggable:true;' class='draggable'>" 
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
		
	  	//Something strange here. I had to sholve this event declaration into the BuildList function. Shouldn't be here, would rather have it in modal.js
	  	//$(".editButton").click(function editJobModal() {
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

		$( "#edit-form" ).dialog( "open" );
	    });

	  	//Delete button removes the job from the List view currently.
	  	$(".deleteButton").click(function() {

	  		if (confirm('Please confirm you would like to delete a job?')) { 
	  			var $id = parseInt(this.id.substring(0));
				delete jobBucket[$id];
	    		buildList();
			}

	    });


	};


	$(".dropButton").live('click', function(){
		var $id = parseInt(this.id.substring(1));

		jobBucket[$id].resource='none';
		buildList();
 		placeScheduledJobs();

	});


	$("#buttonTest").live('click', function(){
	alert("test text");
	});

	//Function to handle drop events
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

 	buildList();
 	placeScheduledJobs();

 	//console.log("blah");

//});
	


