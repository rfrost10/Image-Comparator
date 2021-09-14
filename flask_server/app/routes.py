from app import app
from flask import render_template, jsonify, send_file, request
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
    DB_DNS = app.config["DB_DNS"]
    DB_PORT = app.config["DB_PORT"]
    IMAGES_DB = app.config["IMAGES_DB"]
    DB_ADMIN_USER = app.config["DB_ADMIN_USER"]
    DB_ADMIN_PASS = app.config["DB_ADMIN_PASS"]
    ADMIN_PARTY = bool(app.config["ADMIN_PARTY"])

    username = request.args['username']

    base = "http://{}:{}/{}".format(DB_DNS,DB_PORT,IMAGES_DB)
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