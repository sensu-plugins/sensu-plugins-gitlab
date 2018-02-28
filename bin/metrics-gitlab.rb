#! /usr/bin/env ruby
#
#   metrics-gitlab
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text, metric data, etc
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: gitlab
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

require 'sensu-plugin/metric/cli'
require 'gitlab'

class GitlabGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :endpoint,
         description: 'Github ENDPOINT',
         short: '-E ENDPOINT',
         long: '--endpoint ENDPOINT'

  option :token,
         description: 'TOKEN_API',
         short: '-t TOKEN_API',
         long: '--token TOKEN_API'

  option :period,
         description: 'Sampling Period in seconds.',
         short: '-p',
         long: '--period',
         proc: proc(&:to_i),
         default: 3600

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-S SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.gitlab"

  def gitlab_configure
    Gitlab.private_token = config[:token]
    Gitlab.endpoint = config[:endpoint]
  end

  def commit_count(commits)
    select_by_period(commits).count
  end

  def commit_count_by_status(project, commits)
    result = { pending: 0, running: 0, success: 0, failed: 0, canceled: 0 }
    select_by_period(commits).each do |commit|
      commit_info = Gitlab.commit(project.id, commit.id)
      unless commit_info.status.nil?
        result[commit_info.status.to_sym] = result[commit_info.status.to_sym].to_i + 1
      end
    end

    result
  end

  def project_count(projects)
    projects.count
  end

  def user_count(users)
    users.count
  end

  def group_count(groups)
    groups.count
  end

  def select_by_period(list)
    list.lazy.select { |item| Time.iso8601(item.created_at) >= (Time.now.utc - config[:period]) }
  end

  def repository_count(repositories)
    select_by_period(repositories).count
  end

  def print_hash(hash, path = '')
    hash.each do |key, value|
      if value.is_a? Hash
        print_hash(value, "#{path}.#{key}")
      else
        output "#{config[:scheme]}#{path}.#{key}", value
      end
    end
  end

  def event_count_by_action(events)
    result = {
      created: 0,
      updated: 0,
      closed: 0,
      reopened: 0,
      pushed: 0,
      commented: 0,
      merged: 0,
      joined: 0,
      left: 0,
      destroyed: 0,
      expired: 0
    }
    select_by_period(events).each do |event|
      result[event.action_name.to_sym] = result[event.action_name.to_sym].to_i + 1
    end

    result
  end

  def merge_request_count(merge_requests)
    select_by_period(merge_requests).count
  end

  def run
    gitlab_configure
    metrics = {
      project_count: 0,
      user_count: 0,
      group_count: 0
    }

    projects = Gitlab.projects
    metrics[:project_count] += project_count(projects)
    metrics[:user_count] += user_count(Gitlab.users)
    metrics[:group_count] += group_count(Gitlab.groups)

    if Gitlab::VERSION > '4.3.0'
      metrics[:sidekiq] = {}
      sidekiq_job_stats = Gitlab.sidekiq_job_stats.jobs
      metrics[:sidekiq][:processed] = sidekiq_job_stats.processed
      metrics[:sidekiq][:failed] = sidekiq_job_stats.failed
      metrics[:sidekiq][:enqueued] = sidekiq_job_stats.enqueued
    end

    projects.each do |project|
      metrics[project.name] = { commit_count: 0, commit_count_by_status: {} }

      metrics[project.name][:branches_count] = Gitlab.branches(project.id).count

      project_events = Gitlab.project_events(project.id, after: (Time.now.utc - config[:period]))
      metrics[project.name][:events_count_per_hour] = event_count_by_action(project_events)
      merge_requests = Gitlab.merge_requests(project.id, since: (Time.now.utc - config[:period]))
      metrics[project.name][:merge_request_count_per_hour] = merge_request_count(merge_requests)

      commits = Gitlab.commits(project.id, since: (Time.now.utc - config[:period]))
      metrics[project.name][:commit_count_per_hour] = commit_count(commits)
      metrics[project.name][:commit_count_per_hour_by_status] = commit_count_by_status(project, commits)
    end

    print_hash(metrics)

    ok
  end
end
