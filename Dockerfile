FROM python:3.14

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    UV_LINK_MODE=copy \
    UV_PYTHON_PREFERENCE=only-system \
    DOCKER=true \
    GIT_PYTHON_REFRESH=quiet

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    ffmpeg \
    gcc \
    git \
    libavcodec-dev \
    libavdevice-dev \
    libavformat-dev \
    libavutil-dev \
    libcairo2 \
    libmagic1 \
    libswscale-dev \
    openssh-server \
    xfonts-75dpi \
    xfonts-base \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install --no-install-recommends -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install uv
ADD https://astral.sh/uv/install.sh /uv-install.sh
RUN env UV_NO_PROGRESS=1 UV_PYTHON_PREFERENCE=only-system \
    UV_INSTALL_DIR="/usr/local/bin" \
    sh /uv-install.sh && rm -f /uv-install.sh

WORKDIR /data
RUN mkdir /data/private

RUN git clone https://github.com/0x04A1A430/Heroku /data/Heroku

WORKDIR /data/Heroku

ARG HEROKU_REF=dev
RUN git fetch origin "${HEROKU_REF}" && git checkout "${HEROKU_REF}" && git pull origin "${HEROKU_REF}"

COPY requirements.txt /tmp/requirements.txt
RUN uv pip install --system --no-cache \
    -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

CMD ["python", "-m", "heroku", "--root"]
