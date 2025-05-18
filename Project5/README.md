# Simple Blog with Flask and PostgreSQL using Docker Compose

This project demonstrates a simple blog application built with the Flask microframework (Python) and a PostgreSQL database, orchestrated using Docker Compose. It showcases how to containerize a web application and its database and manage them together using Docker Compose.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

* **Docker:** [Install Docker](https://docs.docker.com/engine/install/)
* **Docker Compose:** [Install Docker Compose](https://docs.docker.com/compose/install/)

## Project Structure

flask-blog/
├── app/
│   ├── app.py              # Flask application code
│   ├── templates/
│   │   └── index.html      # HTML template for displaying blog posts
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Dockerfile for building the Flask application image
├── docker-compose.yml      # Docker Compose configuration file
└── README.md               # This file


## How to Run

## Getting Started

Follow these steps to run the application:

1.  **Clone the repository (if you haven't already):**

    ```bash
    cd flask-blog
    ```

2.  **Start the services using Docker Compose:**

    ```bash
    docker-compose up -d --build
    ```

    This command will:
    * Build the Docker image for the Flask application using the `Dockerfile` in the `app` directory.
    * Pull the `postgres:13` image from Docker Hub if it doesn't exist locally.
    * Create and start containers for both the `web` (Flask app) and `db` (PostgreSQL) services in detached mode.

3.  **Initialize the PostgreSQL Database:**

    Once the containers are running, you need to create the `posts` table and insert some initial data. You can do this by connecting to the `db` container:

    ```bash
    docker exec -it flask-blog-db-1 bash
    ```

    (The container name might vary slightly, check with `docker ps`).

    Inside the container, connect to PostgreSQL:

    ```bash
    psql -U postgres
    ```

    Create the database (though Docker Compose might handle this):

    ```sql
    CREATE DATABASE blog_db;
    \c blog_db;
    ```

    Create the `posts` table:

    ```sql
    CREATE TABLE posts (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL
    );
    ```

    Insert some initial blog posts:

    ```sql
    INSERT INTO posts (title, content) VALUES ('First Post', 'This is the content of the very first blog post.');
    INSERT INTO posts (title, content) VALUES ('Second Thoughts', 'Here are some more thoughts on various topics.');
    ```

    Exit the PostgreSQL prompt and the container's shell:

    ```sql
    \q
    exit
    ```

4.  **Access the Application:**

    Open your web browser and navigate to `http://localhost:5000`. You should see the simple blog page displaying the posts from the PostgreSQL database.

## Key Components

* **`app/app.py`:** The Flask application that handles web requests, connects to the PostgreSQL database using SQLAlchemy, fetches blog posts, and renders the `index.html` template.
* **`app/templates/index.html`:** The HTML template used by Flask to display the blog posts dynamically.
* **`app/requirements.txt`:** Lists the Python dependencies required for the Flask application (Flask, SQLAlchemy, psycopg2-binary).
* **`app/Dockerfile`:** Defines the environment for the Flask application, installs dependencies, copies the application code, and specifies how to run the application.
* **`docker-compose.yml`:** Configures and orchestrates the two Docker containers:
    * **`web`:** Builds the Flask application image and runs the Flask development server. It maps port 5000 on the host to port 5000 in the container and depends on the `db` service.
    * **`db`:** Uses the official `postgres:13` image from Docker Hub and sets up environment variables for the database. It also uses a named volume (`db_data`) to persist the database data.

## Data Persistence

The PostgreSQL database data is persisted using a named Docker volume called `db_data`. This ensures that the blog posts you create will not be lost even if you stop or remove the `db` container (unless you explicitly remove the volume).

## Development

For development, the `docker-compose.yml` file includes a volume mount for the `web` service:

```yaml
volumes:
  - ./app:/app
This allows you to make changes to your Python code and HTML templates in the app directory on your host machine, and those changes will be immediately reflected inside the running web container without needing to rebuild the Docker image.
```

## How to STOP

Stopping the Application
To stop the application and the containers, run:

    ```bash
    docker-compose down
    ```

To also remove the named volumes (including the database data), you can run:

``bash
    docker-compose down -v
    ```

## Screenshot

![Output Image](https://github.com/manoj-2606/My-Projects/blob/8701c8f89c816333da7f968c88505faa3ca09c7d/Project5/Output.png)
