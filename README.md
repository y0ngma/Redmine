# 레드마인 이용해보기
## Installation
- 모든것은 우분투 환경 기준
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
- 레드마인 가동 후 관리자 기본 admin/admin 로그인한뒤 비밀번호 변경화면이 `암호가 만료되었거나 관리자가 변경하도록 설정하였습니다` 문구와 함께 강제로 뜨는 현상 발생
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