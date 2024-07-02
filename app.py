from flask import Flask
from blueprints.signup import signup_bp, db
from blueprints.contracts import contracts_bp
from blueprints.country_currency import country_currency_bp
from blueprints.update_account import update_account_bp
from blueprints.transaction_history import transaction_history_bp
from blueprints.transaction_send import transaction_send_bp

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite3'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

with app.app_context():
    db.create_all()

app.register_blueprint(signup_bp)
app.register_blueprint(contracts_bp)
app.register_blueprint(country_currency_bp)
app.register_blueprint(update_account_bp)
app.register_blueprint(transaction_history_bp)
app.register_blueprint(transaction_send_bp)

if __name__ == '__main__':
    app.run(debug=True)
