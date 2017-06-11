ifndef TARGET_DIR
$(error Must specify TARGET_DIR)
endif

PROFILE ?= debug

ifeq (${PROFILE}, debug)
AS_FLAGS := -g
endif

OBJ_DIR=${TARGET_DIR}/${PROFILE}/native
OUTPUT_DIR=${TARGET_DIR}/${PROFILE}

.PHONY: all
all: ${OUTPUT_DIR}/kernel.bin


export PATH:=${PATH}:${TARGET_DIR}/binutils/bin

${OUTPUT_DIR}/kernel.bin: $(addprefix ${OBJ_DIR}/,$(patsubst %.S,%.o,$(shell find -iname '*.S' | sed -e s_^\\./__))) ${TARGET_DIR}/${PROFILE}/libeos.a
	x86_64-elf-ld \
		--nmagic \
		--gc-sections \
		-o ${OUTPUT_DIR}/kernel.bin \
		-T eos.ld \
		$^ \
		${TARGET_DIR}/${PROFILE}/libeos.a

${OBJ_DIR}/%.o: %.S | ${OBJ_DIR}
	x86_64-elf-as ${AS_FLAGS} $< -o "$@"

${OBJ_DIR}:
	cd ${TARGET_DIR}/${PROFILE} && mkdir -p native && mkdir -p native/amd64
