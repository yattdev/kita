#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from sanic import Sanic
from sanic.response import json, html, text
import os

app = Sanic(__name__)
CORS_OPTIONS = {
    "resources": r'/*',
    "origins": "*",
    "methods": ["GET", "POST", "HEAD", "OPTIONS"]
}
# Disable sanic-ext built-in CORS, and add the Sanic-CORS plugin
Extend(app,
       extensions=[CORS],
       config={
           "CORS": False,
           "CORS_OPTIONS": CORS_OPTIONS
       })

# Serves files from the static folder to the URL /static
app.static('/assets', './assets/')

@app.route('/')
def index(request):
  template = open(os.getcwd() + "/src/index.html")
  return html(template.read())

if __name__ == "__main__":
    app.run()
