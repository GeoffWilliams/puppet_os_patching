#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'win32/registry'

params = JSON.parse(STDIN.read)

begin
  # Find if we are using WSUS or Windows Update
  manager_cmd = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUServiceManager | Where-Object {$_.IsManaged -eq 'true'} | foreach {$_.ServiceID}\""
  _stdout, _stderr, _status = Open3.capture3(manager_cmd)
  raise "Cannot get Windows Update configurations ", _stderr if _status != 0
  # Determine which service is enable can use that to apply patches and updates
  if params['reboot'] == false
    _allow_reboot = '-IgnoreReboot'
  else
    _allow_reboot = ''
  end
  if _stdout
    case _stdout.strip
    when '3da21691-e39d-4da6-8a4b-b43877bcb1b7'
      cmd_string = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll #{_allow_reboot}\""
    when '9482f4b4-e343-43b6-b170-9a65bc822c77'
      cmd_string = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUInstall -WindowsUpdate -AcceptAll #{_allow_reboot}\""
    when '7971f918-a847-4430-9279-4a52d1efe18d'
      cmd_string = "powershell -command \"Import-Module PSWindowsUpdate; Get-WUInstall -MicrosoftUpdate -AcceptAll #{_allow_reboot}\""
    else
      puts 'No Update Services configured'
      exit 0
    end
    # run the relevant command
    stdout, stderr, status = Open3.capture3(cmd_string)
    if status == 0
      puts stdout.strip
      exit 0
    else
      puts 'Could not apply patch'
      exit -1
    end
  end
  _fact_out, stderr, status = Open3.capture3('C:/ProgramData/PuppetLabs/puppet/cache/os_patching_fact_generation.ps1')
  err(status, 'os_patching/fact', stderr, starttime) if status != 0
rescue StandardError => e
  raise "There was a problem #{e.message}"
  exit -1
end
