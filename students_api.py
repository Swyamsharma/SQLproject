from flask import Flask, request, session, jsonify, redirect, url_for, render_template
from werkzeug.security import generate_password_hash, check_password_hash
import mysql.connector
from datetime import datetime, timedelta, date
import json
from sqlQuery import st_db,last_attendance_time


# MySQL connection details

def students_api(app):
    @app.route('/slogin', methods=['GET', 'POST'])
    def slogin():
        if 'user_id' in session:
            return redirect(url_for('student_home'))
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']

            try:
                conn = mysql.connector.connect(**st_db)
                cursor = conn.cursor()
                cursor.execute("SELECT password FROM students WHERE username = %s", (username,))
                result = cursor.fetchone()
                print(result)

                if result and password==result[0]:
                    session['user_id'] = username
                    return redirect(url_for('student_home'))
                else:
                    return render_template('slogin.html', error='Invalid username or password')

            except mysql.connector.Error as err:
                return render_template('slogin.html', error=str(err))
            finally:
                if 'cursor' in locals():
                    cursor.close()
                if 'conn' in locals():
                    conn.close()
        return render_template('slogin.html')

    @app.route('/student_info')
    def display_student_info():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        username = session['user_id']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM students WHERE username = %s", (username,))
            student = cursor.fetchone()
            return jsonify(student), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    @app.route('/student_home')
    def student_home():
        firstname,lastname = None,None
        try:
            if 'user_id' in session:
                conn = mysql.connector.connect(**st_db)
                cursor = conn.cursor()
                cursor.execute("SELECT first_name, last_name,student_id FROM students WHERE username = %s", (session['user_id'],))
                result = cursor.fetchone()
                print(result)
                if result:
                    firstname, lastname, id  = result
                client_ip = request.remote_addr
                print(client_ip)
                return render_template('studenthome.html', username=session['user_id'], fname=firstname, lname=lastname, identity= id)
            else:
                return redirect(url_for('slogin'))
        except mysql.connector.Error as err:
            return render_template('studenthome.html', error=str(err))
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    
    @app.route('/slogout')
    def slogout():
        try:
            if 'user_id' in session:
                session.pop('user_id', None)
                return render_template('logout.html', message='Logged out successfully')
            else:
                return render_template('logout.html', error='You are not logged in')
        except Exception as e:
            return render_template('logout.html', error=f'Error logging out: {str(e)}')
    
    @app.route('/student_complaints', methods=['GET'])
    def get_student_complaints():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        username = session['user_id']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute(
                "SELECT complaint_title, complaint_description, complaint_date, status FROM complaints JOIN students ON complaints.student_id = students.student_id WHERE username = %s ORDER BY complaint_date DESC",
                (username,)
            )
            complaints = cursor.fetchall()
            return jsonify([{'title': row[0], 'description': row[1], 'complaint_date': str(row[2]), 'status': row[3]} for row in complaints]), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    @app.route('/complaints', methods=['POST'])
    def create_complaint():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        student_id = request.json['student_id']
        complaint_title = request.json['complaint_title']
        complaint_description = request.json['complaint_description']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO complaints (student_id, complaint_title, complaint_description) VALUES (%s, %s, %s)",
                (student_id, complaint_title, complaint_description)
            )
            conn.commit()
            return jsonify({'message': 'Complaint created successfully'}), 201
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    
    @app.route('/complaints/<string:complaint_title>', methods=['DELETE'])
    def remove_complaint(complaint_title):
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        username = session['user_id']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute("DELETE FROM complaints WHERE complaint_title = %s AND student_id IN (SELECT student_id FROM students WHERE username = %s)", (complaint_title, username))
            conn.commit()
            if cursor.rowcount == 0:
                return jsonify({'error': 'Complaint not found'}), 404
            else:
                return jsonify({'message': 'Complaint removed successfully'}), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()


    @app.route('/news', methods=['GET'])
    def get_news():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401
        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute("SELECT title, content, posted_by, posted_date FROM news WHERE is_published = TRUE")
            news = cursor.fetchall()
            return jsonify([{'title': row[0], 'content': row[1], 'posted_by': row[2], 'posted_date': str(row[3])} for row in news]), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    @app.route('/reports', methods=['GET'])
    def get_reports():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        student_id = session['user_id']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute(
                "SELECT report_title, report_content, report_date FROM reports JOIN students on reports.student_id=students.student_id WHERE username = %s order by report_date desc",
                (student_id,)
            )
            reports = cursor.fetchall()
            return jsonify([{'title': row[0], 'content': row[1], 'date': str(row[2])} for row in reports]), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    @app.route('/open_attendances', methods=['GET'])
    def list_open_attendances():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401
        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor(dictionary=True)
            
            # Get the student ID from the students table using the username in the session
            cursor.execute("SELECT student_id FROM students WHERE username = %s", (session['user_id'],))
            student_id = cursor.fetchone()['student_id']
            
            # Fetch the open attendances that have not started yet and have not ended yet
            cursor.execute("""
                SELECT 
                    al.attendance_id, 
                    al.subject, 
                    al.attendance_date, 
                    al.start_time, 
                    al.end_time
                FROM 
                    attendance_list al
                LEFT JOIN 
                    student_attendance sa
                ON 
                    al.attendance_id = sa.attendance_id 
                    AND sa.student_id = %s
                WHERE
                    al.attendance_date = %s
                    AND al.start_time <= %s 
                    AND al.end_time > %s
                    AND sa.attendance_status IS NULL
            """, (student_id, date.today(), datetime.now().time(), datetime.now().time()))
            open_attendances = cursor.fetchall()
            
            # Convert timedelta and date objects to strings
            for attendance in open_attendances:
                attendance['start_time'] = str(attendance['start_time'])
                attendance['end_time'] = str(attendance['end_time'])
                attendance['attendance_date'] = str(attendance['attendance_date'])
            
            return json.dumps(open_attendances)
            
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
            
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    
    @app.route('/mark_attendance/<int:attendance_id>/<secret_code>/<status>', methods=['POST'])
    def mark_attendance(attendance_id, secret_code, status):
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401
        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()

            # Check if the secret code is valid
            cursor.execute("SELECT secret_code FROM attendance_list WHERE attendance_id = %s", (attendance_id,))
            stored_secret_code = cursor.fetchone()[0]
            if stored_secret_code != secret_code:
                return jsonify({'error': 'Invalid secret code'}), 401

            # Get the student ID from the students table using the username in the session
            cursor.execute("SELECT student_id FROM students WHERE username = %s", (session['user_id'],))
            student_id = cursor.fetchone()[0]

            # Check if the student already has an attendance record for this attendance
            cursor.execute("SELECT * FROM student_attendance WHERE student_id = %s AND attendance_id = %s", (student_id, attendance_id))
            existing_record = cursor.fetchone()

            # Get the client's IP address
            client_ip = request.remote_addr
            if client_ip in last_attendance_time and (datetime.now() - last_attendance_time[client_ip]) < timedelta(minutes=15):
                return jsonify({'error': 'Attendance can only be marked once every 15 minutes'}), 429

            if existing_record:
                # Update the existing record
                cursor.execute("UPDATE student_attendance SET attendance_status = %s WHERE student_id = %s AND attendance_id = %s", (status, student_id, attendance_id))
            else:
                # Insert a new record
                cursor.execute("INSERT INTO student_attendance (student_id, attendance_id, attendance_status) VALUES (%s, %s, %s)", (student_id, attendance_id, status))

            # Update the last attendance time for the client's IP address
            last_attendance_time[client_ip] = datetime.now()

            conn.commit()
            return jsonify({'message': f'Attendance marked as {status}'}), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    @app.route('/get_complaint_data', methods=['GET'])
    def get_complaint_data():
        if 'username' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor(dictionary=True)
            cursor.execute(
                "SELECT complaint_id, complaint_title, complaint_description, complaint_date, status "
                "FROM complaints "
                "WHERE student_id IN (SELECT student_id FROM students)"
                "ORDER BY complaint_date desc")
            
            complaints = cursor.fetchall()
            print(complaints)
            return jsonify(complaints), 200
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    @app.route('/update_complaint_status', methods=['POST'])
    def update_complaint_status():
        if 'username' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        complaint_id = request.json['complaint_id']
        status = request.json['status']

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            cursor.execute(
                "UPDATE complaints SET status = %s WHERE complaint_id = %s",
                (status, complaint_id)
            )
            conn.commit()
            return jsonify({'message': 'Complaint status updated successfully'})
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    @app.route('/delete_complaint/<int:complaint_id>', methods=['DELETE'])
    def delete_complaint(complaint_id):
        if 'username' not in session:
            return jsonify({'error': 'Unauthorized'}), 401

        try:
            conn = mysql.connector.connect(**st_db)
            cursor = conn.cursor()
            print(complaint_id)
            cursor.execute(
                "DELETE FROM complaints WHERE complaint_id = %s",
                (complaint_id,)
            )
            print(cursor.rowcount)
            conn.commit()
            if cursor.rowcount == 0:
                return jsonify({'error': 'Complaint not found'}), 404
            else:
                return jsonify({'message': 'Complaint deleted successfully'})
        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()

    return app