FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /opt/app

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
RUN pip install -r requirements.txt


FROM nvidia/cuda:12.1.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3.10 \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.10 /usr/bin/python3
RUN ln -s /usr/bin/python3 /usr/bin/python
    
RUN useradd -m -u 1000 -s /bin/bash comfyuser

USER comfyuser

WORKDIR /home/comfyuser/app

COPY --chown=comfyuser:comfyuser --from=builder /opt/venv /home/comfyuser/venv
COPY --chown=comfyuser:comfyuser --from=builder /opt/app /home/comfyuser/app

COPY --chown=comfyuser:comfyuser run.sh .
RUN chmod +x run.sh

ENV PATH="/home/comfyuser/venv/bin:$PATH"

EXPOSE 8188

CMD ["./run.sh"]