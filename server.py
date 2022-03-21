#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from sanic import Sanic
from sanic.response import json, html, text
import os

app = Sanic(__name__)
# Serves files from the static folder to the URL /static
app.static('/assets', './assets/')

@app.route('/')
def index(request):
  template = open(os.getcwd() + "/src/index.html")
  return html(template.read())

app.run(host='0.0.0.0')
