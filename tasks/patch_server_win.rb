#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'win32/registry'

params = JSON.parse(STDIN.read)

begin
  allow_reboot = if params['reboot'] == false
                   '-IgnoreReboot'
                 else
                   ''
                 end
  cmd_string = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUInstall -WindowsUpdate -AcceptAll #{allow_reboot}\""
  stdout, _stderr, status = Open3.capture3(cmd_string)
  if status.zero?
    puts stdout.strip
    _fact_out, _stderr, _status = Open3.capture3('powershell C:/ProgramData/PuppetLabs/puppet/cache/os_patching_fact_generation.ps1')
    exit 0
  else
    puts 'Could not apply patch'
    _fact_out, _stderr, _status = Open3.capture3('powershell C:/ProgramData/PuppetLabs/puppet/cache/os_patching_fact_generation.ps1')
    exit 1
  end
  cmd_string = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUInstall -WindowsUpdate -AcceptAll #{_allow_reboot}\""
  stdout, stderr, status = Open3.capture3(cmd_string)
  if status == 0
    puts stdout.strip
    exit 0
  else
    puts 'Could not apply patch'
    exit (-1)
  end
  _fact_out, stderr, status = Open3.capture3('powershell C:/ProgramData/PuppetLabs/puppet/cache/os_patching_fact_generation.ps1')
  err(status, 'os_patching/fact', stderr, starttime) if status != 0
rescue StandardError => e
  raise "There was a problem #{e.message}"
  exit (-1)
end
