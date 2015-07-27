<?php

$fp=null;
function connectToIcecast(){
 $ret = ''; 
 $ip = '127.0.0.1';
 $port = '8000';
 $verb = 'SOURCE';
 $uri = '/videotest';
 $ctype = 'application/ogg';
 $base64pass = 'c291cmNlOm5ubm5qYW5fMjIyMg==';
 $icename = 'This is my stream name';
 $iceurl = 'http://mindcraft.zapto.org';
 $icegenre = 'stuff';
 $icebitrate = '128';
 $iceprivate = '0';
 $icepublic = '1';
 $icedescription = 'My Stream Description';
 $iceaudioinfo = 'ice-samplerate=44100;ice-bitrate=128;ice-channels=2';

 $crlf = "\r\n"; 
 $req = $verb .' '. $uri .' ICE/1.0' . $crlf; 
 $req .= 'content-type: '. $ctype . $crlf; 
 $req .= 'Authorization: Basic ' . $base64pass . $crlf; 
 $req .= 'ice-name: ' . $icename . $crlf; 
 $req .= 'ice-url: ' . $iceurl . $crlf; 
 $req .= 'ice-genre: ' . $icegenre . $crlf; 
 //$req .= 'ice-bitrate: ' . $icebitrate . $crlf;
 //$req .= 'ice-private: ' . $iceprivate . $crlf;
 $req .= 'ice-public: ' . $icepublic . $crlf;
 $req .= 'ice-description: ' . $icedescription . $crlf;
 //$req .= 'ice-audio-info: ' . $iceaudioinfo . $crlf;
 $req .= $crlf;

 global $fp;
 if (($fp = @fsockopen($ip, $port, $errno, $errstr)) == false) 
         echo "Error $errno: $errstr\n";

 stream_set_blocking($fp, 0);
 fputs($fp, $req);
}

//echo $ret;

/*
$arr=array("ip","icmp","ggp","tcp",
"egp","pup","udp","hmp","xns-idp",
"rdp","rvd" );
//Reads the names of protocols into an array..
for($i=0;$i<11;$i++)
{
$proname=$arr[$i];
echo $proname .":", getprotobyname ($proname)."<br />";
}
*/
if(file_exists("/tmp/icecastrelayS.sock"))
{
unlink("/tmp/icecastrelayS.sock");
}
ignore_user_abort(true);
set_time_limit(0);
$sock = socket_create(AF_UNIX, SOCK_STREAM, getprotobyname("ip"));
register_shutdown_function(function($sock, $fp){socket_shutdown($sock);socket_close($sock);unlink("/tmp/icecastrelayS.sock");fclose($fp);},$sock,$fp);
socket_bind($sock, "/tmp/icecastrelayS.sock") or die('Could not bind to address');
socket_listen($sock);
socket_set_nonblock($sock);
set_time_limit(30);
while (true)
{
 if ($newsock = @socket_accept($sock))
 {
  if (is_resource($newsock))
  {
   set_time_limit(0);
   connectToIcecast();
   while (true)
   {
    fread($fp, 1);
    if (feof($fp)){die('icecast dropped connection1');}
    if (@socket_recv($newsock, $string, 1024, MSG_DONTWAIT) === 0)
    {
     exit();
    }
    if ($string) 
    {
     fwrite($fp, $string);
    }
   }
  }
 }
}
?>
