from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from commons import authenticate, execute_query, logged_in_users

import ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('fullchain.pem', 'privkey.pem')

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'



@app.route("/index.html")
@app.route("/")
def home():
    if 'username' in session:
        return render_template("index.html")
    else:
        return redirect(url_for('login'))

@app.route("/old")
def old():
    if 'username' in session:
        return render_template("index_old.html")
    else:
        return redirect(url_for('login'))

@app.route("/legacy")
def legacy():
    if 'username' in session:
        return render_template("index_legacy.html")
    else:
        return redirect(url_for('login'))

# Login route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        session.pop('error', None)
        username = request.form['username']
        password = request.form['password']
        if authenticate(username, password):
            if username in logged_in_users:
                return render_template('login.html', error='Already logged in from another location')
            session['username'] = username
            logged_in_users.add(username)  # Add username to shared set
            return redirect(url_for('home'))
        else:
            return render_template('login.html', error='Invalid username or password')
    if 'username' in session:
        return redirect(url_for('home'))
    else:
        return render_template('login.html')



@app.route('/logout')
def logout():
    if 'username' in session:
        username = session['username']
        session.pop('username', None)
        try:
            logged_in_users.remove(username)
        finally:
            return redirect(url_for('login'))
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

@app.route('/get_username')
def get_username():
    # Return the username from session
    return jsonify(username=session.get('username', None))



if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True,ssl_context=context)
