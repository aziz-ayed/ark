#FROM python:3.8 AS builder

#RUN apt-get update && apt-get install -y --no-install-recommends \
#    g++ \
#    wget \
#    unzip \
#&& rm -rf /var/lib/apt/lists/*

#COPY requirements.txt .
#RUN pip wheel --no-cache-dir --wheel-dir /wheels/ -r requirements.txt git+https://github.com/pgmikhael/Sybil.git

FROM python:3.8-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    wget \
    unzip \
    git \
&& rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
RUN git clone https://github.com/pgmikhael/Sybil.git && cd Sybil && pip install . && cd ..

RUN apt-get update && apt-get install -y --no-install-recommends \
    dcmtk \
    python3-sklearn-lib \
&& rm -rf /var/lib/apt/lists/*

#COPY --from=builder /wheels /wheels
#RUN pip install --no-cache /wheels/* && rm -rf /wheels/

COPY . .

ENV NAME ark

EXPOSE 5000

ENTRYPOINT ["python", "main.py", "--config", "api/configs/sybil.json"]
