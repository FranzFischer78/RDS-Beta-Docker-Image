#!/bin/bash
# filepath: ini_editor.sh

CONFIG_FILE="rds_config.ini"

# Find a key across all sections and return its section
function find_section_for_key() {
    local search_key=$1
    local section=""
    local current_section=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ ^\[([^\]]+)\] ]]; then
            current_section=${BASH_REMATCH[1]}
        elif [[ $line =~ ^[[:space:]]*$search_key[[:space:]]*= ]]; then
            section=$current_section
            break
        fi
    done < "$CONFIG_FILE"
    
    echo "$section"
}

# Get value of a key without knowing its section
function get_value_by_key() {
    local search_key=$1
    local value=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ ^[[:space:]]*$search_key[[:space:]]*=(.*)$ ]]; then
            value="${BASH_REMATCH[1]}"
            value="${value#"${value%%[![:space:]]*}"}" # Trim leading spaces
            break
        fi
    done < "$CONFIG_FILE"
    
    echo "$value"
}

# Get value of a key in a specific section
function get_value() {
    local section=$1
    local key=$2
    
    value=$(sed -n "/^\[$section\]/,/^\[/p" "$CONFIG_FILE" | grep "^[ \t]*$key[ \t]*=" | cut -d "=" -f2- | sed 's/^[ \t]*//')
    echo "$value"
}

# Update a key's value directly without specifying section
function update_key() {
    local key=$1
    local value=$2
    
    local section=$(find_section_for_key "$key")
    if [ -z "$section" ]; then
        return 1
    fi
    
    update_value "$section" "$key" "$value"
    return $?
}

# Update a key's value in a specific section
function update_value() {
    local section=$1
    local key=$2
    local value=$3
    
    temp_file=$(mktemp)
    local in_section=0
    local key_found=0
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ ^\[$section\] ]]; then
            in_section=1
        elif [[ $line =~ ^\[ && $in_section -eq 1 ]]; then
            in_section=0
        fi
        
        if [[ $in_section -eq 1 && $line =~ ^[[:space:]]*$key[[:space:]]*= ]]; then
            echo "$key = $value" >> "$temp_file"
            key_found=1
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$CONFIG_FILE"
    
    mv "$temp_file" "$CONFIG_FILE"
    
    return $((1 - key_found))
}

# Set config file path if provided as parameter
function set_config_file() {
    local file_path=$1
    if [ -f "$file_path" ]; then
        CONFIG_FILE="$file_path"
        return 0
    else
        return 1
    fi
}

# Direct usage handler
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$1" == "--file" ] && [ -n "$2" ]; then
        set_config_file "$2"
        shift 2
    fi

    if [ "$#" -eq 2 ]; then
        update_key "$1" "$2"
        exit $?
    elif [ "$#" -eq 3 ]; then
        update_value "$1" "$2" "$3"
        exit $?
    else
        echo "Usage:"
        echo "  $0 [--file path_to_config] key value"
        echo "  $0 [--file path_to_config] section key value"
        exit 1
    fi
fi