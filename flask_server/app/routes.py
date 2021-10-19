from app import app
from app import makeTask

from flask import render_template, jsonify, send_file, request, flash, redirect
import requests
import couchdb
import io
import json
import base64
import pdb
from dotenv import load_dotenv

# Config
# For Server Side
DNS = app.config['DNS']
DB_DNS = app.config['DB_DNS']
DB_PORT = app.config["DB_PORT"]
IMAGES_DB = app.config["IMAGES_DB"]
DB_ADMIN_USER = app.config["DB_ADMIN_USER"]
DB_ADMIN_PASS = app.config["DB_ADMIN_PASS"]
ADMIN_PARTY = True if app.config["ADMIN_PARTY"] == 'True' else False

def check_if_admin_party_then_make_request(url, method="GET", data="no data"):
    """
    Checks if we are in admin part and if so sends necessary credentials
    """
    if method == "GET":
        # pdb.set_trace()
        if ADMIN_PARTY:
            response = requests.get('{}'.format(url))
        else:
            response = requests.get('{}'.format(url), auth=(DB_ADMIN_USER, DB_ADMIN_PASS))
    elif method == "PUT":
        # pdb.set_trace()
        if ADMIN_PARTY:
            response = requests.put(url, data=data)
        else:
            response = requests.put(url, data=data, auth=(DB_ADMIN_USER, DB_ADMIN_PASS))
    return response

@app.route('/configuration', methods=['GET'])
def config():
    # pdb.set_trace()
    """
    For the front end
    """
    config = {
        "DB_ADMIN_USER": app.config['DB_ADMIN_USER'],
        "DB_ADMIN_PASS": app.config['DB_ADMIN_PASS'],
        "DNS": app.config['DNS'],
        "IMAGES_DB": app.config['IMAGES_DB'],
        "DB_PORT": app.config['DB_PORT'],
        "HTTP_PORT": app.config['HTTP_PORT'],
        "ADMIN_PARTY": app.config['ADMIN_PARTY'],
    }
    return jsonify(config)

# Apps
@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')


@app.route('/two_image', methods=['GET'])
def two_image():
    con = json.loads(config().data)
    # pdb.set_trace()
    return render_template('two_image.html', app_config=con)


@app.route('/image_class', methods=['GET'])
def image_class():
    return render_template('image_class.html')


@app.route('/grid_class', methods=['GET'])
def grid_class():
    return render_template('grid_class.html')


@app.route('/image_order', methods=['GET'])
def image_order():
    return render_template('image_order.html')

# Pages
@app.route('/about', methods=['GET'])
def about():
    return render_template('about.html')


@app.route('/contact', methods=['GET'])
def contact():
    return render_template('contact.html')


# Action APIs
@app.route('/get_users', methods=['GET'])
def get_users():
    print("in /get_users")
    base = "http://{}:{}/{}".format(DB_DNS, DB_PORT, IMAGES_DB)
    view = f"_design/basic_views/_view/users"
    url = f"{base}/{view}"
    response = check_if_admin_party_then_make_request(url)
    return json.loads(response.content.decode('utf-8'))


@app.route('/get_tasks', methods=['GET'])
def get_tasks():
    username = request.args['username']
    base = "http://{}:{}/{}".format(DB_DNS, DB_PORT, IMAGES_DB)
    view = f"_design/basic_views/_view/incomplete_compare_tasks?key=\"{username}\""
    url = f"{base}/{view}"
    response = check_if_admin_party_then_make_request(url)

    return json.loads(response.content.decode('utf-8'))

@app.route('/get_image_compare_lists', methods=['GET'])
def get_image_compare_lists():
    base = "http://{}:{}/{}".format(DB_DNS, DB_PORT, IMAGES_DB)
    # pdb.set_trace()
    try:
        key=request.args['key']
    except:
        print("in except")
        # pdb.set_trace()
        view = f"_design/basic_views/_view/image_compare_lists"
        url = f"{base}/{view}"
        response = check_if_admin_party_then_make_request(url)
        return json.loads(response.content.decode('utf-8'))
    print("past except")
    view = f"_design/basic_views/_view/image_compare_lists?key=\"{key}\""
    url = f"{base}/{view}"
    response = check_if_admin_party_then_make_request(url)
    return json.loads(response.content.decode('utf-8'))


