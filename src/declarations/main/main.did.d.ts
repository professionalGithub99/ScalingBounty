import type { Principal } from '@dfinity/principal';
export interface NodeCanister {
  'add_controlling_principal' : (arg_0: Principal) => Promise<undefined>,
  'get_controlling_principals' : () => Promise<Array<Principal>>,
  'remove_controlling_principal' : (arg_0: Principal) => Promise<undefined>,
}
export interface canister_status {
  'status' : { 'stopped' : null } |
    { 'stopping' : null } |
    { 'running' : null },
  'memory_size' : bigint,
  'cycles' : bigint,
  'settings' : definite_canister_settings,
  'module_hash' : [] | [Array<number>],
}
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface _SERVICE {
  'add_node_canister' : () => Promise<[Principal, bigint]>,
  'create_canister' : () => Promise<string>,
  'first_avail_node_canister' : () => Promise<[] | [bigint]>,
  'get_all_node_canisters' : () => Promise<Array<Principal>>,
  'join_canister' : (arg_0: Principal, arg_1: bigint) => Promise<undefined>,
  'node_indexes_of_caller' : () => Promise<Array<bigint>>,
  'unjoin_canister' : (arg_0: Principal, arg_1: bigint) => Promise<undefined>,
  'view_canister_statuses' : () => Promise<Array<[] | [canister_status]>>,
  'view_principals_and_canisters' : () => Promise<Array<[Principal, string]>>,
}
