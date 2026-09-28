# ⚡ Recursos Contemporâneos do C++ Moderno (C++23)

Este documento detalha os recursos expressivos introduzidos pelos padrões **ISO/IEC 14882:2020/2024 (C++20/C++23)**, priorizando segurança monádica e zero abstração de custo em tempo de execução.

---

## 1. Tratamento Monádico de Erros: `std::expected<T, E>`

Abandone o uso de exceções lentas para fluxos de negócio esperados e elimine códigos de erro passados por ponteiro. Com `std::expected`, o retorno expressa sucesso com valor ou falha explícita tipada:

```cpp
#include <expected>
#include <string>
#include <string_view>

enum class ConfigError {
    NotFound,
    AccessDenied,
    Corrupted
};

[[nodiscard]] auto read_config(std::string_view path)
    -> std::expected<std::string, ConfigError> {
    if (path.empty()) {
        return std::unexpected(ConfigError::NotFound);
    }
    return std::string("config_payload");
}

// Encadeamento Funcional (.and_then / .or_else):
auto parsed = read_config("settings.json")
    .and_then([](const std::string &content) {
        return parse_json(content);
    });
```

---

## 2. Saída Tipada e Formatação de Alta Velocidade: `<print>`

Substitua terminantemente `printf` (vulnerável a incompatibilidade de tipos) e `std::cout << ... << std::endl` (lento e com flushes excessivos). O header `<print>` do C++23 compila com checagem estática de formato:

```cpp
#include <print>

int main() {
    std::string user = "Gabriel";
    int jobs = 16;
    std::println("Iniciando pool para '{}' com {} threads.", user, jobs);
    return 0;
}
```

---

## 3. Concepts e Constraints: Restrições Formais de Tipos

Substitua SFINAE e `std::enable_if` obscuros por `concepts` declarativos:

```cpp
#include <concepts>

template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <Numeric T>
[[nodiscard]] constexpr auto clamp_value(T val, T min, T max) -> T {
    return (val < min) ? min : (val > max) ? max : val;
}
```

---

## 4. Ranges e Pipelines Funcionais: `std::views`

Processe sequências e coleções de forma preguiçosa (_lazy evaluation_) sem alocações dinâmicas intermediárias:

```cpp
#include <vector>
#include <ranges>
#include <print>

void process_metrics(const std::vector<int> &data) {
    auto view = data
        | std::views::filter([](int n) { return n > 0; })
        | std::views::transform([](int n) { return n * 2; });

    for (int val : view) {
        std::println("Métrica: {}", val);
    }
}
```

---

## 5. Avaliação em Tempo de Compilação: `consteval` e `constexpr`

Cálculos puros, tabelas de consulta e hashes devem ser computados na compilação:

```cpp
consteval auto compile_time_hash(std::string_view str) -> uint64_t {
    uint64_t hash = 14695981039346656037ULL;
    for (char c : str) {
        hash = (hash ^ static_cast<uint64_t>(c)) * 1099511628211ULL;
    }
    return hash;
}

constexpr auto packet_id = compile_time_hash("auth_token_request");
```
