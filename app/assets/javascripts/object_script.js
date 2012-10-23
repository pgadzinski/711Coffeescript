/*MODEL*/

//keeps track of the jobs and their location, as well as other bits of metadata
function StateData(){
	this.jobs = "";
	this.board_jobs = "";
	this.lv_jobs = "";

	this.top_offset = 174; //(offset from top of window + header image + board bar height + space between bar and schedule)
	this.left_offset = $("#root").offset().left; 
	this.width_arr = "";	

}

//redraws jobs on board when board switch occurs
function ReDrawJobs(){
	this.redraw = function(){
		$.each(MXS_job_data, function(key,value){
			var board_val = schedule1.board;

			//hard json values versus job object values
			
			//if(MXS_job_data[key][0]["location"] === 'board')
			if(window[("job"+key)].location === 'board')
			{
				//if(MXS_job_data[key][0]["board"] !== board_val)
				if(window[("job"+key)].board !== board_val)
				{
					window[("job"+key)].remove();
				}
				//else if(MXS_job_data[key][0]["board"] === board_val)
				else if(window[("job"+key)].board === board_val)
				{
					window[("job"+key)].remove();
					window[("job"+key)].create_job();
					window[("job"+key)].width = MXS_board_data[board_val][0]["col_width"];
					window[("job"+key)].set_css();
					
					//issues:
					//position values aren't self-updating (what takes precedence, the web version or MxS?)
					//Dropped items still removed when boards switched (data being taken from initia JSON object, not updated 						
					//job object (need an array of objects) - may be a good idea to stop updating from JSON and load those 							
					//values into objects directly, where they can self-update 
				}
			}	

		});
	}
}


