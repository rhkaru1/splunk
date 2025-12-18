#!/usr/bin/ksh

# Configuration
MOUNT_POINT="/home"
MAX_ATTEMPTS=3
ATTEMPT=1
SLEEP_TIME=10

echo "Starting mount check for $MOUNT_POINT..."

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    # Check AIX mount table for exact match
    if mount | grep -w "$MOUNT_POINT" > /dev/null 2>&1; then
        echo "Attempt $ATTEMPT: $MOUNT_POINT is mounted. Waiting $SLEEP_TIME seconds..."
        sleep $SLEEP_TIME
        
        # Break the loop and proceed with the rest of your script
        break
    else
        echo "Attempt $ATTEMPT: $MOUNT_POINT is NOT mounted."
        
        # If we haven't reached max attempts, wait before trying again
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "Retrying in 5 seconds..."
            sleep 5
        else
            echo "CRITICAL: $MOUNT_POINT failed to mount after $MAX_ATTEMPTS attempts. Exiting."
            exit 1
        fi
    fi
    
    (( ATTEMPT = ATTEMPT + 1 ))
done

# --- Your conscience script starts here ---
echo "Proceeding with script operations..."
