require "colorize"

COLORS = {
  "debug" => :cyan,
  "log" => :white,
  "warning" => :yellow,
  "error" => :red
}

CASES = [error, debug, log, warning]
class Logger

  {% for log_case in CASES %}
    def self.{{log_case}}(message)
      {% begin %}
        time = self.fetch_time().colorize(:white)
        log_case_str = {{log_case.stringify}}.colorize(Colorize::Color256.new(208))
        message = message.colorize(COLORS[{{log_case.stringify}}]).mode(:bold)
        puts "#{time} #{log_case_str}: #{message}"
      {%end%}
    end
  {% end %}

  def self.fetch_time()
    Time.utc_now.to_s("[%d/%m/%Y][%H:%M:%S]")
  end
end
