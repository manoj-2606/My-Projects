# Persistent SQLite App with Docker (Data Persistence Demonstration)

## Overview

This project demonstrates a simple Flask web application that uses an SQLite database, specifically designed to showcase data persistence using Docker volumes. The application allows users to view and add messages, with all data stored within the Docker container. By utilizing a named Docker volume (`persistent-sqlite-data`), we ensure that the database and its contents survive container restarts and removals.

## Technologies Used

* **Python:** The primary programming language for the application logic.
* **Flask:** A lightweight and flexible micro web framework for Python.
* **SQLite:** A self-contained, file-based, and transactional relational database engine.
* **Docker:** A platform for building, running, and managing containerized applications.

## Project Structure