/*VIEW & OBJECTS*/
function Job(id, location, board, lane, top, width, height, stats){
	this.id = id;
	this.location = location;
	this.board = board;
	this.lane = lane;
	this.top = top;
	this.width = width;
	this.height = height;	
	this.color = ""; //optional

	//need to figure out a way to set stat properties, (just passed the object)
	this.stats=stats;

	//set new values for all jobs dropped on a board
	this.set_new_values = function(location, board, lane, top, width){
		this.location = location;
		this.board = board;
		this.lane = lane;
		this.top = top;
		this.width = width;
	}

	this.create_job = function(){
		if((this.location == 'board') && (this.board == schedule1.board)){
			var sch_jobs ="";
			sch_jobs+="<div class='job' id='"+this.id+"'>";
			sch_jobs+="<div class='job_info_chng' id='"+this.id+"info_chng'>I</div>";
			sch_jobs+="<div class='job_drop' id='"+this.id+"drop'>D</div>";
			sch_jobs+="<div class='info' id='"+this.id+"info'>Test</div></div>";
			$("#drag_container").append(sch_jobs);

			this.button_css();
			this.button_setup();
			this.set_text();
			
		} 
		else if(this.location =='listview'){
			var lv_jobs= "";
			lv_jobs+="<div class='lv_job' id='"+this.id+"'></div>";
			$("#list_view").append(lv_jobs);
			this.set_text();
		}
		//else alert("invalid job location");	
	}
	
	this.set_css = function(){
		var self = this;		

		if(this.location =='board'){
			//var grid_width = MXS_board_data[self.board][0]["col_width"];
			
			var left_val = $.fn.get_left_from_lane(self.lane);
			
			$("#"+this.id).css({
				'position':'absolute',
				'left': left_val, 
				'top': self.top,
				'width': self.width,
				'height': self.height,
				'border': '1px solid black',
				'background': self.color,
				'overflow':'hidden'
			});

			//set cornet using new library
			$(".job").corner();


			//Unfortunately setting this in a generic manner for all jobs messes it up when other jobs, with their own grid-widths (on 				//different boards) are created
			//the faster solution here is to set each job's qualities independently
			//the better solution is to create a vM that manages the visual representation of each model separately
			$("#"+self.id+".job").draggable({
				cursor:"move",
				snap:true,
				snapTolerance: 0,
				grid: [1, 1],
				containment: "#drag_container",
				stack: ".job",
				start: function(event, ui){
					//drop shadow on start
					$("#"+self.id).css({
						'-moz-box-shadow': '5px 5px 5px #888',
						'-webkit-box-shadow': '5px 5px 5px #888',
						'box-shadow': '5px 5px 5px #888'
					});
					
				},
				stop: function(){
					var position = $(this).position();
					
					self.top = position.top;
					self.lane = $.fn.get_lane(position.left, "board");

					//very generic snap-to
					var true_left = $.fn.get_left_from_lane(self.lane);
					$("#"+self.id).css({
						'left': true_left,
					});
					
					//kills drop shadow
					$("#"+self.id).css({
						'-moz-box-shadow': '',
						'-webkit-box-shadow': '',
						'box-shadow': ''
					});					
				
					$.fn.ajax_update(this.id, "move_on_board", "");			
				
							
				}
	
			});
		}

		if(this.location =='listview'){
			//css for lv_jobs
			$("#"+this.id).css({
				'position':'relative',
				'height':30,
				'width': (MXS_table_data.table_width +15),
				'margin':'5px',
				//'border': '1px solid black',
				'background':'White',
				'overflow' : 'hidden',
				'border-radius':'5px'
				
			});
					
		}
	}

	this.set_text = function(){
		if(this.location =='board'){
			var string="";
			var tooltip="";
			$.each(this.stats, function(key, value){
				string+=key+": "+value+"</BR>";
				tooltip+=key+": "+value+" - ";

			});
		
			$("#"+this.id+"info").html(string);
			$("#"+this.id).attr("title", tooltip);	
					
		}

		if(this.location =='listview'){
			//id is a persistent property
			var string = "<div id='id' class='lvjob_data_field'>"+this.id+"</div>";
			
			$.each(this.stats, function(key, value){
				string += "<div id='"+key+"' class='lvjob_data_field'>"+value+"</div>";
				
			});

			//console.log(string);
			$("#"+this.id).html(string);

			//set css for all job fields within newly minted job
			//has to stay generic (for some reason)
			$(".lvjob_data_field").css({
				'position':'relative',
				'display':'inline-table',
				'margin':'0 45px 0 0',
				'padding':'0 5 0 5',
				'font-size':'1.5em',
				'overflow':'hidden',	
			});
			//console.log(MXS_field_widths[this.id]);
			//console.log(this.id);
			//console.log(sd.width_arr);

			$.each(this.stats, function(key){
				console.log(key);
				$("#"+key+".lvjob_data_field").width(MXS_field_widths[key]);						
			})

			/*
			var i=0;
			$.each(this.stats, function(key){
				$("#"+key+".lvjob_data_field").width(sd.width_arr[i]);
				i++;							
			});
			*/
			
			
								
		}

	}

	this.button_css = function(){
		//set css values for job info class
		$(".info").css({
			'padding' : '0 0 0 5px', 
			'overflow' : 'hidden',
		});

			
		//set buttons used for scheduled jobs
		$(".job_info_chng").css({
			'position':'relative',
			'border': '1px solid black',
			'height': '20px',
			'line-height': '20px',
			'width': '20px',
			'top':3,
			'left':-3,
			'float':'right',
			'background':'grey',
			'text-align':'center',
			'cursor':'pointer'
		});

		$(".job_info_chng").corner("6px");

		$(".job_drop").css({
			'position':'relative',
			'border': '1px solid black',
			'height': '20px',
			'line-height': '20px',
			'width': '20px',
			'top': 28,
			'left': 19,
			'float':'right',
			'background':'grey',
			'text-align':'center',
			'cursor':'pointer'
		});

		$(".job_drop").corner("6px");

	}

	this.button_setup = function(){
		var self = this; //sets 'this' to a local variable so it can be used in the context of embedded function

		$("#"+this.id+"drop").click(function(){
			self.change_location('listview');
			self.location = "listview";
			$.fn.ajax_update(self.id, "drop_to_listview", "");
			//hard value changes
			//MXS_job_data[self.id][0]["location"] = "listview";
		});

		$("#"+this.id+"info_chng").click(function(){
			$("#modal_dialog").dialog("open");
			dialog1.update_data(self.id, self.stats); //pass stats at dialog creation
		});
	} 

	this.set_stats = function(obj){
		this.stats=obj;
		this.color = 'White';
		var self = this;
		//add color value if available
		$.each(this.stats, function(key, value){
			if((key.toLowerCase() == 'color') || (key.toLowerCase() == 'colour')){
				self.color = value;
				return false;
			}
		});
		
		
	}

	this.change_location = function(loc){
		this.location = loc;
		var self = this; 
		
		if (this.location == 'board' || this.location == 'listview')
		{
			self.remove();
			self.create_job();
			self.set_css();
			$("#list_view").sortable('refresh');
			
			
		}
		else alert("invalid job location");	
		
		
	}
	
	this.remove = function(){
		$("#"+this.id).remove();
	}
		

}

