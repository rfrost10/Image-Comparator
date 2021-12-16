/* Feeder inherits from default.js */

var PairTaskFeeder = {}; // Meant to be global

function init_app() {
    // debugger
    // Update global app feeder variable
    const config_obj = {
        endpoint_image_list: "image_pair_lists",
        message: "Label Frontal Image",
        app: "pair"
    }
    PairTaskFeeder = new TaskFeeder(config_obj);
    // Override methods and attributes of interest

    // - Attributes
    PairTaskFeeder.currentPair = [];
    PairTaskFeeder.nextPair = [];
    PairTaskFeeder.keyboardShortcuts = false; // turn keyboard listener on\off
    PairTaskFeeder.image0Annotation = null;
    PairTaskFeeder.image1Annotation = null;
    PairTaskFeeder.imageSelected = null; // might not need anymore

    // - Methods
    PairTaskFeeder.buildUI = function (imageList) {
        if (imageList === "no tasks left") {
            // debugger
            $("#image0").attr('src', "")
            $("#image1").attr('src', "")
            return "no tasks means no UI to build"
        } else {
            // debugger
            this.currentPair = this.imageList[this.currentTask.current_idx]
            //img0
            var idx0 = this.currentPair[0];
            //img1
            var idx1 = this.currentPair[1];

            this.getBase64DataOfImageFromCouch(idx0.toString(), htmlID = "image0")
                .then((response) => {
                    this.getBase64DataOfImageFromCouch(idx1.toString(), htmlID = "image1")
                        .then((response) => {
                            // debugger
                            this.enableButtons();
                        })
                })


        }
    };

    PairTaskFeeder.pairSubmit = function (selection) {
        console.log("pairSubmit");
        var accept_or_reject = 'accept'
        if (selection.id === 'reject-button'){
            accept_or_reject = 'reject'
            if($('input[name="rejection_criteria"]:checked').val() == null){
                alert("No rejection criteria selected.")
                return "image not classified error (no rejection criteria)"                
            }
        }

        // Classifications
        var classification0 = this.image0Annotation
        var classification1 = this.image1Annotation
        
        // qa for acceptance
        if(accept_or_reject === 'accept'){
            // debugger
            if (this.image0Annotation === null | this.image1Annotation === null){
                    alert("No classifications have been set.")
                    return "image not classified error (no classifications have been set)"
            }
        }

        this.disableButtons();
        // Gather all imageIDs
        TF = this;
        const user = this.user;
        const currentTime = new Date();
        
        const timeStr = currentTime.toString();
        const img0 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentPair[0]}`;
        const img1 = `http://${DNS}:${DB_PORT}/${IMAGES_DB}/${this.currentPair[1]}`;
        
        // If Tie not mandatory and all submissions require comment or at least an optional comment
        const comment = $("#justification").val();
        const task = this.currentTask._id;
        const task_idx = this.currentTask.current_idx;
        
        const save_results = {
            user: user,
            type: "pairResult",
            date: timeStr,
            image0: img0,
            image1: img1,
            classification0: classification0,
            classification1: classification1,
            accept_or_reject: accept_or_reject,
            reject_justification: $('input[name="rejection_criteria"]:checked').val(),
            optional_comment: comment,
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
                console.log('success saving image0')
                // Reset image selections
                $("#image0Classification").text('')
                $("#image1Classification").text('')
                $("#image0").removeClass("selected")
                $("#image1").removeClass("selected")
                $("#image0").removeClass("frontal")
                $("#image1").removeClass("frontal")
                $("#image0").removeClass("lateral")
                $("#image1").removeClass("lateral")
                PairTaskFeeder.image0Annotation = null;
                PairTaskFeeder.image1Annotation = null;
                PairTaskFeeder.imageSelected = null;
                // Reset reject modal
                $('input[name=rejection_criteria]').attr('checked',false);
                // Reset incomplete tasks list
                TF.OnSetUser(TF.user)
            },
            error: function (response) {
                console.log("saving of pairResult failed: " + JSON.stringify(response));
            }
        });
    };


    PairTaskFeeder.commentAlert = function () {
        alert('If you want to provide an optional justification for your decision (left/right/tie), please enter it before you click left/right/tie. The text box will refresh after a decision is made.')
    }

    PairTaskFeeder.initKeyboardListener = function () {
        TF = this;
        document.addEventListener('keydown', function (event) {
            // debugger
            if (!($("#rejectModal").css("display") === "block")) {
                if (TF.keyboardShortcuts === false) {
                    if (event.keyCode == 37) {
                        alert('Left was pressed');
                    }
                    else if (event.keyCode == 39) {
                        alert('Right was pressed');
                    }
                    else if (event.keyCode == 13) {
                        alert('Enter was pressed');
                    }
                } else if (TF.keyboardShortcuts === true && document.getElementById('image0').style.pointerEvents === 'auto') {
                    if (event.keyCode == 37) {
                        $("#image0").click()
                        
                    }
                    else if (event.keyCode == 39) {
                        $("#image1").click()
                        
                    }
                    else if (event.keyCode == 13) {
                        $("#accept-button").click()
                        
                    }
                }
            }
        });
    };

    PairTaskFeeder.toggleKeyboardShortcuts = function () {
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
        document.activeElement.blur()
    };

    PairTaskFeeder.selectThisImage = function (image) {
        // Sotre currently selected image in current state
        this.imageSelected = image
        // Get image selected
        var img_selected = this.imageSelected.id

        // Clear old selections
        $(this.imageSelected).removeClass("frontal");
        $(this.imageSelected).removeClass("lateral");
        
        // Assign image class
        if (img_selected === "image0") {
            this.image0Annotation = 'frontal'
            this.image1Annotation = 'lateral'
            $("#image0").addClass('frontal');
            $("#image1").addClass('lateral');
            $("#image0Classification").text('frontal')
            $("#image1Classification").text('lateral')
        } else {
            this.image1Annotation = 'frontal'
            this.image0Annotation = 'lateral'
            $("#image1").addClass('frontal');
            $("#image0").addClass('lateral');
            $("#image1Classification").text('frontal')
            $("#image0Classification").text('lateral')
        }
    };

    PairTaskFeeder.enableButtons = function () {
        document.getElementById('image0').style.pointerEvents = 'auto';
        document.getElementById('reject-button').style.pointerEvents = 'auto';
        document.getElementById('image1').style.pointerEvents = 'auto';
        document.activeElement.blur()
    };

    PairTaskFeeder.disableButtons = function () {
        document.getElementById('image0').style.pointerEvents = 'none';
        document.getElementById('reject-button').style.pointerEvents = 'none';
        document.getElementById('image1').style.pointerEvents = 'none';
        document.activeElement.blur()
    };


    /* Begin Compare app specific functionality */
    // debugger
    PairTaskFeeder.setPrompt();
    PairTaskFeeder.handleUrlFilter(document.location.search);
    PairTaskFeeder.initKeyboardListener();


}
