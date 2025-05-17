FROM python:3.9-slim-buster
WORKDIR /app
COPY app /app
COPY templates /app/templates
RUN pip install -r /app/requirements.txt
EXPOSE 5000
VOLUME /data
CMD ["python", "/app/app.py"]