function Board_bar(){
	this.create_bar = function(){
		var string = "";
		string += "<div id='board_bar'>";
		$.each(MXS_board_data, function(key){
			string += "<div id='"+key+"' class='board_button'>"+key+"</div>&nbsp;&nbsp;&nbsp;";
		});
		string+="</div>";
		$("#root").append(string);
	}

	this.set_css = function(){
		$("#board_bar").css({
			'position':'absolute',
			'top': 0,
			'width': (MXS_table_data.table_width + 21),
			'height': '1px',
			'border': '2px solid #f8fafb',
			'background': 'transparent',
			'line-height': '1px', 
			'border-radius': '10px 10px 0 0',
	
		});

		$(".board_button").css({
			'position':'relative',
			'display':'inline',
			'margin':'0 15 0 15',
			'padding':'0 5 0 5',
			'font-size':'1.6em',
			'border':'1px solid black',
			'cursor':'default',			
			'border-radius': '5px',	
					
		});
		
		//$(".board_button").corner("5px");	
		

	}

	this.add_selection = function(){
	var self = this;
		/*
		$(".board_button").hover(
			function(){
				$(this).css('border-color', 'White');
			},
			function(){
				$(this).css('border-color', 'Black');
		});
		*/

		$(".board_button").click(function(){
			schedule1.build_board(this.id);
			self.set_active(this.id);			
			rdj.redraw();
		});
	
	}

	this.set_active = function(b_id){
	
		$(".board_button").css({
			'color':'black'
		});
		$("#"+b_id+".board_button").css({
			'color':'#fef1bc'
		});
	}
}

function Schedule(board){
	this.board = board;
	
	this.create_schedule = function(){
		var schedule = "";
		schedule += "<div id ='schedule_container'>";
		schedule += "<div id = 'table_container'></div>";
		schedule += "</div>";
		$("#root").append(schedule);

		this.build_board(this.board);
	}
	
	this.set_css = function(){		
		$("#schedule_container").css({
			'position': 'absolute',
			'top':10,
			'height': '600px',
			'width': (MXS_table_data.table_width +25),
			'overflow': 'scroll',
		});
		
		$("#table_container").css({
			'position': 'absolute',
			
		});

		
	}

	this.build_board = function(board){
		this.board = board;

		//non-row-reliant version is more complex

		//row-reliant version	
		var num_cols = MXS_board_data[board][0]["col_num"] +1; //acounts for date/time column
		var num_rows = MXS_table_data.row_num;
		var col_width = MXS_board_data[board][0]["col_width"]
		//console.log(MXS_table_data.header_height);

		var table ="<table id=table"+this.board+" class='board_table'>";
		//build header
		table += "<tr height='"+MXS_table_data.header_height+"'>";
		table += "<th width = '"+MXS_table_data.fcol_width+"'></th>";
		$.each(MXS_board_data[board][1], function(key, value){
			table+="<th width='"+col_width+"'>"+value+"</th>"
		});
		table += "</tr>";

		for(var i=0; i<num_rows; i++){
			table += "<tr height='"+MXS_table_data.row_height+"'>";
						
			for(var j=0; j<num_cols; j++){
				
				if(j==0) //for the date/time column
				{
					table += "<td class='date_col'>"+date_array[i]+"</td>";
				}
				else
				{
					table += "<td></td>";
				}
				
			}				
			table += "</tr>";
		}
		

		table += "</table>";

		$("#table_container").html(table);

		this.set_table_css();

	}

	this.set_table_css = function(){
		$("table").css({
			'margin':0, 
			'padding':0,
			//'color': '#1C5D79',
			'color':'#444278',					
			'border-width':0,
			'font-family': '"Trebuchet MS",Trebuchet,Arial,sans-serif',

		});

		$("tr").css({
			//'background':'#DFEDF3'
			'background':'#f0e4cc'


		});
	
		//seems slower than native css
		$("tr").hover(
			function(){
				$(this).css({
					'background':'#ffffff'	
				});
	
			},
			function(){
				$(this).css({
					'background':'#f0e4cc'	
				});
			}
		);
	
		$("table, tr,td,th").css({
			//'border':'solid 1px #326e87',
			'border':'1px solid #444278',
			'border-collapse': 'collapse',
			'padding':0,
			'overflow': 'hidden',

		});

		$(".date_col").css({
			'padding':'5px',			
		});

	}
}

