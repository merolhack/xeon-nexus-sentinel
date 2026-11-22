FROM python:3.12-slim

WORKDIR /app

# Instalar dependencias mínimas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código del servicio
COPY app/ ./app/

# Configurar variables de entorno por defecto
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
