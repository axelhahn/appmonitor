<?php

/**
 * notification plugin :: send emails
 * adapted from appmonitor by adding html detection
 *
 * @author hahn
 * 
 * @example <code>
 *     // ----- prepare email
 *     $aOptions = [
 *         'from' => 'webmaster@example.com',
 *         'to' => ['john@example.com'],
 *         'important' => true,
 *         'subject' => 'Test message',
 *         'message' => "Hello John,<br>\n"
 *                 . "I am a <strong>TEST MESSAGE</strong>.<br>\n"
 *                 . "Regards",
 *     ];
 *     // ----- send
 *     $o = new emailNotification();
 *     if (!$o::send($aOptions)){
 *         echo $o::error().PHP_EOL;
 *     };
 * </code>
 * 
 * 2023-03-09 <axel.hahn@unibe.ch>  created
 * 2023-03-13 <axel.hahn@unibe.ch>  add getLastError
 * 2023-06-01 <axel.hahn@unibe.ch>  fix comment
 */

class emailNotification
{
    /**
     * last error
     * @var string
     */
    var $sError='';

    /**
     * send email notification
     * @param  array  $aOptions  array of options
     *                           - from/ to/ subject/ message: main email data
     *                           - priority: (optional) if true then use high priority; default: false
     * @return boolean
     */
    static public function send($aOptions)
    {

        // ----- checks
        if(!is_array($aOptions)){
            self::$sError=__METHOD__.': $aOptions param is not an array'.PHP_EOL;
            return false;
        }

        if (!$aOptions['from']) {
            self::$sError=__METHOD__.'$aOptions has no from key'.PHP_EOL;
            return false; // no from address
        }

        if (!is_array($aOptions['to']) || !count($aOptions['to'])) {
            self::$sError=__METHOD__.'$aOptions key to must be an array'.PHP_EOL;
            return false; // no to adress in server config nor app metadata
        }

        // ----- generate headers
        $aHeaders=[];
        $aHeaders[]='From: ' . $aOptions['from'];
        $aHeaders[]='Reply-To: ' . $aOptions['from'];
        if (isset($aOptions['important']) && $aOptions['important']){
            $aHeaders[]='X-Priority: 1 (Highest)';
            $aHeaders[]='X-MSMail-Priority: High';
            $aHeaders[]='Importance: High';
        }

        $bIsHtml=$aOptions['message']!==strip_tags($aOptions['message']);
        if($bIsHtml){
            $aHeaders[]='Content-Type: text/html; charset="utf-8"';

        } else {
            // wrap text message to width of 70 chars
            $aOptions['message']=wordwrap($aOptions['message'], 70, "\r\n");
        }

        // ----- send
        mail(
            implode(";", $aOptions['to']),
            $aOptions['subject'],
            $aOptions['message'],
            implode("\r\n", $aHeaders)
        );
        return true;
    }

    /**
     * get string with the last error message
     * @return string
     */
    static public function error()
    {
        return self::$sError;
    }

}
