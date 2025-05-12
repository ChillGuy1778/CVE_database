from flask import Flask, render_template, redirect, request, session, flash
from flask_sqlalchemy import SQLAlchemy
import pymysql
import hashlib
from datetime import date

app = Flask(__name__)
app.secret_key = 'supersecret'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:rootpass@localhost:3306/journal_db'
db = SQLAlchemy(app)

# === MODELS ===
class Students(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    full_name = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    def check_password(self, password_input):
        return self.password_hash == hashlib.sha256(password_input.encode()).hexdigest()

class Teachers(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    full_name = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

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

    student = db.relationship('Students', backref='grades')
    teacher = db.relationship('Teachers', backref='grades')
    subject = db.relationship('Subjects', backref='grades')


# === ROUTES ===
@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        full_name = request.form['full_name']

        password_hash = hashlib.sha256(password.encode()).hexdigest()

        if Students.query.filter_by(username=username).first():
            flash('Student with this username already exists', 'danger')
            return render_template('register.html')
        new_user = Students(username=username, password_hash=password_hash, full_name=full_name)
        db.session.add(new_user)


        db.session.commit()
        flash('Registration successful. Please log in.', 'success')
        return redirect('/login')

    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username_input = request.form['username']
        password_input = request.form['password']

        if username_input == 'admin' and password_input == 'adminpass':
            session['user_id'] = 0
            session['username'] = 'admin'
            session['role'] = 'admin'
            return redirect('/admin-panel')

    

        user = Teachers.query.filter_by(username=username_input).first()
        role = 'teacher'
        if not user:
            user = Students.query.filter_by(username=username_input).first()
            role = 'student'

        if user and user.check_password(password_input):
            session['user_id'] = user.id
            session['username'] = user.username
            session['role'] = role
            flash('Login successful', 'success')
            return redirect('/')
        else:
            flash('Invalid username or password', 'danger')

    return render_template('login.html')




@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

from flask import Flask, render_template, redirect, request, session, flash
from flask_sqlalchemy import SQLAlchemy
import hashlib
from datetime import date

# ... [предыдущие определения моделей и настроек]

@app.route('/teacher-panel', methods=['GET', 'POST'])
def teacher_panel():
    if session.get('role') != 'teacher':
        return redirect('/login')

    students = Students.query.all()
    subjects = Subjects.query.all()
    grades = Grades.query.filter_by(teacher_id=session['user_id']).join(Students).join(Subjects).all()

    if request.method == 'POST':
        student_id = request.form['student_id']
        subject_id = request.form['subject_id']
        grade_value = int(request.form['grade_value'])
        grade = Grades(
            student_id=student_id,
            subject_id=subject_id,
            teacher_id=session['user_id'],
            grade_value=grade_value,
            grade_date=date.today()
        )
        db.session.add(grade)
        db.session.commit()
        flash('Grade added successfully.', 'success')
        return redirect('/teacher-panel')

    return render_template('teacher_panel.html', students=students, subjects=subjects, grades=grades)


@app.route('/student-panel')
def student_panel():
    if session.get('role') != 'student':
        return redirect('/login')

    student_id = session['user_id']
    grades = Grades.query.filter_by(student_id=student_id).join(Subjects).join(Teachers).all()
    return render_template('student_panel.html', grades=grades)


@app.route('/admin-panel', methods=['GET', 'POST'])
def admin_panel():
    if session.get('role') != 'admin':
        flash('Access denied.', 'danger')
        return redirect('/login')

    if request.method == 'POST':
        username = request.form['username']
        full_name = request.form['full_name']
        password = request.form['password']
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        if Teachers.query.filter_by(username=username).first():
            flash('Teacher with this username already exists', 'danger')
        else:
            new_teacher = Teachers(username=username, full_name=full_name, password_hash=password_hash)
            db.session.add(new_teacher)
            db.session.commit()
            flash('Teacher successfully added', 'success')

    teachers = Teachers.query.all()
    return render_template('admin_panel.html', teachers=teachers)



@app.route('/test-db')
def test_db():
    all_teachers = Teachers.query.all()
    all_students = Students.query.all()
    return f"Teachers: {len(all_teachers)}, Students: {len(all_students)}"




# === RUN ===
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
