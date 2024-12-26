## 📦 Class \notificationhandler

```txt
/**
 * ____________________________________________________________________________
 * 
 *  _____ _____ __                   _____         _ _           
 * |     |     |  |      ___ ___ ___|     |___ ___|_| |_ ___ ___ 
 * |-   -| | | |  |__   | .'| . | . | | | | . |   | |  _| . |  _|
 * |_____|_|_|_|_____|  |__,|  _|  _|_|_|_|___|_|_|_|_| |___|_|  
 *                          |_| |_|                              
 *                                                                                                                             
 *                       ___ ___ ___ _ _ ___ ___                                      
 *                      |_ -| -_|  _| | | -_|  _|                                     
 *                      |___|___|_|  \_/|___|_|                                       
 *                                                               
 * ____________________________________________________________________________
 * 
 * notificationhandler
 *
 * @author hahn
 * 
 * 2024-07-17  axel.hahn@unibe.ch  php 8 only: use typed variables
 * 2024-11-06  axel.hahn@unibe.ch  update html email output
 */
```

## 🔶 Properties

(none)

## 🔷 Methods

### 🔹 public __construct()



**Return**: `boolean *`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> array $aOptions = [] | `array` | options array with the keys<br>                         - {string} lang       language of the GUI<br>                         - {string} serverurl  base url of the web app to build an url to an app specific page<br>                         - {string} notifications  appmionitor config settings in notification settings (for sleeptime and messages)


### 🔹 public deleteApp()



**Return**: `bool`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<required\> string $sAppId | `string` | app id


### 🔹 public getAppLastResult()



**Return**: `array *`

**Parameters**: **0**


### 🔹 public getAppNotificationdata()



**Return**: `array`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> string $sType = '' | `string` | optional: type email|slack; defailt: false (=return all keys)


### 🔹 public getAppResult()



**Return**: `array`

**Parameters**: **0**


### 🔹 public getLogdata()



**Return**: `array`

**Parameters**: **3**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> array $aFilter = [] | `array` | filter with possible keys timestamp|changetype|status|appid|message (see addLogitem())
| \<optional\> int $iLimit = 0 | `int` | set a maximum of log entries
| \<optional\> bool $bRsort = true | `bool` | flag to reverse sort logs; default is true (=newest entry first)


### 🔹 public getMessageReplacements()



**Return**: `array`

**Parameters**: **0**


### 🔹 public getPlugins()



**Return**: `array`

**Parameters**: **0**


### 🔹 public getReplacedMessage()



**Return**: `string`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<required\> $sMessageId | `one *` | one of changetype-[N].logmessage | changetype-[N].email.message | email.subject


### 🔹 public isSleeptime()



**Return**: `string|bool`

**Parameters**: **0**


### 🔹 public loadLogdata()



**Return**: `array`

**Parameters**: **0**


### 🔹 public notify()



**Return**: `bool`

**Parameters**: **0**


### 🔹 public setApp()



**Return**: `bool`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<required\> string $sAppId | `string` | application id




---
Generated with Axels PHP class doc parser.