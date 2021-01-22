# `sync-s3-cloudfront`

Just another take at static website deployment with `aws-cli`, among plethora of [similar actions](https://github.com/marketplace?type=actions&query=s3).

I prefer to avoid dependencies to other actions as much as possible and a fairly restricted amount of options is enough for my personal needs.

A [properly configured](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html) S3 bucket is required prior to running this action. Same goes for the CloudFront distribution.

## Inputs

| Key                                | Value   | Required |
| ---------------------------------- | ------- | -------- |
| `CONFIG_ACCESS_KEY_ID`             | Content | yes      |
| `CONFIG_SECRET_ACCESS_KEY`         | Content | yes      |
| `CONFIG_AWS_REGION`                | Content | yes      |
| `S3_BUCKET`                        | Content | yes      |
| `S3_SOURCE_DIR`                    | Content | no       |
| `S3_DEST_DIR`                      | Content | no       |
| `CF_DISTRIBUTION_ID` <sup>\*</sup> | Content | no       |
| `CF_PATHS` <sup>\*</sup>           | Content | no       |

<sup>\*</sup> Both parameters should be present in order to run the invalidation.

Additional [args](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html#options) can be passed to the sync step.

## Example usage

- https://github.com/jakejarvis/s3-sync-action/
- https://github.com/chetan/invalidate-cloudfront-action/
- https://github.com/kersvers/s3-sync-with-cloudfront-invalidation/
