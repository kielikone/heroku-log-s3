require 'aws'
require 'aws-sdk-cloudwatchlogs'
require 'logger'
require_relative './base.rb'

class Writer < WriterBase

  S3_BUCKET_OBJECTS = AWS::S3.new({
    access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
  }).buckets[ENV.fetch('S3_BUCKET')].objects

  def initialize(prefix)
    super(prefix)

    @cloudwatch = Aws::CloudWatchLogs::Client.new({})
    @lines = []
  end

  def setup_log_group
    @log_group_name = "app/#{@prefix}"
    res = @cloudwatch.describe_log_groups({ log_group_name_prefix: @log_group_name })
    unless res[:log_groups] and res[:log_groups].length > 0
      @cloudwatch.create_log_group({ log_group_name: @log_group_name, kms_key_id: ENV.fetch('KMS_KEY') })
    end
  end

  def setup_log_stream
    setup_log_group
    log_stream_name = Time.now.utc.strftime("%Y/%m/%d")
    res = @cloudwatch.describe_log_streams({ log_group_name: @log_group_name, log_stream_name_prefix: log_stream_name })
    puts res.to_json
    unless res[:log_streams] and res[:log_streams].length > 0
      @log_stream = @cloudwatch.create_log_stream({ log_group_name: @log_group_name, log_stream_name: log_stream_name })
    end
    log_stream_name
  end

  def write(line, timestamp)
    super(line, timestamp)
    @lines.push([line, timestamp])
    if @lines.length > 100
      push_to_cloudwatch
    end
  end

  def stream_to(filepath)
    @logger.info "begin #{filepath}"
    S3_BUCKET_OBJECTS[filepath].write(
      @io,
      estimated_content_length: 1 # low-ball estimate; so we can close buffer by returning nil
    )
    @logger.info "end #{filepath}"
  end

  def push_to_cloudwatch
    log_stream_name = setup_log_stream

    @logger.info "Cloudwatch to #{log_stream_name}"
    events = @lines.map { |lineTs| { timestamp: DateTime.parse(lineTs[1]).strftime('%Q'), message: lineTs[0] } }
    events = events.sort_by{|event| event[:timestamp]}
    @lines = []
    if events.length === 0
      return
    end

    begin
      @cloudwatch.put_log_events({
        log_group_name: @log_group_name,
        log_stream_name: log_stream_name,
        log_events: events,
      })
    rescue Exception => error
      @logger.error "Cloudwatch push failed #{error.message}"
    end
    @logger.info "Cloudwatch end to #{log_stream_name}"
  end

end
