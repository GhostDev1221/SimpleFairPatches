@echo off

set ARGS={"""ip""":"""127.0.0.1""","""publicIp""":"""127.0.0.1""","""port""":19130,"""mapdir""":"""./map/gameName-debug""","""id""":"""g1008""","""mapid""":"""g1008""","""name""":"""gameName-debug""","""monitoraddr""":"""142.251.32.46:80""","""maxplayer""":16,"""gtype""":"""""","""isDebug""":false,"""userConf""":"""""","""secret""":"""""","""isChina""":false,"""heartbeatInterval""":5,"""dbconfig""":{"""addr""":"""""","""user""":"""""","""password""":"""""","""dbname""":"""g1052"""},"""redisConfig""":{"""ip""":"""""","""port""":8910,"""password""":""""""},"""gameRankParms""":""""""}

GameServer_d.exe %ARGS%
pause
