module {
	public type canister_id = Principal;
	public type user_id = Principal;
	public type wasm_module = Blob;

	public type canister_settings = {
controllers : ?[Principal];
compute_allocation : ?Nat;
memory_allocation : ?Nat;
freezing_threshold : ?Nat;
	};

	type definite_canister_settings = {
controllers : [Principal];
compute_allocation : Nat;
memory_allocation : Nat;
freezing_threshold : Nat;
	};

	public let CANISTER_ID : Text = "aaaaa-aa";
	public type Interface= actor {
	canister_self_size:()->async Int32;
create_canister:{settings:?canister_settings}-> async {canister_id:canister_id};
canister_status:{canister_id:canister_id}->
async {status:{#running;#stopping;#stopped;};
settings: definite_canister_settings;
module_hash: ?Blob;
memory_size: Nat;
cycles: Nat;};
	};

};
