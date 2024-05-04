{ pkgs, ... }:

{
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       calc
     ];
   };
}