function Drag_container(){
	this.left_offset = 0;
	this.top_offset = 0;
	this.div_width = 0;
	this.div_height = 0;

	this.create_container = function(){
		var schedule = "";
		schedule += "<div id='drag_container'></div>";
		$("#schedule_container").append(schedule);		
	}

	this.calculate_pos = function(){
		//made bigger on either side by a pixel to accomodate dragging ranges
		//var left_offset = MXS_table_data.fcol_width; //for chrome
	
		this.left_offset = MXS_table_data.fcol_width +1;
		this.top_offset = MXS_table_data.header_height +3; //column height + top offset(of something)
		this.div_width = MXS_table_data.table_width - MXS_table_data.fcol_width + 5; //don't know why I need that 8
		this.div_height = MXS_table_data.row_height * MXS_table_data.row_num; //number of rows*height of rows
		
		
	}

	this.set_css = function(){
		this.calculate_pos();
		var self = this;
		$("#drag_container").css({
			'position':'absolute',
			'left': self.left_offset, 
			'top': self.top_offset,
			'width': self.div_width,
			'height': self.div_height,
		});

	}

	this.set_drag = function(){
		$("#drag_container").droppable({
		accept: ".lv_job",
		revert: "invalid",
		tolerance: "touch",
		drop: function(event, ui)
			{

				//remove from listview
				$("#"+item_id).remove();
				$("#list_view").sortable('refresh');
			
				//determine values for new job
				var item_id=ui.draggable[0]["attributes"]["id"]["nodeValue"];
								
				//new top position
				var item_pos_top = ui.offset.top;
				var header_row_height = MXS_table_data.header_height;
				//var table_top_offset = 40; //height of the board button bar 
				var table_top_offset = sd.top_offset;
				var scroll_bar_pos = $("#schedule_container").scrollTop();
				var top_val = $.fn.determine_base_height(item_pos_top, item_id) - table_top_offset - header_row_height + scroll_bar_pos;
				
				//solves problem of dropping onto drag container while drag container is "under" the LV
				//774 = height of drop window + top_offset
    				if((item_pos_top > 774) && ((scroll_bar_pos+600)!= drag1.div_height)) return; 
					
				//new lane value
				var item_pos_left = ui.offset.left - sd.left_offset; //natural offset within schedule - left offset caused by centering schedule
				//alert(item_pos_left);
				var lane_val = $.fn.get_lane(item_pos_left, "listview");
				
				//determine board
				var board_val = schedule1.board;

				//new width 
				var new_width = MXS_board_data[board_val][0]["col_width"];
			 	
				window[("job"+item_id)].set_new_values('board', board_val, lane_val, top_val, new_width);				
				window[("job"+item_id)].change_location('board');	
				window[("job"+item_id)].set_css();	

				//hard values
				//MXS_job_data[item_id][0]["location"] = "board";

				$.fn.ajax_update(item_id, "drop_to_board", "");
						
				
			}
		});
	}
	
}

