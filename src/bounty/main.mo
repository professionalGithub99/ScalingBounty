import L "mo:base/List";
import A "mo:base/AssocList";
import D "mo:base/Debug";
import T "mo:base/Text";
import I "mo:base/Int32";
import P "mo:base/Principal";
import Ledger "Ledger";
import Utils "../Utils/Utils";
import Account "../Utils/Account";
import Management "Management";
actor  {
type AccountBalanceArgs = {
  account : Ledger.AccountIdentifier;
};
 type Interface =Ledger.Interface;
 type ManagementInterface = Management.Interface;

stable var registered_ids:A.AssocList<Principal,Principal> = L.nil<(Principal,Principal)>();
public func get_registered_ids(_principalId:Principal):async ?Principal{
var test=A.find<Principal,Principal>(registered_ids,_principalId,func(x:Principal,y:Principal):Bool{x==y});
return test;
};
public func register_id(_principalId:Principal,_principalId2:?Principal):async (A.AssocList<Principal, Principal>, ?Principal){
var ids=A.replace<Principal,Principal>(registered_ids,_principalId,func(x:Principal,y:Principal):Bool{x==y},_principalId2);
registered_ids:=ids.0;
return ids;
};
public func view_registered_ids():async A.AssocList<Principal, Principal>{
return registered_ids;
};
public shared (msg) func whoami() : async Principal {
        msg.caller
    };
public func get_balance(p:Principal) : async Nat64{
var subAcc=Account.defaultSubaccount();
var accountID=Account.accountIdentifier(p,subAcc);
var accBalanceArgs:AccountBalanceArgs={account=accountID};
var ledgerActor= actor("rrkah-fqaaa-aaaaa-aaaaq-cai"):Interface;
var accBalance=await ledgerActor.account_balance(accBalanceArgs);
return accBalance.e8s;
    };
public func test_management_canister(p:Principal):async Principal{	
var managementActor= actor("aaaaa-aa"):ManagementInterface;
        var c_settings:Management.canister_settings = {
controllers = ?[p];
compute_allocation = null;
memory_allocation = null;
freezing_threshold = null;
        };
var canister= await managementActor.create_canister({settings=?c_settings});
return canister.canister_id;
};
public func test_self_call():async (){
var managementActor= actor("aaaaa-aa"):ManagementInterface;
var i:Int32=await managementActor.canister_self_size();
D.print(I.toText(i)#"abcedfkjl");
};
};

//intercanister call code_ note the switch is a pattern for opt type principalId2 when you want it to not be opt since unwrap is deprecated
/*let text:Text = switch (_principalId2){
        case (null) "abc";
        case(?principal) P.toText(principal);
      };*/
