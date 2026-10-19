FROM python:3.10-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code
COPY . .

# Expose the Flask application port
EXPOSE 5153

# Start the application
CMD ["python", "app.py"]
