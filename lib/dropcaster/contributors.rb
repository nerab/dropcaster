require 'octokit'
require 'erb'

module Dropcaster
  def contributors
    template = ERB.new(DATA.read, 0, "%<>")

    cbtors = Octokit.contributors('nerab/dropcaster', true)

    cbtors.sort!{|x,y| y.contributions <=> x.contributions }
    cbtors.map!{|c| template.result(binding)}

    cbtors
  end
end

__END__
<a href='<%= c.html_url %>'><%= Octokit.user(c.login).name %><a/> (<%= c.contributions %> contributions)
