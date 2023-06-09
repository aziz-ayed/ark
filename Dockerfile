# Use a Windows base image
FROM mcr.microsoft.com/windows/server:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install system dependencies using Chocolatey
RUN iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) ; \
    choco install -y ffmpeg --allow-empty-checksums --allow-downgrade ; \
    choco install -y vcbuildtools --allow-empty-checksums --allow-downgrade ; \
    choco install -y python3 --version 3.8.0 --allow-empty-checksums --allow-downgrade ; \
    choco install -y git --allow-empty-checksums --allow-downgrade ; \
    choco install -y dcmtk --allow-empty-checksums --allow-downgrade ; \
    choco install -y wget --allow-empty-checksums --allow-downgrade ; \
    choco install -y unzip --allow-empty-checksums --allow-downgrade ; \
    choco install -y curl ; \
    Remove-Item -Force -Recurse -Path C:\ProgramData\chocolatey

# Set SSL certificates

RUN curl -o C:\cacert.pem https://curl.se/ca/cacert.pem
ENV SSL_CERT_FILE=C:\cacert.pem

# Install "Media Foundation" feature

RUN Install-WindowsFeature Server-Media-Foundation

# Set the working directory
WORKDIR /app

# Copy and install Python dependencies
RUN py -m pip install --upgrade --user pip setuptools wheel

COPY requirements.txt requirements.txt
RUN py -m pip install -r requirements.txt
RUN py -m pip install -U albumentations==1.1.0 --no-binary qudida,albumentations
RUN py -m pip install --upgrade --no-cache-dir gdown

# Clone and install Sybil library
RUN git clone https://github.com/aziz-ayed/win_Sybil.git ;
    WORKDIR /app/win_Sybil
RUN py -m pip install . ;
    WORKDIR /app

# Copy application code
COPY . .

ENV NAME ark

EXPOSE 5000

ENTRYPOINT ["python", "main.py", "--config", "api/configs/sybil.json"]
