# Returns true if we run on a windows platform
#
# Sample:
#
#  puts "Windows" if Kernel.is_windows?
#
# http://snippets.dzone.com/posts/show/2112
#
def Kernel.is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mingw32'
end
