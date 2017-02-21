class {'openiosds':}
openiosds::conscience {'conscience-0':
  ns                    => 'OPENIO',
  ipaddress             => $ipaddress,
  service_update_policy => {'meta2'=>'KEEP|3|1|','sqlx'=>'KEEP|3|1|','rdir'=>'KEEP|1|1|user_is_a_service=rawx'},
  storage_policy        => 'THREECOPIES',
}
openiosds::namespace {'OPENIO':
  ns             => 'OPENIO',
  conscience_url => "SERVER1:6000",
  zookeeper_url  => "SERVER1:6005,SERVER2:6005,SERVER3:6005",
  oioproxy_url   => "${ipaddress}:6006",
  eventagent_url => "beanstalk://${ipaddress}:6014",
}
openiosds::account {'account-0':
  ns                    => 'OPENIO',
  ipaddress             => $ipaddress,
  sentinel_hosts        => 'SERVER1:6012,SERVER2:6012,SERVER3:6012',
  sentinel_master_name  => 'OPENIO-master-1',
}
openiosds::meta0 {'meta0-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::meta1 {'meta1-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::meta2 {'meta2-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::rawx {'rawx-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::oioeventagent {'oio-event-agent-0':
  ns          => 'OPENIO',
  ipaddress   => $ipaddress,
}
openiosds::oioproxy {'oioproxy-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::zookeeper {'zookeeper-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
  servers   => ['SERVER1:2888:3888','SERVER2:2888:3888','SERVER3:2888:3888'],
}
openiosds::redissentinel {'redissentinel-0':
  ns        => 'OPENIO',
  master_name => 'OPENIO-master-1',
  redis_host => "SERVER1",
}
openiosds::redis {'redis-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::conscienceagent {'conscienceagent-0':
  ns  => 'OPENIO',
}
openiosds::beanstalkd {'beanstalkd-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::rdir {'rdir-0':
  ns        => 'OPENIO',
  ipaddress => $ipaddress,
}
openiosds::oioblobindexer {'oio-blob-indexer-rawx-0':
  ns  => 'OPENIO',
}
