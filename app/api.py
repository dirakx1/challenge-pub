from flask import Flask, request, jsonify

app = Flask(__name)

# Sample data to simulate Lambda functionality
data_store = []

# Route to handle GET requests
@app.route('/items', methods=['GET'])
def get_items():
    return jsonify(data_store)

# Route to handle POST requests
@app.route('/items', methods=['POST'])
def add_item():
    try:
        item = request.json
        data_store.append(item)
        return jsonify({'message': 'Item added successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)


