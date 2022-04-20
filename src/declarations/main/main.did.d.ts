import type { Principal } from '@dfinity/principal';
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
  'create_canister' : () => Promise<Array<Principal>>,
  'get_all_canister_ids' : () => Promise<Array<Principal>>,
  'join_canister' : (arg_0: Principal) => Promise<Array<Principal>>,
  'unjoin_canister' : (arg_0: Principal) => Promise<Array<Principal>>,
  'view_canister_statuses' : () => Promise<Array<[] | [canister_status]>>,
  'view_canisters_ids_of_caller' : () => Promise<Array<Principal>>,
  'view_principals_and_canisters' : () => Promise<
      Array<[Principal, Array<Principal>]>
    >,
  'view_principals_of_canister' : (arg_0: Principal) => Promise<
      Array<Principal>
    >,
}
