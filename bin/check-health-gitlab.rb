#! /usr/bin/env ruby
#
#   check-health-gitlab
#
# DESCRIPTION:
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Yuri Zubov  <yury.zubau@gmail.com> sponsored by Actility, https://www.actility.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class CheckHealthGitlab < Sensu::Plugin::Check::CLI
  option :endpoint,
         description: 'Github ENDPOINT',
         short: '-E ENDPOINT',
         long: '--endpoint ENDPOINT',
         default: 'http://localhost/-/liveness'

  option :token,
         description: 'TOKEN_API',
         short: '-t TOKEN_API',
         long: '--token TOKEN_API'

  def request
    RestClient::Request.execute(
      method: :get,
      url: config[:endpoint],
      headers: { params: { token: config[:token] } }
    )
  end

  def check_health
    response = request

    JSON.parse(response)
  end

  def run
    result = check_health
    bad_health = result.reject { |_k, v| v['status'] == 'ok' }.reduce('') { |_result, (k, v)| "#{k}:#{v['status']}" }

    if bad_health.empty?
      ok 'Gitlab is ok'
    else
      warning "Gitlab is not good #{bad_health}"
    end
  rescue StandardError => e
    critical e.message
  end
end
