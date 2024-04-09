import mysql.connector
from datetime import datetime, timedelta

mysql_auth = {
    'host': 'localhost',
    'user': 'shaurya',
    'password': '222w',
    'database': 'test'
}
mysql_library = {
    'host': 'localhost',
    'user': 'shaurya',
    'password': '222w',
    'database': 'library_db'
}
st_db = {
    'host': 'localhost',
    'user': 'shaurya',
    'password': '222w',
    'database': 'student_db'
}
last_attendance_time = {}
logged_in_users = set()

# Authenticate function to check user credentials against the database
def authenticate(username, password):
    try:
        db_connection = mysql.connector.connect(**mysql_auth)
        cursor = db_connection.cursor()
        query = "SELECT * FROM users WHERE BINARY username = %s AND BINARY password = %s"
        cursor.execute(query, (username, password))
        user = cursor.fetchone()
        cursor.close()
        if user:
            return True
        else:
            return False
    except mysql.connector.Error as err:
        # Handle potential errors, such as table not existing or database connection issues
        print("Error during authentication:", err)
        return False
    finally:
        if 'db_connection' in locals():
            db_connection.close()

def execute_query(query,config=mysql_auth):
    try:
        connection = mysql.connector.connect(**config)
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query)
        result = cursor.fetchall()
        print(result)
        connection.commit()
    except mysql.connector.Error as error:
        print("Error executing query:", error)
        result = None
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
    return result
