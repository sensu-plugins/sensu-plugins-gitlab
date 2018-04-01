#!/bin/bash
#
# Set up a super simple web server and make it accept GET and POST requests
# for Sensu plugin testing.
#

set -e

# base utilities that need to exist to start bootatraping
apt-get update
apt-get install -y wget build-essential

# setup the rubies
source /etc/profile
DATA_DIR=/tmp/kitchen/data
RUBY_HOME=${MY_RUBY_HOME}

# Start bootatraping

## install some required deps for gem to install


# End of Actual bootatrap

# Install gems
cd $DATA_DIR
SIGN_GEM=false gem build sensu-plugins-gitlab.gemspec
gem install sensu-plugins-gitlab-*.gem
