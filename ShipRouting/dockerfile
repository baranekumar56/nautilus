# ShipRouting/Dockerfile

# Base image
FROM python:3.12.5

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the Flask port
EXPOSE 5000

# Command to run the Flask app using flsk.py as the main file
CMD ["python", "flsk.py"]
