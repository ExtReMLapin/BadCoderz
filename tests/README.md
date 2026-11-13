# Tests TDD (phase rouge) – BadCoderz

Format GLuaTest, exécutés avec l'outil `tests_run` de gmod-mcp dans un Garry's Mod lancé avec `-mcp`.
L'addon doit être monté (dossier ou jonction dans `garrysmod/addons`). Fixture : `lua/tdd_fixtures/big_random.lua` (120 Ko aléatoires, ~87 Ko compressé).

| Fichier | Royaume | Prérequis |
|---|---|---|
| `unit_scan_state.lua`, `unit_static_args.lua`, `unit_report_size.lua` | server | aucun |
| `scan_e2e.lua` | server | lancer `e2e/run_scan.lua` (lua_exec_file) et attendre `TDD.done` |
| `net_server.lua` | server | `e2e/net_server_setup.lua` (server) puis `e2e/net_client_run.lua` (client), attendre `NETC.done` |
| `net_client.lua` | **client** | idem |

Ne pas lancer `net_client.lua` dans le royaume serveur.
