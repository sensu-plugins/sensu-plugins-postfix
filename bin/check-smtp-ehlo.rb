#!/usr/bin/env ruby
#
#   check-smtp-ehlo
#
# DESCRIPTION:
#   Plugin that sends EHLO to SMTP server.
#   If the response is 250 = SUCCESS otherwise CRITICAL
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   check-smtp-ehlo.rb --help
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 Magic Online,  www.magic.fr - <hanynowsky@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#


require 'sensu-plugin/check/cli'
require 'net/smtp'

#
# Check SMTP EHLO
#
class CheckSMTPEHLO < Sensu::Plugin::Check::CLI
  option(
    :hostname,
    description: 'hostname',
    long: '--hostname HOSTNAME',
    default: 'localhost'
  )

  option(
    :port,
    description: 'SMTP Port',
    long: '--port PORT',
    short: '-p PORT',
    default: 25

  )
  option(
    :smtpbind,
    description: 'SMTP bind address:port',
    long: '--smtpbind SMTPBIND',
    short: '-b SMTPBIND',
    default: ':'
  )

  option(
    :domain,
    description: 'DOmain to send EHLO to',
    short: '-d DOMAINE',
    long: '--domaine DOMAINE',
    default: 'localhost'
  )

  option(
    :method,
    description: 'EHLO or HELO',
    short: '-m METHOD',
    long: '--method METHOD',
    default: 'EHLO'
  )

  option(
    :help,
    description: 'HELP',
    short: '-h',
    long: '--help',
    boolean: false
  )

  option(
    :warn_only,
    description: 'Warn instead of critical on match',
    short: '-w',
    long: '--warn-only',
    boolean: false
  )

  option(
    :timeout,
    description: 'Timeout',
    long: '--timeout TM',
    short: '-t TM',
    default: 6
  )

  # Check EHLO
  def check_ehlo
    hostname = config[:hostname]
    port = config[:port]
    if config[:smtpbind].split(':').size == 2
      hostname = config[:smtpbind].split(':')[0]
      port = config[:smtpbind].split(':')[1]
    end
    puts "Checking for Hostname #{hostname} on port #{port}"
    Timeout.timeout(config[:timeout]) do
      Net::SMTP.start(hostname, port.to_i) do |smtp|
        response = smtp.ehlo(config[:domain]) if config[:method] == 'EHLO'
        response = smtp.helo(config[:domain]) if config[:method] == 'HELO'
        status = response.status
        smtp.finish
        status
      end
    end
  rescue Timeout::Error
    critical "Timeout Error. T > #{config[:timeout]}"
  rescue Net::ReadTimeout => ne
    critical "Timeout error: #{e.message}"
  rescue => e
    critical "Cannot login to SMTP -  TRACE: #{e.message}"
  end

  # Main Function 
  def run
    result = check_ehlo.to_i
    ok "/opt/sensu/embedded/bin/ruby /etc/sensu/plugins/check-smtp-ehlo.rb \
    --warn-only --domain google.com --hostname localhost --port 25 \
    --method EHLO|HELO \nCURRENT VALUES: #{config.inspect} \n option: \
    --smtpbind has priority" if config[:help]
    warning "SMTP #{config[:method]} Failure" if result != 250 and config[:warn_only]
    critical "SMTP #{config[:method]} Failure" if result != 250
    ok "SMTP #{config[:method]} success: #{}" if result == 250
    unknown "Could not fetch SMTP #{config[:method]} response"
  end
end
