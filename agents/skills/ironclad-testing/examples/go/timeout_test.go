package config_test

import (
	"testing"
)

func TestParseTimeout(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name      string
		input     string
		wantMs    int
		expectErr bool
	}{
		{name: "válido milissegundos", input: "500ms", wantMs: 500, expectErr: false},
		{name: "borda zero", input: "0ms", wantMs: 0, expectErr: false},
		{name: "negativo inválido", input: "-10ms", wantMs: 0, expectErr: true},
		{name: "string vazia", input: "", wantMs: 0, expectErr: true},
		{name: "unidade ausente", input: "500", wantMs: 0, expectErr: true},
		{name: "overflow numérico", input: "99999999999999999999ms", wantMs: 0, expectErr: true},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got, err := ParseTimeout(tc.input)
			if (err != nil) != tc.expectErr {
				t.Fatalf("ParseTimeout(%q) erro inesperado: %v (esperava erro: %v)", tc.input, err, tc.expectErr)
			}
			if !tc.expectErr && got != tc.wantMs {
				t.Errorf("ParseTimeout(%q) = %d; esperado %d", tc.input, got, tc.wantMs)
			}
		})
	}
}
