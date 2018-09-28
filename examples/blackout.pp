# @PDQTest

$params = {
  'debug' => 'debug',
}

# write the JSON to file and re-read it to avoid fighting the shell...
file { '/tmp/os_patching/params.json':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => to_json($params),
}

exec { 'run the update script and make sure it fails':
  command => 'bash -c \'cat /tmp/os_patching/params.json | /testcase/tasks/patch_server.rb  > /tmp/os_patching/output.txt ; true\'',
  path    => '/bin:/usr/bin',
  creates => "/tmp/os_patching/output.txt",
}