# WSL
    윈도우11-Home 기준 WSL2 설치 방법
## 시스템 요구사항 체크
- `Windows key + R` -> winver.exe
    - 윈도우11은 빌드버전 확인 불필요.
- `Windows key + R` -> msinfo32.exe
    - Hyper-V 지원여부 *4개 모두 예* 확인
- `Ctrl + Shift + ESC` -> 성능텝에 *가상화: 사용* 확인
- 이후 모든 윈도우 업데이트 마친 후 진행

## 설치
    관리자권한으로 terminal 실행
### 기본 배포판 설치  
- `wsl --install `
- `Enter new UNIX username:` 에 사용자 계정 입력
- `New password:` 에 암호입력
### 사용자 지정 배포판 설치
```bash
# 설치 가능한 배포 목록 출력
wsl --list --online
# 원하는 배포판 설치
wsl --install --distribution ubuntu-22.04
sudo apt update && sudo apt upgrade
```
### Docker compose
    https://gmyankee.tistory.com/305


### 각종 명령어
```bash
# 설치된 Linux배포판 및 WSL버전확인
wsl --list --verbose

# 여러 배포판 설치시 기본 배포판 설정 방법
wsl --set-default ubuntu-22.04

# wsl 기본 버전을 wsl2로 고정
wsl --update
wsl --status
wsl --set-default-version 2
wsl --status

# 전체 종료
wsl --shutdown
# 개별 종료
wsl --terminate ubuntu-22.04
```

# Virtual Machine
## 도입배경
- WSL은 재부팅시 SSH 사용이 개발환경에서 이슈 야기(변동IP)
    - https://gmyankee.tistory.com/307
- 개발환경 셋업 시간 단축 필요. 가상 시스템 환경 구축/관리 자동화 툴 조사
    - https://kgw7401.tistory.com/44

## installation
### Window programs
https://cafe-jun12.tistory.com/33#Vagrant%20%EB%A5%BC%20%EC%9D%B4%EC%9A%A9%ED%95%B4%20VM%20%EC%83%9D%EC%84%B1%ED%95%98%EA%B8%B0%C2%A0-1
- vagrant
- virtual box
### commands
https://cafe-jun12.tistory.com/34?category=858437
```bash
# Vagrant 및 Virtualbox 프로그램 설치 후 Vagrantfile 이 있는 경로에서
vagrant up
# provider 실행 및 정보 확인
vagrant status
# 내부에서도 직접 확인
vagrant ssh
# 우분투 환경 확인
lsb_release -a
ip a s
df -h
cat /proc/cpuinfo | more
free -h
# 중지 및 삭제
vagrant halt
vagrant destory

# 패키징
vagrant package
vagrant box add generic/ubuntu2204/docker ./package.box
```

***

## Vagrantfile
- 명령어 실행순서는 위에서 아래로 진행하되 블럭안에 블럭이 있으면 바깥->안으로 진행
- 이에 따라 글로벌 설정을 바깥블럭에, 특정설정은 안에 배치하여 덮어쓰기 가능

#### Virtualbox용 guest addition설치
- 수동설치시 되나 vagrantfile로 설치시 안되어 보류
    ```bash
    wget http://download.virtualbox.org/virtualbox/7.0.8/VBoxGuestAdditions_7.0.8.iso
    sudo mkdir /media/VBoxGuestAdditions
    sudo mount -o loop,ro VBoxGuestAdditions_7.0.8.iso /media/VBoxGuestAdditions
    sudo apt-get -y install bzip2
    sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run uninstall --force
    sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
    rm VBoxGuestAdditions_7.0.8.iso
    sudo umount /media/VBoxGuestAdditions
    sudo rmdir /media/VBoxGuestAdditions
    ```

### 도커 설치 
- https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
1. 공식문서대로 순차적으로 진행
    ```bash
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Use following command to set up the repository
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

1. sudo apt-get update 자동으로 안되는 이슈때문에 다음을 추가함
    - https://oracle-base.com/blog/2022/09/18/vagrant-ssh-auth-method-private-key-timed-out/
    - https://rainbound.tistory.com/entry/Vagrant-ssh-stuckwindows
    ```bash
    # sudo apt-get update한 뒤에도 컨테이너 내에서 또 해야하는 문제해결
    sudo apt update
    ```

1. 특정버전으로 설치시 가용버전확인 후 Install Docker Engine, containerd, and Docker Compose
    ```bash
    apt-cache madison docker-ce | awk '{ print $3 }'
    VERSION_STRING=5:24.0.2-1~ubuntu.22.04~jammy
    sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
    ```
    - 다만 버전 지정하여 설치시 docker-ce/docker-ce-cli 관련 에러발생. 
        ```bash
        # 다음과 같이 버전 부분 지우고 다음 내용으로 대체후 진행
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```

1. docker 명령어 sudo로 실행전 권한부여필수
    - https://github.com/occidere/TIL/issues/116
        ```bash
        sudo chown vagrant:vagrant /var/run/docker.sock

        # sudo 없이 작동 테스트
        docker run hello-world
        ```
    - docker 명령어 sudo 없이 진행하려 시도한 방법들(재부팅 없이 가능한 방법 못찾음)
        ```bash
        # sudo groupadd docker
        # sudo usermod -aG docker $USER
        # newgrp docker
        # sudo /usr/sbin/groupadd -f docker
        # sudo /usr/sbin/usermod -aG docker $USER

        # 아래는 보안성 문제때문에 제외
        sudo chmod 666 /var/run/docker.sock
        # 컨테이너접속해서 확인시에는 $USER가 vagrant였으나 설치중에는 root였음
        sudo chown $USER:$USER /var/run/docker.sock
        # 따라서 vagrant:vagrant으로 명시함으로 해결.
        ```

1. 설치후 확인 사항
https://stackoverflow.com/questions/22922891/vagrant-ssh-authentication-failure

```bash
vagrant ssh-config
```