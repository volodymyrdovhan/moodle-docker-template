<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

// Debug options - possible to be controlled by flag in future..
$CFG->debug = (E_ALL | E_STRICT); // DEBUG_DEVELOPER
$CFG->debugdisplay = 1;
$CFG->debugstringids = 1; // Add strings=1 to url to get string ids.
$CFG->perfdebug = 15;
$CFG->debugpageinfo = 1;
$CFG->allowthemechangeonurl = 1;
$CFG->passwordpolicy = 0;
$CFG->cronclionly = 0;
$CFG->pathtophp = '/usr/local/bin/php';
// $CFG->cachejs = false;

$CFG->dbtype    = getenv('MOODLE_DOCKER_DBTYPE');
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'moodle_db';
$CFG->dbname    = 'moodle_local';
$CFG->dbuser    = 'root';
$CFG->dbpass    = '12345';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
    'dbpersist' => 0,
    'dbport' => '',
    'dbsocket' => '',
    'dbcollation' => 'utf8mb4_general_ci',
);

$CFG->wwwroot   = 'https://moodle.local:8202';
$CFG->dataroot  = '/var/www/html/moodledata/moodle.local';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;
$CFG->smtphosts = 'moodle-mailhog.local:1025';
$CFG->smtpsecure = '';
$CFG->smtpauthtype = 'PLAIN';
$CFG->noreplyaddress = 'noreply@example.com';
// $CFG->debugsmtp = true;

// Session configuration.
$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = 'moodle_redis';
$CFG->session_redis_port = 6379;  // Optional.
$CFG->session_redis_prefix = 'mls';
$CFG->session_redis_acquire_lock_timeout = 120;
$CFG->session_redis_lock_expire = 7200;

// Unit Tests.
$CFG->phpunit_prefix = 'phpu_';
$CFG->phpunit_dataroot = '/var/www/html/phpunitdata/moodle_local';
$CFG->phpunit_profilingenabled = true;
$CFG->phpunit_dbname    = $CFG->dbname;
$CFG->phpunit_dbuser    = $CFG->dbuser;
$CFG->phpunit_dbpass    = $CFG->dbpass;

// Behat Tests.
$CFG->behat_wwwroot   = 'https://moodle_nginx';
$CFG->behat_dataroot  = '/var/www/html/behatdata/moodle_local';
$CFG->behat_prefix = 'b_';
$CFG->behat_profiles = array(
    'default' => array(
        'browser' => getenv('MOODLE_DOCKER_BROWSER'),
        'wd_host' => 'http://selenium:4444/wd/hub',
    ),
);
$CFG->behat_faildump_path = '/var/www/html/behatfaildumps/moodle_local';

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!