Why I did this Project?
##so this project helps me in understanding the concepts of docker compose, how to host a multile containers on a single host.

Understanding how this application works?
##so here we have files like app.py, dockerfile, requirements.txt, index.html and docker-compose.yml, so once we ran the docker-compose command it will creates 2 images & conatiners [1 is for Flask (app.py) 
application and the other is for postgreDB]

We build an image for the Flask application using our app/Dockerfile, and we use a pre-existing postgres image from Docker Hub for the PostgreSQL database.

Dockerfile Only for Flask: Exactly! The build: ./app directive for the web service in docker-compose.yml points to the directory containing the Dockerfile, which Docker uses to build the Flask application's image. 
For PostgreSQL, the image: "postgres:13" line directly tells Docker Compose to use that pre-built image.

Contents of app.py: It's a Python application built using the Flask framework. It contains Python code that:
  Sets up the web server and defines routes (like the / route).
  Connects to the PostgreSQL database using SQLAlchemy.
  Executes SQL queries (like SELECT title, content FROM posts) through the database connection.
  Fetches the data from the database.
  Renders the index.html template, passing the fetched data to it so the HTML can be dynamically populated with the blog posts.
So, app.py contains Python logic that includes SQL interactions and the rendering of the HTML. It "calls out" for index.html when a user visits the / route, using Flask's render_template() function.

Where SQL Stores Data in docker-compose.yml: The docker-compose.yml file itself doesn't directly contain the SQL data. Instead, it configures how the PostgreSQL container manages its data. 

The Flask application (app.py) contains Python code that interacts with the PostgreSQL database (sends SQL queries) and renders the index.html template to display data.
The templates folder with index.html defines the UI structure that the Flask application populates with dynamic data.
Docker Compose orchestrates the Flask application (in one container) and the PostgreSQL database (in another container), allowing them to communicate.
Docker volumes are used to persist the database data (db_data) and to facilitate code changes during development (./app:/app).
