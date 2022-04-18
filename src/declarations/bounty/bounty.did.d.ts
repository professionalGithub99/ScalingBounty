import type { Principal } from '@dfinity/principal';
export type AssocList = [] | [[[Principal, Principal], List]];
export type List = [] | [[[Principal, Principal], List]];
export interface _SERVICE {
  'get_balance' : (arg_0: Principal) => Promise<undefined>,
  'get_registered_ids' : (arg_0: Principal) => Promise<[] | [Principal]>,
  'register_id' : (arg_0: Principal, arg_1: [] | [Principal]) => Promise<
      [AssocList, [] | [Principal]]
    >,
  'view_registered_ids' : () => Promise<AssocList>,
  'whoami' : () => Promise<Principal>,
}
