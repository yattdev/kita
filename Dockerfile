###########
# BUILDER #
###########
# pull official base image
FROM python:3.8-slim-buster as builder

WORKDIR /usr/src/app

# Set environment variable
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV IS_DOCKER 1

# install psycopg2 dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libc-dev python3-dev && \
    apt-get install -y postgresql && \
    # apt-get install -y jpeg-dev zlib-dev libjpeg && \
    apt-get install -y libffi-dev

# lint
RUN python3 -m pip install --upgrade pip setuptools wheel

# copy dir
COPY . .
# Check code with flake8
# RUN flake8 --ignore=E501,F401 .

# install dependencies
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

#########
# FINAL #
#########
# Pull base image
FROM python:3.8-slim-buster

ENV IS_DOCKER 1

# add new user
RUN useradd -ms /bin/bash alassane
# add user alassane to (root group).
RUN usermod -aG root alassane

# Set work directory
ENV HOME=/home/alassane
ENV APP_HOME=/home/alassane/kita
WORKDIR $APP_HOME

# Add path
ENV PATH="$APP_HOME/.local/bin:${PATH}"

# install dependencies
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache /wheels/*
RUN rm -rf /wheels && rm -rf /usr/src/app

# Install netcut
RUN apt-get update && apt-get install netcat -y

# Copy kita, period dot (.) meant current dir
COPY --chown=alassane:alassane . $APP_HOME

# Switch to root and change ownership of home and app_home
USER root
RUN chown -R alassane:alassane $HOME
RUN chown -R alassane:alassane $APP_HOME

# Change user to clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clean cache apt
RUN apt-get autoclean
RUN apt-get autoremove

# Change user to alassane
USER alassane

# run entrypoint.prod.sh
# ENTRYPOINT [""]
