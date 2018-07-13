# frozen_string_literal: true

require 'octokit'

module Dropcaster
  class << self
    def contributors
      @octokit ||= if ENV.include?('GH_TOKEN')
                     Octokit::Client.new(access_token: ENV['GH_TOKEN'])
                   else
                     Octokit::Client.new
                   end

      @octokit.contributors('nerab/dropcaster', true).
        sort { |x, y| y.contributions <=> x.contributions }.
        map { |c| "* #{contributor_summary(c)}" }.
        join("\n")
    end

    def contributor_summary(contributor)
      contributions = contributor.contributions
      "#{contributor_link(contributor)} (#{contributions} contribution#{contributions == 1 ? '' : 's'})"
    end

    def contributor_link(contributor)
      if contributor.type == 'Anonymous'
        contributor.name.tr('[]', '()')
      else
        # rubocop:disable Style/RescueStandardError
        begin
          "[#{@octokit.user(contributor.login).name}](#{contributor.html_url})"
        rescue
          contributor.login
        end
        # rubocop:enable Style/RescueStandardError
      end
    end
  end
end
