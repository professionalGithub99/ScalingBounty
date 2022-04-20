export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  List.fill(IDL.Opt(IDL.Tuple(IDL.Tuple(IDL.Principal, IDL.Principal), List)));
  const AssocList = IDL.Opt(
    IDL.Tuple(IDL.Tuple(IDL.Principal, IDL.Principal), List)
  );
  return IDL.Service({
    'get_balance' : IDL.Func([IDL.Principal], [IDL.Nat64], []),
    'get_registered_ids' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(IDL.Principal)],
        [],
      ),
    'register_id' : IDL.Func(
        [IDL.Principal, IDL.Opt(IDL.Principal)],
        [AssocList, IDL.Opt(IDL.Principal)],
        [],
      ),
    'test_management_canister' : IDL.Func([IDL.Principal], [IDL.Principal], []),
    'test_self_call' : IDL.Func([], [], []),
    'view_registered_ids' : IDL.Func([], [AssocList], []),
    'whoami' : IDL.Func([], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };
