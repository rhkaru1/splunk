#!/usr/bin/ksh

# --- Configuration ---
MOUNT_POINT="/home"
MAX_ATTEMPTS=3
WAIT_TIME=10
LOG_FILE="/var/log/conscience_mount_check.log"
ATTEMPT=1

# --- Function to Log Messages ---
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# --- Mount Check Loop ---
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if mount | grep -q -w "$MOUNT_POINT"; then
        log_msg "SUCCESS: $MOUNT_POINT is mounted. Starting script."
        break
    else
        log_msg "WARNING: $MOUNT_POINT not mounted (Attempt $ATTEMPT of $MAX_ATTEMPTS)."
        
        if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
            log_msg "CRITICAL: $MOUNT_POINT failed to mount after $MAX_ATTEMPTS tries. Exiting."
            exit 1
        fi
        
        sleep $WAIT_TIME
        (( ATTEMPT = ATTEMPT + 1 ))
    fi
done

# --- Main Script Logic Starts Here ---
log_msg "Script execution moving to main logic."
