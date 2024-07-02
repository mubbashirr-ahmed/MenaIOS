# Setting Up and Running Flask Application on Windows and macOS

This guide will walk you through the steps to set up a virtual environment, install dependencies, and run a Flask application using Python on both Windows and macOS.

## Prerequisites

Before you begin, ensure you have the following installed:

- Python 3.x (preferably the latest stable version)
- pip (Python package installer)

## Steps

### 1. Clone the Repository

Clone the repository containing your Flask application (`app.py`) and `requirements.txt` file to your local machine.

```bash
git clone <repository-url>
cd <repository-directory>
```

Replace `<repository-url>` with the URL of your Git repository and `<repository-directory>` with the name of the directory created during cloning.

### 2. Set Up a Virtual Environment

#### On Windows

Open Command Prompt or PowerShell:

```cmd
# Navigate to your project directory
cd path\to\your\project

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
venv\Scripts\activate
```

#### On macOS

Open Terminal:

```bash
# Navigate to your project directory
cd path/to/your/project

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate
```

### 3. Install Dependencies

While in the virtual environment, install the required packages using `pip` and `requirements.txt`.

```bash
pip install -r requirements.txt
```

### 4. Run the Flask Application

After installing the dependencies, you can run your Flask application.

```bash
python app.py
```

The Flask development server will start running. You should see output similar to:

```
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```

### 5. Accessing the Application

Open a web browser and navigate to `http://127.0.0.1:5000/` or `http://localhost:5000/` to access your Flask application.

### 6. Stopping the Application

To stop the Flask application, press `Ctrl + C` in the terminal or command prompt where the application is running.

### 7. Deactivating the Virtual Environment

When you're done working with the application, deactivate the virtual environment.

```bash
deactivate
```