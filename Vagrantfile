Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.2.16"
  ENV['LC_ALL']="ko_KR.UTF-8"
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
  config.vm.post_up_message
  config.vm.synced_folder "../VAGRANT_SYNC", "/sync"#, owner: "root", group: "root"
  config.vm.network "forwarded_port", guest: 13000, host: 13000
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
  config.vm.provision "shell", inline: "sudo mkdir -p /app"
  config.vm.provision "shell", inline: "sudo cp -r /sync/* /app"
  
  # 내부에서 실행하기
  config.vm.provision "shell", inline: "sudo echo $(id)"
  config.vm.provision "shell", inline: "sudo echo $(pwd)"
  config.vm.provision "shell", inline: "docker compose -f /app/docker-compose.yml up -d --build"
  config.vm.provision "shell", inline: "sudo echo $(docker ps)"
end