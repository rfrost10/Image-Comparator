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
            image_url = v.value.image
            image_id_index = image_url.search('image_comparator/') + 'image_comparator/'.length
            image_id = parseInt(image_url.substring(image_id_index, image_url.length))
            results[image_id] = v.value.diagnosis
          })
          GTF.cachedClassifyResults = results;
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
          // var results = {};
          var results = [];
          pairResults = response.rows
          // debugger
          pairResults.forEach((v, i, a) => {
            image_url0 = v.value.image0
            image_url1 = v.value.image1
            
            image_id_index0 = image_url0.search('image_comparator/') + 'image_comparator/'.length
            image_id_index1 = image_url1.search('image_comparator/') + 'image_comparator/'.length
            
            image_id0 = parseInt(image_url0.substring(image_id_index0, image_url0.length))
            image_id1 = parseInt(image_url1.substring(image_id_index1, image_url1.length))
            if (v.value.accept_or_reject === 'accept') {
              temp_res = {}
              temp_res[image_id0] = v.value.classification0
              temp_res[image_id1] = v.value.classification1
              results.push(temp_res)
              // results[image_id0] = v.value.classification0
              // results[image_id1] = v.value.classification1
            }
            else if(v.value.accept_or_reject === 'reject'){
              temp_res = {}
              temp_res[image_id0] = 'reject'
              temp_res[image_id1] = 'reject'
              results.push(temp_res)
              // results[image_id0] = 'reject'
              // results[image_id1] = 'reject'
            }
          })
          // debugger
          GTF.cachedPairResults = results;
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
      this.cachedClassifyResults = [];
      this.cachedPairResults = [];
      return "no tasks means no UI to build";
    }
    if (this.gridAppRedirect === true) {
      // flatten into new variable
      results = {}
      
      if (Object.keys(this.cachedClassifyResults).length != 0){
        imageListSource = this.cachedClassifyResults
      } else if (Object.keys(this.cachedPairResults).length != 0) {
        imageListSource = this.cachedPairResults
      } else if (Object.keys(this.cachedClassifyResults).length === 0 && Object.keys(this.cachedPairResults).length === 0){
        alert("no cached results but this.gridAppRedirect === true")
      }
      
      imageListSource.forEach((v,i,a) => {
        Object.keys(v).forEach((v_,i_,a_) => {
          results[v_] = v[v_]
        })
      })
      // For ordering by frontal, lateral in pairs so that frontal is always first
      results_order = Object.keys(results)
      Object.keys(results).forEach((v, i, a) => {
        // debugger
        // if(i === 16){debugger}
        if (i % 2 === 0 && results[a[i]] === 'lateral' && results[a[i+1]] === 'frontal'){
          temp = results_order[i]
          results_order[i] = results_order[i+1]
          results_order[i+1] = temp        
        }
      })
      // debugger

      // For ordering by frontal, lateral and reject

      // frontal = [];
      // lateral = [];
      // reject = [];
      // Object.values(results).forEach((v, i, a) => {
      //   // debugger
      //   var keys = Object.keys(results)
      //   image_id = i + 1;
      //   image_id = keys[i];
      //   if (v === "frontal") {
      //     frontal.push(image_id)
      //   } else if (v === "lateral"){
      //     lateral.push(image_id)
      //   } else if (v === "reject"){
      //     reject.push(image_id)
      //   }
        
      // })
      grid_of_images = $('#grid_of_images');
      grid_of_images.empty()
      let n_count = Object.keys(results).length;
      let width = $("#img_columns")[0].value
      // let width = 2;
      let col_sizes = { 1: 12, 2: 6, 3: 4, 4: 3, 5: 2 }
      // debugger
      height = Math.floor(n_count / width) + n_count % width;
      [...Array(height).keys()].forEach((v, i, a) => {
        console.log(`making row ${i}`)
        var row = $(`<div class="row"></div>`)
        grid_of_images.append(row)
        // debugger
        results_order.slice(v * width, (v + 1) * width).forEach((v, i, a) => {
          var col = $(`<div class="col-xs-${col_sizes[width]}"></div>`)
          // var img = $(`<img src="/static/img/TCGA_CS_4944.png" alt="">`)
          // debugger
          reject_border = ''
          if (Object.keys(this.cachedPairResults).length != 0) {
            reject_border = results[v] === 'reject' ? "reject_border":""
          }
          var img = $(`<img id="image${v}"" src="" class="img-responsive image_frame ${reject_border}" alt="">`)
          this.getBase64DataOfImageFromCouch(v, htmlID = `image${v}`); // set image
          var label = $(`<label for="choices">Choose a class:</label>`)
          // selection_list = ['lateral','frontal'] //for later development
          // debugger
          var select = $(`<select name="class" id="image_${v}">
          <option value="frontal" ${results[v] === 'frontal' ? ' selected' : ''}>frontal</option>
          <option value="lateral" ${results[v] === 'lateral' ? ' selected' : ''}>lateral</option>
          <option value="reject" ${results[v] === 'reject' ? ' selected' : ''}>reject</option>
          </select>`)
          row.append(col)
          col.append(img, label, select)
          // debugger
          select[0].addEventListener('change', function(event){
            GridTaskFeeder.manageSelections(event)
          })
        })
      })
      // if
    }
    else {

      grid_of_images = $('#grid_of_images');
      grid_of_images.empty()
      let n_count = imageList.length;
      let width = $("#img_columns")[0].value
      // let width = 5;
      let col_sizes = { 1: 12, 2: 6, 3: 4, 4: 3, 5: 2 }
      height = Math.floor(n_count / width) + n_count % width;
      [...Array(height).keys()].forEach((v, i, a) => {
        // debugger
        console.log(`making row ${i}`)
        var row = $(`<div class="row"></div>`)
        grid_of_images.append(row)
        imageList.slice(v * width, (v + 1) * width).forEach((v, i, a) => {
          var col = $(`<div class="col-xs-${col_sizes[width]}"></div>`)
          // var img = $(`<img src="/static/img/TCGA_CS_4944.png" alt="">`)
          var img = $(`<img id="image${v}"" src="" class="img-responsive" alt="">`)
          // debugger
          this.getBase64DataOfImageFromCouch(v, htmlID = `image${v}`); // set image
          var label = $(`<label for="choices">Choose a class:</label>`)
          // selection_list = ['lateral','frontal'] //for later development
          // debugger
          var select = $(`<select name="class" id="image_${v}">
                            <option value="frontal" "selected">frontal</option>
                            <option value="lateral">lateral</option>
                            <option value="reject">reject</option>
                          </select>`)
          row.append(col)
          col.append(img, label, select)
        })
      })
      // else
    }
        
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

  GridTaskFeeder.manageSelections = function (event) {
    image_id = event.currentTarget.id
    row = event.currentTarget.parentElement.parentElement.children
    for(var i=0; i<row.length; i++){
      // debugger
      img_int_id = image_id.slice(6,image_id.length)
      row_item_int_id = row[i].children[0].id.slice(5,row[i].children[0].id.length)
      if (img_int_id === row_item_int_id){

        if (i % 2 === 0){
          // even index but odd position
          // debugger
          if (event.currentTarget.value === 'frontal'){
            row[i+1].children[2].value = 'lateral'
            row[i+1].children[0].classList.remove('reject_border')
            row[i].children[0].classList.remove('reject_border')
            break
          } else if (event.currentTarget.value === 'lateral'){
            row[i+1].children[2].value = 'frontal'
            row[i+1].children[0].classList.remove('reject_border')
            row[i].children[0].classList.remove('reject_border')
            break
          } else if (event.currentTarget.value === 'reject'){
            row[i+1].children[2].value = 'reject'
            row[i+1].children[0].classList.add('reject_border')
            row[i].children[0].classList.add('reject_border')
            break
          }
        } else if (i % 2 != 0){
          // odd index but even position
          // debugger
          if (event.currentTarget.value === 'frontal'){
            row[i-1].children[2].value = 'lateral'
            row[i-1].children[0].classList.remove('reject_border')
            row[i].children[0].classList.remove('reject_border')
            break
          } else if (event.currentTarget.value === 'lateral'){
            row[i-1].children[2].value = 'frontal'
            row[i-1].children[0].classList.remove('reject_border')
            row[i].children[0].classList.remove('reject_border')          
            break
          } else if (event.currentTarget.value === 'reject'){
            row[i-1].children[2].value = 'reject'
            row[i-1].children[0].classList.add('reject_border')
            row[i].children[0].classList.add('reject_border')
            break
          }
        } // if / else if

      } // if

    } // for

  };

  /* Begin Grid app specific functionality */
  // debugger
  GridTaskFeeder.setPrompt()
  GridTaskFeeder.handleUrlFilter(document.location.search);

}
