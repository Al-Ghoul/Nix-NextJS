{
  siteSrc ? builtins.fetchTarball https://github.com/al-ghoul/Nix-NextJS/archive/main.tar.gz
}:
  let
    pkgs = (import <nixpkgs> { system = builtins.currentSystem or "x86_64-linux"; });
    jobs = with pkgs; rec {
      nodeModules = mkYarnPackage rec {
        name = "node-modules";
        src = siteSrc;
      };

       build = stdenv.mkDerivation {
        name = "NextJS-E2E-test";
        system = builtins.currentSystem or "x86_64-linux";
        src = siteSrc;

        buildInputs = with pkgs;[
          nodejs_21
          playwright
          yarn
        ];

        configurePhase = ''
          export HOME=$PWD
          cp -r ${nodeModules}/libexec/nix-nextjs .
          chmod -R +rw nix-nextjs
          export PATH=$PWD/nix-nextjs/node_modules/.bin/:$PATH
          export NODE_PATH=$PWD/nix-nextjs/node_modules/:$PWD/nix-nextjs/deps/nix-nextjs/node_modules:$NODE_PATH
          yarn config --offline set yarn-offline-mirror $NODE_PATH
        '';

        buildPhase = ''
          yarn run build
         # yarn exec playwright test
        '';

        dontInstall = true;
        PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}";
      }; 
    };
  in
    jobs

