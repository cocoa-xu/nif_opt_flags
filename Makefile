PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_SO = $(PRIV_DIR)/nif.so

C_SRC = $(shell pwd)/c_src
LIB_SRC = $(shell pwd)/lib
CPPFLAGS += -shared -std=c++11 -O3 -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -fPIC
CPPFLAGS += -I$(ERTS_INCLUDE_DIR)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	CPPFLAGS += -undefined dynamic_lookup -flat_namespace -undefined suppress
endif

.DEFAULT_GLOBAL := build

# this is where we are interested in
# pretend that this is a 3rd party library compilation flag
# we can only switch it on or off
# and that 3rd party library does not support 
# auto-detecting whether the CPU and/or the compiler supports AVX or not
3RD_PARTY_FLAGS = -D USE_AVX -march=native -mavx

# what we want to achieve here:
# conditionally turn on that compilation flag if we know we are compiling for an x86_64 target
# (although not every x86_64 CPU supports the AVX instruction set, let's pretend it does)
#
# there can be a few ways to do so:
#
# 1). set `TARGET_{ARCH,OS,ABI}`.
# ifeq ($(TARGET_ARCH),x86_64)
#   3RD_PARTY_FLAGS =
# endif
#
# 2). set `MIX_TARGET` to the target triplet.
# ifeq (,$(findstring x86_64,$(MIX_TARGET)))
#   3RD_PARTY_FLAGS =
# endif
#
# 3). let the specific precompiler decide
# ifeq (,$(findstring x86_64,$(CC_PRECOMPILER_CURRENT_TARGET)))
#   3RD_PARTY_FLAGS =
# endif
#
# 
# The third one might be the best approach because 
#   a) the name of the indicator, `CC_PRECOMPILER_CURRENT_TARGET` here, 
#      is uniquely set by the `cc_precompiler`,
#   b) since the library author(s) will explicitly choose the precompiler
#      for their library, they would know which environment variable to check and
#      what values to expect

ifeq (,$(findstring x86_64,$(CC_PRECOMPILER_CURRENT_TARGET)))
	3RD_PARTY_FLAGS =
endif

build: $(NIF_SO)
	@ echo > /dev/null

$(NIF_SO):
	@ mkdir -p $(PRIV_DIR)
	$(CC) $(CPPFLAGS) $(3RD_PARTY_FLAGS) $(C_SRC)/nif.cpp  -o $(NIF_SO)
