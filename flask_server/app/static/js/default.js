
// This file adds shared utilities for ImageCompare objects
// - BB It also adds some global variables that can be used by other js and html files
$.ajax({
  url : "/configuration",
  type : 'GET',
  success: function(response){
    // Still super insecure, but at least we're converted to flask
    DNS = response['DNS']
    IMAGES_DB = response['IMAGES_DB']
    DB_PORT = response['DB_PORT']
    HTTP_PORT = response['HTTP_PORT']
    DB_ADMIN_USER = response['DB_ADMIN_USER']
    DB_ADMIN_PASS = response['DB_ADMIN_PASS']
      
    // Set initial values for dropdowns and other default elements 

    database_dropdown = document.getElementById('database')
    database_dropdown.innerHTML = "<option value='"+ DNS +"'>"+ DNS +"</option>"

    database_dropdown = document.getElementById('si_db')
    database_dropdown.innerHTML = DNS
    
    // Init App
    init_app(); // Each will separately set this function up
  },
  error: function (response) {
      console.log("config setup failed : " + JSON.stringify(response));
  }
})

// - BB - Attempt to clean up ImageCompare class
// 08/27/2021
function TaskFeeder(config_obj) {
  // Most Attributes and Methods are deigned to be overwritted by inheritance

  // Attributes (may change as db model changes)
  // Meant to be updated and represent app state
  this.user = "default";
  this.message = config_obj['message'];
  this.incompleteTasks = [];
  this.currentTask = {};
  this.imageList = [];

  // DB Endpoints
  this.endpoint_rawImageDbName = "imageSet2ImageId/";
  this.endpoint_allTasks = "tasks/";
  this.endpoint_resultsDB = "taskresults/";
  this.endpoint_image_lists = config_obj['endpoint_image_list'];
  this.endpoint_incompleteTasks = "incomplete_tasks/";

  // Flask Endpoints
  this.endpoint_task_results = "task_results"

  // DB URLs
  this.url_incomplete_tasks_base = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/_design/basic_views/_view/${this.endpoint_incompleteTasks}`;
  this.url_image_list_base = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/_design/basic_views/_view/${this.endpoint_image_lists}`;
  this.url_results_base = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/_design/basic_views/_view/${this.endpoint_resultsDB}`;

  // Flask URLs
  this.url_results_base = `http://${DNS}:${HTTP_PORT}/${this.endpoint_task_results}/`;
  this.url_results_base = `http://${DNS}:${HTTP_PORT}/${this.endpoint_task_results}/`;
  
  


  // Methods
  this.setPrompt = function(message=this.message){
    $('#to-do-message').html(message)
  };
  /* This (OnSetUser) kicks off most tasks.
     It's importanat as much as possible that we have this high level function kick off
     as many tasks so that future developers don't have to 
     navigate chains of callbacks and ajax calls to find the final
     method or function being called in a string of calls.
     Inevitably JavaScript is event driven and some things really have to wait for
     others to finish so they can act on that data. 
     In those cases, nesting of function calls is hard to avoid.
  */ 
  this.OnSetUser = function(user) {
    console.log('In OnSetUser:\n')
    console.log ("User changed to: " + user);
    this.user = user;
    ImageCompare.user = this.user; // should retire as soon as TaskFeeder does everything it does
    this.updateUserAndDB();
    // this.getIncompleteTasks(this.user, this.updateStatInfoTasks);
    this.getIncompleteTasks(this.user)
      .then((response) => {return this.updateStatInfoTasks(response)})
      .then((response) => {return this.getHighestPriorityTask(response)})
      .then((response) => {return this.getTaskImageList(response)})
      .then((response) => {this.buildUI(response)})
    
    // ImageCompare.TaskFeeder.SetImage(user); //delete when you know you don't need it anymore
  };

  this.updateUserAndDB = function() {
    console.log('In updateUserAndDB:\n')

    // update user
    var si_user = document.getElementById("si_user");
    var user_elem = document.getElementById("username");
    var selUser = user_elem.options[user_elem.selectedIndex];
    si_user.textContent = selUser.text;
    var label = $("#si_user_label");
    var isDanger = (selUser.value === "testuser");
    setLabelDanger(isDanger, label);

    // update database
    var is_db = document.getElementById("si_db"); // is this being used?
    var db_elem = document.getElementById("database");
    var seldb = db_elem.options[db_elem.selectedIndex];
    si_db.textContent = seldb.text;
    var label = $("#si_db_label");
    var isDanger = (seldb.value === "localhost");
    setLabelDanger(isDanger, label);

  };

  this.getIncompleteTasks = function(user) {
  // this.getIncompleteTasks = function(user, successFn) {
    console.log('In getIncompleteTasks:\n')
    // We should have this set a "state" or attribute of TaskFeeder that is the user's incomplete tasks so 
    // other functions can just reference it.
    return new Promise((resolve, reject) => {
      $.ajax({
        url : this.url_incomplete_tasks_base,
        type : 'GET',
        success: function(response){
          resolve(response);
        },
        error: function (response) {
            console.log("get of tasks failed : " + JSON.stringify(response));
            reject(Error("get of tasks failed : " + JSON.stringify(response)))
        }
      });      
    }) // Promise

  };
  
  this.updateStatInfoTasks = function(json) {
    // okay, this seems wrong, we got all the tasks - way too much data over the wire
    // filtering should happen on the server side - is this what reduce is for?
    var tasks = json.rows;
    var si_tasks_elem = document.getElementById("si_tasks");
    // this is to be updated - hide it if there are no pending tasks
    var curTaskElem = document.getElementById("si_curtask");

    relevant_tasks_for_this_app=[];
    tasks.forEach((v,i,a) => {
      task = v;
      if (task.value.task_type === "grid" && task.value.user === this.user){
        relevant_tasks_for_this_app.push(task.value)
      }
    })
    this.incompleteTasks = relevant_tasks_for_this_app
    if (relevant_tasks_for_this_app.length > 0) {
      si_tasks_elem.innerText = `${this.incompleteTasks.length} unfinished tasks`
      curTaskElem.hidden = false;
    }else{
      // curTaskElem.hidden = true;
      si_tasks_elem.innerText = "0 unfinished tasks"
      curTaskElem.innerText = "Currently no tasks found"
    }
    return 'updateStatInfoTasks is done'
  };

  this.getHighestPriorityTask = function(input){ // input is a bad name for what is coming through 'updateStatInfoTasks is done'
    tasks = this.incompleteTasks
    var lastHighestPriority = 1000000
    var highestPriorityTaskIndex = 0
    tasks.forEach((v,i,a) => {
      if(i != 0){ // if not the first item
        if (v.task_order < lastHighestPriority){
          highestPriorityTaskIndex = i
        }
      }else {
        lastHighestPriority = v.task_order
      }      
    })

  this.currentTask = this.incompleteTasks[highestPriorityTaskIndex]
  return this.currentTask;
  };
  
  this.getTaskImageList = function(task) {
    GTF = this; // otherwise "this" becomes the $.ajax object
    return new Promise((resolve, reject) => {
      $.ajax({
        url : this.url_image_list_base,
        type : 'GET',
        success: function(response){
          GTF.imageList = response.rows[0].value.list;
          resolve(GTF.imageList);
        },
        error: function (response) {
            console.log("get of tasks failed : " + JSON.stringify(response));
            reject("get of tasks failed : " + JSON.stringify(response))
        }
      });
    })
  };

  this.buildUI = function(imageList) {
    alert("app not set up to inherit properly")
  };

}









































// - BB - meant to be deleted 
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
// - BB - meant to be deleted 
