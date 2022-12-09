# NifOptFlags

Example for how to conditionally switch on/off some compilation flags for 3rd party library (or for your own code) when using `cc_precompiler`.

In the following description, we discuss a case when a 3rd party library can be compiled with/without `AVX` feature. But this idea can be generalised to any compilation flags that you want/have to maunally switch on/off based on the target.

### Example
Suppose we have the following `Makefile` (a fragment of it)

```makefile
...
3RD_PARTY_FLAGS = -D USE_AVX -march=native -mavx
...
```

There is a `3RD_PARTY_FLAGS` var in it with a default value `-D USE_AVX -march=native -mavx`, which would use the x86_64 AVX instruction set if we leave `3RD_PARTY_FLAGS` as is.

```cpp
#ifdef USE_AVX
#include <immintrin.h>
ERL_NIF_TERM multiply_and_add(ErlNifEnv *env, __m256 a, __m256 b, __m256 c) {
    __m256 aa = _mm256_load_ps(a.data());
    __m256 bb = _mm256_load_ps(b.data());
    __m256 cc = _mm256_load_ps(c.data());
    __m256 d = _mm256_fmadd_ps(aa, bb, cc);
    return make_f32x8(env, (float *)&d, "avx256");
}
#else
ERL_NIF_TERM multiply_and_add(ErlNifEnv *env, const float* a, const float* b, const float* c) {  
    float d[8] = {0};
    for (int i=0; i<8; i++) {
        d[i] = a[i] * b[i];
        d[i] = d[i] + c[i];
    }
    return make_f32x8(env, (float *)d, "for_loop");
}
#endif
```

What we want to achieve here is to conditionally turn on that compilation flag if we know we are compiling for an x86_64 target, and turn off that flag for other targets. (although not every x86_64 CPU supports the AVX instruction set, let's pretend it does)

Though we can set something env vars in `elixir_make` like 1) and 2) below

1. set `TARGET_{ARCH,OS,ABI}`.

  ```makefile
  ifeq ($(TARGET_ARCH),x86_64)
    3RD_PARTY_FLAGS =
  endif
  ```

2. set `MIX_TARGET` to the target triplet.

  ```makefile
  ifeq (,$(findstring x86_64,$(MIX_TARGET)))
    3RD_PARTY_FLAGS =
  endif
  ```

They have some limitations, and the very first limitation (as @josevalim mentioned to me), it's not an easy job to have a standardized naming scheme across the board; 

Besides that, these two approaches have another limitation: when we intentionally want to build two sets of libraries for the same target, one with AVX turned on while the other one does not use the AVX instruction set. 

(Imagine that we want to carefully control the usage of the AVX registers because we really want to leave them free for some other critical applications; one real case would be in the high-frequency trading world, where you are reserving AVX registers for the trading algorithms/packet processing function)

1. let the specific precompiler decide

  ```makefile
  ifeq (,$(findstring x86_64,$(CC_PRECOMPILER_CURRENT_TARGET)))
    3RD_PARTY_FLAGS =
  endif
  ```

So the last approach (the one shown above) might be the best because 

1. the name of the indicator, `CC_PRECOMPILER_CURRENT_TARGET` here, is uniquely set by the `cc_precompiler` (or any other precompiler). 

  So there will be no clashes unless they intended to do so.

1. since the library author(s) will explicitly choose which precompiler to use for their library, they would know which environment variable to check and what values to expect.
  
  So we no longer have to worry about the standardize thing because the values will be given by the precompiler (if they want to do this), and it's their job to tell you what values they would set.
