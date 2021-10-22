// source: https://gist.github.com/paldepind/7211654

var HOST = "pop-os"
var PORT = "5984"
var DB = "image_comparator"
var DB_USER = "admin"
var DB_PASS = "password"
var ADMIN_PARTY = false
var VIEWS_CATEGORY_NAME = "basic_views"

// let VIEW = "imageSet2ImageId_deleteme"

function delete_docs_in_view(VIEW) {

    var url_getViewDocs = `http://${HOST}:${PORT}/${DB}/_design/${VIEWS_CATEGORY_NAME}/_view/${VIEW}`
    var url_delete_doc = `http://${HOST}:${PORT}/${DB}`

    // auth
    auth = () => { } // ADMIN PARTY
    if (!ADMIN_PARTY) {
        var auth = (xhr) => {
            xhr.setRequestHeader('Authorization', 'Basic ' + btoa(`${DB_USER}:${DB_PASS}`));
        }
    }

    // AJAX
    $.ajax({
        url: url_getViewDocs,
        type: 'GET',
        beforeSend: auth,
        success: (data) => {
            data.rows.forEach(function (doc) {
                // AJAX
                $.ajax({
                    url: url_delete_doc + `/${doc.id}?rev=${doc.value._rev}`,
                    type: 'DELETE',
                    beforeSend: auth,
                    success: function (result) {
                        console.log("Deleted document with id " + doc.key[1]);
                    }
                });
            });
        },

    })

}

// delete_docs_in_view(VIEW)

// Dangerous!!!
// views_to_clear = ['users', 'taskresults', 'tasks', 'classifyResults', 'image_classify_lists', 'image_compare_lists', 'image_grid_lists', 'imageSet2ImageId_deleteme']

views_to_clear.forEach((v, i, a) => {
    delete_docs_in_view(v) //delete al docs in this view
})


// Get Doc
let DOC_ID = "9218b9c59ce6a2194bd03091e7005c92"
let DOC_URL = `http://${HOST}:${PORT}/${DB}/${DOC_ID}`
$.ajax({
    url: DOC_URL,
    type: "GET",
    success: function (data) {
        console.log(data)
    }
})