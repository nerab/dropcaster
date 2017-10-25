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
      "#{contributor_link(contributor)} (#{contributor.contributions} contributions)"
    end
    def contributor_link(contributor)
      if contributor.type == 'Anonymous'
        contributor.name.tr('[]', '()')
      else
        "[#{@octokit.user(contributor.login).name}](#{contributor.html_url})"
      end
    end
  end
end
