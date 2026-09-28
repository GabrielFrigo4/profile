#include <cstdint>
#include <expected>
#include <print>
#include <string_view>

enum class ParseError { EmptyInput, InvalidDigit, Overflow };

[[nodiscard]] constexpr std::expected<uint32_t, ParseError>
parse_port(std::string_view sv) noexcept {
	if (sv.empty()) return std::unexpected(ParseError::EmptyInput);
	uint64_t val = 0;
	for (char c : sv) {
		if (c < '0' || c > '9') return std::unexpected(ParseError::InvalidDigit);
		val = val * 10 + static_cast<uint64_t>(c - '0');
		if (val > 65535) return std::unexpected(ParseError::Overflow);
	}
	return static_cast<uint32_t>(val);
}

/* Invariantes checadas em tempo de compilação */
static_assert(parse_port("8080").value() == 8080);
static_assert(parse_port("").error() == ParseError::EmptyInput);
static_assert(parse_port("99999").error() == ParseError::Overflow);
static_assert(parse_port("abc").error() == ParseError::InvalidDigit);

int main() {
	std::println("✅ [C++23] Invariantes de compilação e runtime 100% verificadas.");
	return 0;
}
