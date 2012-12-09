class minecraft (
		$install_path = '/home/ubuntu',
		$jar_name = 'minecraft_server.jar',
		$jar_source = 'https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar',
		$max_ram = 1024,
		$startup_template = 'minecraft/minecraft-server.service.conf.erb',
	) {
	
	$full_path = "${install_path}/${jar_name}"

	package { 'openjdk-7-jre':
		ensure => present,
	}

	exec { 'download minecraft_server':
		command => "wget -O ${full_path} ${jar_source}",
		unless => "test -f ${full_path}",
	}

	file { 'startup script':
		path    => '/etc/init/minecraft.conf',
		content => template($startup_template),
		require => [
			Package['openjdk-7-jre'],
			Exec['download minecraft_server'],
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