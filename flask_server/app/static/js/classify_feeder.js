
// ImageCompare is the namespace
var ImageCompare = (function (IC) {

    IC.TaskFeeder = IC.TaskFeeder || {};
    IC.TaskFeeder.defaultComment = "<insert comment>";

    // some of this is probably not needed
    IC.TaskFeeder.current_task = "";
    IC.TaskFeeder.current_task_idx = -1;
    IC.TaskFeeder.current_icl = ""; // image_classify_list

    IC.TaskFeeder.taskViewName = '_design/basic_views/_view/incomplete_classify_tasks';

    // consult results and image database to select image to present to user
    IC.TaskFeeder.SetImage = function(username) {

        var dbName = IC.TaskFeeder.GetImageDbUrl();
        var taskViewName = IC.TaskFeeder.taskViewName;
        var fullurl = dbName + taskViewName + '?key=\"' + username + "\"";
        $.ajax({
            url : fullurl,
            type : 'GET',
            success : function(json) {
                var viewName = dbName + '_design/basic_views/_view/image_classify_lists';
                findTaskAndSetImage(json, username, viewName);
            },
            error: function (response) {
                console.log("get failed : " + JSON.stringify(response));
            }
        });
    };

    return IC;

}(ImageCompare || {}));
