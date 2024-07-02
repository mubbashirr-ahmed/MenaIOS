from flask import Blueprint, request, jsonify
from sqlalchemy.exc import IntegrityError
from blueprints.signup import db, User 

update_account_bp = Blueprint('update_account', __name__)

@update_account_bp.route('/accounts/otc-update-menaapp', methods=['POST'])
def update_details():
    auth_key = request.form.get('auth_key')
    email = request.form.get('email')
    type_ = request.form.get('type')
    account_name = request.form.get('account-name')
    sort_code = request.form.get('sort-code')
    account_number = request.form.get('account-number')
    account_country = request.form.get('account-country')

    if not auth_key or not email or not type_ or not account_name or not sort_code or not account_number or not account_country:
        return jsonify({'error': 'All fields are required'}), 400

    if type_ != "update":
        return jsonify({'error': 'Invalid type. It should be "update"'}), 400

    user = User.query.filter_by(auth_key=auth_key, email=email).first()

    if not user:
        return jsonify({'error': 'Invalid auth_key or email'}), 400

    try:
        user.account_name = account_name
        user.sort_code = sort_code
        user.account_number = account_number
        user.account_country = account_country

        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'error': 'An error occurred while updating account details'}), 400

    response = {
        "result": "Account updated successfully"
    }

    return jsonify(response), 200
