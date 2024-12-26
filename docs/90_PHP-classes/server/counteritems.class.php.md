## 📦 Class \counteritems

```txt
/**
 * container for all counters of a single app
 * store last N response time to draw a graph
 *
 * @example
 * <code>
 * // INIT
 * $oCounters=new counteritems($sAppId, $sCounterId); 
 * OR
 * $oCounters=new counteritems();
 * $oCounters->setApp($sAppId);
 * $oCounters->setCounter($sCounterId);
 * 
 * // ADD VALUE
 * $oCounters->add([array]);
 * 
 * </code>
 *
 * @author hahn
 * 
 * 2024-07-17  axel.hahn@unibe.ch  php 8 only: use typed variables
 */
```

## 🔶 Properties

(none)

## 🔷 Methods

### 🔹 public __construct()



**Return**: ``

**Parameters**: **2**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> string $sAppid = '' | `string` | optional: id of an app
| \<optional\> string $sCounterId = '' | `string` | optional: name of a counter


### 🔹 public add()



**Return**: `bool`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<required\> array $aItem | `array` | array item to add


### 🔹 public delete()



**Return**: `bool`

**Parameters**: **0**


### 🔹 public deleteCounter()



**Return**: `bool`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> string $sCounterId = '' | `string` | delete data of another than the current counter id


### 🔹 public get()



**Return**: `array`

**Parameters**: **1**

| Parameter | Type | Description
|--         |--    |--
| \<optional\> int $iMax = 0 | `int` | optional: get last N values; default: get all stored values


### 🔹 public getCounters()



**Return**: `array`

**Parameters**: **0**


### 🔹 public setApp()



**Return**: `bool`

**Parameters**: **2**

| Parameter | Type | Description
|--         |--    |--
| \<required\> string $sAppid | `string` | id of an app
| \<optional\> string $sCounterId = '' | `string` | optional: name of a counter


### 🔹 public setCounter()



**Return**: `boolean *`

**Parameters**: **2**

| Parameter | Type | Description
|--         |--    |--
| \<required\> string $sCounterId | `string` | name of a counter
| \<optional\> array $aMeta = [] | `array` | metadata with these keys<br>                           - title  - text above value<br>                           - visual - visualisation type




---
Generated with Axels PHP class doc parser.