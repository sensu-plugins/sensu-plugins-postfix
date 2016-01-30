#!/bin/sh
#
# Set up a super simple Postfix server and block its outbound port 25 so we can
# use it for testing.
#

DATA_DIR=/tmp/kitchen/data
SENSU_DIR=/opt/sensu
GEM=$SENSU_DIR/embedded/bin/gem
RUBY=$SENSU_DIR/embedded/bin/ruby

if [ ! -d $SENSU_DIR ]; then
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
  echo "deb http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list

  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git vim postfix mailutils sensu
  sudo iptables -I OUTPUT -m tcp -p tcp --dport 25 -j DROP
fi

cd $DATA_DIR
SIGN_GEM=false $GEM build sensu-plugins-postfix.gemspec
sudo sensu-install -p sensu-plugins-postfix-*.gem
