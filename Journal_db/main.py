from flask import Flask, render_template, redirect, request, session, flash
from flask_sqlalchemy import SQLAlchemy
import pymysql
import hashlib
from datetime import date
from ldap3 import Server, Connection, ALL, NTLM

app = Flask(__name__)
app.secret_key = 'supersecret'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:rootpass@localhost:3307/journal_db'
db = SQLAlchemy(app)

# === AD CONFIG ===
AD_SERVER = '192.168.238.193'
AD_DOMAIN = 'journal_ac'
AD_DN = 'DC=journal_ac,DC=local'

# === MODELS ===
class Students(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    full_name = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    def check_password(self, password_input):
        return self.password_hash == hashlib.sha256(password_input.encode()).hexdigest()

class TeachersLite(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    full_name = db.Column(db.String(255), nullable=True)  # Можно расширить потом

class Subjects(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)

class Grades(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('students.id'), nullable=False)
    subject_id = db.Column(db.Integer, db.ForeignKey('subjects.id'), nullable=False)
    teacher_id = db.Column(db.Integer, db.ForeignKey('teachers_lite.id'), nullable=False)
    grade_value = db.Column(db.Integer, nullable=False)
    grade_date = db.Column(db.Date, nullable=False)

    student = db.relationship('Students', backref='grades')
    teacher = db.relationship('TeachersLite', backref='grades')
    subject = db.relationship('Subjects', backref='grades')

# === ROUTES ===

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')




@app.route('/ad-login', methods=['GET', 'POST'])
def ad_login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user_dn = f'{AD_DOMAIN}\\{username}'
        server = Server(AD_SERVER, get_info=ALL)

        try:
            conn = Connection(
                server,
                user=user_dn,
                password=password,
                authentication=NTLM,
                auto_bind=True
            )

            # Поиск DN пользователя в AD
            conn.search(
                search_base=AD_DN,
                search_filter=f'(sAMAccountName={username})',
                attributes=['distinguishedName', 'displayName']
            )

            if not conn.entries:
                flash('User not found in AD.', 'danger')
                return render_template('ad_login.html')

            user_entry = conn.entries[0]
            user_dn_full = str(user_entry.distinguishedName)
            full_name = str(user_entry.displayName) if 'displayName' in user_entry else username

            # Определяем роль по OU
            if 'OU=Teachers' in user_dn_full:
                role = 'teacher'

                teacher = TeachersLite.query.filter_by(username=username).first()
                if not teacher:
                    teacher = TeachersLite(username=username, full_name=full_name)
                    db.session.add(teacher)
                    db.session.commit()

                session['user_id'] = teacher.id
                session['username'] = username
                session['role'] = role
                flash('Logged in as teacher.', 'success')
                return redirect('/teacher-panel')

            elif 'OU=Students' in user_dn_full:
                role = 'student'

                student = Students.query.filter_by(username=username).first()
                if not student:
                    # Можно сгенерировать "заглушку" для пароля, т.к. вход всё равно через AD
                    fake_hash = hashlib.sha256('external_ad_only'.encode()).hexdigest()
                    student = Students(username=username, full_name=full_name, password_hash=fake_hash)
                    db.session.add(student)
                    db.session.commit()

                session['user_id'] = student.id
                session['username'] = username
                session['role'] = role
                flash('Logged in as student.', 'success')
                return redirect('/student-panel')


            else:
                flash('Access denied: not in allowed OU.', 'danger')
                return render_template('ad_login.html')

        except Exception as e:
            flash(f"AD login failed: {str(e)}", "danger")
            return render_template('ad_login.html')

    return render_template('ad_login.html')




@app.route('/teacher-panel', methods=['GET', 'POST'])
def teacher_panel():
    if session.get('role') != 'teacher':
        return redirect('/ad-login')

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
        return redirect('/ad-login')

    student_id = session['user_id']
    grades = Grades.query.filter_by(student_id=student_id).join(Subjects).join(TeachersLite).all()
    return render_template('student_panel.html', grades=grades)


@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

@app.route('/test-db')
def test_db():
    all_students = Students.query.all()
    all_teachers = TeachersLite.query.all()
    return f"Students: {len(all_students)}, Teachers: {len(all_teachers)}"


# === RUN ===
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=True)
