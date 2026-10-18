# Joystick Tester (JOYTEST) - build
#
#   make          builds JOYTEST.TOS (French) and JOYTSTEN.TOS (English) into build/
#   make check    verifies both programs against the expected checksums
#   make vasm     builds the vasm assembler into .tools/ (done automatically)

VASM   ?= $(shell command -v vasmm68k_mot 2>/dev/null || echo .tools/vasm/vasmm68k_mot)
B      := build
VFLAGS := -quiet -m68000
PY     ?= python3

.PHONY: all check vasm clean
all: $(B)/JOYTEST.TOS $(B)/JOYTSTEN.TOS

$(VASM):
	sh scripts/get-vasm.sh .tools

vasm: $(VASM)

$(B):
	mkdir -p $(B)

$(B)/JOYTEST.TOS: src/joytest.s | $(B) $(VASM)
	$(VASM) $(VFLAGS) -Ftos -o $@ $<

$(B)/JOYTSTEN.TOS: src/joytest.s | $(B) $(VASM)
	$(VASM) $(VFLAGS) -Ftos -DENGLISH -o $@ $<

# Expected MD5 (README.md, README_FR.md); update them when the program changes on purpose
check: all
	@$(PY) -c "import hashlib,sys; \
exp={'$(B)/JOYTEST.TOS':'409a6a20a58231d018e19241b7feac34','$(B)/JOYTSTEN.TOS':'324808fc4ba48e3561794939379ea1ce'}; \
bad=[f for f,h in exp.items() if hashlib.md5(open(f,'rb').read()).hexdigest()!=h]; \
print('OK' if not bad else 'MISMATCH: '+' '.join(bad)); sys.exit(1 if bad else 0)"

clean:
	rm -rf $(B)
