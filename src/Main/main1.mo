import NodeCanisters "NodeCanisters";
import L "mo:base/List";
import I "mo:base/Iter";
import D "mo:base/Debug";
import P "mo:base/Principal";
import A "mo:base/Array";
import AL"mo:base/AssocList";
import N "mo:base/Nat";
import Management "Management";
actor Main{
	public type NodeCanister=NodeCanisters.NodeCanister;
	public type ManagementInterface=Management.Interface;
	public type canister_status=Management.canister_status;
	public type node_canister_index=Nat;
	var node_canisters:L.List<NodeCanister> =L.nil<NodeCanister>();
	var node_principals:AL.AssocList<Principal,Nat> =L.nil<(Principal,Nat)>();


	public func first_avail_node_canister():async ?Nat{
	var c_status:?canister_status=null;
	var node_canisters_arr=L.toArray<NodeCanister>(node_canisters);
	var node_canister_size=L.size(node_canisters);
	for (x in node_canisters_arr.keys()){
	let management_canister=actor("aaaaa-aa"):ManagementInterface;
	let canister_stats=await management_canister.canister_status({canister_id=P.fromActor(node_canisters_arr[x])});
	c_status:=?canister_stats;
	let principal_id=P.toText(P.fromActor(node_canisters_arr[x]));
	D.print("principal_id: "#principal_id );
	 switch (c_status){
	 case(null){};
        case(?can_stats) {if(can_stats.memory_size < 10000000){D.print(N.toText(can_stats.memory_size)# "size "# principal_id#" "#N.toText(x));return ?x}};
      };
	};
	return null;
	};

	public func view_canister_statuses():async [?canister_status]{
	var node_canisters_arr=L.toArray<NodeCanister>(node_canisters);
	var node_canister_size=L.size(node_canisters);
	var node_canister_mut_arr=A.init<?canister_status>(node_canister_size,null);
	for (x in node_canisters_arr.keys()){
	let management_canister=actor("aaaaa-aa"):ManagementInterface;
	let canister_stats=await management_canister.canister_status({canister_id=P.fromActor(node_canisters_arr[x])});
	node_canister_mut_arr[x]:=?canister_stats;
	};
	var node_canister_imm_arr=A.freeze<?canister_status>(node_canister_mut_arr);
	return node_canister_imm_arr;
	};
	 
	 public query func view_principals_and_canisters():async [(Principal,Nat)]{
	 var node_principals_size=L.size<(Principal,Nat)>(node_principals);
	 var node_principals_arr=L.toArray<(Principal,Nat)>(node_principals);
	 return node_principals_arr;
	 };
	 public query func view_node_canisters():async [NodeCanister]{
	 var node_canisters_arr=L.toArray<NodeCanister>(node_canisters);
	 return node_canisters_arr;
	 };

	public func add_node_canister():async Nat{
	let self:Principal=P.fromActor(Main);
	let node_canister=await NodeCanisters.NodeCanister(self);
	node_canisters:=L.push<NodeCanister>(node_canister,node_canisters);
	D.print(P.toText(P.fromActor(node_canister)));
	return L.size(node_canisters);
	};

	public func create_profile(p:Principal):async ?Nat{
	var principal:?Nat=AL.find<Principal,Nat>(node_principals,p,func(x:Principal,y:Principal):Bool{x==y});
	if (principal==null){
	var avail_node=await first_avail_node_canister();
	if(avail_node==null){
	      var x:Nat=await add_node_canister();
	      node_principals:=(AL.replace<Principal,Nat>(node_principals,p,func(y:Principal,z:Principal):Bool{z==y},?x)).0;
	}
	else{
	};
	};
	return null;
	};
};
	/*public func get_last_node_canister_size():async  ?canister_status{
	var c_status:?canister_status=null;
	var node_canisters_arr=L.toArray<NodeCanister>(node_canisters);
	var node_canister_size=L.size(node_canisters);
	var canister_status_arr=A.init<?canister_status>(node_canister_size,null);
	for (x in node_canisters_arr.keys()){
	let management_canister=actor("aaaaa-aa"):ManagementInterface;
	let canister_stats=await management_canister.canister_status({canister_id=P.fromActor(node_canisters_arr[x])});
	c_status:=?canister_stats;
        canister_status_arr[x]:=?canister_stats;
	let principal_id=P.toText(P.fromActor(node_canisters_arr[x]));
	D.print("principal_id: "#principal_id );
	};
	return c_status;
	};*/
