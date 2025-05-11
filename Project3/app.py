from flask import Flask, render_template
import os

app = Flask(__name__)
COUNT_FILE = '/data/count.txt'

def get_count():
    try:
        with open(COUNT_FILE, 'r') as f:
            return int(f.read())
    except FileNotFoundError:
        return 0

def increment_count():
    count = get_count() + 1
    with open(COUNT_FILE, 'w') as f:
        f.write(str(count))
    return count

@app.route('/')
def index():
    count = increment_count()
    return render_template('index.html', count=count)

if __name__ == '__main__':
    os.makedirs(os.path.dirname(COUNT_FILE), exist_ok=True)
    app.run(debug=True, host='0.0.0.0')
