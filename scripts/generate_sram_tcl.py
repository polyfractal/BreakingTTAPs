import yaml
import sys

def generate_tcl_snippets(config_file, output_file):
    # File paths for templates
    EAST_WEST_TEMPLATE = "east_west.tcl"
    NORTH_SOUTH_TEMPLATE = "north_south.tcl"

    try:
        # Load the configuration YAML
        with open(config_file, 'r') as f:
            data = yaml.safe_load(f)
        
        # Load the TCL templates
        with open(EAST_WEST_TEMPLATE, 'r') as f:
            ew_template = f.read()
            
        with open(NORTH_SOUTH_TEMPLATE, 'r') as f:
            ns_template = f.read()

    except FileNotFoundError as e:
        print(f"Error: Could not find required file: {e.filename}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        sys.exit(1)

    output_snippets = []
    macro_counter = 0
    
    # List of macro types to process
    target_macros = [
        'gf180mcu_fd_ip_sram__sram512x8m8wm1',
        'gf180mcu_fd_ip_sram__sram256x8m8wm1'
    ]
    
    macros_data = data.get('MACROS', {})
    
    for macro_type in target_macros:
        instances = macros_data.get(macro_type, {}).get('instances', {})

        if not instances:
            print(f"Info: No instances found for macro type '{macro_type}'.")
            continue
        
        # Iterate through instances and generate snippets
        for instance_name, props in instances.items():
            orientation = props.get('orientation')
            
            if not orientation:
                print(f"Warning: No orientation specified for {instance_name}, skipping.")
                continue

            # Select template based on orientation
            if orientation in ['N', 'S', 'FN', 'FS']:
                snippet = ns_template
            elif orientation in ['E', 'W', 'FE', 'FW']:
                snippet = ew_template
            else:
                print(f"Warning: Unknown orientation '{orientation}' for {instance_name}, skipping.")
                continue

            # Define Macro Name using continuous counter
            macro_name = f"sram_macro_{macro_counter}"
            macro_counter += 1

            # Perform replacements
            # We assume the template uses specific placeholders
            snippet = snippet.replace('INSTANCE_NAME', instance_name)
            snippet = snippet.replace('MACRO_NAME', macro_name)
            
            # Add a comment header for readability in the output file
            header = f"# Generated for: {instance_name} (Orientation: {orientation})\n"
            output_snippets.append(header + snippet + "\n")

    if not output_snippets:
        print("Warning: No snippets were generated from any macro paths.")

    # Write to output file
    try:
        with open(output_file, 'w') as f:
            f.writelines(output_snippets)
        print(f"Successfully generated {output_file} with {len(output_snippets)} snippets.")
    except IOError as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    # Default filenames based on prompt
    config_path = "config.yaml"
    output_path = "sram_generated.tcl"
    
    generate_tcl_snippets(config_path, output_path)