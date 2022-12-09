#ifndef OPTIMALIZATION_H
#define OPTIMALIZATION_H

#include <erl_nif.h>
#include <vector>

ERL_NIF_TERM make_f32x8(ErlNifEnv *env, float * data, const char * computed_using) {
    ERL_NIF_TERM values[8];
    for (int i=0; i<8; i++) {
        values[i] = enif_make_double(env, data[i]);
    }
    ERL_NIF_TERM by = enif_make_atom(env, computed_using);
    return enif_make_tuple2(env, by, enif_make_list_from_array(env, values, 8));
}

#ifdef USE_AVX
#include <immintrin.h>
ERL_NIF_TERM multiply_and_add(ErlNifEnv *env, const std::vector<float>& a, const std::vector<float>& b, const std::vector<float>& c) {
    __m256 d = _mm256_fmadd_ps(_mm256_load_ps(a.data()), _mm256_load_ps(b.data()), _mm256_load_ps(c.data()));
    return make_f32x8(env, (float *)&d, "avx256");
}
#else
ERL_NIF_TERM multiply_and_add(ErlNifEnv *env, const std::vector<float>& a, const std::vector<float>& b, const std::vector<float>& c) {  
    float d[8] = {0};
    for (int i=0; i<8; i++) {
        d[i] = a[i] * b[i];
        d[i] = d[i] + c[i];
    }
    return make_f32x8(env, (float *)d, "for_loop");
}
#endif

#endif  // OPTIMALIZATION_H
