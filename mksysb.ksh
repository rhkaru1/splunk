#!/usr/bin/ksh

# This script creates a mksysb backup, names the backup file and directory with the LPAR name and date, and retains only the two most recent backups.

# Define variables
LPAR_NAME=$(lparstat -i | grep "Partition Name" | awk '{print $NF}')
DATE_STAMP=$(date +%Y%m%d)
BACKUP_ROOT="/mksysb_backups"
BACKUP_DIR="${BACKUP_ROOT}/${LPAR_NAME}"
BACKUP_FILE="${LPAR_NAME}_${DATE_STAMP}.mksysb"
LOG_FILE="/var/log/mksysb_script.log"
RETAIN_COUNT=2

# Define the NFS mount specifics
NFS_SERVER="gfnas01"
NFS_REMOTE_DIR="/mksysbs"

# Check if LPAR_NAME was successfully retrieved
if [ -z "${LPAR_NAME}" ]; then
  echo "Error: Could not retrieve LPAR name. Exiting." | tee -a "${LOG_FILE}"
  exit 1
fi

# Function to check and mount the NFS directory
check_and_mount() {
  echo "Checking if ${BACKUP_ROOT} is mounted..." | tee -a "${LOG_FILE}"
  # Check if the mount point is active and is an nfs type
  if mount | grep -q "${NFS_SERVER}:${NFS_REMOTE_DIR} on ${BACKUP_ROOT}"; then
    echo "${BACKUP_ROOT} is already mounted." | tee -a "${LOG_FILE}"
  else
    echo "${BACKUP_ROOT} is not mounted. Attempting to mount..." | tee -a "${LOG_FILE}"
    # Attempt to mount the NFS share
    mount "${NFS_SERVER}:${NFS_REMOTE_DIR}" "${BACKUP_ROOT}"
    if [ $? -eq 0 ]; then
      echo "Successfully mounted ${NFS_SERVER}:${NFS_REMOTE_DIR} to ${BACKUP_ROOT}." | tee -a "${LOG_FILE}"
    else
      echo "Failed to mount ${NFS_SERVER}:${NFS_REMOTE_DIR}. Exiting." | tee -a "${LOG_FILE}"
      exit 1
    fi
  fi
}

# Run the check and mount function before proceeding
check_and_mount

# Create the LPAR-specific backup directory if it doesn't exist.
if [ ! -d "${BACKUP_DIR}" ]; then
  echo "Creating LPAR-specific backup directory: ${BACKUP_DIR}" | tee -a "${LOG_FILE}"
  mkdir -p "${BACKUP_DIR}"
fi

# Create the mksysb backup
echo "Starting mksysb backup for LPAR: ${LPAR_NAME} at $(date)" | tee -a "${LOG_FILE}"
mksysb -i "${BACKUP_DIR}/${BACKUP_FILE}"
if [ $? -eq 0 ]; then
  echo "mksysb backup completed successfully: ${BACKUP_DIR}/${BACKUP_FILE}" | tee -a "${LOG_FILE}"
else
  echo "mksysb backup failed for LPAR: ${LPAR_NAME} at $(date)" | tee -a "${LOG_FILE}"
  exit 1
fi

# Clean up old backups, keeping only the two most recent
echo "Cleaning up old backups..." | tee -a "${LOG_FILE}"
# The '-t' option sorts by modification time, newest first. 'tail -n +3' starts from the third line, effectively selecting all but the top two.
ls -t "${BACKUP_DIR}"/*.mksysb | tail -n +$((RETAIN_COUNT + 1)) | xargs rm --
echo "Cleanup complete. Retaining the ${RETAIN_COUNT} most recent backups." | tee -a "${LOG_FILE}"

echo "Script finished at $(date)" | tee -a "${LOG_FILE}"