//Sets up sorter bar
function LV_sorter(){
	this.fields = [];
	
	this.create_sorter = function(){
		var sorter = "<div id='list_view_sorter'>Sort</div>";
		$("#root").append(sorter);

	}

	this.create_fields = function(){
		//sets key-value pairs for each job using the $.each method
		//assumes all jobs have the same keys in stats
		
		var field_string="";
		var first = 0;
		var self = this;

		//test what happens when mxs loads a page with no jobs
		if(MXS_job_data != ""){
			$.each(MXS_job_data, function(key){
				first = key;
				return(false);
				
				//break;
			});

		}
	
		
		self.fields.push("id");	
		
		$.each(MXS_job_data[first][1], function(key, value){
			self.fields.push(key);					  	
		});

		for(var i in self.fields)
		{
			field_string+="<div id='"+self.fields[i]+"' class='field'>"+self.fields[i]+"</div>";
		}
	
		$("#list_view_sorter").html(field_string);

	}
	

	this.set_css = function(){
		$("#list_view_sorter").css({
			'position':'relative',
			'top': '346px',
			'width': (MXS_table_data.table_width +21),
			'height': '36px',
			'border': '2px solid #f8fafb',
			'background': 'Transparent',
			'line-height': '36px', 	
		});

		//sets it for the fields too
		$(".field").css({
			'position':'relative',
			'display':'inline',
			//'margin':'0 15 0 15',
			//'margin': '3 0 3 0',
			//'padding':'0 5 0 5',
			'height':'36px',
			//'line-height':'28px',
			'font-size':'1.2em',
			'border':'1px solid black', //#e5e5e5
			'cursor':'default',
			'border-radius': '5px',
			
		});

		$.each(MXS_field_widths, function(key, val){
			$("#"+key+".field").css({
				'width': val
			})

		});

		/*

		var field_offset = 36 + 55; //needs +6 
		
		//roughly calculates position of field buttons to align with start of fields
		for(var i in this.fields)
		{
			var x = parseInt(i) + 1;
			
			//var field_width = $("#"+this.fields[i]+".field").width();
			
			 
			//location of center of each job field
			//width of id div + margin value + 1/2 of job field width
			//var field_offset = parseInt(36 + ((x)*45) + (sd.width_arr[i]/2));

			
			if(i!=0)
			{
				field_offset += (45 + 10 + sd.width_arr[(parseInt(i)-1)]);	
			}
			
						
			$("#"+this.fields[x]+".field").css({
				//'left': parseInt(field_offset - (field_width/2)), 
				'left': parseInt(field_offset),

			});

		}
		
		$("#id.field").css({
				'left': 5,

		});
	
		//$(".field").corner("5px");	
		*/

	}

	this.add_sorting = function(){
		//sets hover, but may not be necessary if ui "selectable" values set
		
		//bind sorters to fields, using toggle mode
		$(".field").toggle(
			function(){
				$.fn.sort_by_id($(this).attr('id'), "down");
			},
			function(){
				$.fn.sort_by_id($(this).attr('id'), "up");
		});
	}
	

}

//Creates Listview
function Listview(){
	this.create_list = function(){
		var list = "";
		list = "<div id='list_view'></div>";
		$("#root").append(list);
	}
	
	this.set_css = function(){
		$("#list_view").css({
			'position':'absolute',
			'top': '344px',
			'margin': '46px 0 0 0',
			'width': (MXS_table_data.table_width +25),
			'height': '300px',
			//'border': '1px solid black',
			'background': 'Gray',
			'overflow':'auto',			
			'border-radius': '0 0 10px 10px', 
		});

		
	}

	this.set_sortable = function(){
		$("#list_view").sortable({
			accept: ".lv_job",
			helper: "clone",
			appendTo: 'body',
			cursorAt: {left:30},
			out: function(event, ui){
				//item_id = ui.item.attr('id');
				//useful
				//console.log(ui.helper);
			
				//check if ui.helper is invoked
				if(ui.helper != null){
					ui.helper.css({
						'width':50
					});
				}
			
			
			}
		
			
		});
	//if necessary
	$("#list_view").disableSelection(); 

	}


}

function Modaldialog(){
	this.label_array = [];
	this.parent_handle = "";
	this.data_string = "";
	
	this.create_box = function(){
		var dialog = "<div id='modal_dialog'>";
		
		dialog += "<table id='dialog_table'>";

		dialog+="</table>";


		$("#root").append(dialog);
	}

	this.set_features = function(){
		//dialog box settings
		var self = this;

		$("#modal_dialog").dialog({
			'modal': true,
			'autoOpen': false,
			'resizable': true,
			'buttons':{
				"Submit":function(){
					//need to update the job's own stats values and draw from there
					self.update_job_stats();
					self.collect_string();
					$.fn.ajax_update(self.parent_handle, "update_data", self.data_string);
					$(this).dialog("close");
					},
				"Cancel":function(){
					$(this).dialog("close");
					},				
				},
		});
		
		//jquery ui dialog css class
		$(".ui-dialog").css({
			'overflow':'scroll',
			'padding': '0.2em',
			'background': 'LightGrey',
			'border': '1px solid black',
		});		

				
	}
	
	this.update_data = function(id, stats){
		var self =this;		

		var labels = "";
		var vals = "";
		var input_id = "";

		var table_body = "";
		//table_body += "<tr><th id='label_head'>Name</th><th id='val_head'>Value</th></tr>";
		$.each(stats, function(key, value){
			
			table_body += "<tr>"

			table_body += "<td>"+key+"</td>"


			input_id = "input_"+key;
			table_body += "<td><input type ='text' id='"+input_id+"' class='dlg_val' value='"+value+"'/></td>";

			table_body += "</tr>";
			//labels += key+"<BR/><BR/>";
			//input_id = "input_"+key;
			//vals+="<input type ='text' id='"+input_id+"' class='dlg_val' value='"+value+"'/><BR/><BR/>";

			//store id's to each input type in our array
			self.label_array.push(key);
		});

		this.parent_handle = id;


		$("#dialog_table").html(table_body);
			
		//$("#labels").html(labels);
		//$("#vals").html(vals);

		
	}

	this.update_job_stats = function()
	{
		var self = this;
		//grab values from each dialog input
		var all_vals = ($(".dlg_val").map(function(){ //goes through each el in matched set and retrieves given value
			return this.value;	//value of each input line
		}).get()); //get returns an array 

		
		//create new stats object
		var temp_stats = {};
		for (x in all_vals){
			temp_stats[(self.label_array[x])] = all_vals[x];

		};		

		//update job stats		
		window["job"+this.parent_handle].stats = temp_stats; //update stats objects
		window["job"+this.parent_handle].set_text(); //update job text
		
	
	}	
	

	this.collect_string = function(){
		var self=this;
		self.data_string = "";
		var job_stats = window["job"+self.parent_handle].stats;
		
		index = 1
				
		$.each(job_stats, function(key, value){
			self.data_string+="&job[attr"+index+"]="+value;
			index = index + 1
		});
				
	}

}





