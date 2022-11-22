<?php
/**
 * ____________________________________________________________________________
 * 
 *  _____ _____ __                   _____         _ _           
 * |     |     |  |      ___ ___ ___|     |___ ___|_| |_ ___ ___ 
 * |-   -| | | |  |__   | .'| . | . | | | | . |   | |  _| . |  _|
 * |_____|_|_|_|_____|  |__,|  _|  _|_|_|_|___|_|_|_|_| |___|_|  
 *                          |_| |_|                              
 *                           _ _         _                                            
 *                       ___| |_|___ ___| |_                                          
 *                      |  _| | | -_|   |  _|                                         
 *                      |___|_|_|___|_|_|_|   
 *                                                               
 * ____________________________________________________________________________
 * 
 * CHECK PING RESPONSE TIME VIA ICMP
 * ____________________________________________________________________________
 * 
 * 2022-07-05  <axel.hahn@iml.unibe.ch>
 * 2022-09-16  <axel.hahn@iml.unibe.ch>  read error before closing socket.
 * 2022-11-22  <axel.hahn@iml.unibe.ch>  Use exec with detecting MS Win for the ping parameter for count of pings
 */
class checkPing extends appmonitorcheck{
    /**
     * get default group of this check
     * @param array   $aParams
     * @return array
     */
    public function getGroup(){
        return 'network';
    }

    /**
     * check ping to a target
     * @param array $aParams
     * array(
     *     host                string   optional hostname to connect; default: 127.0.0.1
     *     timeout             integer  optional timeout in sec; default: 5
     * )
     * @return boolean
     */
    public function run($aParams) {
        $sHost = array_key_exists('host', $aParams) ? $aParams['host'] : '127.0.0.1';

        $sParamCount=strtoupper(substr(PHP_OS, 0, 3)) === 'WIN' ? "n" : "c";
        $iRepeat=1;
        
        $sCommand="ping -$sParamCount $iRepeat $sHost";
        exec($sCommand, $aOut, $iRc);
        $sOut=implode("\n", $aOut);

        if ($iRc>0){
            return [RESULT_ERROR, "ERROR: ping to $sHost failed.\n".$sOut];
        }
        return [RESULT_OK, "OK: ping to $sHost\n".$sOut];

        /*
            Socket functions require root :-/

        if (!function_exists('socket_create')){
            return [RESULT_UNKNOWN, "UNKNOWN: Unable to perform ping test. The socket module is not enabled in the php installation."];
        }

        // ICMP ping packet with a pre-calculated checksum
        $package = "\x08\x00\x7d\x4b\x00\x00\x00\x00PingHost";
        $socket  = socket_create(AF_INET, SOCK_RAW, getprotobyname('icmp'));
        // TODO
        if(!$socket){
                die("ERROR: unable to create socket");
        }
        socket_set_option(
            $socket, 
            SOL_SOCKET, 
            SO_RCVTIMEO, 
            array(
                "sec"=>(isset($aParams["timeout"]) && (int)$aParams["timeout"]) ? (int)$aParams["timeout"] : $this->_iTimeoutTcp, // timeout in seconds
                "usec"=>0
              )
        );

        $start = microtime(true);
        socket_connect($socket, $sHost, 0);
        $connect = socket_send($socket, $package, strLen($package), 0);
        if($connect){
            if (socket_read($socket, 255)){
                $result = microtime(true) - $start;
                socket_close($socket);
                return [RESULT_OK, 
                    "OK: ping to $sHost",
                    array(
                        'type'=>'counter',
                        'count'=>$result,
                        'visual'=>'line',
                    )

                ];
            } else {
                $aResult=[RESULT_ERROR, "ERROR: ping to $sHost failed after connect." . socket_strerror(socket_last_error($socket))];
                socket_close($socket);
                return $aResult;
            }
        } else {
            return [RESULT_ERROR, "ERROR: ping to $sHost failed. " . socket_strerror(socket_last_error($socket))];
        }

        */
    }

}
