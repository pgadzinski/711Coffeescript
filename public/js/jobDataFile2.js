

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
            //24: (new jobCreate(24,'1',140,60,250,40,'red','attr1', 'attr2','attr3','attr4','attr5','attr6','attr7')),
            4: (new jobCreate( 4,'2',100,20,250,40,'blue','11111','2222','33333','White','2','fish','door')),
};

