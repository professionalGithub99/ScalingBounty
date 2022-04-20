export const idlFactory = ({ IDL }) => {
  const NodeCanister = IDL.Service({
    'add_controlling_principal' : IDL.Func([IDL.Principal], [], []),
    'get_controlling_principals' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'remove_controlling_principal' : IDL.Func([IDL.Principal], [], []),
  });
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
    'add_node_canister' : IDL.Func([], [NodeCanister, IDL.Nat], []),
    'create_canister' : IDL.Func([], [IDL.Text], []),
    'first_avail_node_canister' : IDL.Func([], [IDL.Opt(IDL.Nat)], []),
    'get_all_node_canisters' : IDL.Func(
        [],
        [IDL.Vec(IDL.Principal)],
        ['query'],
      ),
    'join_canister' : IDL.Func([IDL.Principal, IDL.Nat], [], []),
    'node_indexes_of_caller' : IDL.Func([], [IDL.Vec(IDL.Nat)], []),
    'unjoin_canister' : IDL.Func([IDL.Principal, IDL.Nat], [], []),
    'view_canister_statuses' : IDL.Func(
        [],
        [IDL.Vec(IDL.Opt(canister_status))],
        [],
      ),
    'view_principals_and_canisters' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Text))],
        ['query'],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
