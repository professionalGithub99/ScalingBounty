import NodeCanisters "NodeCanisters";
import L "mo:base/List";
import T "mo:base/Text";
import I "mo:base/Iter";
import D "mo:base/Debug";
import P "mo:base/Principal";
import A "mo:base/Array";
import AL"mo:base/AssocList";
import N "mo:base/Nat";
import Char "mo:base/Char";
import Nat32 "mo:base/Nat32";
import Management "Management";
actor Main{
	public type NodeCanister=NodeCanisters.NodeCanister;
	public type ManagementInterface=Management.Interface;
	public type canister_status=Management.canister_status;
	public type node_canister_index=Nat;
	var node_canisters:L.List<NodeCanister> =L.nil<NodeCanister>();
	var principal_canisters:AL.AssocList<Principal,Text> =L.nil<(Principal,Text)>();


 	public query func get_all_node_canisters(): async [Principal]{
       var node_canister_arr=L.toArray<NodeCanister>(node_canisters);
       var node_principals_arr=A.mapFilter<NodeCanister,Principal>(node_canister_arr,func(x:NodeCanister):?Principal{return ?(P.fromActor(x));});
       return node_principals_arr;
	};
  
	public query func view_principals_and_canisters():async [(Principal,Text)]{
		var node_principals_arr=L.toArray<(Principal,Text)>(principal_canisters);
		return node_principals_arr;
	};
	 func node_indexes_of_principal(_principal:Principal): [Nat]{
		var canister_indexes_as_string:?Text=AL.find(principal_canisters,_principal,func(x:Principal,y:Principal):Bool{x==y;}); 	
		switch(canister_indexes_as_string){
			case (null){
				var node_array=A.init<Nat>(0,0);
				var imm_node_array=A.freeze<Nat>(node_array);
				return imm_node_array;
			};
			case(?text){
			  var imm_node_array=text_to_nat_array(text,','); 
			  return imm_node_array;
			};
		};
	};
	public shared(msg) func node_indexes_of_caller(): async [Nat]{
	       var node_indexes=node_indexes_of_principal(msg.caller);
	       return node_indexes;
	};
	public shared(msg) func join_canister(_principal:Principal,_index:Nat):async (){
	var canister_indexes_as_string:?Text=AL.find(principal_canisters,_principal,func(x:Principal,y:Principal):Bool{x==y;}); 	
		switch(canister_indexes_as_string){
			case (null){
	        var canister_index_as_text=N.toText(_index);
		D.print(canister_index_as_text);
	        principal_canisters:=AL.replace<Principal,Text>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y;},?canister_index_as_text).0;
			};
			case(?text){
			var canister_index_array=text_to_nat_array(text,',');
			var canister_index_found=A.find<Nat>(canister_index_array,func(x:Nat):Bool{x==_index;});
			if(canister_index_found==null){
			var word=text#","#N.toText(_index);
	        	principal_canisters:=AL.replace<Principal,Text>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y;},?word).0;
			}
			else{return;};
			};
		};
		var canister=L.get<NodeCanister>(node_canisters,_index);
		switch(canister){
			case (null){
			return;
			};
			case(?can){
       			await can.add_controlling_principal(msg.caller);
			};
		};
	};
	public shared(msg) func unjoin_canister(_principal:Principal,_index:Nat):async (){
	var canister_indexes_as_string:?Text=AL.find(principal_canisters,_principal,func(x:Principal,y:Principal):Bool{x==y;}); 	
		switch(canister_indexes_as_string){
			case (null){
			return;
			};
			case(?text){
		var canister=L.get<NodeCanister>(node_canisters,_index);
		switch(canister){
			case (null){
			return;
			};
			case(?can){
       			await can.remove_controlling_principal(msg.caller);
			};
		};
			  var imm_node_array=text_to_nat_array(text,','); 
			  imm_node_array:=A.filter<Nat>(imm_node_array,func(x:Nat):Bool{x!=_index;});
			  var updated_canister_index_as_text=nat_array_to_text(imm_node_array);
	        	principal_canisters:=AL.replace<Principal,Text>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y;},?updated_canister_index_as_text).0;
			};
		};
	};

	func text_to_nat_array(_text:Text,_delimiter:Char):[Nat]{
				var node_array=A.init<Nat>(I.size(T.split(_text,#char _delimiter)),0);
				var j:Nat=0;
				for(i in T.split(_text,#char _delimiter)){
					node_array[j]:=textToNat(i);
					j:=j+1;};
				var imm_node_array=A.freeze<Nat>(node_array);
				return imm_node_array;
				};
       public shared(msg) func create_canister(): async Text{
       var node_canister_tuple=await add_node_canister();
       var canister_index=node_canister_tuple.1;
       var canister=node_canister_tuple.0;
       await canister.add_controlling_principal(msg.caller);
	var canister_indexes=node_indexes_of_principal(msg.caller);
        var arr_size=I.size<Nat>(A.vals<Nat>(canister_indexes));
	if(arr_size==0){
	        var canister_index_as_text=N.toText(canister_index);
		D.print(canister_index_as_text);
	        principal_canisters:=AL.replace<Principal,Text>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y;},?canister_index_as_text).0;
		return nat_array_to_text(node_indexes_of_principal(msg.caller));
		}
        else{  
	var index_text=nat_array_to_text(canister_indexes);
	index_text#=",";
	index_text#=N.toText(canister_index);
	principal_canisters:=AL.replace<Principal,Text>(principal_canisters,msg.caller,func(x:Principal,y:Principal):Bool{x==y;},?index_text).0;
	return index_text;
	};
	};
 
       func nat_array_to_text(nat_array: [Nat]): Text{
        var text:Text="";
       var j:Nat=0;	
       for (i in nat_array.vals()){
       if(j==0){
       text#=N.toText(i);
       }
       else{
       text#=",";
       text#=N.toText(i);
       };
       j:=j+1;
       };
       return text;
       };
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

	public func add_node_canister():async (NodeCanister,Nat){
		let self:Principal=P.fromActor(Main);
		let node_canister=await NodeCanisters.NodeCanister(self);
node_canisters:=L.push<NodeCanister>(node_canister,node_canisters);
	       D.print(P.toText(P.fromActor(node_canister)));
	       return (node_canister,L.size(node_canisters)-1);
	};

	func textToNat(txt : Text) : Nat {
		assert(txt.size() > 0);
		let chars = txt.chars();
		var num : Nat = 0;
		for (v in chars){
			let charToNum = Nat32.toNat(Char.toNat32(v)-48);
			assert(charToNum >= 0 and charToNum <= 9);
num := num * 10 +  charToNum;          
		};

		num;
	};

};
