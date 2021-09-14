/* Feeder inherits from default.js */

var GridTaskFeeder = {}; // Meant to be global

function init_app() {
  // Update global app feeder variable
  const config_obj = {
      endpoint_image_list:"image_grid_lists",
      message:"Relabel incorrect images",
  }
  GridTaskFeeder = new TaskFeeder(config_obj);
  // Override methods and attributes of interest
  GridTaskFeeder.buildUI = function(imageList) {
    if(imageList === "no tasks left"){
      return "no tasks means no UI to build"
    }else{
      grid_of_images = $('#grid_of_images');
      n_count = imageList.length;
      width = 5;
      height = Math.floor(n_count/width) + n_count%width;
      [...Array(height).keys()].forEach((v,i,a) => {
        console.log(`making row ${i}`)
        var row = $(`<div class="row"></div>`)
        grid_of_images.append(row)
        imageList.slice(v*width,(v+1)*width).forEach((v,i,a) => {
          var col = $(`<div class="col-xs-2"></div>`)
          // var img = $(`<img src="/static/img/TCGA_CS_4944.png" alt="">`)
          var img = $(`<img src="http://${DNS}:${DB_PORT}/image_comparator/${v}/image" alt="">`)
          var label = $(`<label for="cars">Choose a class:</label>`)
          var select = $(`<select name="class" id="image_${v}">
                            <option value="no_motion">no_motion</option>
                            <option value="mild_motion" selected>mild_motion</option>
                            <option value="moderate_motion">moderate_motion</option>
                            <option value="severe_motion">severe_motion</option>
                           </select>`)
          row.append(col)
          col.append(img, label, select)    
        })
      })

    }
  };

  GridTaskFeeder.gridSubmit = function() {
    console.log("gridSubmit");
    // Gather all imageIDs
    let = images = $("select[name='class']");

    // Gather all responses and ids
    // image_ids = images.map((i) => {return `image_${i+1}`})

    image_ids = images.map((i) => {return images[i].id})
    image_results = images.map((i) => {return images[i].value})
    
    couch_results = {}
    image_ids.toArray().forEach((v,i,a) => {
      couch_results[v] = image_results[i]
    })
    
    
    now = new Date()
    save_results = {
      user: this.user,
      type: "gridResult",
      date: now,
      couch_results: couch_results,
      task_list_name: this.currentTask.list_name,
      // task_idx: "6"
    }

    $.ajax({
      url : `http://${DNS}:${HTTP_PORT}/task_results`,
      data : JSON.stringify(save_results),
      dataType: "json",
      type : 'POST',
      contentType: 'application/json',
      success: function(response){
        console.log('success')
        // Remove Images
        $('#grid_of_images').empty()
        // Reset incomplete tasks list
        GTF.OnSetUser(GTF.user)
      },
      error: function (response) {
          console.log("get of tasks failed : " + JSON.stringify(response));
      }
    });

  };
  
  /* Begin Grid app specific functionality */
  // debugger
  GridTaskFeeder.setPrompt()
  
}
