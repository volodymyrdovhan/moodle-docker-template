Docker template for Moodle development based on NGINX and PHP-FPM

**Databases**<br>
user: root<br>
password: 12345

**Start project**<br>
- Add moodle.local to your "hosts" file<br>
- `clone Moodle source code to ./src/moodle.local folder`<br>
- `$ make install`<br>
- `$ make docker_up`<br>
- `$ create DB moodle_local`<br>
- copy ./config/config.php to ./src/moodle.local <br>

**Project URL**<br>
 - Moodle: https://moodle.local:8202
 - PHPMyAdmin: http://localhost:8205
 - Adminer: http://localhost:8283
 - Mailhog: http://localhost:8025

**Build with custom containers**<br>
Use PostrgeSQL:<br>
`$ export dockerfile='-f docker-compose.yml -f docker-compose.dbpostgre13.yml -f docker-compose.mailhog.yml -f docker-compose.adminer.yml'`<br>
`$ make docker_build`<br>
`$ make docker_up`

**Run moodle commands**
- Export moodleroot path: `$ export moodleroot=moodle.local`
- Run Cron: `$ make run_cron`
- Run PHP command: `$ make path=admin/cli/check_database_schema.php run_php_script`

**Run CI**
- Export moodleroot path: `$ export moodleroot=moodle.local`
- Install node: `$ make node_install`
- Install CI plugin: `$ make init_ci`
- Run plugin CI: `$ make pluginpath=admin/tool/dataprivacy run_plugin_ci`

**Run PHPUnit**
- Export moodleroot path: `$ export moodleroot=moodle.local`
- Init PHPUnit: `$ make init_tests`
- Run testsuite for one plugin: `$ make testsuite=tool_dataprivacy_testsuite run_testsuite`

**Run Behat Tests**
<br>Will be configured soon...

**Setup new host**
- generate new ssl for host with mkcert (https://github.com/FiloSottile/mkcert) in ./docker/nginx/ssl
- add new host to local host file
- add new DB to ./database/init/init.sql or create new DB instance manually
- add logs files to ./docker/nginx/logs
- add conf file to ./docker/nginx/configs
- clone code to ./src/newhost
- `$ make init`
- `$ make docker_up`
- to run scripts/tests in specific host export moodleroot: `$ export moodleroot=newhost`