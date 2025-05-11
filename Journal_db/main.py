from contextlib import redirect_stderr
from flask import Flask, render_template, redirect, request, session, flash
from flask_sqlalchemy import SQLAlchemy
import pymysql
import hashlib


app = Flask(__name__)
app.secret_key = 'supersecret'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:rootpass@localhost:3306/journal_db'
db = SQLAlchemy(app)


class Users(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    full_name = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(100), nullable=False)

    ''' def __init__(self, username, full_name, hashed_password):
        self.username = username
        self.full_name = full_name
        self.password = hashed_password
        self.'''

    def check_password(self, password_input):
        return self.password_hash == hashlib.sha256(password_input.encode()).hexdigest()


class Subjects(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)

class Grades(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('students.id'), nullable=False)
    subject_id = db.Column(db.Integer, db.ForeignKey('subjects.id'), nullable=False)
    teacher_id = db.Column(db.Integer, db.ForeignKey('teachers.id'), nullable=False)
    grade_value = db.Column(db.Integer, nullable=False)
    grade_date = db.Column(db.Date, nullable=False)



@app.route('/index')
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/test-db')
def test_db():
    students = Users.query.all()
    print(f"Найдено студентов: {len(students)}")
    return redirect("/")

@app.route('/login', methods=['POST', 'GET'])
def login():
    if request.method == 'POST':
        username_input = request.form['username']
        password_input = request.form['password']

        user = Users.query.filter_by(username=username_input).first()
        if user and user.check_password(password_input):
            session['user_id'] = user.id
            session['username'] = user.username
            session['role'] = user.role
            flash('Успешный вход', 'success')
            return redirect('/')
        else:
            flash('Неверный логин или пароль', 'danger')

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        full_name = request.form['full_name']
        role = request.form['role']

        if role not in ['student', 'teacher']:
            flash("Role doesn't exist", 'danger')
            return render_template('register.html')

        if Users.query.filter_by(username=username).first():
            flash('User already exist', 'danger')
            return render_template('register.html')

        password_hash = hashlib.sha256(password.encode()).hexdigest()
        new_user = Users(username=username, password_hash=password_hash, full_name=full_name, role=role)
        db.session.add(new_user)
        db.session.commit()
        flash('Register is. Now please log in.', 'success')
        return redirect('/login')

    return render_template('register.html')

@app.route('/teacher-panel')
def teacher_panel():
    if session.get('role') != 'teacher':
        return redirect('/login')  # или 403
    return render_template('teacher_panel.html')



if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)


