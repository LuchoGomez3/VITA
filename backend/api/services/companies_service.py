import time
from api.schemas.models import CompaniesInfo
from core.config import Config
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

config = Config()
startup_time = time.time()

class CompaniesService:
    def __init__(self):
        pass

    def _get_companies(self) -> list:
        """
        Simple component checks placeholder.
        """
        return ["Visa", "Mastercard"]
        
    def get_companies_info(self) -> CompaniesInfo:

        companies = self._get_companies()

        return CompaniesInfo(
            companies=companies
        )