/*HELPER METHODS*/

//doesn't work in IE, searches entire window, so use array instead
//found at http://www.liam-galvin.co.uk/2010/11/24/javascript-find-instance-name-of-an-object/#read
function findInstanceOf(obj){
	for(var v in window){
		try{
			if(window[v] instanceof obj){
				//return v; 	//return name
				return window[v]; //return object
			}
		}
		catch(e){}

	}
	return false;
}

//function to dynamically generate objects
function makejob(){
	//perhaps need to make an associative array of "pointers" to job objects 	
	var jobs = [];
	var b_jobs = [];
	var lv_jobs = []; 

	//make our little helper object in advance, then fill it with data as it comes in.
	sd = new StateData();
	sd.width_arr = $.fn.field_size();	

	$.each(MXS_job_data, function(key, value){
		var id = key;	
		var t = MXS_job_data[key][0];	
		var ar=[];
		var i=0;
		$.each(t, function(key, value){
			ar[i] = value;
			i++;
		});

		var stats = MXS_job_data[key][1];		
						
		window["job"+id] = new Job(key, ar[4], ar[5], ar[6], ar[1], ar[2], ar[3], '');
						
		//most direct way to access objects
		window[("job"+id)].set_stats(stats); //have to pass object in later due to inability of eval to process it
		window[("job"+id)].create_job();
		window[("job"+id)].set_css();

		
		//array of objects
		jobs.push(window[("job"+id)]);

		if(window[("job"+id)].location == 'board')
		{
			b_jobs.push(window[("job"+id)]);
		}
		else if(window[("job"+id)].location == 'listview')
		{
			lv_jobs.push(window[("job"+id)]);
		}
		
								
	});
		//set array of objects
		sd.jobs = jobs;
		sd.board_jobs = b_jobs;
		sd.lv_jobs = lv_jobs;
			

}

//determines the largest field size across all listview objects in order to create appropriate sizing  
(function($){
	$.fn.field_size = function(){
		var array = [];
		var i = 0;
		//added relevant font-size in css to properly determine pixel size of div with text @ font-size		
	
		$.each(MXS_job_data, function(key){
			i=0;
			$.each(MXS_job_data[key][1], function(key2, value){
				var width_val = $('#hidden').html(value).width();
				
				if(array[i] == null)
				{
					array.push(width_val); //loads with primary values
				}
				else
				{					
					if(width_val>array[i]) array[i] = width_val; //compares for size and keeps largest
				}				
				i++;
								
			});
			
		});

		return array;
	}
})(jQuery);

