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
		23: (new jobCreate(23333,'none',100,20,200,20,'blue','attr122', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		24: (new jobCreate(24,'1',140,60,250,40,'red','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		25: (new jobCreate(25,'1',140,100,300,60,'green','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
		26: (new jobCreate(26,'none',100,100,300,60,'green','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
	};