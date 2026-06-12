/**
 * 允许在纯明文 HTTP 环境下正常写入登录 Session Cookie
 */
/* Authentication type */
//$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['CookieSecure'] = false;
