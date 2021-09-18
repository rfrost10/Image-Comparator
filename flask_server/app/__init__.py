import os

from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
CORS(app)

load_dotenv(verbose=True)
app.config['DB_ADMIN_USER'] = os.getenv("DB_ADMIN_USER")
app.config['DB_ADMIN_PASS'] = os.getenv("DB_ADMIN_PASS")
app.config['DNS'] = os.getenv("DNS")
app.config['DB_DNS'] = os.getenv("DB_DNS")
app.config['IMAGES_DB'] = os.getenv("IMAGES_DB")
app.config['DB_PORT'] = os.getenv("DB_PORT")
app.config['HTTP_PORT'] = os.getenv("HTTP_PORT")
app.config['ADMIN_PARTY'] = os.getenv("ADMIN_PARTY")

from app import routes
