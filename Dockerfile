ARG PYTHON_ENV=python:3.11-slim

FROM $PYTHON_ENV as build

RUN pip install pipenv

COPY Pipfile Pipfile.lock /
RUN pipenv requirements > /requirements.txt

FROM $PYTHON_ENV
ENV APP_DIR=/app

WORKDIR $APP_DIR
COPY --from=build /requirements.txt $APP_DIR
RUN pip install -r $APP_DIR/requirements.txt

COPY src $APP_DIR

ENTRYPOINT ["python3", "main.py"]
