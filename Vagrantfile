Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.2.16"
  # 개발환경에서 자주 사용하는 포트를 미리 설정해두면 편리
  # 호스트 IP를 127.0.0.1로 강제하면 포트 포워딩이 되더라도 외부에서는 가상머신에 접근불가
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # 호스트에서만 접근 가능한 아이피 값을 추가적으로 지정하기
  config.vm.network "private_network", ip: "192.168.33.10"
  # 브릿지를 통해 마치 내부 망의 물리머신에 있는 머신처럼 사용가능
  config.vm.network "public_network", :bridge => 'en0'
  
  config.vm.provider "virtualbox" do |machine|
    machine.memory=4096
    machine.cpus=4
    machine.name="ubuntu_2204_redmine"
    machine.gui=false
    machine.check_guest_additions=false
    # 호스트리소스 최대사용 허용치 설정(단위%)
    machine.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  end
  config.vm.synced_folder "./App", "/App"
  
  # update apt package index
  config.vm.provision "shell", inline: "sudo apt-get update"
  
  # guest addition install
  config.vm.provision "shell" do |ubun|
    ubun.inline="sudo apt-get update"
    ubun.inline="sudo wget http://download.virtualbox.org/virtualbox/7.0.8/VBoxGuestAdditions_7.0.8.iso"
    ubun.inline="sudo mkdir /media/VBoxGuestAdditions"
    ubun.inline="sudo mount -o loop,ro VBoxGuestAdditions_7.0.8.iso /media/VBoxGuestAdditions"
    ubun.inline="sudo apt-get -y install bzip2"
    ubun.inline="sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run uninstall --force"
    ubun.inline="sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run"
    ubun.inline="rm VBoxGuestAdditions_7.0.8.iso"
    ubun.inline="sudo umount /media/VBoxGuestAdditions"
    ubun.inline="sudo rmdir /media/VBoxGuestAdditions"
  end

  # https://docs.docker.com/engine/install/ubuntu/
  config.vm.provision "shell" do |dc|
    # dc.inline="sudo apt install -y docker.io"
    # dc.inline="usermod -aG docker vagrant"
    # install pakcages to allow apt to use a repository over HTTPS:
    dc.inline="sudo apt-get install -y ca-certificates curl gnupg"
    # Add Docker's official GPG key:
    dc.inline="sudo install -m 0755 -d /etc/apt/keyrings"
    dc.inline="curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
    dc.inline="sudo chmod a+r /etc/apt/keyrings/docker.gpg"
    # Use following command to set up the repository
    dc.inline='echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
    # 가용버전확인 후 Install Docker Engine, containerd, and Docker Compose
    dc.inline="apt-cache madison docker-ce | awk '{ print $3 }'"
    dc.inline="VERSION_STRING=5:24.0.2-1~ubuntu.22.04~jammy"
    dc.inline="sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin"
    # docker 명령어 sudo로 실행전 권한부여필수
    dc.inline="sudo groupadd docker"
    dc.inline="sudo usermod -aG docker $USER"
    dc.inline="newgrp docker"
    # sudo 없이 작동 테스트
    dc.inline="docker run hello-world"
    dc.inline="sudo echo Provision is completed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  # vagrant up으로 구동시 항상 실행하는 블럭
  config.vm.provision "shell", run: "always" do |sh2|
    # 1. redmine
    sh2.inline="cd /App"
    sh2.inline="echo pwd"
    sh2.inline="echo Last line of Vagrantfile !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end
end
