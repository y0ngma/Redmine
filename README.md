# 레드마인 이용해보기
## Installation
### 우분투 환경 기준
1. with docker run command
    - https://www.2cpu.co.kr/QnA/782618
    - https://hiseon.me/server/redmine-install/
        ```bash
        # 디비 생성 이후 레드마인 실행
        docker run -d --name postgres -e POSTGRES_PASSWORD=secret -e POSTGRES_USER=redmine postgres

        # docker logs [컨테이너 아이디 입력] 하면 결과 확인 가능
        docker run -d --name redmine --link postgres:postgres --volume /data:/data --publish 7270:3000 redmine
        
        # STATUS가 Exited인 경우 docker restart [컨테이너명]으로 재시작
        ```
        - 이후 http://192.168.0.232:7270/ 접속확인

1. with docker-compose.yml
    - 사용자가 docker 그룹이 아닌 경우 그룹에 포함시킴 
        ```bash
        sudo usermod -a -G docker $USER
        # 명령 수행후 적용되기 위해 시스템 재부팅 필요함
        id # 현재 사용자 ID, 그룹 확인
        ```

    - 도커 컴포즈 파일이 있는 경로에서 docker-compose up -d --build 명령어 실행

### 윈도우 환경 기준
1. 가상머신 프로그램 설치
    - Vagrant 홈페이지에서 호환가능한 Virtualbox버전을 참고하여 다운로드 받도록 한다.
    - 참고 사이트
        - https://developer.hashicorp.com/vagrant/docs/installation
        - https://www.virtualbox.org/wiki/Downloads
    - 설명에 기준이 된 버전은 다음과 같다
        - Vagrant 2.3.6
        - Virtualbox 6.1
1. 가상머신 파일 구동
    - 설치 완료후에 Vagrantfile이 있는 ~/Redmine 리포지토리 경로로 이동하여 다음을 입력한다
        ```bash
        cd Redmine

        # cpfile에 있는 파일을 리포지토리 외부의 마운트 경로로 복사
        init_overwirte.sh
        
        # 가상머신 구동 및 각종 설치
        vagrant up
        ```
1. 가상머신 접속 
    - 가상머신 구동시 docker-compose.yml을 자동실행하도록 되어있다. 
    - 접속 이후 docker 또는 Redmine 관련 명령어를 입력하여 필요한 설정을 마무리 한다.
        ```bash
        # 가상머신 접속
        vagrant ssh
        # 가상머신 나오기 exit
        # 가상머신 끄기 vagrant halt
        # 가상머신 삭제 vagrant destroy
        
        # 레드마인 컨테이너 구동 확인
        docker ps

        # 웹브라우져 레드마인 접속
        http://127.0.0.1:13000/
        ```

***

# 초기 설정 진행
- 레드마인 사용법
    - https://www.redmine.org/projects/redmine/wiki/KoGetting_Started

## 이메일 알림 설정
- configuration.yml파일에 user_name 이메일 주소와 레드마인 웹페이지에 설정된 발신주소가 동일해야함.

1. 설정파일에 발신주소 및 SMTP 설정
    - 수정사항이 있을시 컨테이너 재시작한다
    ```yml
    # redmine/config/configuration.yml
    email_delivery:
        delivery_method: :smtp
        smtp_settings:
        address: "<SMTP SERVER ADDR>"
        port: 587
        domain: "<SMTP SERVER ADDR>"
        user_name: "test@gmail.com"
        password: "password"
    ```

1. 웹페이지내 발신주소 설정
    - 메뉴위치 : 좌측상단에 `관리`
        - 좌측메뉴 `설정`
            - `메일알림`탭의 발신주소
        - 해당 메일주소로 발신자가 설정이 됨


## 초기비밀번호 변경
- 최초 레드마인 가동 후 관리자 기본 admin/admin 로그인한뒤 비밀번호 변경화면뜸
    - `암호가 만료되었거나 관리자가 변경하도록 설정하였습니다`

- 접속 주소: `<ip>:13000`
  - `로그인` 누르고 관리자로 접속
  - 초기 패스워드 admin / admin임

## 기타 유용한 설정
- 좌측상단 `관리`
    - 한글을 기본 언어로 설정: 관리자/설정/표시방법 페이지에서 "기본언어" 한글로 설정
    - 좌측메뉴 `설정`
        1. `일반`탭
            1. 레드마인 제목 설정: 관리자/설정/일반 페이지에서 "레드마인 제목" "GNEW Lab 프로젝트관리" 설정
            1. URL 설정: 관리자/설정/일반 페이지에서 "호스트 이름과 경로"에 `<ip>:13000` 경로설정

        1. `표시방식`탭
            1. 사용자 표시 형식 성 이름 순서로 표시되게 함: 관리자/설정/표시방법 페이지에서 "사용자 표시 형식" 변경

        1. `인증`탭
            1. 로그인하지 않은 사용자 프로젝트 볼수 없게함: 관리자/설정/인증 페이지에서 "인증이 필요함" Yes로 설정
            1. 자동 로그인 설정: 관리자/설정/인증 페이지에서 "자동로그인" 365일로 설정

        1. `파일`탭
            1. 첨부파일 최대크기변경: 관리자/설정/파일 페이지에서 "최대첨부파일크기" 102400로 설정


* * *


# Plugins
## Slack Notifications
    https://www.redmine.org/projects/redmine/wiki/Plugins
    https://github.com/sciyoshi/redmine-slack

### Installation of Redmine plugin 
- docker 내에 plugin 폴더경로로 이동하여 설치한다
```bash
docker exec -it redmine_test1_container bash
cd /usr/src/redmine/plugins
git clone https://github.com/sciyoshi/redmine-slack.git redmine_slack
bundle install
exit
docker-compose down -v; docker-compose up -d --build
```

