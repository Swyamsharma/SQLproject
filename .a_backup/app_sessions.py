from flask import Flask, render_template, request, jsonify, session, redirect, url_for
import mysql.connector

import ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('fullchain.pem', 'privkey.pem')

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

mysql_config = {
    'host': 'localhost',
    'user': 'shaurya',
    'password': '222w',
    'database': 'test'
}

def authenticate(username, password):
    # Function to authenticate user against database
    # Replace this with your actual authentication logic
    if username == 'admin' and password == 'password':
        return True
    return False

@app.route("/")
def home():
    if 'username' in session:
        return render_template("index.html")
    else:
        return redirect(url_for('login'))
    
@app.route("/legacy")
def legacy():
    if 'username' in session:
        return render_template("index_legacy.html")
    else:
        return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if authenticate(username, password):
            session['username'] = username
            return redirect(url_for('home'))
        else:
            return render_template('login.html', error='Invalid username or password')
    if 'username' in session:
        return redirect(url_for('home'))
    else:
        return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('login'))

@app.route('/chat', methods=['POST'])
def chat():
    if 'username' not in session:
        return jsonify(error='Unauthorized'), 401
    data = request.form.get('data')
    return jsonify(response=data.upper())

@app.route('/query', methods=['POST'])
def query():
    if 'username' not in session:
        return jsonify(error='Unauthorized'), 401
    query = request.form['query']
    result = execute_query(query)
    return jsonify(result=result)

def execute_query(query):
    try:
        connection = mysql.connector.connect(**mysql_config)
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query)
        result = cursor.fetchall()
    except mysql.connector.Error as error:
        print("Error executing query:", error)
        result = None
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
    return result

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True,ssl_context=context)
