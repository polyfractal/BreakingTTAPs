# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_0 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_0 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_0 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_0 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_0 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_1 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_1 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_1 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_1 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_1 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_2 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_2 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_2 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_2 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_2 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_0.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_3 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_3 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_3 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_3 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_3 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_4 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_4 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_4 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_4 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_4 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_5 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_5 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_5 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_5 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_5 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_6 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_6 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_6 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_6 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_6 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.lsu_fu_1.sram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_7 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_7 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_7 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_7 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_7 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_8 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_8 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_8 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_8 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_8 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_9 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_9 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_9 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_9 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_9 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_10 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_10 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_10 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_10 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_10 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_11 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_11 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_11 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_11 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_11 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_12 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_12 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_12 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_12 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_12 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_13 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_13 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_13 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_13 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_13 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_14 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_14 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_14 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_14 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_14 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_0.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_15 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_15 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_15 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_15 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_15 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_16 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_16 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_16 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_16 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_16 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_17 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_17 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_17 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_17 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_17 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_18 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_18 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_18 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_18 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_18 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_0.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_19 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_19 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_19 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_19 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_19 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_0 \
    -name sram_macro_20 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_20 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_20 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_20 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_20 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_1 \
    -name sram_macro_21 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_21 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_21 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_21 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_21 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_2 \
    -name sram_macro_22 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_22 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_22 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_22 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_22 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 (Orientation: N)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.boot_imem_sub_0.imem_0.iram_1024x32_1.iram_512x32_1.gf180mcu_fd_ip_sram__sram512x8m8wm1_3 \
    -name sram_macro_23 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_23 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_23 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_23 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_23 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7

# Generated for: i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.stack_ram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_0
# Generated for: i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.sram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_0 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.stack_ram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_0 \
    -name sram_macro_24 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_24 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_24 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_24 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_24 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.sram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_1 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.stack_ram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_1 \
    -name sram_macro_25 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_25 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_25 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_25 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_25 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.sram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_2 (Orientation: S)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.stack_ram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_2 \
    -name sram_macro_26 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_26 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_26 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_26 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_26 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
# Generated for: i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.sram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_3 (Orientation: FS)
define_pdn_grid \
    -macro \
    -instances i_chip_core.chip_top_inst.tta_0.stack_lsu_fu_0.stack_ram_256x32_0.gf180mcu_fd_ip_sram__sram256x8m8wm1_3 \
    -name sram_macro_27 \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macro_27 \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macro_27 \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid sram_macro_27 \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 426.86 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid sram_macro_27 \
    -layer Metal4 \
    -width 4.00 \
    -offset 65.93 \
    -spacing 0.28 \
    -pitch 50 \
    -starts_with GROUND \
    -number_of_straps 7
