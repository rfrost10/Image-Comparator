/* Feeder inherits from default.js */

var ClassifyTaskFeeder = {}; // Meant to be global

function init_app() {
    // debugger
    // Update global app feeder variable
    const config_obj = {
        endpoint_image_list: "image_classify_lists",
        message: "Default Classify Message",
        app: "classify"
    }
    ClassifyTaskFeeder = new TaskFeeder(config_obj);
    // Override methods and attributes of interest

    // - Attributes
    ClassifyTaskFeeder.currentImg = null;
    ClassifyTaskFeeder.nextImg = null;
    ClassifyTaskFeeder.practice = true; // turn keyboard listener on\off

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
            this.getBase64DataOfImageFromCouch(this.currentImg.toString(), htmlID = "image0");
        }
    };

    ClassifyTaskFeeder.classifySubmit = function (selection) {
        console.log("classifySubmit");

        // Gather all imageIDs
        // debugger
        TF = this;
        const user = this.user;

        const currentTime = new Date();

        const timeStr = currentTime.toString();
        const img0 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentImg}`;
        const task = this.currentTask._id;
        const task_idx = this.currentTask.current_idx;
        // debugger

        const save_results = {
            user: user,
            type: "classifyResult",
            date: timeStr,
            image0: img0,
            diagnosis: selection.id,
            task: task,
            task_list_name: this.currentTask.list_name,
            task_idx: task_idx,
        }

        $.ajax({
            url: `http://${DNS}:${HTTP_PORT}/task_results`,
            data: JSON.stringify(save_results),
            dataType: "json",
            type: 'POST',
            contentType: 'application/json',
            success: function (response) {
                // debugger
                console.log('success')
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

    ClassifyTaskFeeder.initKeyboardListener = function () {
        TF = this;
        document.addEventListener('keydown', function (event) {
            if (TF.practice === true) {
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
            } else if (TF.practice === false) {
                if (event.keyCode == 49) {
                    $("#option1").click()
                }
                else if (event.keyCode == 50) {
                    $("#option2").click()
                }
                else if (event.keyCode == 51) {
                    $("#option3").click()
                }
                else if (event.keyCode == 52) {
                    $("#option4").click()
                }
            }

        });
    };

    ClassifyTaskFeeder.togglePracticeMode = function () {
        p_mode = document.getElementById('practice_mode')
        if (this.practice === true) {
            p_mode.innerHTML = 'Off'
            this.practice = false
            console.log(p_mode.innerHTML)
            console.log(this.practice)
        } else {
            p_mode.innerHTML = 'On'
            this.practice = true
            console.log(p_mode.innerHTML)
            console.log(this.practice)
        }
    };

    /* Begin Classify app specific functionality */
    // debugger
    ClassifyTaskFeeder.setPrompt();
    ClassifyTaskFeeder.handleUrlFilter(document.location.search);
    ClassifyTaskFeeder.initKeyboardListener();

}
