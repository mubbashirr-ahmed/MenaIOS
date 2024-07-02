from flask import Blueprint, request, jsonify

transaction_send_bp = Blueprint('transaction_send', __name__)

@transaction_send_bp.route('/api/mena/transactions/mena/send-transaction', methods=['POST'])
def send_mena_transaction():
    data = request.json
    if not data or not isinstance(data, dict) or 'data' not in data or not isinstance(data['data'], dict):
        return jsonify({'error': 'Invalid request body'}), 400

    transactions = data['data'].get('transactions')
    if not transactions or not isinstance(transactions, list):
        return jsonify({'error': 'Transactions list is required'}), 400

    response = {
        "success": "Mena transaction sent successfully",
        "error": None
    }
    return jsonify(response), 200

@transaction_send_bp.route('/api/mena/transactions/token/send-transaction', methods=['POST'])
def send_token_transaction():
    data = request.json
    if not data or not isinstance(data, dict) or 'data' not in data or not isinstance(data['data'], dict):
        return jsonify({'error': 'Invalid request body'}), 400

    transactions = data['data'].get('transactions')
    if not transactions or not isinstance(transactions, list):
        return jsonify({'error': 'Transactions list is required'}), 400

    response = {
        "success": "Token transaction sent successfully",
        "error": None
    }
    return jsonify(response), 200

@transaction_send_bp.route('/api/mena/transactions/multi/send-transaction', methods=['POST'])
def make_multi_transaction():
    data = request.json
    if not data or not isinstance(data, dict) or 'data' not in data or not isinstance(data['data'], dict):
        return jsonify({'error': 'Invalid request body'}), 400

    transactions = data['data'].get('transactions')
    if not transactions or not isinstance(transactions, list):
        return jsonify({'error': 'Transactions list is required'}), 400

    response = {
        "success": "Multi transaction sent successfully",
        "error": None
    }
    return jsonify(response), 200
