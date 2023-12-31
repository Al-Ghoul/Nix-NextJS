{
  siteSrc ? builtins.fetchTarball https://github.com/al-ghoul/Nix-NextJS/archive/main.tar.gz
}:
  let
    pkgs = (import <nixpkgs> { system = builtins.currentSystem or "x86_64-linux"; });
    jobs = with pkgs; {
      nextjs-build = mkYarnPackage {
        name = "NextJS-build";
        src = siteSrc;

        configurePhase = ''
          export NODE_OPTIONS=--openssl-legacy-provider
          ln -s $node_modules node_modules
        '';

        buildPhase = ''
          runHook preBuild
          export HOME=$(mktemp -d)
          export PLAYWRIGHT_BROWSERS_PATH="${playwright-driver.browsers-chromium}";
          yarn build
          yarn exec playwright test
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
      };
    };
  in
    jobs

