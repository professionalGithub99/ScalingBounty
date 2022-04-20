import NodeCanisters "NodeCanisters";
import L "mo:base/List";
import T "mo:base/Text";
import I "mo:base/Iter";
import D "mo:base/Debug";
import P "mo:base/Principal";
import A "mo:base/Array";
import AL"mo:base/AssocList";
import N "mo:base/Nat";
import B "mo:base/Buffer";
import O "mo:base/Option";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Management "Management";
actor Main{
 	public type CanisterId=Principal;
	public type NodeCanister=NodeCanisters.NodeCanister;
	public type ManagementInterface=Management.Interface;
	public type canister_status=Management.canister_status;
	var canister_ids:L.List<CanisterId> =L.nil<CanisterId>();
	var principal_canisters:AL.AssocList<Principal,B.Buffer<Principal>> =L.nil<(Principal,B.Buffer<Principal>)>();

//allows you to view all the principal Ids with their respective canister_ids that are being stored in this central canister
	public query func view_principals_and_canisters():async [(Principal,[Principal])]{
		var node_principals_arr=L.toArray<(Principal,B.Buffer<Principal>)>(principal_canisters);
		var node_principals_arr_mapped=A.map<(Principal,B.Buffer<Principal>),(Principal,[Principal])>(node_principals_arr,func(x:(Principal,B.Buffer<Principal>)):(Principal,[Principal]){return (x.0,x.1.toArray());});
		return node_principals_arr_mapped;
	};


	public shared(msg) func view_canisters_ids_of_caller(): async [Principal]{
	       var node_principals=node_canister_ids_of_principal(msg.caller);
	       return node_principals;
	};

	func node_canister_ids_of_principal(_principal:Principal):[Principal]{
	      var node_principals_as_buffer=AL.find<Principal,B.Buffer<Principal>>(principal_canisters,_principal,func(x:Principal,y:Principal):Bool{x==y});
	      var unwrapped_buffer=O.getMapped<B.Buffer<Principal>,B.Buffer<Principal>>(node_principals_as_buffer,func(b:B.Buffer<Principal>):B.Buffer<Principal>{return b},B.Buffer<Principal>(0));
	     var node_principals_as_arr=unwrapped_buffer.toArray();
	      return node_principals_as_arr;
	};


	public shared(msg) func create_canister():async [Principal]{
	   	let self:Principal=P.fromActor(Main);
		let canister=await NodeCanisters.NodeCanister(self);
		let canister_id=P.fromActor(canister);
		canister_ids:=L.push<CanisterId>(canister_id,canister_ids);
		var principals_of_canister=await canister.add_controlling_principal(msg.caller);
		var canisters_of_principal_buffer=AL.find<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y});
		var canisters_of_principal_buffer_updated=add_to_buffer<Principal>(func(x:Principal):Bool{x==canister_id},canister_id,canisters_of_principal_buffer);
     principal_canisters:=AL.replace<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y},?canisters_of_principal_buffer_updated).0;
		return principals_of_canister;
	};

	public shared(msg) func unjoin_canister(_principal:Principal):async [Principal]{
    	assert(L.find<CanisterId>(canister_ids,func(x:Principal):Bool{x==_principal})!=null);
	let canister=actor(P.toText(_principal)):NodeCanister;
	var principals_in_canister=await canister.remove_controlling_principal(msg.caller);
	var canisters_of_principal_buffer=AL.find<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y});
	var canisters_of_principal_buffer_updated=remove_from_buffer<Principal>(func(x:Principal):Bool{x==_principal},func(x:Principal):Bool{x!=_principal},_principal,canisters_of_principal_buffer);
	principal_canisters:=AL.replace<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y},?canisters_of_principal_buffer_updated).0;
	return principals_in_canister;
	};


	public shared(msg) func join_canister(_principal:Principal):async[Principal]{
		assert(L.find<CanisterId>(canister_ids,func(x:Principal):Bool{x==_principal})!=null);
	let canister=actor(P.toText(_principal)):NodeCanister;
		var principals_of_canister=await canister.add_controlling_principal(msg.caller);
		var canisters_of_principal_buffer=AL.find<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y});
		var canisters_of_principal_buffer_updated=add_to_buffer<Principal>(func(x:Principal):Bool{x==_principal},_principal,canisters_of_principal_buffer);
     principal_canisters:=AL.replace<Principal,B.Buffer<Principal>>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y},?canisters_of_principal_buffer_updated).0;
		return principals_of_canister;};




//---------------Helper functions------
	func add_to_buffer<T>(equality_function:(T)->Bool,t:T,b:?B.Buffer<T>):B.Buffer<T>{
	switch(b){
	case(null){var empty_buffer=B.Buffer<T>(0);
	empty_buffer.add(t);
	return empty_buffer;
	};
	case(?x){
	     let array_of_buffer=x.toArray();
	     var element:?T=A.find<T>(array_of_buffer,equality_function);
	     switch(element){
	     case(null){ x.add(t); return x;};
	     case(?z){return x;};
	     };
	};
	};
	};

	func remove_from_buffer<T>(equality_function:(T)->Bool,inequality_function:(T)->Bool,t:T,b:?B.Buffer<T>):B.Buffer<T>{
	switch(b){
	case(null){var empty_buffer=B.Buffer<T>(0);
	return empty_buffer;
	};
	case(?x){
	     let array_of_buffer=x.toArray();
	     var element:?T=A.find<T>(array_of_buffer,equality_function);
	     switch(element){
	     case(null){
	     return x;
	     };
	     case(?z){var filtered_array_of_buffer=A.filter<T>(array_of_buffer,inequality_function);
	     var filtered_buffer=convert_array_to_buffer<T>(filtered_array_of_buffer);
	     return filtered_buffer;};
	     };
	};
	};
	};
	func convert_array_to_buffer<T>(array:[T]):B.Buffer<T>{
	var size=I.size<T>(array.vals());
	   var buffer=B.Buffer<T>(size);
	   for(i in I.range(0,size-1)){
	   buffer.add(array[i]);
	   };
	   return buffer;
	};

	public func view_canister_statuses():async [?canister_status]{
		var node_canisters_arr=L.toArray<CanisterId>(canister_ids);
		var node_canister_size=L.size(canister_ids);
		var node_canister_mut_arr=A.init<?canister_status>(node_canister_size,null);
		for (x in node_canisters_arr.keys()){
			let management_canister=actor("aaaaa-aa"):ManagementInterface;
			let canister_stats=await management_canister.canister_status({canister_id=node_canisters_arr[x]});
			node_canister_mut_arr[x]:=?canister_stats;
		};
		var node_canister_imm_arr=A.freeze<?canister_status>(node_canister_mut_arr);
		return node_canister_imm_arr;
	};



  public func view_principals_of_canister(_principal:Principal): async [Principal]{
    assert(L.find<CanisterId>(canister_ids,func(x:Principal):Bool{x==_principal})!=null);
    var opt_canister_id=L.find<CanisterId>(canister_ids,func(x:Principal):Bool{x==_principal});
    switch(opt_canister_id){
    case (null){
			var node_array:[Principal]=[];
			return node_array;};
	case(?can_id){
	let canister=actor(P.toText(_principal)):NodeCanister;
	return await canister.view_controlling_principals();};
  };};
 	public query func get_all_canister_ids(): async [Principal]{
       var canister_ids_arr=L.toArray<CanisterId>(canister_ids);
       return canister_ids_arr;
	};

};
