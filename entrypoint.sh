#!/bin/sh

set -e

check_input() {
  if [ -z "$1" ]; then
    echo "${1} is not set, exiting."
    exit 1
  fi
}

check_input $CONFIG_ACCESS_KEY_ID
check_input $CONFIG_SECRET_ACCESS_KEY
check_input $CONFIG_AWS_REGION
check_input $S3_BUCKET

# Create a dedicated profile for to avoid conflicts with other actions
NAMED_PROFILE = "sync-s3-cloudfront"

aws configure --profile $NAMED_PROFILE <<-EOF > /dev/null 2>&1
${CONFIG_ACCESS_KEY_ID}
${CONFIG_SECRET_ACCESS_KEY}
${CONFIG_AWS_REGION}
text
EOF

# Sync using the dedicated profile, defaults source dir to the root
# All other flags are optional and passed via the `args:` directive
aws s3 sync "${S3_SOURCE_DIR:-.}" \
  "s3://${S3_BUCKET}/${S3_DEST_DIR}" \
  --profile $NAMED_PROFILE

# Start invalidating if CloudFront distribution and paths are found
if [ -n "$CF_DISTRIBUTION_ID" ] && [ -n "$CF_PATHS" ]; then
  # Handle multiple space-separated args but quote each arg to avoid
  # globbing of args containing wildcards. i.e., if PATHS="/* /foo"
  IFS=', ' read -r -a PATHS_ARR <<< "$CF_PATHS"

  aws cloudfront create-invalidation \
    --profile $NAMED_PROFILE \
    --distribution-id "$CF_DISTRIBUTION_ID" \
    --paths "${PATHS_ARR[@]}" $*
fi

# Clear out the credentials by passing bogus input to `aws configure`
# Avoid deleting ~/.aws to preserve existing credentials
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile $NAMED_PROFILE <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
