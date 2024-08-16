# syntax=docker/dockerfile:1

FROM python:3.12.4-slim
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD [ "python", "-m" , "flask", "run", "--host=0.0.0.0"]