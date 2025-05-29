#!/usr/bin/ksh

# Define the sshd_config file path
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

# Define the output CSV file
OUTPUT_CSV="sshd_allowed_users_groups.csv"

# Clear the output file or create it with headers (reversed order)
echo "User Name,Group Name" > "$OUTPUT_CSV"

# Use awk to find lines starting with "AllowGroups" and extract the group names.
grep -i "^AllowGroups" "$SSHD_CONFIG_FILE" | awk '
{
    sub(/AllowGroups[[:space:]]*/, "", $0)
    gsub(/,/, " ", $0)
    for (i=1; i<=NF; i++) {
        print $i
    }
}' | while read GROUP_NAME; do
    # Skip empty lines or comments from awk output
    if [[ -z "$GROUP_NAME" ]]; then
        continue
    fi

    echo "Processing group: $GROUP_NAME" >> /dev/stderr # For debugging/progress

    # Run lsgroup to get group members.
    lsgroup -h -a users "$GROUP_NAME" 2>/dev/null | awk -v group="$GROUP_NAME" '
    /users=/ {
        users_str = substr($0, index($0, "users=") + 6)
        sub(/^[[:space:]]+|[[:space:]]+$/, "", users_str)

        if (users_str == "") {
            # Print empty user, then group name
            print "," group
        } else {
            split(users_str, user_array, ",")
            for (i in user_array) {
                # Print user name first, then group name
                print user_array[i] "," group
            }
        }
    }' >> "$OUTPUT_CSV"

    # If lsgroup fails (e.g., group not found), add a note
    if [ $? -ne 0 ]; then
        echo "GROUP_NOT_FOUND_OR_ERROR,$GROUP_NAME" >> "$OUTPUT_CSV"
    fi

done

echo "CSV file '$OUTPUT_CSV' generated successfully."
echo "Check '$OUTPUT_CSV' for the results."
