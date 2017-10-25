# frozen_string_literal: true

require 'octokit'

module Dropcaster
  def self.contributors
    octokit = if ENV.include?('GITHUB_TOKEN')
                Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
              else
                Octokit::Client.new
              end

    octokit.contributors('nerab/dropcaster', true)
      .sort { |x, y| y.contributions <=> x.contributions }
      .map { |c|
        begin
          "* [#{octokit.user(c.login).name}](#{c.html_url}) (#{c.contributions} contributions)"
        rescue
          "* #{c.tr('[]', '()')} (#{c.contributions} contributions)"
        end
      }
      .compact
      .join("\n")
  end
end
