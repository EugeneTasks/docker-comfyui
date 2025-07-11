#!/bin/bash
ARGS=${COMFYUI_ARGS:-""}
cd /home/comfyuser/app
exec python3 main.py --listen 0.0.0.0 $ARGS