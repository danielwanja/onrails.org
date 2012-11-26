#!/usr/bin/env ruby

# daemon to scrape response times from rails logs

require 'rubygems'
require 'file/tail'
require 'mongrel'
require 'yaml'

RAILS_ENV = ENV['RAILS_ENV'] || "production"
PORT = ENV['PORT'] || "8888"
IGNORE_PATTERNS = %r{heartbeat}.freeze

class Accumulator
  def initialize
    @values = Array.new()
    @max = 0
  end

  def add( n )
    @values << n
    @max = n if n > @max
  end

  def average(read_only=false)
    return_value = if @values.length == 0
      nil
    else
      @values.inject(0) {|sum,value| sum + value } / @values.length
    end
    @values = Array.new() unless read_only
    
    return_value
  end
  
  def max(read_only=false)
    return_value = @max
    @max = 0 unless read_only
    return_value
  end
  
  def count
    @values.length
  end
  alias_method :length, :count
  alias_method :size, :count
end

LOGFILE = File.join(File.dirname(__FILE__), '..', '..', 'log', "#{RAILS_ENV}.log")
$response_data = { :total     => Accumulator.new(),
                   :rendering => Accumulator.new(),
                   :db        => Accumulator.new() }

Thread.abort_on_exception = true
logtail = Thread.new do
  File::Tail::Logfile.tail(LOGFILE) do |line|
    if line =~ /^Completed in /
      parts = line.split(/\s+\|\s+/)
      resp = parts.pop
      requested_url = resp[/http:\/\/[^\]]*/]
      next if requested_url =~ IGNORE_PATTERNS
      
      parts.each do |part|
        part.gsub!(/Completed in/, "total")
        type, time, pct = part.split(/\s+/)
        type = type.gsub(/:/,'').downcase.to_sym
        
        $response_data[type].add(time.to_f)
      end
    end
  end
end

class ResponseTimeHandler < Mongrel::HttpHandler
  def initialize(method)
    @method = method
  end
  
  def process(request, response)
    response.start(200) do |head,out|
      debug = Mongrel::HttpRequest.query_parse(request.params["QUERY_STRING"]).has_key? "debug"
      head["Content-Type"] = "text/plain"
      output = $response_data.map do |k,v|
        value = v.send(@method, debug)
        formatted = value.nil? ? 'U' : sprintf('%.5f', value)
        
        "#{k}.value #{formatted}"
      end.join("\n")
      output << "\n"
      out.write output
    end
  end
end

h = Mongrel::HttpServer.new("127.0.0.1", PORT)
h.register("/avg_response_time", ResponseTimeHandler.new(:average))
h.register("/max_response_time", ResponseTimeHandler.new(:max))
h.run.join
