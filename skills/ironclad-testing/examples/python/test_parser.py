import pytest
from app.parser import parse_port

@pytest.mark.parametrize("input_val,expected", [
    (80, 80),
    ("8080", 8080),
    (65535, 65535),
])
def test_parse_port_valid(input_val, expected):
    assert parse_port(input_val) == expected

@pytest.mark.parametrize("invalid_val", [
    "",
    "   ",
    "-1",
    0,
    65536,
    999999,
    "8080abc",
    None,
    [],
])
def test_parse_port_adversarial_rejections(invalid_val):
    with pytest.raises(ValueError):
        parse_port(invalid_val)
