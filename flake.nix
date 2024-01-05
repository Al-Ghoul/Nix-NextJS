{
  description = "Nix-Laravel hydra build & tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
        pkgs = import nixpkgs {
            system = "x86_64-linux";
        };
    in
        {
            hydraJobs = rec {
              build = with pkgs; mkYarnPackage {
                name = "NextJS-build";
                src = self;

                configurePhase = ''
                  ln -s $node_modules node_modules
                '';

                buildPhase = ''
                  runHook preBuild
                  runHook postBuild
                '';

                installPhase = ''
                  runHook preInstall
                  mkdir -p $out
                  mv {.,}* $out
                  runHook postInstall
                '';

                doDist = false;
                doCheck = false;

                passthru.tests.playwright-tests = runCommand "run-tests" { buildInputs = [ build.buildInputs ]; }
                ''
                  export PLAYWRIGHT_BROWSERS_PATH="${playwright-driver.browsers-chromium}";
                  cp -r ${build}/{.,}* .
                  yarn build
                  yarn exec playwright test
                  touch $out
                '';
              };
              tests = build.tests;
            };
        };
}
