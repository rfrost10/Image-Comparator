/* Feeder inherits from default.js */

var GridTaskFeeder = {}; // Meant to be global

function init_app() {
  // Update global app feeder variable
  const config_obj = {
    endpoint_image_list: "image_grid_lists",
    message: "Relabel incorrect images",
    app: "grid"
  }
  GridTaskFeeder = new TaskFeeder(config_obj);
  // Override methods and attributes of interest

  // - Methods
  GridTaskFeeder.getClassificationResults = function (imageList) {
    if (imageList === "no tasks left") {
      return "no tasks left"
    }

    GTF = this; // otherwise "this" becomes the $.ajax object
    return new Promise((resolve, reject) => {
      $.ajax({
        url: GTF.url_get_classification_results + `?username=${GTF.user}`,
        type: 'GET',
        success: function (response) {
          var results = {};
          classifyResults = response.rows
          classifyResults.forEach((v, i, a) => {
            // debugger
            image_url = v.value.image
            image_id_index = image_url.search('image_comparator/') + 'image_comparator/'.length
            image_id = parseInt(image_url.substring(image_id_index, image_url.length))
            results[image_id] = v.value.diagnosis
          })
          GTF.classifyResults = results // No longer needed.
          resolve(results);
        },
        error: function (response) {
          console.log("getClassificationResults failed : " + JSON.stringify(response));
          reject(Error("getClassificationResults failed : " + JSON.stringify(response)))
        }
      });
    })

  };

  GridTaskFeeder.getPairResults = function (imageList) {
    if (imageList === "no tasks left") {
      return "no tasks left"
    }
    GTF = this; // otherwise "this" becomes the $.ajax object
    return new Promise((resolve, reject) => {
      $.ajax({
        url: GTF.url_get_pair_results + `?username=${GTF.user}`,
        type: 'GET',
        success: function (response) {
          var results = {};
          pairResults = response.rows
          pairResults.forEach((v, i, a) => {
            if (v.value.accept_or_reject === 'accept') {
              image_url0 = v.value.image0
              image_url1 = v.value.image1

              image_id_index0 = image_url0.search('image_comparator/') + 'image_comparator/'.length
              image_id_index1 = image_url1.search('image_comparator/') + 'image_comparator/'.length

              image_id0 = parseInt(image_url0.substring(image_id_index0, image_url0.length))
              image_id1 = parseInt(image_url1.substring(image_id_index1, image_url1.length))

              results[image_id0] = v.value.classification0
              results[image_id1] = v.value.classification1
            }
          })
          // debugger
          // GTF.results = results // No longer needed.
          resolve(results);
        },
        error: function (response) {
          console.log("getPairResults failed : " + JSON.stringify(response));
          reject(Error("getPairResults failed : " + JSON.stringify(response)))
        }
      });
    })

  };

  GridTaskFeeder.buildUI = function (imageList) {
    console.log("in buildUI")
    if (imageList === "no tasks left") {
      this.imageList = [];
      return "no tasks means no UI to build";
    }
    // imageList coming in is really classifyResults and we ignore for now as we store the state ahead of time
    // debugger
    classifyResults = this.classifyResults
    newImageList = this.imageList
    if(this.gridAppRedirect === true){
      //Reorder by frontal\lateral\reject
      no_motion = [];
      mild_motion = [];
      moderate_motion = [];
      severe_motion = [];
      newImageList = [];
      // debugger
      Object.values(classifyResults).forEach((v, i, a) => {
        var keys = Object.keys(classifyResults)
        // image_id = i + 1;
        image_id = keys[i];
        if (v === "no_motion") {
          no_motion.push(image_id)
        } else if (v === "mild_motion") {
          mild_motion.push(image_id)
        } else if (v === "moderate_motion") {
          moderate_motion.push(image_id)
        } else {
          severe_motion.push(image_id)
        }
  
      })      
      newImageList = no_motion.concat(mild_motion).concat(moderate_motion).concat(severe_motion)
    }
    grid_of_images = $('#grid_of_images');
    grid_of_images.empty()
    let n_count = newImageList.length;
    let width = $("#img_columns")[0].value
    // let width = 5;
    let col_sizes = { 1: 12, 2: 6, 3: 4, 4: 3, 5: 2 }
    height = Math.floor(n_count / width) + n_count % width;
    [...Array(height).keys()].forEach((v, i, a) => {
      // debugger
      console.log(`making row ${i}`)
      var row = $(`<div class="row"></div>`)
      grid_of_images.append(row)
      newImageList.slice(v * width, (v + 1) * width).forEach((v, i, a) => {
        var col = $(`<div class="col-xs-${col_sizes[width]}"></div>`)
        // var img = $(`<img src="/static/img/TCGA_CS_4944.png" alt="">`)
        var img = $(`<img id="image${v}"" src="" class="img-responsive" alt="">`)
        // debugger
        this.getBase64DataOfImageFromCouch(v, htmlID = `image${v}`); // set image
        var label = $(`<label for="choices">Choose a class:</label>`)
        // selection_list = ['lateral','frontal'] //for later development
        // debugger
        if(this.gridAppRedirect === true){
          var select = $(`<select name="class" id="image_${v}">
                            <option value="no_motion" ${classifyResults[v] === 'no_motion' ? ' selected' : ''}>no_motion</option>
                            <option value="mild_motion" ${classifyResults[v] === 'mild_motion' ? ' selected' : ''}>mild_motion</option>
                            <option value="moderate_motion" ${classifyResults[v] === 'moderate_motion' ? ' selected' : ''}>moderate_motion</option>
                            <option value="severe_motion" ${classifyResults[v] === 'severe_motion' ? ' selected' : ''}>severe_motion</option>
                          </select>`)
        }else{
          var select = $(`<select name="class" id="image_${v}">
                            <option value="no_motion" selected>no_motion</option>
                            <option value="mild_motion">mild_motion</option>
                            <option value="moderate_motion">moderate_motion</option>
                            <option value="severe_motion">severe_motion</option>
                          </select>`)
        }
        row.append(col)
        col.append(img, label, select)
      })
    })
  };

  GridTaskFeeder.gridSubmit = function () {
    TF = this;
    console.log("gridSubmit");
    // Gather all imageIDs
    let = images = $("select[name='class']");

    // Gather all responses and ids
    // image_ids = images.map((i) => {return `image_${i+1}`})

    image_ids = images.map((i) => { return images[i].id })
    image_results = images.map((i) => { return images[i].value })

    couch_results = {}
    image_ids.toArray().forEach((v, i, a) => {
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
      url: `http://${DNS}:${HTTP_PORT}/task_results`,
      data: JSON.stringify(save_results),
      dataType: "json",
      type: 'POST',
      contentType: 'application/json',
      success: function (response) {
        console.log('success')
        // Remove Images
        $('#grid_of_images').empty()
        // Reset incomplete tasks list
        TF.OnSetUser(TF.user)
      },
      error: function (response) {
        console.log("get of tasks failed : " + JSON.stringify(response));
      }
    });

  };

  /* Begin Grid app specific functionality */
  // debugger
  GridTaskFeeder.setPrompt()
  GridTaskFeeder.handleUrlFilter(document.location.search);

}
