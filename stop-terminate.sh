#!/bin/bash
# Ask user to choose instances by numbers
read -p "Enter the numbers of the instances you want to manage (comma-separated): " INPUT

# Convert input to array of indices
IFS=', ' read -ra SELECTED_NUMBERS <<< "$INPUT"

INSTANCE_IDS=()
for num in "${SELECTED_NUMBERS[@]}"; do
  num=$(echo "$num" | xargs)
  if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#INSTANCE_ARRAY[@]}" ]; then
    echo "Invalid selection: $num"
    exit 1
  fi
  selected="${INSTANCE_ARRAY[$((num - 1))]}"
  instance_id=$(echo "$selected" | awk '{print $1}')
  INSTANCE_IDS+=("$instance_id")
done

# Confirm action
echo "You selected instance IDs: ${INSTANCE_IDS[*]}"
echo "Choose an action:"
echo "1) Stop"
echo "2) Terminate"
read -p "Enter your choice (1 or 2): " ACTION

case "$ACTION" in
  1)
    read -p "Are you sure you want to STOP these instances? (y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
      aws ec2 stop-instances --instance-ids "${INSTANCE_IDS[@]}"
    else
      echo "Aborted."
    fi
    ;;
  2)
    read -p "Are you sure you want to TERMINATE these instances? (y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
      aws ec2 terminate-instances --instance-ids "${INSTANCE_IDS[@]}"
    else
      echo "Aborted."
    fi
    ;;
  *)
    echo "Invalid action."
    exit 1
    ;;
esac
