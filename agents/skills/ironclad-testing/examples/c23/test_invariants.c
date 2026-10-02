#include <stdio.h>
#include <stdlib.h>
#include <stdckdint.h>

/* Macro de asserção cirúrgica com diagnóstico exato */
#define IRON_ASSERT(expr, msg) \
	do { \
		if (!(expr)) { \
			fprintf(stderr, "❌ [FALHA] %s:%d: %s (asserção: %s)\n", \
			        __FILE__, __LINE__, msg, #expr); \
			return 1; \
		} \
	} while (0)

/* Função sob teste com atributo obrigatório de retorno checado */
[[nodiscard]] static int safe_multiply(int a, int b, int *result) {
	if (result == nullptr) {
		return -1;
	}
	/* C23: Detecção de overflow no nível do compilador */
	if (ckd_mul(result, a, b)) {
		return -2; /* Overflow detectado */
	}
	return 0;
}

/* Caso de teste negativo: deve detectar overflow com segurança */
static int test_integer_overflow_detection(void) {
	int res = 0;
	int status = safe_multiply(1000000, 1000000, &res);
	IRON_ASSERT(status == -2, "Multiplicação deve retornar -2 em overflow");

	status = safe_multiply(10, 20, &res);
	IRON_ASSERT(status == 0 && res == 200, "Cálculo válido deve produzir 200");

	status = safe_multiply(10, 20, nullptr);
	IRON_ASSERT(status == -1, "Ponteiro nulo deve retornar -1 com segurança");
	return 0;
}

int main(void) {
	if (test_integer_overflow_detection() != 0) {
		return 1;
	}
	printf("✅ [C23] Todos os testes de invariantes passaram com sucesso.\n");
	return 0;
}