//the crappy sorter
(function($){
	$.fn.sort_by_id = function(field, direction){
	
	
	//grab id's of jobs in list view. may not be necesary if have all the details up front.
	//for each element in children grab id and store in array
		
	$("#list_view").sortable('refresh');	
	//$("#list_view").sortable('refreshPositions');
	
	//returns an array of ids located in the sortable container
	//var values_arr = $("#list_view").sortable("toArray");
	var ids_arr = $("#list_view").sortable("toArray");
	var values_arr = [];

	//for each id in list grabs the text data of the respective field to be sorted by
	$.each(ids_arr, function(index, value){
		var field_data = $("#"+value).find("#"+field).html();
		values_arr.push(field_data);

		});

	//alert(values_arr[0]+","+values_arr[1]+","+values_arr[2]+","+values_arr[3]+","+values_arr[4]+","+values_arr[5]+","+values_arr[6]+","+values_arr[7]);
	
	var last_pos = parseInt(values_arr.length);

	//only works as a descending sorter
	var i=0;
	var temp=0, temp_id=0;

	if(direction == 'down')
	{
		while(last_pos>1)
		{
			for(i=0; i<last_pos; i++)
			{
			//var str = values_arr[i];
			//var next_str = values_arr[i+1];
			//if(str.localeCompare(next_str) == 1)
				if(values_arr[i]>values_arr[i+1])
				{
					temp = values_arr[i+1];
					temp_id = ids_arr[i+1];

					values_arr[i+1] = values_arr[i];
					ids_arr[i+1] = ids_arr[i];
	
					values_arr[i] = temp; 
					ids_arr[i] = temp_id;
				
					$("#"+ids_arr[i+1]).insertAfter("#"+ids_arr[i]);	
					//$("#list_view").sortable('refresh');						
				}

			}
			last_pos--;
		}
	}

	//ascending
	if(direction == 'up')
	{
		var first_pos = 0;
		while(first_pos<last_pos)
		{
			for(i=last_pos; i>first_pos; i--)
			{
				if(values_arr[i]>values_arr[i-1])
				{
					temp = values_arr[i-1];
					temp_id = ids_arr[i-1];

					values_arr[i-1] = values_arr[i];
					ids_arr[i-1] = ids_arr[i];

					values_arr[i] = temp; 
					ids_arr[i] = temp_id;

					$("#"+ids_arr[i-1]).insertBefore("#"+ids_arr[i]);
					//$( "#list_view" ).sortable('refresh');	
				}

			}
			first_pos++;
		}
	}		
	
	
	};
})(jQuery);

//find the lane value based on drop position from LV to the board, and within the board drag container
(function($){
	$.fn.get_lane = function(pos_left, origin){
		var lane = "";
		var board_val = schedule1.board;
		
		//console.log(pos_left+" "+MXS_table_data.fcol_width);

		//dropped to the left of the dc
		if(pos_left<=(MXS_table_data.fcol_width+5)) //+5 for left offset
		{
			lane=1;
		}
		//dropped to the right of the board
		else if(pos_left>MXS_table_data.table_width){
			lane = MXS_board_data[board_val][0]["col_num"];
		}
		else
		{
			//within board from lv
			if(origin == 'listview')
			{
				var lane_width = parseInt(MXS_board_data[board_val][0]["col_width"]);
				lane = Math.round(pos_left/lane_width);
			}
			//within board
			if(origin == 'board')
			{
				var lane_width = parseInt(MXS_board_data[board_val][0]["col_width"]);
				var pos_center = pos_left+parseInt(MXS_board_data[board_val][0]["col_width"]/2);//measures from the center
				lane = Math.ceil((pos_center)/lane_width);
			}
		}
		
		return lane;
		
	};
})(jQuery);

//do the reverse of the above and obtain the pixel value (position left) from the lane value
(function($){
	$.fn.get_left_from_lane = function(lane){
		var board_val = schedule1.board;
		var lane_width = parseInt(MXS_board_data[board_val][0]["col_width"]);
		

		//include offset for each column including one one-pixel border piece
		var border_offset = lane-1;

		var left_pos = ((parseInt(lane)-1)*lane_width) + border_offset;
		
		return left_pos;
				
	};
})(jQuery);

//minimum height at which to drop based on job height
(function($){
	$.fn.determine_base_height = function(item_position_top, item_id){
	var top_pos = item_position_top;
	var job_height = window[("job"+item_id)].height; //figure this out from JSON using item_id
	var container_height = MXS_table_data.row_height * MXS_table_data.row_num + (MXS_table_data.row_height + $('table').offset().top-51); // num rows + drag container top offset also grab this from earlier data

	//make sure job doesn't start below the drag container
	if((top_pos+job_height)>container_height)
	{
		top_pos = top_pos - ((top_pos+job_height)-container_height) -1;
	}

	//make sure job doesn't start above the drag container
	//this is a problem since the drag container can't record the proper position of the job is outside of it
	//try to get an over: ui.position.top value for this
	if(top_pos<0)
	{
		top_pos = 68;
	}
	
	return top_pos;

	};
})(jQuery);

