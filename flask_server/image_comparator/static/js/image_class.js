/* Feeder inherits from default.js */

var ClassifyTaskFeeder = {}; // Meant to be global

function init_app() {
    // debugger
    // Update global app feeder variable
    const config_obj = {
        endpoint_image_list: "image_classify_lists",
        message: "Classify Motion Severity",
        app: "classify"
    }
    ClassifyTaskFeeder = new TaskFeeder(config_obj);
    // Override methods and attributes of interest

    // - Attributes
    ClassifyTaskFeeder.currentImg = null;
    ClassifyTaskFeeder.nextImg = null;
    ClassifyTaskFeeder.usingCheckbox = true;
    ClassifyTaskFeeder.keyboardShortcuts = false; // turn keyboard listener on\off

    // - Methods
    ClassifyTaskFeeder.buildUI = function (imageList) {
        // debugger
        if (imageList === "no tasks left") {
            $("#image0").attr('src', "")
            return "no tasks means no UI to build"
        } else {
            // debugger
            this.currentImg = this.imageList[this.currentTask.current_idx]
            // //img0
            this.getBase64DataOfImageFromCouch(this.currentImg.toString(), htmlID = "image0")
                .then(response => {
                    // enable buttons now that submission is over
                    this.enableButtons();
                })
        }
    };

    ClassifyTaskFeeder.classifySubmit = function (selection) {
        console.log("classifySubmit");

        // Check that one of the motion categories has been selected
        if (ClassifyTaskFeeder.usingCheckbox && document.getElementById('class_checkboxes') != null){
            no_motion_checkbox = document.getElementById('no_motion');
            mild_motion_checkbox = document.getElementById('mild_motion');
            moderate_motion_checkbox = document.getElementById('moderate_motion');
            severe_motion_checkbox = document.getElementById('severe_motion');

            let motion_boxes = [no_motion_checkbox.checked, mild_motion_checkbox.checked, moderate_motion_checkbox.checked, severe_motion_checkbox.checked]
            if ( motion_boxes.every(element => element === false) ){
                alert("Please select a motion category!")
                return false
            }
        }

        this.disableButtons();
        // Gather all imageIDs
        TF = this;
        const user = this.user;

        const currentTime = new Date();

        const timeStr = currentTime.toString();
        const img0 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentImg}`;
        const task = this.currentTask._id;
        const task_idx = this.currentTask.current_idx;
        // debugger

        save_results = {
            user: user,
            type: "classifyResult",
            date: timeStr,
            image: img0,
            // diagnosis: selection.id, // button id
            task: task,
            task_list_name: this.currentTask.list_name,
            task_idx: task_idx,
        }

        // Check if this is a button or checkbox classification
        if (ClassifyTaskFeeder.usingCheckbox && document.getElementById('class_checkboxes') != null){
            let checkboxes = ['no_motion','mild_motion','moderate_motion','severe_motion','neck','flow']
            checkboxes.forEach((v,i,a) =>{
                save_results[`diagnosis_${v}`] = document.getElementById(v).checked
            })
        }
        debugger
        $.ajax({
            url: `http://${DNS}:${HTTP_PORT}/task_results`,
            data: JSON.stringify(save_results),
            dataType: "json",
            type: 'POST',
            contentType: 'application/json',
            success: function (response) {
                // debugger
                // Uncheck checkbox
                TF.clearSelection()
                // Reset incomplete tasks list
                TF.OnSetUser(TF.user)
            },
            error: function (response) {
                console.log("get of tasks failed : " + JSON.stringify(response));
            }
        });

    };


    ClassifyTaskFeeder.commentAlert = function () {
        alert('If you want to provide an optional justification for your decision (left/right/tie), please enter it before you click left/right/tie. The text box will refresh after a decision is made.')
    };

    ClassifyTaskFeeder.initCheckboxListener = function (number_keys) {
        no_motion_checkbox = document.getElementById('no_motion');
        mild_motion_checkbox = document.getElementById('mild_motion');
        moderate_motion_checkbox = document.getElementById('moderate_motion');
        severe_motion_checkbox = document.getElementById('severe_motion');
        neck_checkbox = document.getElementById('neck');
        flow_checkbox = document.getElementById('flow');
        // If no_motion is checked, unselect mild,moderate,severe
        no_motion_checkbox.addEventListener('change', function() {
            // alert("hello") // can use to check a button is being pressed
            mild_motion_checkbox.checked = false
            moderate_motion_checkbox.checked = false
            severe_motion_checkbox.checked = false
        });
        mild_motion_checkbox.addEventListener('change', function() {
            no_motion_checkbox.checked = false
            moderate_motion_checkbox.checked = false
            severe_motion_checkbox.checked = false
        });
        moderate_motion_checkbox.addEventListener('change', function() {
            no_motion_checkbox.checked = false
            mild_motion_checkbox.checked = false
            severe_motion_checkbox.checked = false
        });
        severe_motion_checkbox.addEventListener('change', function() {
            no_motion_checkbox.checked = false
            mild_motion_checkbox.checked = false
            moderate_motion_checkbox.checked = false
        });

    };
    ClassifyTaskFeeder.initKeyboardListener = function () {
        TF = this;
        document.addEventListener('keydown', function (event) {
            if (!($("#rejectModal").css("display") === "block")) {
                if (TF.keyboardShortcuts === false) {
                    if (event.keyCode == 49) {
                        alert('1 was pressed');
                    }
                    else if (event.keyCode == 50) {
                        alert('2 was pressed');
                    }
                    else if (event.keyCode == 51) {
                        alert('3 was pressed');
                    }
                    else if (event.keyCode == 52) {
                        alert('4 was pressed');
                    }
                    else if (event.keyCode == 53) {
                        alert('5 was pressed');
                    }
                    else if (event.keyCode == 54) {
                        alert('6 was pressed');
                    }
                } else if (TF.keyboardShortcuts === true && document.getElementById("no_motion").disabled === false) {
                    if (event.keyCode == 49) {
                        $("#no_motion")[0].click()
                    }
                    else if (event.keyCode == 50) {
                        $("#mild_motion")[0].click()
                    }
                    else if (event.keyCode == 51) {
                        $("#moderate_motion")[0].click()
                    }
                    else if (event.keyCode == 52) {
                        $("#severe_motion")[0].click()
                    }
                    else if (event.keyCode == 53) {
                        $("#neck")[0].click()
                    }
                    else if (event.keyCode == 54) {
                        $("#flow")[0].click()
                    }
                    // else if (event.keyCode == 54) {  // for enter find id/attribute for "submit"
                    //     $("#flow")[0].click()
                    // }
                }
            }
        });  
    };

    ClassifyTaskFeeder.toggleKeyboardShortcuts = function () {
        p_mode = document.getElementById('keyboardShortcuts')
        if (this.keyboardShortcuts === true) {
            p_mode.innerHTML = 'Off'
            this.keyboardShortcuts = false
            console.log(p_mode.innerHTML)
            console.log(this.keyboardShortcuts)
        } else {
            p_mode.innerHTML = 'On'
            this.keyboardShortcuts = true
            console.log(p_mode.innerHTML)
            console.log(this.keyboardShortcuts)
        }
    };

    ClassifyTaskFeeder.resetToPreviousClassification = function () {
        TF = this;
        if (TF.currentTask.current_idx === 0) {
            alert('You are on the first task, cannot go back.')
        } else {
            TF.disableButtons();
            $.ajax({
                url: this.url_reset_to_previous_result,
                type: 'POST',
                data: JSON.stringify(this.currentTask),
                headers: { 'Content-Type': 'application/json' },
                success: (response) => {
                    TF.OnSetUser(TF.user)
                },
                error: (response) => {
                    console.log('resetToPreviousClassification error!')
                },
            });
        }
    };

    ClassifyTaskFeeder.clearSelection = function () {
        document.getElementById("no_motion").checked = false;
        document.getElementById("mild_motion").checked = false;
        document.getElementById("moderate_motion").checked = false;
        document.getElementById("severe_motion").checked = false;
        document.getElementById("neck").checked = false;
        document.getElementById("flow").checked = false;
    };

    ClassifyTaskFeeder.enableButtons = function () {
        document.getElementById("no_motion").disabled = false;
        document.getElementById("mild_motion").disabled = false;
        document.getElementById("moderate_motion").disabled = false;
        document.getElementById("severe_motion").disabled = false;
        document.getElementById("neck").disabled = false;
        document.getElementById("flow").disabled = false;
        document.getElementById("previousClassification").disabled = false;
    };

    ClassifyTaskFeeder.disableButtons = function () {
        document.getElementById("no_motion").disabled = true;
        document.getElementById("mild_motion").disabled = true;
        document.getElementById("moderate_motion").disabled = true;
        document.getElementById("severe_motion").disabled = true;
        document.getElementById("neck").disabled = true;
        document.getElementById("flow").disabled = true;
        document.getElementById("previousClassification").disabled = true;
    };

    /* Begin Classify app specific functionality */
    // debugger
    ClassifyTaskFeeder.setPrompt();
    ClassifyTaskFeeder.handleUrlFilter(document.location.search);
    ClassifyTaskFeeder.initCheckboxListener();
    ClassifyTaskFeeder.initKeyboardListener();

}
