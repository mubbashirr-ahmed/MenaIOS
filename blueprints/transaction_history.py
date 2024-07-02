from flask import Blueprint, request, jsonify

transaction_history_bp = Blueprint('transaction_history', __name__)

mena_history = [
    {"id": 1, "from_address": "address1", "receive_address": "address2", "contract_address": None, "amount": 100.0, "tx_hash": "txhash1", "date": "2023-06-01"},
    {"id": 2, "from_address": "address2", "receive_address": "address1", "contract_address": None, "amount": 50.0, "tx_hash": "txhash2", "date": "2023-06-02"},
    {"id": 3, "from_address": "address3", "receive_address": "address4", "contract_address": None, "amount": 75.0, "tx_hash": "txhash3", "date": "2023-06-03"},
    {"id": 4, "from_address": "address4", "receive_address": "address3", "contract_address": None, "amount": 120.0, "tx_hash": "txhash4", "date": "2023-06-04"},
    {"id": 5, "from_address": "address5", "receive_address": "address6", "contract_address": None, "amount": 80.0, "tx_hash": "txhash5", "date": "2023-06-05"},
    {"id": 6, "from_address": "address6", "receive_address": "address5", "contract_address": None, "amount": 95.0, "tx_hash": "txhash6", "date": "2023-06-06"},
    {"id": 7, "from_address": "address7", "receive_address": "address8", "contract_address": None, "amount": 60.0, "tx_hash": "txhash7", "date": "2023-06-07"},
    {"id": 8, "from_address": "address8", "receive_address": "address7", "contract_address": None, "amount": 110.0, "tx_hash": "txhash8", "date": "2023-06-08"},
    {"id": 9, "from_address": "address9", "receive_address": "address10", "contract_address": None, "amount": 70.0, "tx_hash": "txhash9", "date": "2023-06-09"},
    {"id": 10, "from_address": "address10", "receive_address": "address9", "contract_address": None, "amount": 85.0, "tx_hash": "txhash10", "date": "2023-06-10"}
]

token_history = [
    {"id": 1, "from_address": "address11", "receive_address": "address12", "contract_address": "contract1", "amount": 150.0, "tx_hash": "txhash11", "date": "2023-06-11"},
    {"id": 2, "from_address": "address12", "receive_address": "address11", "contract_address": "contract2", "amount": 200.0, "tx_hash": "txhash12", "date": "2023-06-12"},
    {"id": 3, "from_address": "address13", "receive_address": "address14", "contract_address": "contract3", "amount": 180.0, "tx_hash": "txhash13", "date": "2023-06-13"},
    {"id": 4, "from_address": "address14", "receive_address": "address13", "contract_address": "contract4", "amount": 90.0, "tx_hash": "txhash14", "date": "2023-06-14"},
    {"id": 5, "from_address": "address15", "receive_address": "address16", "contract_address": "contract5", "amount": 100.0, "tx_hash": "txhash15", "date": "2023-06-15"},
    {"id": 6, "from_address": "address16", "receive_address": "address15", "contract_address": "contract6", "amount": 125.0, "tx_hash": "txhash16", "date": "2023-06-16"},
    {"id": 7, "from_address": "address17", "receive_address": "address18", "contract_address": "contract7", "amount": 95.0, "tx_hash": "txhash17", "date": "2023-06-17"},
    {"id": 8, "from_address": "address18", "receive_address": "address19", "contract_address": "contract8", "amount": 70.0, "tx_hash": "txhash18", "date": "2023-06-18"},
    {"id": 9, "from_address": "address19", "receive_address": "address20", "contract_address": "contract9", "amount": 110.0, "tx_hash": "txhash19", "date": "2023-06-19"},
    {"id": 10, "from_address": "address20", "receive_address": "address19", "contract_address": "contract10", "amount": 85.0, "tx_hash": "txhash20", "date": "2023-06-20"}
]

@transaction_history_bp.route('/api/mena/address/transactions/mena/history', methods=['GET'])
def get_mena_history():
    address = request.args.get('address')
    if not address:
        return jsonify({'error': 'Address is required'}), 400

    response = {
        "result": mena_history[:10]
    }
    return jsonify(response), 200

@transaction_history_bp.route('/api/mena/address/transactions/tokens/history', methods=['GET'])
def get_token_history():
    address = request.args.get('address')
    if not address:
        return jsonify({'error': 'Address is required'}), 400

    response = {
        "result": token_history[:10]
    }
    return jsonify(response), 200
