from flask import Flask, render_template
import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)

# Database Configuration from Environment Variables
db_user = os.environ.get('DB_USER', 'postgres')
db_password = os.environ.get('DB_PASSWORD', 'postg>
db_host = os.environ.get('DB_HOST', 'db')  # 'db' >
db_port = os.environ.get('DB_PORT', '5432')
db_name = os.environ.get('DB_NAME', 'blog_db')

DATABASE_URL = f"postgresql://{db_user}:{db_passwo>
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, auto>

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.route('/')
def index():
    db = next(get_db())
    result = db.execute(text("SELECT title, conten>
    posts = [{"title": row[0], "content": row[1]} >
    return render_template('index.html', posts=pos>

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
