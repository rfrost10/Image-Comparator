
// This file adds shared utilities for ImageCompare objects
// - BB It also adds some global variables that can be used by other js and html files

// Get config file
var txt = '';
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function(){
  if(xmlhttp.status == 200 && xmlhttp.readyState == 4){
    txt = xmlhttp.responseText;
    
    DNS = eval(txt.substring(txt.indexOf('DNS',0), txt.indexOf('IMAGES_DB',0)-3))
    IMAGES_DB = eval(txt.substring(txt.indexOf('IMAGES_DB',0), txt.indexOf('DB_PORT',0)-3))
    DB_PORT = eval(txt.substring(txt.indexOf('DB_PORT',0), txt.indexOf('HTTP_PORT',0)-3))
    HTTP_PORT = eval(txt.substring(txt.indexOf('HTTP_PORT',0), txt.indexOf('DB_ADMIN_USER',0)-3))
    DB_ADMIN_USER = eval(txt.substring(txt.indexOf('DB_ADMIN_USER',0), txt.indexOf('DB_ADMIN_PASS',0)-3))
    DB_ADMIN_PASS = eval(txt.substring(txt.indexOf('DB_ADMIN_PASS',0), txt.indexOf('end',0)-1))

	  
    // Set initial values for dropdowns and other default elements 

    database_dropdown = document.getElementById('database')
    //var s = new Option(DNS,DNS)
    database_dropdown.innerHTML = "<option value='"+ DNS +"'>"+ DNS +"</option>"
    //database_dropdown.insertBefore(s,database_dropdown.childNodes[0])
    //database_dropdown.appendChild(s)


    database_dropdown = document.getElementById('si_db')
    database_dropdown.innerHTML = DNS


  }
};
xmlhttp.open("GET","../dbutil/Configuration.rb",true);
xmlhttp.send();



// - BB

var ImageCompare = (function (IC) {

    IC.TaskFeeder = IC.TaskFeeder || {};

    IC.TaskFeeder.GetImageDbUrl = function () {

        var  db_config_elem = document.getElementById("database");
        IC.TaskFeeder.db_config = db_config_elem.options[db_config_elem.selectedIndex].value;
        //IC.TaskFeeder.hostname = IC.TaskFeeder.db_config = "http://ec2-18-220-36-255.us-east-2.compute.amazonaws.com:54956/";
        IC.TaskFeeder.hostname = IC.TaskFeeder.db_config = "http://"+DNS+":"+DB_PORT+"/"
        IC.TaskFeeder.imageDbName = IMAGES_DB+"/";
        
	return IC.TaskFeeder.hostname + IC.TaskFeeder.imageDbName;
    };



    return IC;

}(ImageCompare || {}));
