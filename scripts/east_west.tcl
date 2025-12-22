define_pdn_grid \
    -macro \
    -instances INSTANCE_NAME \
    -name MACRO_NAME \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid MACRO_NAME \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid MACRO_NAME \
    -layers "$::env(PDN_VERTICAL_LAYER) Metal3"

# Add stripes on W/E edges of SRAM
add_pdn_stripe \
    -grid MACRO_NAME \
    -layer Metal4 \
    -width 2.36 \
    -offset 1.18 \
    -spacing 0.28 \
    -pitch 479.88 \
    -starts_with GROUND \
    -number_of_straps 2

# Since the above stripes block the top level PDN at Metal4, add some more stripes
# to improve the PDN's integrity and ensure a better connection for the macro.
add_pdn_stripe \
    -grid MACRO_NAME \
    -layer Metal4 \
    -width 4.00 \
    -offset 46.48 \
    -spacing 0.28 \
    -pitch 48.48 \
    -starts_with GROUND \
    -number_of_straps 9