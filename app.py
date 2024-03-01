from flask import Flask, render_template,request
import mysql.connector

app = Flask(__name__)
mysql_config = {
    'host': 'localhost',
    'user': 'shaurya',
    'password': '222w',
    'database': 'test'
}

@app.route("/")
def home():
    return render_template("index.html")


@app.route('/chat', methods=['POST'])
def chat():
    data = request.form.get('data')
    return data.upper()

@app.route('/query', methods=['POST'])
def query():
    query = request.form['query']
    result = execute_query(query)
    return render_template('index.html', result=result)

def execute_query(query):
    try:
        connection = mysql.connector.connect(**mysql_config)
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query)
        result = cursor.fetchall()
        connection.commit()
    except mysql.connector.Error as error:
        print("Error executing query:", error)
        result = None
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
    return result


    
if __name__ == "__main__":
    app.run(debug=True)