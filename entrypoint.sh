#!/bin/sh

set -e

if [ -z "$CONFIG_ACCESS_KEY_ID" ]; then
  echo "CONFIG_ACCESS_KEY_ID is not set"
  exit 1
fi

if [ -z "$CONFIG_SECRET_ACCESS_KEY" ]; then
  echo "CONFIG_SECRET_ACCESS_KEY is not set"
  exit 1
fi

# Default to us-east-1 if region not set
if [ -z "$CONFIG_AWS_REGION" ]; then
  CONFIG_AWS_REGION="us-east-1"
fi

if [ -z "$S3_BUCKET" ]; then
  echo "S3_BUCKET is not set"
  exit 1
fi

# Create a dedicated profile for this action
# to avoid conflicts with other actions
aws configure --profile sync-s3-cloudfront <<-EOF > /dev/null 2>&1
${CONFIG_ACCESS_KEY_ID}
${CONFIG_SECRET_ACCESS_KEY}
${CONFIG_AWS_REGION}
text
EOF

# Sync using our dedicated profile
# All other flags are optional via the `args:` directive
sh -c "aws s3 sync ${S3_SOURCE_DIR:-.} s3://${S3_BUCKET}/${S3_DEST_DIR} \
  --profile sync-s3-cloudfront"

if [ -n "$CF_DISTRIBUTION_ID" ] && [ -n "$CF_PATHS" ]; then
  # Handle multiple space-separated args but still quote each arg to avoid any
  # globbing of args containing wildcards. i.e., if PATHS="/* /foo"
  IFS=', ' read -r -a PATHS_ARR <<< "$CF_PATHS"

  # Invalidate CloudFront distribution
  sh -c "aws cloudfront create-invalidation \
    --profile sync-s3-cloudfront \
    --distribution-id "$CF_DISTRIBUTION_ID" \
    --paths "${PATHS_ARR[@]}" $*"
fi

# Clear out credentials after we're done
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile sync-s3-cloudfront <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
