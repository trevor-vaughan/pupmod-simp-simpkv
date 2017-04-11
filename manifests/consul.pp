# == Class libkv::consul
# vim: set expandtab ts=2 sw=2:
#
# This class uses solarkennedy/consul to initialize .
#
class libkv::consul(
  $server = false,
  $version = '0.8.0',
  $use_puppet_pki = true,
  $bootstrap = false,
  $dont_copy_files = false,
  $serverhost = undef,
  $advertise = undef,
  $datacenter = undef,
  $ca_file_name = undef,
  $private_file_name = undef,
  $cert_file_name = undef,
  $config_hash = undef,
) {
  package { "unzip": }
  if ($bootstrap == true) {
    $bootstrap_expect = 1
  }
  if ($datacenter == undef) {
    $_datacenter = {}
  } else {
    $_datacenter = { "datacenter" => $datacenter }
  }
  if ($serverhost == undef) {
    if ($::servername == undef) {
      $_serverhost = $::fqdn
    } else {
      $_serverhost = $::servername
    }
  } else {
    $_serverhost = $serverhost
  }
  if ($advertise == undef) {
    $_advertise = $::ipaddress
  } else {
    $_advertise = $advertise
  }
  $keypath = '/etc/simp/bootstrap/consul/key'
  $master_token_path = '/etc/simp/bootstrap/consul/master_token'
  if ($use_puppet_pki == true) {
    if ($server == true) {
      $_cert_file_name = '/etc/simp/bootstrap/consul/server.dc1.consul.cert.pem'
      $_private_file_name = '/etc/simp/bootstrap/consul/server.dc1.consul.private.pem'
      $_ca_file_name = '/etc/simp/bootstrap/consul/ca.pem'
      if ($dont_copy_files == false) {
        file { $_cert_file_name:
          content => file($_cert_file_name)
        }
        file { $_private_file_name:
          content => file($_private_file_name)
        }
        file { $_ca_file_name:
          content => file($_ca_file_name)
        }
      }
    } else {
      $_cert_file_name = '/etc/puppetlabs/puppet/ssl/certs/${::clientcert}.pem'
      $_ca_file_name = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
      $_private_file_name = '/etc/puppetlabs/puppet/ssl/private_keys/${::clientcert}.pem'
    }
  }
  $hash = lookup('consul::config_hash', { "default_value" => {} })
  $class_hash =     {
    'bootstrap_expect' => $bootstrap_expect,
    'server'           => $server,
    'node_name'        => $::hostname,
    'retry_join'       => [ $_serverhost ],
    'advertise_addr'   => $_advertise,
    'cert_file'        => $_cert_file_name,
    'ca_file'          => $_ca_file_name,
    'key_file'         => $_key_File_name,
    'acl_master_token' => file($master_token_path),
    'encrypt'          => file($keypath),
  }
  $merged_hash = $hash + $class_hash + $_datacenter + $config_hash
  class { '::consul':
    config_hash          => $merged_hash,
    version => $version,
  }
}
