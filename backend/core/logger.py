import logging

LOGGING_LEVEL = logging.INFO
LOGGING_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Configure logging to output to the console only
logging.basicConfig(level=LOGGING_LEVEL, format=LOGGING_FORMAT)

# Example usage
logger = logging.getLogger(__name__)
