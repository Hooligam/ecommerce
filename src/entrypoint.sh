#!/bin/bash
python -m flask db upgrade
python -m gunicorn --bind 0.0.0.0:5000 index:app