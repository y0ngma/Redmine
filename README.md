# 레드마인 이용해보기
## Installation
- 우분투 환경 기준
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
    - 도커 컴포즈 파일이 있는 경로에서 docker-compose up -d --build 명령어 실행

## 레드마인 사용법
- https://www.redmine.org/projects/redmine/wiki/KoGetting_Started

### 초기비밀번호 변경
- 최초 레드마인 가동 후 관리자 기본 admin/admin 로그인한뒤 비밀번호 변경화면이 `암호가 만료되었거나 관리자가 변경하도록 설정하였습니다` 문구와 함께 강제로 뜨는 현상
- 거기서 비번을 올바르게 입력하여도 틀렸다고 나오는 이슈 발생시 해결방안
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

## 이메일 알림 설정
- 성공적으로 설정이 되면 관리자 권한이 있는 계정으로 로그인 후 상단에 관리-설정-메일알림에서 알림메일이 필요한 작업을 선택가능합니다.
- 
- configuration.yml
    - smtp_settings 의 user_name 이메일 주소와 레드마인 페이지 상단에 관리-설정-메일알림의 발신주소가 동일해야함
    - 해당 메일주소로 발신자가 설정이 됨
    - 폴더 마운트시 호스트 -> 컨테이너로 덮어쓰기 되어 버린다.
        - 수정을 원했던 configuration.yml파일 하나만 덮어쓰기를 원하는 상황인데 정작 마운트는 config전체 폴더를 해두고 그 안에 파일을 넣어두니 결국 컨테이너내에는 빈폴더로 덮어쓰기 된다.

- 에러 해결시 참고 자료
    - https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
    - https://littlecandle.co.kr/bbs/board.php?bo_table=codingnote&wr_id=236&sfl=mb_id%2C1&stx=byungil
    - https://www.redmineup.com/pages/help/helpdesk/how-to-set-up-outgoing-mail-settings-and-send-an-answer-to-a-customer-ticket
    - https://www.redmine.org/boards/2/topics/22259

## 백업
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