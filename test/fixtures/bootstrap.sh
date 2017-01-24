#!/bin/bash
#
# Set up a super simple Postfix server and block its outbound port 25 so we can
# use it for testing.
#

set -e

source /etc/profile
DATA_DIR=/tmp/kitchen/data
RUBY_HOME=${MY_RUBY_HOME:-/opt/sensu/embedded}

if [ "$RUBY_HOME" = "/opt/sensu/embedded" ] && [ ! -d $RUBY_HOME ]; then
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
  echo "deb http://repositories.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
  apt-get update
  apt-get install -y sensu
else
  apt-get update
fi

DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential postfix mailutils
iptables -I OUTPUT -m tcp -p tcp --dport 25 -j DROP
service postfix restart

cd $DATA_DIR
SIGN_GEM=false $RUBY_HOME/bin/gem build sensu-plugins-postfix.gemspec
$RUBY_HOME/bin/gem install sensu-plugins-postfix-*.gem