### Installation of Slack Webhook App
- 알림을 받을 채널에 webhook app 설치
    1. 슬랙에서 webhook app 검색하여 설치한다
    1. 알림을 받을 슬랙 채널명을 선택하여 webhook URL을 생성한다.

### Configuration of Redmine general and project settings
- 설정할 내용은 다음과 같습니다. 레드마인 UI에서 플러그인 설정을 먼저 마칩니다. 이후, 알림 종류(프로젝트 등)을 설정한 후 알림 대상별 설정텝에서 알림 보낼 슬랙의 채널명 등을 설정하면 됩니다.
1. 레드마인 플러그인 설정
    - 레드마인 상단 관리 - 플러그인 - 설치된 플러그인의 설정을 차례로 누른다.
        - Slack URL칸에 슬랙에서 생성해 둔 webhook URL을 복사해 넣는다
        - Slack Channel 칸에 알림 보낼 채널명을 입력한다
        - 하단에 적용 클릭
1. 알림 종류 설정
    - 레드마인 상단 관리 - 사용자 정의 항목 - 새 사용자 정의 항목
        - 프로젝트 등 설정할 알림의 종류 선택
        - 이름 : 종류명 기입
        - 형식 : 목록
            - 가능한 값들 : #<슬랙채널명> 형식으로 기입
        - 설정값 기입 후 만들기
1. 알림 대상 설정
    - 레드마인 상단 프로젝트 - 특정 프로젝트 - 상단에 설정탭
        - 앞서 설정한 알림 종류에서 알림 보낼 채널명 선택
        - 저장


* * *


# Theme
    https://github.com/mrliptontea/PurpleMine2

## purplemine
### Theme main features
- 가독성이 좋은 폰트, 깃허브와 유사한 wiki
- list, issue page 및 wiki 에서 tracker 링크를 색깔로 구분
- Jira에서 영감을 받은 우선순위 아이콘 채택
- 좌측으로 옮겨진 사이드바의 투명도 토글화
- variable로 관리하는 보다 편리한 커스터마이징

### Installation of theme
도커내에 압축을 해제
```bash
docker exec -it redmine_test1_container bash
# 레드마인설치경로 = "/usr/src/redmine"
cd /usr/src/redmine/public/themes
wget https://github.com/mrliptontea/PurpleMine2/archive/master.zip
unzip master.zip
```

### Configuration for Redmine theme
1. 레드마인 테마 설정
    - 상단에 관리 - 설정 클릭후 - 표시방식 텝 내에서 설정한다
        - 테마(드롭다운) - 설치한 테마 선택 - 저장


***


# Back up and Restore
- 각종 설정을 마친 후 백업 및 복원까지 해보기
- 참고 사이트
    - https://www.redmine.org/projects/redmine/wiki/RedmineBackupRestore
    - https://luckygg.tistory.com/357

### 백업 생성
```sh
# 마운트 경로 확인 후 접속 docker inspect <컨테이너명>
docker inspect -f '{{ json .Mounts }}' redmine_test1_db | python -m json.tool
docker exec -it redmine_test1_db bash

# /usr/bin/pg_dump -U <username> -h <hostname> -Fc --file=redmine.sqlc <redmine_database>
# 저장경로를 마운트 되어 있는 폴더로 지정
/usr/local/bin/pg_dump -U redmine -h redmine_test1_db -Fc --file=/var/lib/postgresql/data/redmine.sqlc redmine
```

### 백업 복원
```sh
# 백업파일이 있는곳으로 이동
cd /var/lib/postgresql/data/
# --clean : 기존 삭제후 복원(덮어쓰기 되는듯?)
pg_restore -U redmine -h redmine_test1_db -d redmine --clean redmine.sqlc
```

### attachments 파일 백업
- pg_store만 하면 프로젝트에 첨부파일은 복원 안되고 404뜬다
- 따라서 /usr/src/redmine/files에 있던 내용을 백업해두었다가 붙여넣는다
- 붙여넣는 즉시 404해결됨(컨테이너 재시작 또는 웹페이지 새로고침 필요없음)
```bash
# 백업
mkdir -p /home/gocp/redmine/test1-redmine/mybackup
rsync -r /home/gocp/redmine/test1-redmine/files /home/gocp/redmine/test1-redmine/mybackup
# 복원
cp -r /home/gocp/redmine/test1-redmine/mybackup/files/* /home/gocp/redmine/test1-redmine/files
```


***


# 에러 내용 정리
- 초기 관리자 비번을 올바르게 입력하여도 틀렸다고 나올때
    - https://stackoverflow.com/questions/30655292/is-there-a-rake-command-to-reset-a-redmine-admin-password/30666786#30666786
        ```ruby
        # redmine 컨테이너 내부로 접속
        docker exec -it redmine_test1_container bash
        
        # Wait until rail env come up.
        RAILS_ENV=production bundle exec rails c

        # Load your admin user, I use id = 1 here but it should be what you have found in step 1 
        user = User.where(id: 1).first

        # set new password
        user.password = 'password'
        user.password_confirmation = 'password'
        user.must_change_password = false

        # save changes
        user.save!
        exit
        ```

- 폴더 마운트시 호스트 -> 컨테이너로 덮어쓰기 되어 버린다.
    - 수정을 원했던 configuration.yml파일 하나만 덮어쓰기를 원하는 상황인데 정작 마운트는 config전체 폴더를 해두고 그 안에 파일을 넣어두니 결국 컨테이너내에는 빈폴더로 덮어쓰기 된다.
    - 해결방안
        ```yml
        # docker-compose.yml 에 마운트 경로를 아래와 같이 <파일경로>:<파일경로>
        volumes:
        - ./redmine/config/configuration.yml:/usr/src/redmine/config/configuration.yml
        ```
