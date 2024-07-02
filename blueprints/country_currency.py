from flask import Blueprint, jsonify

country_currency_bp = Blueprint('country_currency', __name__)

class Country:
    def __init__(self, country):
        self.country = country

class Currencies:
    def __init__(self, fiatCurrency):
        self.fiatCurrency = fiatCurrency

class CountryCurrency:
    def __init__(self, countries, currencies):
        self.countries = countries
        self.currencies = currencies

def get_hardcoded_country_currency():
    countries = [
        Country(country="USA"), Country(country="Canada"), Country(country="UK"),
        Country(country="Germany"), Country(country="France"), Country(country="Japan"),
        Country(country="Australia"), Country(country="India"), Country(country="Brazil"),
        Country(country="South Africa")
    ]
    currencies = [
        Currencies(fiatCurrency="USD"), Currencies(fiatCurrency="CAD"), Currencies(fiatCurrency="GBP"),
        Currencies(fiatCurrency="EUR"), Currencies(fiatCurrency="EUR"), Currencies(fiatCurrency="JPY"),
        Currencies(fiatCurrency="AUD"), Currencies(fiatCurrency="INR"), Currencies(fiatCurrency="BRL"),
        Currencies(fiatCurrency="ZAR")
    ]
    return CountryCurrency(countries=countries, currencies=currencies)

@country_currency_bp.route('/countrycurrency-menaapp', methods=['GET'])
def get_country_currency_list():
    country_currency = get_hardcoded_country_currency()
    response = {
        "countries": [{"country": country.country} for country in country_currency.countries],
        "currencies": [{"fiatCurrency": currency.fiatCurrency} for currency in country_currency.currencies]
    }
    return jsonify(response)
