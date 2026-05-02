{
  description = "nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs }: {
    darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ ./darwin/configuration.nix ];
    };
  };
}
