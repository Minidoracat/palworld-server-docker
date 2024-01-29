# 本修改版容器仅在使用标准的 Ubuntu 20 至 23 系统且使用官网流程部署的 docker engine 上通过测试

修改内容：
- ~~内存溢出修复（已弃用）~~
- 内存快满后自动重启
- 内存用量警告
- 定时备份
- 首次启动强制更新

## Compose File:
```yaml
services:
  palworld:
    image: djkcyl/palserver-patch:latest
    restart: unless-stopped
    container_name: palworld-server-test
    ports:
    - 8211:8211/udp
    environment:
    - ADMIN_PASSWORD="Aa123456"
    - COMMUNITY=false
    - MULTITHREADING=true
    - PGID=1000
    - PLAYERS=32
    - PORT=8211
    - PUID=1000
    - ROCN_ENABLED=true
    - ROCN_PORT=25575
    - UPDATE_ON_BOOT=false
    - AUTO_SHUTDOWN=true
    - AUTO_BACKUP=true
    - PATCH_SERVER=true
    volumes:
    - ./palworld:/palworld/
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
    networks:
    - pal_network
networks:
  pal_network:
    external: true
```

## 首次启动的示范

```shell
palworld-server-test  | *****EXECUTING USERMOD*****
palworld-server-test  | usermod: no changes
palworld-server-test  | *****STARTING INSTALL/UPDATE*****
palworld-server-test  | tid(22) burning pthread_key_t == 0 so we never use it
palworld-server-test  | Redirecting stderr to '/home/steam/Steam/logs/stderr.txt'
palworld-server-test  | Logging directory: '/home/steam/Steam/logs'
palworld-server-test  | [  0%] Checking for available updates...
palworld-server-test  | [----] Verifying installation...
palworld-server-test  | Steam Console Client (c) Valve Corporation - version 1705108307
palworld-server-test  | -- type 'quit' to exit --
palworld-server-test  | Loading Steam API...OK
palworld-server-test  | 
palworld-server-test  | Connecting anonymously to Steam Public...OK
palworld-server-test  | Waiting for client config...OK
palworld-server-test  | Waiting for user info...OK
palworld-server-test  |  Update state (0x3) reconfiguring, progress: 0.00 (0 / 0)
palworld-server-test  |  Update state (0x3) reconfiguring, progress: 0.00 (0 / 0)
palworld-server-test  |  Update state (0x5) verifying install, progress: 33.72 (757952516 / 2248053389)
palworld-server-test  |  Update state (0x5) verifying install, progress: 78.61 (1767232590 / 2248053389)
palworld-server-test  |  Update state (0x61) downloading, progress: 100.00 (189756648 / 189756648)
palworld-server-test  | Success! App '2394010' fully installed.
palworld-server-test  | *****CHECKING FOR EXISTING CONFIG*****
palworld-server-test  | RCON_ENABLED=true
palworld-server-test  | RCON_PORT=25575
palworld-server-test  | ***** NO [PATCHED] SERVER: 当前服务端与修改后的 MD5 值不同。 *****
palworld-server-test  | ***** [PATCHING] SERVER: 当前原始文件与预期的 MD5 值相同。 *****
palworld-server-test  | ***** [PATCHED] SERVER: 服务端已修改。 *****
palworld-server-test  | 应修改 647b75edde73dd7d9825523fe8aa0f3e 为 272f517e01bcfaa885a8911176d15369
palworld-server-test  | 当前 272f517e01bcfaa885a8911176d15369
palworld-server-test  | *****STARTING SERVER*****
palworld-server-test  | ./PalServer.sh -port=8211 -players=32 -adminpassword="Aa123456" -queryport=27015 -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
palworld-server-test  | [S_API] SteamAPI_Init(): Loaded local 'steamclient.so' OK.
palworld-server-test  | Shutdown handler: initalize.
palworld-server-test  | Increasing per-process limit of core file size to infinity.
palworld-server-test  | - Existing per-process limit (soft=18446744073709551615, hard=18446744073709551615) is enough for us (need only 18446744073709551615)
palworld-server-test  | CAppInfoCacheReadFromDiskThread took 6 milliseconds to initialize
palworld-server-test  | Setting breakpad minidump AppID = 2394010
palworld-server-test  | [S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.
palworld-server-test  | [S_API FAIL] Tried to access Steam interface SteamFriends017 before SteamAPI_Init succeeded.
palworld-server-test  | [S_API FAIL] Tried to access Steam interface STEAMAPPS_INTERFACE_VERSION008 before SteamAPI_Init succeeded.
palworld-server-test  | [S_API FAIL] Tried to access Steam interface SteamNetworkingUtils004 before SteamAPI_Init succeeded.
palworld-server-test  | 
palworld-server-test  | *****STARTING RCON*****
palworld-server-test  | *****AUTO_SHUTDOWN IS ENABLED*****
palworld-server-test  | Weird. This response is for another request.
palworld-server-test  | Broadcasted: Server_current_memory_usage:_8.6453%.
palworld-server-test  |
```
