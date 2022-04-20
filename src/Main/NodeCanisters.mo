import L "mo:base/List";
import AL "mo:base/AssocList";
import P "mo:base/Principal";
import I "mo:base/Iter";
import A "mo:base/Array";
actor class NodeCanister(_p:Principal){
       let editing_principal:Principal=_p;
       var controlling_principals:L.List<Principal> =L.nil<Principal>();
       public func get_controlling_principals():async [Principal]{
               var principal_arrays=L.toArray<Principal>(controlling_principals);
	       return principal_arrays;
       };
       public shared(msg) func add_controlling_principal(_principal:Principal):async [Principal]{
          assert(msg.caller==editing_principal);
              var p=L.find<Principal>(controlling_principals,func(_p:Principal):Bool{_p==_principal});
	      if(p==null){
	        controlling_principals:=L.push<Principal>(_principal,controlling_principals);
	      };
	      return L.toArray<Principal>(controlling_principals);
       };
       public shared(msg) func remove_controlling_principal(_principal:Principal):async [Principal]{
	  assert(msg.caller==editing_principal);
	  controlling_principals:=L.filter<Principal>(controlling_principals,func(_p:Principal):Bool{_p!=_principal});
	  return L.toArray<Principal>(controlling_principals);
       };
       
       public query func view_controlling_principals():async [Principal]{
	  var principal_arrays=L.toArray<Principal>(controlling_principals);
	  return principal_arrays;
       };

};
