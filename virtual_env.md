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

## provider as docker
- 도커 프로바이더로 진행 에러로 인해 보류. virtualbox로 진행
```bash
Vagrant.configure("2") do |config|
  config.vm.hostname = "ubuntu"
  config.vm.provider "docker" do |dc|
    # dc.build_dir="."
    dc.image = "ubuntu"
    # dc.compose=true
    dc.remains_running = true
    dc.has_ssh = true
  end
end
```
## provider as virtualbox
### Virtualbox용 guest addition설치
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
        # newgrp docker
        # sudo /usr/sbin/groupadd -f docker
        # sudo /usr/sbin/usermod -aG docker vagrant

        # id입력시 다음과 같이 서브그룹에 추가되어 999(docker)나오는지 확인
        # uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant),999(docker)

        # 아래는 보안성 문제때문에 제외
        sudo chmod 666 /var/run/docker.sock

        # 컨테이너접속해서 확인시에는 $USER가 vagrant였으나 설치중에는 root였음
        sudo chown $USER:$USER /var/run/docker.sock
        # 따라서 vagrant:vagrant으로 명시함으로 해결.
        ```

***

## 설치 후 서비스 실행 해보기
- 설치후 확인 사항
https://stackoverflow.com/questions/22922891/vagrant-ssh-authentication-failure
```bash
vagrant ssh-config
```
- 도커 실행 명령어
```bash
config.vm.provision "shell", inline: "docker build -t username/image /vagrant; docker run -d username/image"
```

### error : 서버는 지정한 데이터 디렉터리의 소유주 권한으로 시작되어야 합니다.
- 내용
```bash
# 한글 로케일로 LANG 설정시 디버깅 시 에러검색하기에 불리
vagrant@ubuntu2204:/sync$ docker logs 1d03b8a95b2a
이 데이터베이스 시스템에서 만들어지는 파일들은 그 소유주가 "postgres" id로
지정될 것입니다. 또한 이 사용자는 서버 프로세스의 소유주가 됩니다.

데이터베이스 클러스터는 "ko_KR.utf8" 로케일으로 초기화될 것입니다.
기본 데이터베이스 인코딩은 "UTF8" 인코딩으로 설정되었습니다.
기본 텍스트 검색 구성이 "simple"(으)로 설정됩니다.

자료 페이지 체크섬 기능 사용 하지 않음
initdb: "ko_KR.utf8" 로케일에 알맞은 전문검색 설정을 찾을 수 없음

이미 있는 /var/lib/postgresql/data 디렉터리의 액세스 권한을 고치는 중 ...완료
하위 디렉터리 만드는 중 ...완료
사용할 동적 공유 메모리 관리방식을 선택하는 중 ... posix
max_connections 초기값을 선택하는 중 ...20
기본 shared_buffers를 선택하는 중... 400kB
기본 지역 시간대를 선택 중 ... Etc/UTC
환경설정 파일을 만드는 중 ...완료
2023-06-23 07:42:07.646 UTC [84] 치명적오류:  "/var/lib/postgresql/data" 데이터 디렉터리 소유주가 잘못 되었습니다.
2023-06-23 07:42:07.646 UTC [84] 힌트:  서버는 지정한 데이터 디렉터리의 소유주 권한으로 시작되어야 합니다.
하위 프로세스가 종료되었음, 종료 코드 1
initdb: "/var/lib/postgresql/data" 데이터 디렉터리 안의 내용을 지우는 중
부트스트랩 스크립트 실행 중 ... 
```

#### 권한이 없다고 하는 폴더 권한 변경하기
```bash
sudo chown vagrant:vagrant /var/lib/postgresql/data
```

#### vi시 폰트깨짐 문제 : 가상머신 내 설정된 로케일 영어 -> 한글 변경
- sudo /usr/sbin/usermod -aG docker vagrant가 잘 먹히지 않아 직접 vi로 수정중 깨짐 증상 확인 
```bash
# 사용가능한 로케일 목록에 한글 있는지 확인
locale -a
# 없을 시 locales 패키지 설치 후 생성가능한 로케일 확인
sudo apt-get update
audo apt-get install locales
cat /usr/share/i18n/SUPPORTED # 목록에 ... ko_KR.UTF-8 UTF-8 ...확인
# 로케일 생성 후 추가확인
localedef -f UTF-8 -i ko_KR ko_KR.UTF-8
locale -a
# 환경변수 정의
export LC_ALL=ko_KR.UTF-8
# 현재 설정된 로케일 확인
locale
# 깨지지 않는지 확인
cat /usr/sbin/usermod
```

#### 해결 : sync폴더 밖에서 postgres 실행
- 마운트 된 파일들을 VM 안에서 직접 root계정상태에서 타경로로 복사하여 docker-compose up하여 해결
    - 도커서브그룹 포함여부(usermod -aG docker vagrant또는root)와 무관. 로케일과 무관
- ~~따라서 애초에 마운트 디렉토리시 소유권을 root로 변경 필요~~


### 할일
1. 로케일 설정 vagrant up 할때 적용 및 유지되도록 하기

