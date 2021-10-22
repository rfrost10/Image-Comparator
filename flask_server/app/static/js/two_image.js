/* Feeder inherits from default.js */

var CompareTaskFeeder = {}; // Meant to be global

function init_app() {
    // debugger
    // Update global app feeder variable
    const config_obj = {
        endpoint_image_list: "image_compare_lists",
        message: "Default Compare Message",
        app: "compare"
    }
    CompareTaskFeeder = new TaskFeeder(config_obj);
    // Override methods and attributes of interest

    // - Attributes
    CompareTaskFeeder.currentPair = [];
    CompareTaskFeeder.nextPair = [];

    // - Methods
    CompareTaskFeeder.buildUI = function (imageList) {
        if (imageList === "no tasks left") {
            // debugger
            $("#image0").attr('src', "")
            $("#image1").attr('src', "")
            return "no tasks means no UI to build"
        } else {
            // debugger
            this.currentPair = this.imageList[this.currentTask.current_idx]
            // //img0
            var idx0 = this.currentPair[0];
            image0_src_attribute = this.getBase64DataOfImageFromCouch(idx0.toString(), htmlID = "image0")
            // //img1
            var idx1 = this.currentPair[1];
            image1_src_attribute = this.getBase64DataOfImageFromCouch(idx1.toString(), htmlID = "image1")
        }
    };

    CompareTaskFeeder.compareSubmit = function (selection) {
        console.log("compareSubmit");
        // Gather all imageIDs
        TF = this;
        const user = this.user;

        const currentTime = new Date();

        const timeStr = currentTime.toString();
        const img0 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentPair[0]}`;
        const img1 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentPair[1]}`;
        const winnerId = selection;
        // If Tie not mandatory and all submissions require comment or at least an optional comment
        const comment = $("#justification").val();
        const task = this.currentTask._id;
        const task_idx = this.currentTask.current_idx;
        // debugger

        const save_results = {
            user: user,
            type: "compareResult",
            date: timeStr,
            image0: img0,
            image1: img1,
            winner: winnerId,
            justification: comment,
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


    CompareTaskFeeder.commentAlert = function () {
        alert('If you want to provide an optional justification for your decision (left/right/tie), please enter it before you click left/right/tie. The text box will refresh after a decision is made.')
    }

    /* Begin Compare app specific functionality */
    // debugger
    CompareTaskFeeder.setPrompt();
    CompareTaskFeeder.handleUrlFilter(document.location.search);


}
