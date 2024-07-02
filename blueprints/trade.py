from flask import Blueprint, request, jsonify
from sqlalchemy.exc import IntegrityError
from blueprints.signup import db, User, Trade 

trade_bp = Blueprint('trade', __name__)

@trade_bp.route('/trade/create-otctrade-menaapp', methods=['POST'])
def create_trade():
    auth_key = request.form.get('auth_key')
    email = request.form.get('email')
    type_ = request.form.get('type')
    coin = request.form.get('coin')
    amount = request.form.get('amount')
    country = request.form.get('country')
    currency_type = request.form.get('currency-type')

    if not auth_key or not email or not type_ or not coin or not amount or not country or not currency_type:
        return jsonify({'error': 'All fields are required'}), 400

    if type_ != "buy":
        return jsonify({'error': 'Invalid type. It should be "buy"'}), 400

    user = User.query.filter_by(auth_key=auth_key, email=email).first()

    if not user:
        return jsonify({'error': 'Invalid auth_key or email'}), 400

    new_trade = Trade(auth_key=auth_key, email=email, type=type_, coin=coin, amount=amount, country=country, currency_type=currency_type)

    try:
        db.session.add(new_trade)
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'error': 'An error occurred while creating the trade'}), 400

    response = {
        "result": "Trade created successfully"
    }

    return jsonify(response), 200
