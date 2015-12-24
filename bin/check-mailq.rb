#!/usr/bin/env ruby
#
#   check-mailq
#
# DESCRIPTION:
#   Check the size of the Postfix mail queue
#
# OUTPUT:
#   Plain text
#
# PLATFORMS:
#   Linux; any platform with Postfix and egrep
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   ./check-mailq.rb [-p path_to_mailq] [-q queue] -w warn -c crit
#   ./check-mailq.rb -w 200 -c 400
#   ./check-mailq.rb -q deferred -w 100 -c 200
#   ./check-mailq.rb -p /usr/local/bin/mailq -q active -w 50 -c 100
#
# NOTES:
#   This is split out into its own check because, unlike `check-mailq`, it
#   requires storing details about every message in the queue in memory, which
#   may not be desirable on heavily-trafficked systems.
#
# LICENSE:
#   Justin Lambert <jlambert@letsevenup.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

class PostfixMailq < Sensu::Plugin::Check::CLI
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

  option :warning,
         short: '-w WARN_NUM',
         long: '--warnnum WARN_NUM',
         description: 'Number of messages in the queue considered to be a warning',
         required: true

  option :critical,
         short: '-c CRIT_NUM',
         long: '--critnum CRIT_NUM',
         description: 'Number of messages in the queue considered to be critical',
         required: true

  def run
    num_messages = send("check_queue_size_#{config[:queue]}")
    msg = "#{num_messages} messages in the postfix #{config[:queue] == 'all' ? 'mail' : config[:queue]} queue"

    if num_messages >= config[:critical].to_i
      critical msg
    elsif num_messages >= config[:warning].to_i
      warning msg
    else
      ok msg
    end
  end

  #
  # Return the number of messages in all the queues.
  #
  # `mailq` will either end with a summary line (-- 11 Kbytes in 31 Requests.)
  # or 'Mail queue is empty'.  Using grep rather than returning the entire
  # list since that could consume a significant amount of memory.
  #
  def check_queue_size_all
    queue = `#{config[:path]} | /bin/egrep '[0-9]+ Kbytes in [0-9]+ Request\|Mail queue is empty'`
    queue == 'Mail queue is empty' ? 0 : queue.split(' ')[4].to_i
  end

  #
  # Items in the active queue appear with a '*' next to the QID in `mailq`
  #
  def check_queue_size_active
    `#{config[:path]} | /bin/egrep -c '^[0-9A-F]+\\*'`.to_i
  end

  #
  # Items in the deferred queue do not have a special indicator in `mailq`,
  # but are followed by lines with deferral reasons in ()s.
  #
  def check_queue_size_deferred
    `#{config[:path]} | /bin/grep -c '^ *(.*)$'`.to_i
  end

  #
  # Items in the hold queue appear with a '!' next to the QID in `mailq`.
  #
  def check_queue_size_hold
    `#{config[:path]} | /bin/egrep -c '^[0-9A-F]+!'`.to_i
  end

  #
  # Items in the incoming queue have no special character indicating as much in
  # `mailq`. Inspecting `/var/spool/postfix` directly requires root or postfix
  # user permissions, so let's try to be crafty and subtract the number of
  # deferred messages from the total number of messages with no special
  # character appended to their QID.
  #
  def check_queue_size_incoming
    `#{config[:path]} | /bin/egrep -c '^[0-9A-F]+ +'`.to_i - check_queue_size_deferred
  end
end
