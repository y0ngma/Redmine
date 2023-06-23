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
  # docker 설치
  config.vm.provision :shell, path: "bootstrap.sh"
  
  config.trigger.after [:provision] do |t|
    t.name = "Reboot after provisioning"
    t.run = { :inline => "vagrant reload" }
  end
end
