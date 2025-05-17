# Persistent SQLite App with Docker (Data Persistence Demonstration)

## Overview

This project demonstrates a simple Flask web application that uses an SQLite database, specifically designed to showcase data persistence using Docker volumes. The application allows users to view and add messages, with all data stored within the Docker container. By utilizing a named Docker volume (`persistent-sqlite-data`), we ensure that the database and its contents survive container restarts and removals.

## Technologies Used

* **Python:** The primary programming language for the application logic.
* **Flask:** A lightweight and flexible micro web framework for Python.
* **SQLite:** A self-contained, file-based, and transactional relational database engine.
* **Docker:** A platform for building, running, and managing containerized applications.

## Project Structure

persistent-sqlite-app/

├── app/
│   ├── app.py           # Main Flask application with SQLite interaction
│   ├── schema.sql       # SQL script to initialize the database schema
│   └── requirements.txt # Python dependencies (Flask)
├── data/                # Directory where the Docker volume is mounted inside the container
├── templates/
│   └── list_messages.html # HTML to display messages with project explanation
├── Dockerfile           # Instructions to build the Docker image
└── README.md            # This file (project documentation)