@app.route('/icl_lengths', methods=['GET'])
def icl_lengths():
    print("in /icl_lengths")
    base = "http://{}:{}/{}".format(DB_DNS, DB_PORT, IMAGES_DB)
    icl_id = request.args['key']
    view = f"_design/basic_views/_view/icl_lengths?key=\"{icl_id}\""
    url = f"{base}/{view}"
    response = check_if_admin_party_then_make_request(url)
    return json.loads(response.content.decode('utf-8'))


@app.route('/update_tasks/<task_id>', methods=['PUT'])
def update_tasks(task_id):
    base = "http://{}:{}/{}".format(DB_DNS, DB_PORT, IMAGES_DB)
    url = f"{base}/{task_id}"
    results = json.loads(request.data)
    response = check_if_admin_party_then_make_request(url, method="PUT", data=json.dumps(results))
    return response.content



@app.route('/get_image/<image_id>', methods=['GET'])
def get_image(image_id):
    # Get Image ID
    IMAGE_ID = image_id
    url_for_couchdb_image_fetch = f'http://{DB_DNS}:{DB_PORT}/{IMAGES_DB}/{IMAGE_ID}/image'
    response = check_if_admin_party_then_make_request(url_for_couchdb_image_fetch)
    response.raw.decode_content = True
    # type(response.content) # bytes
    image_response = base64.b64encode(response.content)
    return send_file(
        # io.BytesIO(response.content),
        io.BytesIO(image_response),
        mimetype='image/png',
        as_attachment=True,
        attachment_filename='test.png')


@app.route('/task_results', methods=['POST'])
def task_results():
    print("in /task_results")
    # WILL NEED SOMETHING FOR NOT BEING IN ADMIN PARTY - FIX
    if ADMIN_PARTY:
        couch = couchdb.Server(f'http://{DB_DNS}:{DB_PORT}')
        db = couch[app.config["IMAGES_DB"]]
    else:
        # pdb.set_trace()
        couch = couchdb.Server(f'http://{DB_ADMIN_USER}:{DB_ADMIN_PASS}@{DB_DNS}:{DB_PORT}')
        db = couch[app.config["IMAGES_DB"]]
        # db = couch['image_comparator']
    results = json.loads(request.data)
    doc_id, doc_rev = db.save(results)
    doc = db.get(doc_id)

    # Determine task type
    if results['type'] != "imageCompareResult":
        # pdb.set_trace()
        # 1 save results to db

        # 1 save results to db
        # 2 needs to mark grid task being referenced as "completed"
        task_name = results['task_list_name']
        x = db.find({'selector': {'list_name': task_name, 'type': 'task'}})
        _id = x.__next__()['_id']
        grid_list = db[_id]
        grid_list['completed'] = True
        db[_id] = grid_list

        return jsonify('asdf') # ! What is this

    return jsonify('asdf') # ! What is this

@app.route('/create_user', methods=['POST'])
def create_user():
    print("in /create_user")
    couch = couchdb.Server(f'http://{DB_DNS}:{DB_PORT}')
    db = couch[app.config["IMAGES_DB"]]
    con = json.loads(config().data)
    # Check Form
    if request.form['username'] == '':
        flash("You can't leave user field blank")
        return render_template('two_image.html', app_config=con)
    elif request.form['username'].find(";") != -1:
        flash("Username cannot have \";\"'s")
        return render_template('two_image.html', app_config=con)
    else:
        username = request.form['username']

    try:
        years_exp = request.form['years-exp']
    except:
        flash("You have to choose your years of experience")
        return render_template('two_image.html', app_config=con)

    try:
        specialty = request.form['specialty']
    except:
        flash("You have to choose your specialty")
        return render_template('two_image.html', app_config=con)

    # Check if user already exists
    username_db_record = db.find({'selector': {'username': username}})
    usernames = [u for u in username_db_record]
    if len(usernames) == 0:
        # brand new user; create
        # pdb.set_trace()
        user = {
            "type": "user",
            "username": username,
            "years_experience": years_exp,
            "specialty": specialty
        }
        # pdb.set_trace()
        doc_id, doc_rev = db.save(user)
        flash(f"Created User: {username}")

        # Make task for Image Compare - manually enter imageListName specific for now
        makeTask.main(user=username, imageListName='ikbeomDataICL1',
                      imageListType="compare", taskOrder=1)
        # Return to app
        # pdb.set_trace()
        return redirect(f'/two_image?username={username}')
    else:
        # User exists
        flash("That user exists already")
        return render_template('two_image.html', app_config=con)

    # results = json.loads("create_user - success")
    return redirect('/two_image')
