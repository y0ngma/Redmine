Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.2.16"
  
  config.vm.provider "virtualbox" do |machine|
    machine.memory=4096
    machine.cpus=4
  end

  # 개발환경에서 자주 사용하는 포트를 미리 설정해두면 편리
  # 호스트 IP를 127.0.0.1로 강제하면 포트 포워딩이 되더라도 외부에서는 가상머신에 접근불가
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # 호스트에서만 접근 가능한 아이피 값을 추가적으로 지정하기
  config.vm.network "private_network", ip: "192.168.33.10"
  # 브릿지를 통해 마치 내부 망의 물리머신에 있는 머신처럼 사용가능
  config.vm.network "public_network", :bridge => 'en0'

  config.vm.synced_folder "../data", "/vagrant_data"

  # config.vm.provision "shell", inline: "wget -qO- https://get.docker.com/ | sh"
  # config.vm.provision "shell", inline: "usermod -aG docker vagrant"
  config.vm.provision "shell" do |sh1|
    sh1.inline="wget -qO- https://get.docker.com/ | sh"
    sh1.inline="usermod -aG docker vagrant"
    sh1.inline="echo Provision is completed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end
  config.vm.provision "shell", run: "always" do |sh2|
    sh2.inline="echo Last line of Vagrantfile !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

end