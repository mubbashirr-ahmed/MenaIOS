import random
import string
from flask import Blueprint, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError

signup_bp = Blueprint('accounts', __name__)
db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(255), unique=True, nullable=False)
    signature = db.Column(db.String(255), nullable=False)
    message = db.Column(db.String(255), nullable=False)
    path = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    auth_key = db.Column(db.String(255), unique=True, nullable=False)
    account_name = db.Column(db.String(255), nullable=True)
    sort_code = db.Column(db.String(255), nullable=True)
    account_number = db.Column(db.String(255), nullable=True)
    account_country = db.Column(db.String(255), nullable=True)

class Trade(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auth_key = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    type = db.Column(db.String(255), nullable=False)
    coin = db.Column(db.String(255), nullable=False)
    amount = db.Column(db.String(255), nullable=False)
    country = db.Column(db.String(255), nullable=False)
    currency_type = db.Column(db.String(255), nullable=False)

def generate_random_string(length=8):
    """Generate a random string of fixed length."""
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(random.choice(letters_and_digits) for i in range(length))

@signup_bp.route('/accounts/register/mena', methods=['POST'])
def create_user():
    address = request.form.get('address')
    signature = request.form.get('signature')
    message = request.form.get('message')
    path = request.form.get('path')

    if not address or not signature or not message or not path:
        return jsonify({'error': 'All fields are required'}), 400

    existing_user = User.query.filter_by(address=address).first()
    if existing_user:
        return jsonify({
            "auth_key": existing_user.auth_key,
            "email": existing_user.email
        }), 200

    random_email = generate_random_string(10) + "@example.com"
    random_auth_key = generate_random_string(16)

    new_user = User(
        address=address,
        signature=signature,
        message=message,
        path=path,
        email=random_email,
        auth_key=random_auth_key
    )
    
    try:
        db.session.add(new_user)
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'error': 'Failed to register user'}), 400

    response = {
        "auth_key": random_auth_key,
        "email": random_email
    }

    return jsonify(response), 200
