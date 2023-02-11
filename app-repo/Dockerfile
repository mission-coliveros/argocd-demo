FROM python:3.8.1-alpine

#
WORKDIR /code

#
COPY ./requirements.txt /code/requirements.txt

#
RUN set -eux \
    && apk add --no-cache --virtual .build-deps build-base \
    libressl-dev libffi-dev gcc musl-dev python3-dev \
    postgresql-dev \
    && pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --upgrade -r /code/requirements.txt \
    && rm -rf /root/.cache/pip

COPY ./app /code/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "6379"]


## pull official base image
#FROM python:3.8.1-alpine
#
## set work directory
#WORKDIR /src
#
## set environment variables
#ENV PYTHONDONTWRITEBYTECODE 1
#ENV PYTHONUNBUFFERED 1
#
## copy requirements file
#COPY ./requirements.txt /src/requirements.txt
#
#EXPOSE 8002:8000
#
#VOLUME "./:/src/"
#
## install dependencies
#RUN set -eux \
#    && apk add --no-cache --virtual .build-deps build-base \
#    libressl-dev libffi-dev gcc musl-dev python3-dev \
#    postgresql-dev \
#    && pip install --upgrade pip setuptools wheel \
#    && pip install -r /src/requirements.txt \
#    && rm -rf /root/.cache/pip
#
## copy project
#COPY . /src/
#
#CMD ["printenv"]
#CMD ["uvicorn app.main:app --reload --workers 1 --host 0.0.0.0 --port 8000"]