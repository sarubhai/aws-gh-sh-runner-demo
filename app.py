import json
from flask import Flask, jsonify

app = Flask(__name__)

products = [
    { 'id': 1, 'name': 'Cakes' },
    { 'id': 2, 'name': 'Cookies' },
    { 'id': 3, 'name': 'Chocolates' },
    { 'id': 4, 'name': 'Milk' },
    { 'id': 5, 'name': 'Coffee' },
    { 'id': 6, 'name': 'Soft Drinks' },
    { 'id': 7, 'name': 'Ice cream' }
]

@app.route('/api/products', methods=['GET'])
def get_products():
    return jsonify(products)


customers = [
    { 'id': 1, 'name': "John Doe", 'age': 30 },
    { 'id': 2, 'name': "Jane Smith", 'age': 25 },
    { 'id': 3, 'name': "Mike Johnson", 'age': 40 },
    { 'id': 4, 'name': "Jane Doe", 'age': 28 },
    { 'id': 5, 'name': "Micheal Page", 'age': 36 },
    { 'id': 6, 'name': "Peter Alter", 'age': 39 }
]

@app.route('/api/customers', methods=['GET'])
def get_customers():
    return jsonify(customers)


if __name__ == '__main__':
   app.run(debug=True)