//Ajax calls
//send position update
(function($){
	$.fn.ajax_update = function(id, action, data){
	var msg = "";	
	var job = window[("job"+id)];
	var urladdon = "/jobs/" + id
		
	switch(action)
	{
		case "move_on_board":
			//msg = "utf8=%E2%9C%93&job[maxscheduler_id]=1&job[site_id]=1&job[user_id]=1&job[resource_id]="+job.lane+"&job[schedDate]=2012-09-26 10:00:00&job[schedTime]="+job.top+"&commit=Update+Job"
			msg = "utf8=%E2%9C%93&job[resource_id]="+job.lane+"&job[schedPixelVal]="+job.top+"&commit=Update+Job"
			break;

		case "drop_to_board":
			//msg = "shipID="+id+"&boardName="+job.board+"&lane="+job.lane+"&y="+job.top+"&path="+action;
			msg = "utf8=%E2%9C%93&job[resource_id]="+job.lane+"&job[schedPixelVal]="+job.top+"&commit=Update+Job"
			break;

		case "drop_to_listview":
			//msg = "shipID="+id+"&path="+action;
			msg = "utf8=%E2%9C%93&job[resource_id]=none&job[schedPixelVal]=0&commit=Update+Job"
			break;

		case "update_data":
			//msg = "shipID="+id+data+"&path="+action+"&commit=Update+Job";
			//msg = "utf8=%E2%9C%93&job%5Bmaxscheduler_id%5D=1&job%5Bsite_id%5D=1&job%5Buser_id%5D=1&job%5Bresource_id%5D=1&job%5BschedDate%5D=&job%5BschedTime%5D=&job%5Battr1%5D="+id+"&job%5Battr2%5D=FeliksFeliksMinidata&job%5Battr3%5D=blue&job%5Battr4%5D=blue&job%5Battr5%5D=blue&job%5Battr6%5D=fdafdsa&job%5Battr7%5D=fdafdsa&job%5Battr8%5D=fdafdsa&job%5Battr9%5D=&job%5Battr10%5D=&job%5Battr11%5D=&job%5Battr12%5D=&job%5Battr13%5D=&job%5Battr14%5D=&job%5Battr15%5D=&job%5Battr16%5D=&job%5Battr17%5D=&job%5Battr18%5D=&job%5Battr19%5D=&job%5Battr20%5D=&job%5Battr21%5D=&job%5Battr22%5D=&job%5Battr23%5D=&job%5Battr24%5D=&job%5Battr25%5D=&job%5Battr26%5D=&job%5Battr27%5D=&job%5Battr28%5D=&job%5Battr29%5D=&job%5Battr30%5D=&commit=Update+Job"
			msg = "utf8=%E2%9C%93&job[resource_id]="+job.lane+"&job[schedPixelVal]="+job.top+"&"+ data +"&commit=Update+Job"
			break;	

		default: 
			alert("The action did not result in a valid message");
			break;

	}
	console.log(msg);
	
	//if(action === "update_data"){
		$.ajax({
			type: 'POST',
			url: '/jobs/update/' + id,  //MXS_posting_url+urladdon
			data: msg, //{ _method:'PUT', msg : msg },
			dataType: 'text',
			async: true,
			success: function(data){
				console.log(data); //place around methods to allow success return to initiate action
			}					
			
		});		
	//}
		
	
	};
})(jQuery);




/*MAIN*/
//refresh method - can't use AJAX because it catches the response

$(document).ready(function(){
	var t = setTimeout("$.fn.self_update()", 300000);	

});

(function($){
	$.fn.self_update = function(){

		document.forms["load_form"].submit();	
		
	};
})(jQuery);


//The main object creator
$(document).ready(function(){
	//alert("something");	

//boardbar1 = new Board_bar();
//boardbar1.create_bar();
//boardbar1.set_css();
//boardbar1.add_selection();
//boardbar1.set_active("Board1");

schedule1 = new Schedule("Board1");
schedule1.create_schedule();
schedule1.set_css();

drag1 = new Drag_container();
drag1.create_container();
drag1.set_css();
drag1.set_drag();

listview1 = new Listview();
listview1.create_list();
listview1.set_css();
listview1.set_sortable();

dialog1 = new Modaldialog();
dialog1.create_box();
dialog1.set_features();

rdj = new ReDrawJobs();

makejob();

//needs to be placed here, to have access to job listview job position data
sorter1 = new LV_sorter();
sorter1.create_sorter();
sorter1.create_fields();
sorter1.set_css();
sorter1.add_sorting();

});








