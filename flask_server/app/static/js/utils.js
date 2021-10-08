// source: https://gist.github.com/paldepind/7211654

let HOST="image-comparator.westeurope.cloudapp.azure.com"
let PORT="5985"
let DB="image_comparator"
let VIEWS_CATEGORY_NAME="basic_views"

let VIEW="taskresults"

function delete_docs_in_view(VIEW){

    var getViewDocs = `http://${HOST}:${PORT}/${DB}/_design/${VIEWS_CATEGORY_NAME}/_view/${VIEW}`;
    $.getJSON(getViewDocs, function(data) {
        data.rows.forEach(function (doc) {
            // debugger;
            $.ajax({
                url: `http://${HOST}:${PORT}/${DB}/${doc.id}?rev=${doc.value._rev}`,
                type: 'DELETE',
                success: function(result) {
                    console.log("Deleted document with id " + doc.key[1]);
                }
            });
        });
    });

}

// delete_docs_in_view(VIEW)

// Dangerous!!!
views_to_clear = ['users','taskresults','tasks', 'classifyResults', 'image_classify_lists', 'image_compare_lists', 'image_grid_lists', 'imageSet2ImageId_deleteme']
views_to_clear.forEach((v,i,a) =>{
    delete_docs_in_view(v) //delete al docs in this view
})


// Get Doc
let DOC_ID="9218b9c59ce6a2194bd03091e7005c92"
let DOC_URL=`http://${HOST}:${PORT}/${DB}/${DOC_ID}`
$.ajax({
    url:DOC_URL,
    type:"GET",
    success: function(data){
        console.log(data)
    }
})