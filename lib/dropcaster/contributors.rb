# frozen_string_literal: true

require 'octokit'

module Dropcaster
  def self.contributors
    cbtors = Octokit.contributors('nerab/dropcaster', true)

    cbtors.sort! { |x, y| y.contributions <=> x.contributions }
    cbtors.map! { |c| "* [#{Octokit.user(c.login).name}](#{c.html_url}) (#{c.contributions} contributions)" }

    cbtors.join("\n")
  end
end
