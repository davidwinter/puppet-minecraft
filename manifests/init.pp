class minecraft (
		$path,
		$name = 'minecraft_server.jar',
		$source = 'https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar',
		$ram = 1024,
		$startup_template = 'minecraft/minecraft-server.service.conf.erb',
	) {
	
	$full_path = $path + '/' + $name

	package { 'openjdk-7-jre':
		ensure => present,
	}

	file { 'minecraft_server':
		source => $source,
		path   => $full_path,
	}

	file { 'startup script':
		path    => '/etc/init/minecraft',
		content => template($startup_template),
		require => [
			Package['openjdk-7-jre'],
			File['minecraft_server'],
		],
	}

	service { 'minecraft':
		ensure  => running,
		require => File['startup script'],
	}
	
}