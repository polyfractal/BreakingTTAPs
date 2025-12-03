MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PDK_ROOT ?= $(MAKEFILE_DIR)/../../gf180mcu
PDK ?= gf180mcuD

all: logo drc
.PHONY: all

logo:
	python3 script/make_gds.py image/bt_tap.png gds/gf180mcu_bt_ip__tap.gds --cellname gf180mcu_bt_ip__tap --invert --merge --pixel-size 0.75 --scale 0.07 --foreground "81/0" --boundary "0/0" "152/5"
.PHONY: logo

drc:
	PDK_ROOT=${PDK_ROOT} PDK=${PDK} klayout -b -zz -r ${PDK_ROOT}/${PDK}/libs.tech/klayout/tech/drc/gf180mcu.drc -rd input=gds/gf180mcu_bt_ip__tap.gds -rd report=report.xml -rd feol=false -rd beol=true
.PHONY: drc
