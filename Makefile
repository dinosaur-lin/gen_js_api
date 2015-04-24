# The package gen_js_api is released under the terms of an MIT-like license.
# See the attached LICENSE file.
# Copyright 2015 by LexiFi.

VERSION=0.1
# Don't forget to change META file as well

include $(shell ocamlc -where)/Makefile.config

.PHONY: all tests test test_jquery clean


OCAMLFLAGS = -w +A-4-41-45 -warn-error +8
OCAMLC = ocamlc $(OCAMLFLAGS)

JSOO_PATH = ~/js_of_ocaml
JSOO = $(JSOO_PATH)/compiler/js_of_ocaml --pretty --noruntime $(JSOO_PATH)/runtime/runtime.js

all:
	$(OCAMLC) -c ojs.mli ojs.ml
	$(OCAMLC) -a -o gen_js_api.cma ojs.cmo
	$(OCAMLC) -I +compiler-libs -o gen_js_api$(EXE) ocamlcommon.cma gen_js_api.mli gen_js_api.ml

tests: all test test_jquery

test:
	./gen_js_api$(EXE) examples/test_js.mli
	$(OCAMLC) -c -I examples examples/test_js.mli examples/test_js.ml
	$(OCAMLC) -c -I examples -ppx "./gen_js_api$(EXE) -ppx" examples/main.ml
	$(OCAMLC) -no-check-prims -o examples/main$(EXE) gen_js_api.cma examples/test_js.cmo examples/main.cmo
	$(JSOO) -o examples/main.js ojs_runtime.js examples/main$(EXE)

test_jquery:
	./gen_js_api$(EXE) examples/jquery.mli
	$(OCAMLC) -c -I examples examples/jquery.mli examples/jquery.ml
	$(OCAMLC) -c -I examples -ppx "./gen_js_api$(EXE) -ppx" examples/test_jquery.ml
	$(OCAMLC) -no-check-prims -o examples/test_jquery$(EXE) gen_js_api.cma examples/jquery.cmo examples/test_jquery.cmo
	$(JSOO) -o examples/test_jquery.js ojs_runtime.js examples/test_jquery$(EXE)

clean:
	rm -f *~ gen_js_api$(EXE) *.cm* .*~
	cd examples && rm -f *~ main$(EXE) test_jquery$(EXE) *.cm* main.js test_js.ml test_jquery.js jquery.ml


INSTALL=META gen_js_api$(EXE) gen_js_api.cma ojs.cmi ojs_runtime.js

install:
	ocamlfind install gen_js_api $(INSTALL)

uninstall:
	ocamlfind remove gen_js_api
