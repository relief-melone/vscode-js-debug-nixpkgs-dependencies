{ pkgs, system, ... }:
let
  nodejs = pkgs.nodejs_20;
  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode-js-debug";
    rev = "v1.100.0";
  };
  default = import ./default.nix;

  nodePkgs = default { inherit pkgs system nodejs; };
  nodeDependencies = ( nodePkgs // { inherit pkgs; }).nodeDependencies;

in
pkgs.vimUtils.buildVimPlugin {
  inherit src;
  inherit nodeDependencies;

  pname = "vscode-js-debug";
  version = "v1.100.0";

  nativeBuildInputs = [ nodejs ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules

    export PATH="${nodeDependencies}/bin:$PATHw"
    export XDG_CACHE_HOME=$(pwd)/node-gyp-cache

    npx gulp dapDebugServer

    mv ./dist/out
  '';
}
