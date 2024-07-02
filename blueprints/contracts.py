from flask import Blueprint, jsonify

contracts_bp = Blueprint('contracts', __name__)

class Contract:
    def __init__(self, currency, currencyName, address, decimalCount, currencyRate):
        self.currency = currency
        self.currencyName = currencyName
        self.address = address
        self.decimalCount = decimalCount
        self.currencyRate = currencyRate

def get_hardcoded_contracts():
    contracts = [
        Contract(currency="USD", currencyName="United States Dollar", address="1", decimalCount=2, currencyRate=1.0),
        Contract(currency="EUR", currencyName="Euro", address="2", decimalCount=2, currencyRate=0.85),
        Contract(currency="GBP", currencyName="British Pound", address="3", decimalCount=2, currencyRate=0.75),
        Contract(currency="JPY", currencyName="Japanese Yen", address="4", decimalCount=0, currencyRate=110.0),
        Contract(currency="AUD", currencyName="Australian Dollar", address="5", decimalCount=2, currencyRate=1.35),
        Contract(currency="CAD", currencyName="Canadian Dollar", address="6", decimalCount=2, currencyRate=1.25),
        Contract(currency="CHF", currencyName="Swiss Franc", address="7", decimalCount=2, currencyRate=0.92),
        Contract(currency="CNY", currencyName="Chinese Yuan", address="8", decimalCount=2, currencyRate=6.45),
        Contract(currency="INR", currencyName="Indian Rupee", address="9", decimalCount=2, currencyRate=73.5),
        Contract(currency="PKR", currencyName="Pakistani Rupee", address="10", decimalCount=2, currencyRate=160.0)
    ]
    return contracts


@contracts_bp.route('/contractsaddresses-menaapp', methods=['GET'])
def get_contract_list():
    contracts = get_hardcoded_contracts()
    contracts_list = [
        {
            "currency": contract.currency,
            "currencyName": contract.currencyName,
            "address": contract.address,
            "decimalCount": contract.decimalCount,
            "currencyRate": contract.currencyRate
        } for contract in contracts
    ]
    return jsonify(contracts_list)
