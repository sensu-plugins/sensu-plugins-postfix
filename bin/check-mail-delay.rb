#!/usr/bin/env ruby
#
#   check-mail-delay
#
# DESCRIPTION:
#   Check for mail delays in the Postfix mail queue
#
# OUTPUT:
#   Plain text
#
# PLATFORMS:
#   Linux; any platform with Postfix, egrep, and awk
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   ./check-mail-delay.rb [-p path_to_mailq] [-q queue] [-d delay] -w warn -c crit
#   ./check-mail-delay.rb -w 100 -c 200
#   ./check-mail-delay.rb -q hold -w 50 -c 100
#   ./check-mail-delay.rb -q deferred -d 7200 -w 10 -c 20
#   ./check-mail-delay.rb -p /usr/local/bin/mailq -q active -d 300 -w 100 -c 200
#
# NOTES:
#   This is split out into its own check because, unlike `check-mailq`, it
#   requires storing details about every message in the queue in memory, which
#   may not be desirable on heavily-trafficked systems.
#
# LICENSE:
#   Jonathan Hartman <j@hartman.io>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'date'
require 'sensu-plugin/check/cli'

class PostfixMailDelay < Sensu::Plugin::Check::CLI
  option :path,
         short: '-p MAILQ_PATH',
         long: '--path MAILQ_PATH',
         description: 'Path to the postfix mailq binary.  Defaults to /usr/bin/mailq',
         default: '/usr/bin/mailq'

  option :queue,
         short: '-q QUEUE_NAME',
         long: '--queue QUEUE_NAME',
         description: 'The queue to check (active, deferred, hold, ' \
                      "incoming, or all). Defaults to 'all'",
         default: 'all'

  option :delay,
         short: '-d DELAY_IN_SECONDS',
         long: '--delay DELAY_IN_SECONDS',
         description: 'Age in seconds of messages to look for',
         default: 3600

  option :warning,
         short: '-w WARN_NUM',
         long: '--warnnum WARN_NUM',
         description: 'Number of delayed messages considered a worth a warning',
         required: true

  option :critical,
         short: '-c CRIT_NUM',
         long: '--critnum CRIT_NUM',
         description: 'Number of delayed messages considered to be critical',
         required: true

  def run
    count = 0
    timestamps = send("queue_data_#{config[:queue]}")
    timestamps.each do |t|
      count += 1 if check_age_of(t) > config[:delay].to_i
    end

    msg = "#{count} messages in the postfix " \
          "#{config[:queue] == 'all' ? 'mail' : config[:queue]} queue older " \
          "than #{config[:delay]} seconds"

    if count >= config[:critical].to_i
      critical msg
    elsif count >= config[:warning].to_i
      warning msg
    else
      ok msg
    end
  end

  #
  # Parse a timestamp from the output of `mailq` and return that message's
  # age in seconds. The `mailq` command does not insert years in its output,
  # so we're going to make the (hopefully valid) assumption that there won't
  # be any queue items older than a year and just subtract one year if a queue
  # item appears to be from the future.
  #
  def check_age_of(timestamp)
    d = DateTime.parse("#{timestamp} #{DateTime.now.zone}")
    now = DateTime.now
    d = d.prev_year if d > now
    (now.to_time - d.to_time).to_i
  end

  #
  # Return an array of timestamps for every message in the queue.
  #
  # `mailq` will either end with a summary line (-- 11 Kbytes in 31 Requests.)
  # or 'Mail queue is empty'.  Using grep rather than returning the entire
  # list since that could consume a significant amount of memory.
  #
  def queue_data_all
    queue = `#{config[:path]} | /bin/egrep '^[0-9A-F]+' | awk '{print $3, $4, $5, $6}'`
    queue.split("\n")
  end

  #
  # Return an array of timestamps for messages in the active queue.
  #
  # Items in the active queue appear with a '*' next to the QID in `mailq`
  #
  def queue_data_active
    queue = `#{config[:path]} | /bin/egrep '^[0-9A-F]+\\*' | awk '{print $3, $4, $5, $6}'`
    queue.split("\n")
  end

  #
  # Return an array of timestamps for messages in the deferred queue.
  #
  # Items in the deferred queue do not have a special indicator in `mailq`,
  # but are followed by lines with deferral reasons in ()s.
  #
  def queue_data_deferred
    output = `#{config[:path]} | /bin/egrep -A 1 '^[0-9A-F]+ +'`.split("\n--\n")
    queue = []
    output.each do |o|
      if o.lines[1].strip.match(/^\(.*\)$/)
        fields = o.lines[0].split
        queue << "#{fields[2]} #{fields[3]} #{fields[4]} #{fields[5]}"
      end
    end
    queue
  end

  #
  # Return an array of timestamps for messages in the hold queue.
  #
  # Items in the hold queue appear with a '!' next to the QID in `mailq`.
  #
  def queue_data_hold
    queue = `#{config[:path]} | /bin/egrep '^[0-9A-F]+!' | awk '{print $3, $4, $5, $6}'`
    queue.split("\n")
  end

  #
  # Return an array of timestamps for messages in the incoming queue.
  #
  # Items in the incoming queue have no special character indicating as much in
  # `mailq`. Inspecting `/var/spool/postfix` directly requires root or postfix
  # user permissions, so we have to get a little tricky here and find any queue
  # item with no special character and that's not followed by a deferal line.
  #
  def queue_data_incoming
    output = `#{config[:path]} | /bin/egrep -A 1 '^[0-9A-F]+ +'`.split("\n--\n")
    queue = []
    output.each do |o|
      unless o.lines[1].strip.match(/^\(.*\)$/)
        fields = o.lines[0].split
        queue << "#{fields[2]} #{fields[3]} #{fields[4]} #{fields[5]}"
      end
    end
    queue
  end
end
