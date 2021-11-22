import os

from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY=b'_5#y2L"F4Q8z\n\xec]/',
        # DATABASE=os.path.join(app.instance_path, 'image_comparator.sqlite'),
    )
    CORS(app)

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)
    
    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    load_dotenv(verbose=True)
    app.config['DB_ADMIN_USER'] = os.getenv("DB_ADMIN_USER")
    app.config['DB_ADMIN_PASS'] = os.getenv("DB_ADMIN_PASS")
    app.config['DNS'] = os.getenv("DNS")
    app.config['DB_DNS'] = os.getenv("DB_DNS")
    app.config['IMAGES_DB'] = os.getenv("IMAGES_DB")
    app.config['DB_PORT'] = os.getenv("DB_PORT")
    app.config['HTTP_PORT'] = os.getenv("HTTP_PORT")
    app.config['ADMIN_PARTY'] = True if os.getenv("ADMIN_PARTY") == 'True' else False

    # from image_comparator import routes

    from . import routes_blueprint
    app.register_blueprint(routes_blueprint.bp)

    return app