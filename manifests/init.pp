class minecraft (
		$minecraft_version,
		$install_path = '/home/ubuntu/minecraft',
		$jar_name = 'minecraft_server.jar',
		$jar_source = 'https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar',
		$max_ram = 1024,
		$startup_template = 'minecraft/minecraft-server.service.conf.erb',
		$properties_template = 'minecraft/minecraft-server.properties.erb',
	) {
	
	$owner_user = 'ubuntu'
	$full_path = "${install_path}/${jar_name}"

	package { 'openjdk-7-jre':
		ensure => present,
	}

	file { 'directory':
		path    => $install_path,
		ensure  => directory,
		owner   => $owner_user,
	}

	exec { 'download minecraft_server':
		command => "wget -O ${full_path} ${jar_source}",
		unless  => "test `cat ${install_path}/version.txt` = '${minecraft_version}'",
		require => File['directory'],
	}

	file { 'version':
		require => [
			File['directory'],
			Exec['download minecraft_server'],
		],
		path => "${install_path}/version.txt",
		content => $minecraft_version,
		notify => Service['minecraft'],
	}

	file { 'server.properties':
		ensure => file,
		content => template($properties_template),
		path => "${install_path}/server.properties",
		require => File['directory'],
		notify => Service['minecraft'],
	}

	file { 'startup script':
		path    => '/etc/init/minecraft.conf',
		content => template($startup_template),
		require => [
			Package['openjdk-7-jre'],
			File['version'],
			File['server.properties'],
		],
	}

	file { '/etc/init.d/minecraft':
		ensure => link,
		target => '/lib/init/upstart-job',
	}

	service { 'minecraft':
		ensure  => running,
		require => [
			File['/etc/init.d/minecraft'],
			File['startup script'],
		],
	}
	
}