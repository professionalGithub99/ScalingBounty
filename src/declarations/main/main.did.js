export const idlFactory = ({ IDL }) => {
  const definite_canister_settings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const canister_status = IDL.Record({
    'status' : IDL.Variant({
      'stopped' : IDL.Null,
      'stopping' : IDL.Null,
      'running' : IDL.Null,
    }),
    'memory_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'settings' : definite_canister_settings,
    'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  return IDL.Service({
    'create_canister' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'get_all_canister_ids' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'join_canister' : IDL.Func([IDL.Principal], [IDL.Vec(IDL.Principal)], []),
    'unjoin_canister' : IDL.Func([IDL.Principal], [IDL.Vec(IDL.Principal)], []),
    'view_canister_statuses' : IDL.Func(
        [],
        [IDL.Vec(IDL.Opt(canister_status))],
        [],
      ),
    'view_canisters_ids_of_caller' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'view_principals_and_canisters' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Vec(IDL.Principal)))],
        ['query'],
      ),
    'view_principals_of_canister' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(IDL.Principal)],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
