import pytest
from api.services.companies_service import CompaniesService
from api.schemas.models import CompaniesInfo


def test__get_companies_returns_expected_list():
    service = CompaniesService()
    companies = service._get_companies()
    assert isinstance(companies, list)
    assert companies == ["Visa", "Mastercard"]


def test_get_companies_info_returns_companiesinfo_model():
    service = CompaniesService()
    info = service.get_companies_info()
    assert isinstance(info, CompaniesInfo)
    assert info.companies == ["Visa", "Mastercard"] 