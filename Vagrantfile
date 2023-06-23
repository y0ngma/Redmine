Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.2.16"
  config.vm.provider "virtualbox" do |machine|
    machine.memory=4096
    machine.cpus=4
    # provider에 명시되는 이름
    machine.name="ubuntu_2204_redmine"
    machine.gui=false
    machine.check_guest_additions=true
    # 호스트리소스 최대사용 허용치 설정(단위%)
    machine.customize ["modifyvm", :id, "--vram", "128", "--cpuexecutioncap", "50"]
  end
  config.vm.synced_folder "../VAGRANT_SYNC", "/sync"
  # config.vm.network "forwarded_port", guest: 13000, host: 7270, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 13000, host: 7270
  # # 호스트에서만 접근 가능한 아이피 값을 추가적으로 지정하기
  # config.vm.network "private_network", ip: "192.168.33.10"
  # # 브릿지를 통해 마치 내부 망의 물리머신에 있는 머신처럼 사용가능
  # config.vm.network "public_network", :bridge => 'en0'
  
  # docker 설치
  config.vm.provision :shell, path: "bootstrap.sh"
  config.trigger.after [:provision] do |t|
    t.name = "Reboot after provisioning"
    t.run = { :inline => "vagrant reload" }
  end
  
  # init_overwrite.sh 실행후
  config.vm.provision "shell", inline: "sudo mkdir -p /sync/redmine/config"
  config.vm.provision "shell", inline: "sudo cp /sync/configuration.yml /sync/redmine/config/"
  # # init_overwrite.sh 실행 없이
  # config.vm.synced_folder "./cpfile/configuration.yml", "/sync/redmine/config/configuration.yml"
  # config.vm.synced_folder "./cpfile/Dockerfile-postgres", "/sync"
  # config.vm.synced_folder "./cpfile/docker-compose.yml", "/sync"

  # 내부에서 실행하기
  config.vm.provision "shell", inline: "sudo echo cd /sync"
  config.vm.provision "shell", inline: "sudo echo $(ls)"
  # config.vm.provision "shell", inline: "sudo cp /sync/docker-compose.yml /sync"
  # config.vm.provision "shell", inline: "sudo cp /sync/Dockerfile-postgres /sync"
  config.vm.provision "shell", inline: "docker-compose up -d --build"
end
