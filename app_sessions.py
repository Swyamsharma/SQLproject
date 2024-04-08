from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from sqlQuery import authenticate, execute_query, logged_in_users, mysql_auth, mysql_library, st_db
from students_api import students_api
from datetime import timedelta

import ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('fullchain.pem', 'privkey.pem')

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
app = students_api(app)



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
            if(username in logged_in_users):
                logged_in_users.remove(username)
            return render_template('logout.html', message=f"{username} logged out successfully")
        except ValueError:
            return render_template('logout.html', error="You are not logged in")
    return render_template('logout.html', error="You are not logged in")


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

@app.route('/querylib', methods=['POST'])
def querylib():
    if 'username' not in session:
        return jsonify(error='Unauthorized'), 401
    query = request.form['query']
    result = execute_query(query,mysql_library)
    return jsonify(result=result)

@app.route('/queryatt', methods=['POST'])
def queryatt():
    if 'username' not in session:
        return jsonify(error='Unauthorized'), 401
    
    query = request.form['query']
    print(query)
    result = execute_query(query, st_db)

    # Convert timedelta objects to string representations
    for row in result:
        if 'start_time' in row:
            row['start_time'] = str(row['start_time'])
        if 'end_time' in row:
            row['end_time'] = str(row['end_time'])

    return jsonify(result=result)

@app.route('/get_username')
def get_username():
    # Return the username from session
    return jsonify(username=session.get('username', None))



if __name__ == "__main__":
   # app.run(host="0.0.0.0", debug=True,ssl_context=context)
   app.run(host="0.0.0.0", debug=True,port=2026,ssl_context=context)
