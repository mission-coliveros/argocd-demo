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
