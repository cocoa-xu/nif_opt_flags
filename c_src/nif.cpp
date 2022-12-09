#include <erl_nif.h>
#include <vector>
#include "optimalization.h"

int get_list(ErlNifEnv *env, ERL_NIF_TERM list, std::vector<float> &var) {
    unsigned int length;
    if (!enif_get_list_length(env, list, &length)) {
        return 0;
    }

    var.reserve(length);
    ERL_NIF_TERM head, tail;

    while (enif_get_list_cell(env, list, &head, &tail)) {
        double elem;
        if (!enif_get_double(env, head, &elem)) {
            return 0;
        }

        var.push_back(static_cast<float>(elem));
        list = tail;
    }
    return 1;
}

static ERL_NIF_TERM multiply_and_add_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 3) {
        return enif_make_atom(env, "expecting 3 arguments: a, b and c, each is a list that contains 8 floating-point numbers");
    }

    std::vector<float> a, b, c;
    if (get_list(env, argv[0], a) && get_list(env, argv[1], b) && get_list(env, argv[2], c)) {
        return multiply_and_add(env, a, b, c);
    }
    return enif_make_atom(env, "invalid input");
}

static int on_load(ErlNifEnv *env, void **_sth1, ERL_NIF_TERM _sth2) {
    return 0;
}

static int on_reload(ErlNifEnv *_sth0, void **_sth1, ERL_NIF_TERM _sth2) {
    return 0;
}

static int on_upgrade(ErlNifEnv *_sth0, void **_sth1, void **_sth2, ERL_NIF_TERM _sth3) {
    return 0;
}

static ErlNifFunc nif_functions[] = {
    {"multiply_and_add", 3, multiply_and_add_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
};

ERL_NIF_INIT(Elixir.NifOptFlags.Nif, nif_functions, on_load, on_reload, on_upgrade, NULL);
