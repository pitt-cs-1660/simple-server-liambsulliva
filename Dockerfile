# Build Stage
FROM python:3.12 AS builder
WORKDIR /app
COPY pyproject.toml ./
RUN pip install uv
RUN uv pip compile pyproject.toml -o requirements.txt
RUN pip install --prefix=/install -r requirements.txt

# Final Stage
FROM python:3.12-slim
WORKDIR /app

# Copy build environment to final
COPY --from=builder /install /usr/local

# Copy source
COPY . .

# Reset python path so cc_simple_server can be imported properly
ENV PYTHONPATH=/app

# Create non-root user and set permissions
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose FastAPI port
EXPOSE 8000

# Run server
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]