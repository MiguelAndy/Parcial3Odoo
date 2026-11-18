# =============================================================
#  Parcial 3 - Odoo 19 construido DESDE EL CÓDIGO FUENTE
#  (repositorio https://github.com/odoo/odoo, rama 19.0)
#  No usa la imagen oficial "odoo": instala dependencias y
#  ejecuta odoo-bin igual que en la instalación nativa.
# =============================================================
FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

# 1) Librerías del sistema que necesitan los paquetes de requirements.txt
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libldap2-dev libsasl2-dev \
        libxml2-dev libxslt1-dev \
        libjpeg-dev zlib1g-dev libffi-dev libssl-dev \
        fonts-noto-cjk curl \
    && rm -rf /var/lib/apt/lists/*

# 2) Usuario sin privilegios para correr Odoo (buena práctica)
RUN useradd -m -d /opt/odoo -s /bin/bash odoo \
    && mkdir -p /var/lib/odoo /etc/odoo \
    && chown -R odoo:odoo /var/lib/odoo

# 3) Dependencias Python (se copia solo requirements.txt primero
#    para aprovechar la caché de capas de Docker)
COPY odoo/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip setuptools wheel \
    && pip install -r /tmp/requirements.txt

# 4) Código fuente clonado del repositorio + configuración
COPY --chown=odoo:odoo odoo/ /opt/odoo/src/
COPY --chown=odoo:odoo odoo.docker.conf /etc/odoo/odoo.conf

USER odoo
WORKDIR /opt/odoo/src
EXPOSE 8069

CMD ["python", "odoo-bin", "-c", "/etc/odoo/odoo.conf"]
