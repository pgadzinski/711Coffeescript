

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

jobBucket = {
1: (new jobCreate(1,[1],0,50.0,250,150.0,"blue","32503","Toffee Hex Rings","48","Red","3","fish")),
3: (new jobCreate(3,[3],0,88.0,250,50.0,"blue","32520","Dutchies","60","Green","1","fish")),
2: (new jobCreate(2,0,0,0,250,200.0,"blue","32510","Yeast Fills","72","White","4","fish")),
4: (new jobCreate(4,0,0,0,250,100.0,"blue","32531","Apple Fritters","36","White","2","fish")),}; 
