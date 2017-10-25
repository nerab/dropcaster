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

    # rubocop:disable Lint/RescueWithoutErrorClass
    def contributor_link(contributor)
      "[#{@octokit.user(contributor.login).name}](#{contributor.html_url})"
    rescue => e
      warn "Error: Could not link to contributor. #{e}"
      contributor.tr('[]', '()')
    end
  end
end
