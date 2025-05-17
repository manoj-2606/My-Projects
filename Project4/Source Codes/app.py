import sqlite3
from flask import Flask, render_template
import os

app = Flask(__name__)
DATABASE_FILE = '/data/mydatabase.db'

def get_db():
    conn = sqlite3.connect(DATABASE_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    db = get_db()
    with app.open_resource('schema.sql', mode='r') as f:
        db.cursor().executescript(f.read())
    db.commit()
    db.close()

@app.cli.command('initdb')
def initdb_command():
    """Initializes the database."""
    init_db()
    print('Initialized the database.')

def query_db(query, args=(), one=False):
    cur = get_db().execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv

@app.route('/')
def list_messages():
    messages = query_db('select text from messages')
    return render_template('list_messages.html', messages=messages)

@app.route('/add/<message>')
def add_message(message):
    db = get_db()
    db.execute('insert into messages (text) values (?)', [message])
    db.commit()
    db.close()
    return "Message added!"

if __name__ == '__main__':
    if not os.path.exists('/data/mydatabase.db'):
        with app.app_context():
            init_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
