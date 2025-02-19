# Heroku Log S3

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/kielikone/heroku-log-s3/tree/master)

## Configure

Setup the following `ENV` (aka `heroku config:set`)

- `FILTER_PREFIX` this is the prefix string to look out for. every other log lines are ignored
- `S3_BUCKET` bucket to use
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` necessary for ACL
- `AWS_REGION` the AWS region your S3 bucket is in
- `KMS_KEY` for encrypting cloudwatch logs
- `EXPIRE_CLOUDWATCH_LOGS` (default `365`) cloudwatch log group retention in days
- `PUSH_TO_CLOUDWATCH` (default `100`) number of logs between cloudwatch log puts
- `DURATION` (default `60`) seconds to buffer until we close the `IO` to `AWS::S3::S3Object#write`
- `STRFTIME` (default `:prefix:/%Y/%m/%d/%H/%M%S.:thread_id:.log`) format of your s3 `object_id`
  - `:thread_id:` will be replaced by a unique number to prevent overwriting of the same file between reboots, in case the timestamp overlaps
  - `:prefix:` will be replaced by the prefix added to the `path` on the drain command (e.g. `heroku drains:add https://DRAIN_APP_NAME.herokuapp.com/path/to/logs -a <application-to-log>` will have a prefix of `path/to/logs`)
- `HTTP_USER`, `HTTP_PASSWORD` (default no password protection) credentials for HTTP Basic Authentication
- `WRITER_LIB` (default `./writer/s3.rb`) defines the ruby script to load `Writer` class

## Using

In your heroku app, add this drain (changing `HTTP_USER`, `HTTP_PASSWORD` and `DRAIN_APP_NAME` to appropriate values)

```
heroku drains:add https://HTTP_USER:HTTP_PASSWORD@DRAIN_APP_NAME.herokuapp.com/path/to/logs -a <application-to-log>
```

or if you have no password protection

```
heroku drains:add https://DRAIN_APP_NAME.herokuapp.com/path/to/logs -a <application-to-log>
```

# Credits

- https://github.com/rwdaigle/heroku-log-parser
- https://github.com/rwdaigle/heroku-log-store

# Alternatives

- https://logbox.io a logs drain that forwards Heroku messages for a long‑term archival to AWS S3, Glacier or CloudWatch.
- _{insert suggestions here}_
