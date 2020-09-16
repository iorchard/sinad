#!/bin/sh
docker build -t sinad:1.0.0 .
docker tag sinad:1.0.0 sinad:latest
