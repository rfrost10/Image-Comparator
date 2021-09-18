from app import app
from app import makeTask

from flask import render_template, jsonify, send_file, request, flash, redirect
import requests, couchdb, io, json, pdb
from dotenv import load_dotenv

# Config
@app.route('/configuration', methods=['GET'])
def config():
    # pdb.set_trace()
    config = {
        "DB_ADMIN_USER":app.config['DB_ADMIN_USER'],
        "DB_ADMIN_PASS":app.config['DB_ADMIN_PASS'],
        "DNS":app.config['DNS'],
        "IMAGES_DB":app.config['IMAGES_DB'],
        "DB_PORT":app.config['DB_PORT'],
        "HTTP_PORT":app.config['HTTP_PORT'],
        "HTTP_PORT":app.config['HTTP_PORT'],
        "ADMIN_PARTY":app.config['ADMIN_PARTY'],
    }
    return jsonify(config)

# Apps
@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/two_image', methods=['GET'])
def two_image():
    return render_template('two_image.html')

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
@app.route('/get_tasks', methods=['GET'])
def get_tasks():
    DNS = app.config['DNS']
    DB_PORT = app.config["DB_PORT"]
    IMAGES_DB = app.config["IMAGES_DB"]
    DB_ADMIN_USER = app.config["DB_ADMIN_USER"]
    DB_ADMIN_PASS = app.config["DB_ADMIN_PASS"]
    ADMIN_PARTY = bool(app.config["ADMIN_PARTY"])

    username = request.args['username']

    base = "http://{}:{}/{}".format(DNS,DB_PORT,IMAGES_DB)
    view = f"_design/basic_views/_view/incomplete_compare_tasks?key=\"{username}\""
    url = f"{base}/{view}"
    # pdb.set_trace()
    if ADMIN_PARTY:
        response = requests.get('{}'.format(url))
    else:
        response = requests.get('{}'.format(url), auth=(DB_ADMIN_USER, DB_ADMIN_PASS))

    return json.loads(response.content.decode('utf-8'))

@app.route('/get_image', methods=['GET'])
def get_image():
    url1 = "http://image-comparator.westeurope.cloudapp.azure.com:5984/images_db/32/image"
    response = requests.get(url1)
    response.raw.decode_content = True
    return send_file(
        io.BytesIO(response.content),
        mimetype='image/png',
        as_attachment=True,
        attachment_filename='test.png')


@app.route('/task_results', methods=['POST'])
def task_results():
    # return render_template('index.html')
    results = json.loads(request.data)
    # 1 save results to db
    DNS = app.config['DNS']
    DB_PORT = app.config['DB_PORT']
    couch = couchdb.Server(f'http://{DNS}:{DB_PORT}')
    db = couch[app.config["IMAGES_DB"]]
    doc_id, doc_rev = db.save(results)
    doc = db.get(doc_id)
    # 2 needs to mark grid task being referenced as "completed"
    task_name =results['task_list_name']
    x = db.find({'selector': {'list_name': task_name, 'type':'task'}})
    _id = x.__next__()['_id']
    grid_list = db[_id]
    grid_list['completed'] = True
    # pdb.set_trace()
    db[_id] = grid_list

    return jsonify("asdf")

@app.route('/create_user', methods=['POST'])
def create_user():
    DNS = app.config['DNS']
    DB_PORT = app.config['DB_PORT']
    couch = couchdb.Server(f'http://{DNS}:{DB_PORT}')
    db = couch[app.config["IMAGES_DB"]]
    pdb.set_trace()
    # Check Form
    if request.form['username'] == '':
        flash("You can't leave user field blank")
        return render_template('two_image.html')   
    else:
        username = request.form['username']

    try:
        years_exp = request.form['years-exp']
    except:
        flash("You have to choose your years of experience")
        return render_template('two_image.html') 

    try:
        specialty = request.form['specialty']
    except:
        flash("You have to choose your specialty")
        return render_template('two_image.html') 

    ## Check if user already exists
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
        flash(f"Created {username}")

        # Make task for Image Compare - Kathi specific for now
        makeTask.main(user=username, imageListName='kathisICList', imageListType="compare", taskOrder=1)
        # Return to app
        return redirect('/two_image')
    else:
        # User exists
        flash("That user exists already")
        return render_template('two_image.html')
    
    # results = json.loads("create_user - success")
    return redirect('/two_image') 